import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/theme/tile_theme.dart';
import 'package:classic_15_puzzle/widgets/game/material/sheets.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_purchase_service.dart';

void main() {
  Future<void> pumpSheet(WidgetTester tester, FakePurchaseService fake) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      PurchaseContainer(
        service: fake,
        child: ConfigUiContainer(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows the store-localized price and locked palettes when not owned',
    (tester) async {
      final fake = FakePurchaseService(
        isThemePackOwned: false,
        themePackProduct: FakePurchaseService.themePackProductFixture(),
      );

      await pumpSheet(tester, fake);

      expect(find.text('Unlock Themes'), findsOneWidget);
      expect(find.text(r'$3.99'), findsOneWidget);
      expect(find.text('Photo Mode'), findsNothing);

      await tester.ensureVisible(find.text('Unlock Themes'));
      await tester.tap(find.text('Unlock Themes'));
      await tester.pump();
      expect(fake.buyThemePackCallCount, 1);
    },
  );

  testWidgets(
    'shows tappable palettes and Photo Mode once owned, selecting persists',
    (tester) async {
      final fake = FakePurchaseService(isThemePackOwned: true);

      await pumpSheet(tester, fake);

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

  testWidgets('Android (unconditionally owned) renders directly in owned state',
      (tester) async {
    final fake = FakePurchaseService(isSupported: false, isThemePackOwned: true);

    await pumpSheet(tester, fake);

    expect(find.text('Unlock Themes'), findsNothing);
    expect(find.text('Photo Mode'), findsOneWidget);
    expect(find.text('Classic'), findsOneWidget);
  });
}
