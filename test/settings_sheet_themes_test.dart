import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/theme/tile_theme.dart';
import 'package:classic_15_puzzle/widgets/game/material/sheets.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:classic_15_puzzle/widgets/util/theme_unlock_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_purchase_service.dart';
import 'fakes/fake_rewarded_ad_source.dart';

void main() {
  Future<void> pumpSheet(
    WidgetTester tester,
    FakeRewardedAdSource fakeAdSource,
  ) async {
    await tester.pumpWidget(
      PurchaseContainer(
        service: FakePurchaseService(
          product: FakePurchaseService.removeAdsProductFixture(),
        ),
        child: ThemeUnlockContainer(
          adSource: fakeAdSource,
          child: ConfigUiContainer(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => SettingsPage(
                              currentGridSize: 3,
                              onGridSizeSelected: (_) {},
                            ),
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
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows a watch-ad row and unlocks themes once the ad rewards the user',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final fakeAdSource = FakeRewardedAdSource(isAdAvailable: true)
        ..nextShowEarnsReward = true;

      await pumpSheet(tester, fakeAdSource);

      expect(find.text('Unlock Themes'), findsOneWidget);
      expect(find.text('Photo Mode'), findsNothing);

      await tester.ensureVisible(find.text('Unlock Themes'));
      await tester.tap(find.text('Unlock Themes'));
      await tester.pumpAndSettle();

      expect(fakeAdSource.showAdCallCount, 1);
      expect(find.text('Unlock Themes'), findsNothing);
      expect(find.text('Photo Mode'), findsOneWidget);
    },
  );

  testWidgets(
    'shows an unavailable trailing label when no rewarded ad is loaded',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final fakeAdSource = FakeRewardedAdSource(isAdAvailable: false);

      await pumpSheet(tester, fakeAdSource);

      expect(find.text('Unlock Themes'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
    },
  );

  testWidgets(
    'shows tappable palettes and Photo Mode once unlocked, selecting persists',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'theme_unlock::unlocked': true,
      });
      final fakeAdSource = FakeRewardedAdSource();

      await pumpSheet(tester, fakeAdSource);

      expect(find.text('Unlock Themes'), findsNothing);
      expect(find.text('Photo Mode'), findsOneWidget);
      expect(find.text('Midnight'), findsOneWidget);
      expect(find.text('Sunset'), findsOneWidget);
      expect(find.text('Mint'), findsOneWidget);

      late BuildContext capturedContext;
      capturedContext = tester.element(find.text('Midnight'));
      expect(
        ConfigUiContainer.of(capturedContext)!.selectedTileThemeId,
        TileThemeId.classic,
      );

      await tester.ensureVisible(find.text('Midnight'));
      await tester.tap(find.text('Midnight'));
      await tester.pumpAndSettle();

      expect(
        ConfigUiContainer.of(capturedContext)!.selectedTileThemeId,
        TileThemeId.midnight,
      );
    },
  );
}
