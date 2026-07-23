import 'dart:async';
import 'dart:io';

import 'package:classic_15_puzzle/config/purchase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-shot feedback events the UI should surface to the user
/// (as a SnackBar or similar), keyed to what just happened.
enum PurchaseFeedback {
  storeUnavailable,
  productUnavailable,
  purchasePending,
  purchaseCancelled,
  purchaseFailed,
  purchaseSuccess,
  alreadyOwned,
  restoreSuccess,
  restoreEmpty,
  restoreFailed,
}

const String _prefsKeyAdsRemoved = 'purchase::ads_removed';

/// Reads the locally cached entitlement without needing the widget tree,
/// so `main()` can decide whether to initialize the ads SDK at all before
/// [PurchaseService] exists.
Future<bool> readCachedAdsRemoved() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKeyAdsRemoved) ?? false;
  } on Exception {
    return false;
  }
}

/// Manages the "Remove Ads" non-consumable purchase.
///
/// Only [_StoreKitPurchaseService] talks to the App Store; on every other
/// platform [PurchaseService] resolves to [_UnsupportedPurchaseService], a
/// no-op stub, so Android keeps compiling and running with ads unchanged.
/// Android billing can later be added as a third implementation behind this
/// same interface.
///
/// Tile themes/photo mode are a separate, ad-based unlock — see
/// [ThemeUnlockContainer] — not part of this purchase flow.
abstract class PurchaseService extends ChangeNotifier {
  factory PurchaseService() {
    if (Platform.isIOS) return _StoreKitPurchaseService();
    return _UnsupportedPurchaseService();
  }

  PurchaseService.internal();

  /// Whether this platform can offer purchases at all.
  bool get isSupported;

  /// Whether the store is currently reachable.
  bool get isAvailable;

  bool get isLoadingProduct;

  bool get isPurchasePending;

  bool get isAdsRemoved;

  ProductDetails? get removeAdsProduct;

  Stream<PurchaseFeedback> get feedback;

  Future<void> init();

  Future<void> loadProducts();

  Future<void> buyRemoveAds();

  Future<void> restorePurchases();

  /// Debug-only: clears the locally persisted entitlement and cached
  /// product/purchase state, re-enabling ads immediately. Cannot revoke the
  /// real App Store entitlement — a later [restorePurchases] call will
  /// legitimately restore it. Callers must gate the UI for this behind
  /// `kDebugMode`; the method itself also no-ops in release as a safeguard.
  Future<void> resetForDebug();
}

class _StoreKitPurchaseService extends PurchaseService {
  _StoreKitPurchaseService({InAppPurchase? inAppPurchase})
      : _iap = inAppPurchase ?? InAppPurchase.instance,
        super.internal();

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  SharedPreferences? _prefs;

  bool _isAvailable = false;
  bool _isLoadingProduct = false;
  bool _isPurchasePending = false;
  bool _isAdsRemoved = false;
  ProductDetails? _product;

  bool _isManualBuyInFlight = false;
  bool _isManualRestoreInFlight = false;
  bool _manualRestoreFoundPurchase = false;

  final _feedbackController = StreamController<PurchaseFeedback>.broadcast();

  @override
  bool get isSupported => true;

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isLoadingProduct => _isLoadingProduct;

  @override
  bool get isPurchasePending => _isPurchasePending;

  @override
  bool get isAdsRemoved => _isAdsRemoved;

  @override
  ProductDetails? get removeAdsProduct => _product;

  @override
  Stream<PurchaseFeedback> get feedback => _feedbackController.stream;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isAdsRemoved = _prefs?.getBool(_prefsKeyAdsRemoved) ?? false;
    notifyListeners();

    try {
      _isAvailable = await _iap.isAvailable();
    } catch (e) {
      debugPrint('PurchaseService: store availability check failed: $e');
      _isAvailable = false;
    }
    notifyListeners();

    if (!_isAvailable) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error) {
        debugPrint('PurchaseService: purchase stream error: $error');
      },
    );

    await loadProducts();
    await _silentRestore();
  }

  @override
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    _isLoadingProduct = true;
    notifyListeners();
    try {
      final response = await _iap
          .queryProductDetails({PurchaseConfig.removeAdsProductId});
      _product =
          response.error == null && response.productDetails.isNotEmpty
              ? response.productDetails.first
              : null;
    } catch (e) {
      debugPrint('PurchaseService: loadProducts failed: $e');
      _product = null;
    } finally {
      _isLoadingProduct = false;
      notifyListeners();
    }
  }

  @override
  Future<void> buyRemoveAds() async {
    if (_isAdsRemoved) {
      _emit(PurchaseFeedback.alreadyOwned);
      return;
    }
    if (!_isAvailable) {
      _emit(PurchaseFeedback.storeUnavailable);
      return;
    }
    final product = _product;
    if (product == null) {
      _emit(PurchaseFeedback.productUnavailable);
      return;
    }

    _isManualBuyInFlight = true;
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      debugPrint('PurchaseService: buyRemoveAds failed: $e');
      _isManualBuyInFlight = false;
      _emit(PurchaseFeedback.purchaseFailed);
    }
  }

  @override
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      _emit(PurchaseFeedback.storeUnavailable);
      return;
    }

    _isManualRestoreInFlight = true;
    _manualRestoreFoundPurchase = false;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('PurchaseService: restorePurchases failed: $e');
      _isManualRestoreInFlight = false;
      _emit(PurchaseFeedback.restoreFailed);
      return;
    }

    // Owned non-consumables arrive asynchronously via the purchase stream;
    // give them a short window before declaring the restore empty.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!_manualRestoreFoundPurchase) {
      _emit(PurchaseFeedback.restoreEmpty);
    }
    _isManualRestoreInFlight = false;
  }

  Future<void> _silentRestore() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      // Offline or transient failure — the cached local entitlement still
      // applies until the next successful reconciliation.
      debugPrint('PurchaseService: silent restore failed: $e');
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == PurchaseConfig.removeAdsProductId) {
        await _handlePurchase(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        _isPurchasePending = true;
        notifyListeners();
        if (_isManualBuyInFlight) _emit(PurchaseFeedback.purchasePending);
        break;

      case PurchaseStatus.error:
        _isPurchasePending = false;
        notifyListeners();
        if (_isManualBuyInFlight) _emit(PurchaseFeedback.purchaseFailed);
        _isManualBuyInFlight = false;
        break;

      case PurchaseStatus.canceled:
        _isPurchasePending = false;
        notifyListeners();
        if (_isManualBuyInFlight) _emit(PurchaseFeedback.purchaseCancelled);
        _isManualBuyInFlight = false;
        break;

      case PurchaseStatus.purchased:
        _isPurchasePending = false;
        await _grantEntitlement();
        if (_isManualBuyInFlight) {
          _emit(PurchaseFeedback.purchaseSuccess);
        } else if (_isManualRestoreInFlight &&
            !_manualRestoreFoundPurchase) {
          _manualRestoreFoundPurchase = true;
          _emit(PurchaseFeedback.restoreSuccess);
        }
        _isManualBuyInFlight = false;
        break;

      case PurchaseStatus.restored:
        _isPurchasePending = false;
        await _grantEntitlement();
        if (_isManualRestoreInFlight && !_manualRestoreFoundPurchase) {
          _manualRestoreFoundPurchase = true;
          _emit(PurchaseFeedback.restoreSuccess);
        }
        break;
    }
  }

  Future<void> _grantEntitlement() async {
    if (_isAdsRemoved) return;
    _isAdsRemoved = true;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(_prefsKeyAdsRemoved, true);
    notifyListeners();
  }

  void _emit(PurchaseFeedback event) {
    if (!_feedbackController.isClosed) {
      _feedbackController.add(event);
    }
  }

  @override
  Future<void> resetForDebug() async {
    if (!kDebugMode) return;

    _isAdsRemoved = false;
    _product = null;
    _isPurchasePending = false;
    _isManualBuyInFlight = false;
    _isManualRestoreInFlight = false;
    _manualRestoreFoundPurchase = false;

    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_prefsKeyAdsRemoved);
    notifyListeners();

    await loadProducts();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _feedbackController.close();
    super.dispose();
  }
}

/// No-op stand-in used on every platform other than iOS (Android included).
/// Ads keep behaving exactly as before, and no purchase UI is ever wired to
/// this instance.
class _UnsupportedPurchaseService extends PurchaseService {
  _UnsupportedPurchaseService() : super.internal();

  @override
  bool get isSupported => false;

  @override
  bool get isAvailable => false;

  @override
  bool get isLoadingProduct => false;

  @override
  bool get isPurchasePending => false;

  @override
  bool get isAdsRemoved => false;

  @override
  ProductDetails? get removeAdsProduct => null;

  @override
  Stream<PurchaseFeedback> get feedback => const Stream.empty();

  @override
  Future<void> init() async {}

  @override
  Future<void> loadProducts() async {}

  @override
  Future<void> buyRemoveAds() async {}

  @override
  Future<void> restorePurchases() async {}

  @override
  Future<void> resetForDebug() async {}
}
