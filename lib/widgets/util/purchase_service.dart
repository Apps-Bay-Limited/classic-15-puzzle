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

/// Which non-consumable product a [PurchaseFeedback] event is about, so the
/// UI can pick accurate wording (e.g. "Remove Ads" vs "Theme Pack"). `null`
/// for store-level events not tied to one product (e.g. [PurchaseFeedback.
/// storeUnavailable] or [PurchaseFeedback.restoreEmpty], which cover a
/// whole restore/availability check rather than a single purchase).
enum PurchaseProduct { removeAds, themePack }

class PurchaseFeedbackEvent {
  final PurchaseFeedback type;
  final PurchaseProduct? product;

  const PurchaseFeedbackEvent(this.type, {this.product});
}

const String _prefsKeyAdsRemoved = 'purchase::ads_removed';
const String _prefsKeyThemePackOwned = 'purchase::theme_pack_owned';

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

/// Manages the "Remove Ads" and "Theme Pack" non-consumable purchases.
///
/// Only [_StoreKitPurchaseService] talks to the App Store; on every other
/// platform [PurchaseService] resolves to [_UnsupportedPurchaseService], a
/// no-op stub, so Android keeps compiling and running with ads unchanged.
/// Android billing can later be added as a third implementation behind this
/// same interface. Note that on unsupported platforms [isThemePackOwned] is
/// unconditionally `true` — there's no way to charge Android users, so
/// themes/photo mode are simply free there rather than an unpayable paywall.
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

  bool get isThemePackOwned;

  ProductDetails? get removeAdsProduct;

  ProductDetails? get themePackProduct;

  Stream<PurchaseFeedbackEvent> get feedback;

  Future<void> init();

  Future<void> loadProducts();

  Future<void> buyRemoveAds();

  Future<void> buyThemePack();

  Future<void> restorePurchases();

  /// Debug-only: clears the locally persisted entitlements and cached
  /// product/purchase state, re-enabling ads/locking themes immediately.
  /// Cannot revoke the real App Store entitlement — a later
  /// [restorePurchases] call will legitimately restore it. Callers must gate
  /// the UI for this behind `kDebugMode`; the method itself also no-ops in
  /// release as a safeguard.
  Future<void> resetForDebug();
}

/// Tracks purchase state for a single non-consumable product.
class _ProductEntitlement {
  _ProductEntitlement({
    required this.productId,
    required this.prefsKey,
    required this.product,
  });

  final String productId;
  final String prefsKey;

  /// Which [PurchaseProduct] this entitlement corresponds to, so feedback
  /// events can be attributed to the right product for the UI.
  final PurchaseProduct product;

  bool isOwned = false;
  ProductDetails? productDetails;
  bool isManualBuyInFlight = false;
}

class _StoreKitPurchaseService extends PurchaseService {
  _StoreKitPurchaseService({InAppPurchase? inAppPurchase})
      : _iap = inAppPurchase ?? InAppPurchase.instance,
        super.internal();

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  SharedPreferences? _prefs;

  final _adsEntitlement = _ProductEntitlement(
    productId: PurchaseConfig.removeAdsProductId,
    prefsKey: _prefsKeyAdsRemoved,
    product: PurchaseProduct.removeAds,
  );
  final _themePackEntitlement = _ProductEntitlement(
    productId: PurchaseConfig.themePackProductId,
    prefsKey: _prefsKeyThemePackOwned,
    product: PurchaseProduct.themePack,
  );
  late final Map<String, _ProductEntitlement> _entitlementsByProductId = {
    _adsEntitlement.productId: _adsEntitlement,
    _themePackEntitlement.productId: _themePackEntitlement,
  };

  bool _isAvailable = false;
  bool _isLoadingProduct = false;
  bool _isPurchasePending = false;

  bool _isManualRestoreInFlight = false;
  bool _manualRestoreFoundPurchase = false;

  final _feedbackController =
      StreamController<PurchaseFeedbackEvent>.broadcast();

  @override
  bool get isSupported => true;

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isLoadingProduct => _isLoadingProduct;

  @override
  bool get isPurchasePending => _isPurchasePending;

  @override
  bool get isAdsRemoved => _adsEntitlement.isOwned;

  @override
  bool get isThemePackOwned => _themePackEntitlement.isOwned;

  @override
  ProductDetails? get removeAdsProduct => _adsEntitlement.productDetails;

  @override
  ProductDetails? get themePackProduct => _themePackEntitlement.productDetails;

  @override
  Stream<PurchaseFeedbackEvent> get feedback => _feedbackController.stream;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    for (final entitlement in _entitlementsByProductId.values) {
      entitlement.isOwned = _prefs?.getBool(entitlement.prefsKey) ?? false;
    }
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
          .queryProductDetails(_entitlementsByProductId.keys.toSet());
      for (final entitlement in _entitlementsByProductId.values) {
        entitlement.productDetails = null;
      }
      for (final details in response.productDetails) {
        _entitlementsByProductId[details.id]?.productDetails = details;
      }
    } catch (e) {
      debugPrint('PurchaseService: loadProducts failed: $e');
      for (final entitlement in _entitlementsByProductId.values) {
        entitlement.productDetails = null;
      }
    } finally {
      _isLoadingProduct = false;
      notifyListeners();
    }
  }

  @override
  Future<void> buyRemoveAds() => _buy(_adsEntitlement);

  @override
  Future<void> buyThemePack() => _buy(_themePackEntitlement);

  Future<void> _buy(_ProductEntitlement entitlement) async {
    if (entitlement.isOwned) {
      _emit(PurchaseFeedback.alreadyOwned, entitlement.product);
      return;
    }
    if (!_isAvailable) {
      _emit(PurchaseFeedback.storeUnavailable, entitlement.product);
      return;
    }
    final productDetails = entitlement.productDetails;
    if (productDetails == null) {
      _emit(PurchaseFeedback.productUnavailable, entitlement.product);
      return;
    }

    entitlement.isManualBuyInFlight = true;
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
      );
    } catch (e) {
      debugPrint(
          'PurchaseService: buy failed for ${entitlement.productId}: $e');
      entitlement.isManualBuyInFlight = false;
      _emit(PurchaseFeedback.purchaseFailed, entitlement.product);
    }
  }

  @override
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      _emit(PurchaseFeedback.storeUnavailable, null);
      return;
    }

    _isManualRestoreInFlight = true;
    _manualRestoreFoundPurchase = false;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('PurchaseService: restorePurchases failed: $e');
      _isManualRestoreInFlight = false;
      _emit(PurchaseFeedback.restoreFailed, null);
      return;
    }

    // Owned non-consumables arrive asynchronously via the purchase stream;
    // give them a short window before declaring the restore empty.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!_manualRestoreFoundPurchase) {
      _emit(PurchaseFeedback.restoreEmpty, null);
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
      final entitlement = _entitlementsByProductId[purchase.productID];
      if (entitlement != null) {
        await _handlePurchase(entitlement, purchase);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _handlePurchase(
    _ProductEntitlement entitlement,
    PurchaseDetails purchase,
  ) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        _isPurchasePending = true;
        notifyListeners();
        if (entitlement.isManualBuyInFlight) {
          _emit(PurchaseFeedback.purchasePending, entitlement.product);
        }
        break;

      case PurchaseStatus.error:
        _isPurchasePending = false;
        notifyListeners();
        if (entitlement.isManualBuyInFlight) {
          _emit(PurchaseFeedback.purchaseFailed, entitlement.product);
        }
        entitlement.isManualBuyInFlight = false;
        break;

      case PurchaseStatus.canceled:
        _isPurchasePending = false;
        notifyListeners();
        if (entitlement.isManualBuyInFlight) {
          _emit(PurchaseFeedback.purchaseCancelled, entitlement.product);
        }
        entitlement.isManualBuyInFlight = false;
        break;

      case PurchaseStatus.purchased:
        _isPurchasePending = false;
        await _grantEntitlement(entitlement);
        if (entitlement.isManualBuyInFlight) {
          _emit(PurchaseFeedback.purchaseSuccess, entitlement.product);
        } else if (_isManualRestoreInFlight &&
            !_manualRestoreFoundPurchase) {
          _manualRestoreFoundPurchase = true;
          _emit(PurchaseFeedback.restoreSuccess, entitlement.product);
        }
        entitlement.isManualBuyInFlight = false;
        break;

      case PurchaseStatus.restored:
        _isPurchasePending = false;
        await _grantEntitlement(entitlement);
        if (_isManualRestoreInFlight && !_manualRestoreFoundPurchase) {
          _manualRestoreFoundPurchase = true;
          _emit(PurchaseFeedback.restoreSuccess, entitlement.product);
        }
        break;
    }
  }

  Future<void> _grantEntitlement(_ProductEntitlement entitlement) async {
    if (entitlement.isOwned) return;
    entitlement.isOwned = true;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(entitlement.prefsKey, true);
    notifyListeners();
  }

  void _emit(PurchaseFeedback type, PurchaseProduct? product) {
    if (!_feedbackController.isClosed) {
      _feedbackController.add(PurchaseFeedbackEvent(type, product: product));
    }
  }

  @override
  Future<void> resetForDebug() async {
    if (!kDebugMode) return;

    for (final entitlement in _entitlementsByProductId.values) {
      entitlement.isOwned = false;
      entitlement.productDetails = null;
      entitlement.isManualBuyInFlight = false;
    }
    _isPurchasePending = false;
    _isManualRestoreInFlight = false;
    _manualRestoreFoundPurchase = false;

    _prefs ??= await SharedPreferences.getInstance();
    for (final entitlement in _entitlementsByProductId.values) {
      await _prefs?.remove(entitlement.prefsKey);
    }
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
/// Ads keep behaving exactly as before, and no Remove Ads purchase UI is
/// ever wired to this instance. Themes/photo mode are unlocked for free
/// here, since there's no billing mechanism to charge Android users.
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
  bool get isThemePackOwned => true;

  @override
  ProductDetails? get removeAdsProduct => null;

  @override
  ProductDetails? get themePackProduct => null;

  @override
  Stream<PurchaseFeedbackEvent> get feedback => const Stream.empty();

  @override
  Future<void> init() async {}

  @override
  Future<void> loadProducts() async {}

  @override
  Future<void> buyRemoveAds() async {}

  @override
  Future<void> buyThemePack() async {}

  @override
  Future<void> restorePurchases() async {}

  @override
  Future<void> resetForDebug() async {}
}
