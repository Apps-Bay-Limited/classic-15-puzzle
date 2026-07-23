import 'package:classic_15_puzzle/widgets/util/purchase_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('readCachedAdsRemoved (entitlement persistence)', () {
    test('returns false when nothing has been persisted yet', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await readCachedAdsRemoved(), isFalse);
    });

    test('returns true once the entitlement key has been persisted', () async {
      SharedPreferences.setMockInitialValues({
        'purchase::ads_removed': true,
      });
      expect(await readCachedAdsRemoved(), isTrue);
    });

    test('returns false when the persisted key is explicitly false', () async {
      SharedPreferences.setMockInitialValues({
        'purchase::ads_removed': false,
      });
      expect(await readCachedAdsRemoved(), isFalse);
    });
  });

  group('PurchaseService platform gating', () {
    test(
      'resolves to a no-op implementation on non-iOS test hosts, matching '
      'Android behavior: no purchase support, ads unaffected',
      () async {
        SharedPreferences.setMockInitialValues({});
        final service = PurchaseService();

        expect(service.isSupported, isFalse);
        expect(service.isAdsRemoved, isFalse);
        expect(service.removeAdsProduct, isNull);
        expect(service.themePackProduct, isNull);

        // Buying, restoring, and resetting must all be safe no-ops.
        await service.init();
        await service.loadProducts();
        await service.buyRemoveAds();
        await service.buyThemePack();
        await service.restorePurchases();
        await service.resetForDebug();

        expect(service.isAdsRemoved, isFalse);
        await expectLater(service.feedback, emitsDone);

        service.dispose();
      },
    );

    test(
      'unlocks the Theme Pack for free on non-iOS test hosts, matching '
      'Android behavior: no billing exists to charge them for it',
      () {
        final service = PurchaseService();
        expect(service.isThemePackOwned, isTrue);
        service.dispose();
      },
    );
  });
}
