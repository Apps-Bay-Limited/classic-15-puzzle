import 'package:classic_15_puzzle/widgets/game/material/sheets.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_purchase_service.dart';

void main() {
  Future<void> pumpSheet(WidgetTester tester, FakePurchaseService fake) async {
    // PurchaseContainer must wrap MaterialApp (as it does in main.dart), not
    // the other way around: showModalBottomSheet pushes a new route as a
    // sibling OverlayEntry inside the Navigator, so it only inherits
    // ancestors that sit above MaterialApp/the Navigator itself.
    await tester.pumpWidget(
      PurchaseContainer(
        service: fake,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => createSettingsBottomSheet(
                        context,
                        onGridSizeSelected: (_) {},
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows the store-localized price and purchase entry when not yet bought',
    (tester) async {
      final fake = FakePurchaseService(
        isAdsRemoved: false,
        product: FakePurchaseService.removeAdsProductFixture(),
      );

      await pumpSheet(tester, fake);

      expect(find.text('Remove Ads'), findsOneWidget);
      expect(find.text(r'$2.99'), findsOneWidget);
      expect(find.text('Ads removed'), findsNothing);

      await tester.tap(find.text('Remove Ads'));
      await tester.pump();
      expect(fake.buyRemoveAdsCallCount, 1);
    },
  );

  testWidgets('shows an unavailable message when the product failed to load',
      (tester) async {
    final fake = FakePurchaseService(isAdsRemoved: false, product: null);

    await pumpSheet(tester, fake);

    expect(find.text('Remove Ads'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
  });

  testWidgets('shows the ads-removed state once purchased, no buy button',
      (tester) async {
    final fake = FakePurchaseService(isAdsRemoved: true);

    await pumpSheet(tester, fake);

    expect(find.text('Ads removed'), findsOneWidget);
    // Restore stays accessible even once purchased.
    expect(find.text('Restore Purchases'), findsOneWidget);
  });

  testWidgets('Restore Purchases always stays accessible and wired up',
      (tester) async {
    final fake = FakePurchaseService(isAdsRemoved: false);

    await pumpSheet(tester, fake);

    await tester.ensureVisible(find.text('Restore Purchases'));
    await tester.tap(find.text('Restore Purchases'));
    await tester.pump();
    expect(fake.restorePurchasesCallCount, 1);
  });

  testWidgets(
    'debug-only Reset IAP control clears the entitlement after confirmation',
    (tester) async {
      final fake = FakePurchaseService(isAdsRemoved: true);

      await pumpSheet(tester, fake);

      expect(find.text('Reset IAP (Debug)'), findsOneWidget);

      await tester.ensureVisible(find.text('Reset IAP (Debug)'));
      await tester.tap(find.text('Reset IAP (Debug)'));
      await tester.pumpAndSettle();

      // A confirmation dialog gates the destructive-looking action.
      expect(find.text('RESET'), findsOneWidget);
      await tester.tap(find.text('RESET'));
      await tester.pumpAndSettle();

      expect(fake.resetForDebugCallCount, 1);
      expect(fake.isAdsRemoved, isFalse);
    },
  );

  testWidgets('hides all purchase UI when the platform is not supported',
      (tester) async {
    final fake = FakePurchaseService(isSupported: false);

    await pumpSheet(tester, fake);

    expect(find.text('Remove Ads'), findsNothing);
    expect(find.text('Ads removed'), findsNothing);
    expect(find.text('Restore Purchases'), findsNothing);
    expect(find.text('Reset IAP (Debug)'), findsNothing);
  });
}
