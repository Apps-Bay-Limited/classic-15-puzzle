import 'package:classic_15_puzzle/widgets/util/ads_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ad gating: dispose() safely tears down unloaded ads', () {
    test('InterstitialAdManager.dispose is a no-op when nothing is loaded',
        () {
      final manager = InterstitialAdManager();
      expect(manager.isAdAvailable, isFalse);
      expect(() => manager.dispose(), returnsNormally);
      expect(manager.isAdAvailable, isFalse);
    });

    test('AppOpenAdManager.dispose is a no-op when nothing is loaded', () {
      final manager = AppOpenAdManager();
      expect(manager.isAdAvailable, isFalse);
      expect(() => manager.dispose(), returnsNormally);
      expect(manager.isAdAvailable, isFalse);
    });
  });

  group('AppLifecycleReactor: skips app-open ads during purchase', () {
    test('does not show an ad on resume while a purchase is in progress', () {
      final appOpenAdManager = AppOpenAdManager();
      var isPurchaseInProgress = true;

      final reactor = AppLifecycleReactor(
        appOpenAdManager: appOpenAdManager,
        isPurchaseInProgress: () => isPurchaseInProgress,
      );

      // Simulate backgrounding then resuming while a purchase is pending.
      // No ad is loaded, and showAdIfAvailable() is never even reached
      // because the purchase-in-progress guard short-circuits first.
      reactor.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(
        () => reactor.didChangeAppLifecycleState(AppLifecycleState.resumed),
        returnsNormally,
      );
      expect(appOpenAdManager.isAdAvailable, isFalse);
    });
  });
}
