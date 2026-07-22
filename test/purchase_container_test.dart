import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_purchase_service.dart';

void main() {
  Widget wrap(FakePurchaseService service, Widget child) {
    return MaterialApp(
      home: PurchaseContainer(service: service, child: child),
    );
  }

  testWidgets('exposes the injected service state through of(context)',
      (tester) async {
    final fake = FakePurchaseService(isAdsRemoved: false);
    late BuildContext capturedContext;

    await tester.pumpWidget(
      wrap(fake, Builder(builder: (context) {
        capturedContext = context;
        return const SizedBox.shrink();
      })),
    );

    final container = PurchaseContainer.of(capturedContext);
    expect(container, isNotNull);
    expect(container!.isAdsRemoved, isFalse);
    expect(container.isSupported, isTrue);
  });

  testWidgets('init() is called once the container mounts', (tester) async {
    final fake = FakePurchaseService();
    await tester.pumpWidget(wrap(fake, const SizedBox.shrink()));
    expect(fake.initCallCount, 1);
  });

  testWidgets(
    'buyRemoveAds/restorePurchases/resetForDebug delegate to the service',
    (tester) async {
      final fake = FakePurchaseService();
      late PurchaseContainerState state;

      await tester.pumpWidget(
        wrap(fake, Builder(builder: (context) {
          state = PurchaseContainer.of(context)!;
          return const SizedBox.shrink();
        })),
      );

      await state.buyRemoveAds();
      expect(fake.buyRemoveAdsCallCount, 1);

      await state.restorePurchases();
      expect(fake.restorePurchasesCallCount, 1);

      await state.resetForDebug();
      expect(fake.resetForDebugCallCount, 1);
    },
  );

  testWidgets(
    'rebuilds reactively when the entitlement activates mid-session '
    '(fresh purchase or store reconciliation)',
    (tester) async {
      final fake = FakePurchaseService(isAdsRemoved: false);
      late BuildContext capturedContext;
      var buildCount = 0;

      await tester.pumpWidget(
        wrap(fake, Builder(builder: (context) {
          capturedContext = context;
          buildCount++;
          return Text(
            PurchaseContainer.of(context)!.isAdsRemoved
                ? 'ads removed'
                : 'ads shown',
          );
        })),
      );

      expect(find.text('ads shown'), findsOneWidget);
      final buildsBefore = buildCount;

      fake.setIsAdsRemoved(true);
      await tester.pump();

      expect(buildCount, greaterThan(buildsBefore));
      expect(PurchaseContainer.of(capturedContext)!.isAdsRemoved, isTrue);
      expect(find.text('ads removed'), findsOneWidget);
    },
  );

  testWidgets('debug reset clears the entitlement and re-enables gating',
      (tester) async {
    final fake = FakePurchaseService(isAdsRemoved: true);
    late PurchaseContainerState state;

    await tester.pumpWidget(
      wrap(fake, Builder(builder: (context) {
        state = PurchaseContainer.of(context)!;
        return const SizedBox.shrink();
      })),
    );

    expect(state.isAdsRemoved, isTrue);

    await state.resetForDebug();
    await tester.pump();

    expect(state.isAdsRemoved, isFalse);
    expect(fake.resetForDebugCallCount, 1);
  });
}
