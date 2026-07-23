import 'dart:async';

import 'package:classic_15_puzzle/widgets/util/purchase_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Controllable test double for [PurchaseService]. Never touches the App
/// Store — tests drive state directly and assert on recorded calls.
class FakePurchaseService extends PurchaseService {
  FakePurchaseService({
    bool isSupported = true,
    bool isAvailable = true,
    bool isAdsRemoved = false,
    ProductDetails? product,
  })  : _isSupported = isSupported,
        _isAvailable = isAvailable,
        _isAdsRemoved = isAdsRemoved,
        _product = product,
        super.internal();

  static ProductDetails removeAdsProductFixture() => ProductDetails(
        id: 'com.appsbay.classic15Puzzle.remove_ads',
        title: 'Remove Ads',
        description: 'Remove ads permanently from this app.',
        price: '\$2.99',
        rawPrice: 2.99,
        currencyCode: 'USD',
        currencySymbol: '\$',
      );

  bool _isSupported;
  bool _isAvailable;
  bool _isLoadingProduct = false;
  bool _isPurchasePending = false;
  bool _isAdsRemoved;
  ProductDetails? _product;

  int initCallCount = 0;
  int loadProductsCallCount = 0;
  int buyRemoveAdsCallCount = 0;
  int restorePurchasesCallCount = 0;
  int resetForDebugCallCount = 0;

  final _feedbackController = StreamController<PurchaseFeedback>.broadcast();

  @override
  bool get isSupported => _isSupported;

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
    initCallCount++;
  }

  @override
  Future<void> loadProducts() async {
    loadProductsCallCount++;
  }

  @override
  Future<void> buyRemoveAds() async {
    buyRemoveAdsCallCount++;
  }

  @override
  Future<void> restorePurchases() async {
    restorePurchasesCallCount++;
  }

  @override
  Future<void> resetForDebug() async {
    resetForDebugCallCount++;
    _isAdsRemoved = false;
    notifyListeners();
  }

  /// Test helpers to simulate state changes the way the real StoreKit
  /// service would report them through its stream/side effects.

  void setIsAdsRemoved(bool value) {
    _isAdsRemoved = value;
    notifyListeners();
  }

  void setIsPurchasePending(bool value) {
    _isPurchasePending = value;
    notifyListeners();
  }

  void setIsLoadingProduct(bool value) {
    _isLoadingProduct = value;
    notifyListeners();
  }

  void setProduct(ProductDetails? value) {
    _product = value;
    notifyListeners();
  }

  void setIsSupported(bool value) {
    _isSupported = value;
    notifyListeners();
  }

  void setIsAvailable(bool value) {
    _isAvailable = value;
    notifyListeners();
  }

  void emit(PurchaseFeedback event) {
    _feedbackController.add(event);
  }

  @override
  void dispose() {
    _feedbackController.close();
    super.dispose();
  }
}
