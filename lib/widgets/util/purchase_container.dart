import 'package:classic_15_puzzle/widgets/util/purchase_service.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Exposes the "Remove Ads" purchase state to the widget tree, following the
/// same Container/InheritedWidget pattern as [ConfigUiContainer] and
/// [PlayGamesContainer].
class PurchaseContainer extends StatefulWidget {
  final Widget child;

  /// Overrides the real StoreKit-backed service, for tests to inject a
  /// fake/mock [PurchaseService].
  final PurchaseService? service;

  const PurchaseContainer({super.key, required this.child, this.service});

  static PurchaseContainerState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        ?.data;
  }

  @override
  PurchaseContainerState createState() => PurchaseContainerState();
}

class PurchaseContainerState extends State<PurchaseContainer> {
  late final PurchaseService _service = widget.service ?? PurchaseService();

  bool get isSupported => _service.isSupported;

  bool get isAvailable => _service.isAvailable;

  bool get isLoadingProduct => _service.isLoadingProduct;

  bool get isPurchasePending => _service.isPurchasePending;

  bool get isAdsRemoved => _service.isAdsRemoved;

  ProductDetails? get removeAdsProduct => _service.removeAdsProduct;

  Stream<PurchaseFeedback> get feedback => _service.feedback;

  @override
  void initState() {
    super.initState();
    _service.addListener(_handleServiceChange);
    _service.init();
  }

  void _handleServiceChange() {
    if (mounted) setState(() {});
  }

  Future<void> loadProducts() => _service.loadProducts();

  Future<void> buyRemoveAds() => _service.buyRemoveAds();

  Future<void> restorePurchases() => _service.restorePurchases();

  Future<void> resetForDebug() => _service.resetForDebug();

  @override
  void dispose() {
    _service.removeListener(_handleServiceChange);
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final PurchaseContainerState data;

  const _InheritedStateContainer({
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
