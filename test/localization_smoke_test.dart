import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'AppLocalizations resolves every string for locale $locale without error',
      (tester) async {
        late AppLocalizations l10n;

        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                l10n = AppLocalizations.of(context)!;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Exercise every message, including the interpolated ones, so a
        // malformed ARB placeholder in any locale throws here rather than
        // silently at runtime for a real user.
        expect(l10n.appTitle, isNotEmpty);
        expect(l10n.close, isNotEmpty);
        expect(l10n.aboutTitle, isNotEmpty);
        expect(l10n.aboutDescription1, isNotEmpty);
        expect(l10n.aboutDescription2, isNotEmpty);
        expect(l10n.aboutJoinDevelopment, isNotEmpty);
        expect(l10n.aboutSendBugReport, isNotEmpty);
        expect(l10n.aboutVersion('1.0.0', '1'), contains('1.0.0'));
        expect(l10n.tileLabel('3'), contains('3'));
        expect(l10n.emptyTileLabel, isNotEmpty);
        expect(l10n.hallOfFameTitle, isNotEmpty);
        expect(l10n.gridSizeLabel('4'), contains('4'));
        expect(l10n.gridSizeSemanticsLabel('4'), contains('4'));
        expect(l10n.noGamesYet, isNotEmpty);
        expect(l10n.solveToSeeRecords, isNotEmpty);
        expect(l10n.bestTimeLabel, isNotEmpty);
        expect(l10n.minMovesLabel, isNotEmpty);
        expect(l10n.noDataPlaceholder, isNotEmpty);
        expect(l10n.recentLogLabel, isNotEmpty);
        expect(l10n.recentLogTimestamp('1', '2', '3', '04'), contains('04'));
        expect(l10n.movesCount('12'), contains('12'));
        expect(l10n.photoLoadFailedMessage, isNotEmpty);
        expect(l10n.productNameRemoveAds, isNotEmpty);
        expect(l10n.productNameThemePack, isNotEmpty);
        expect(l10n.productNameGeneric, isNotEmpty);
        expect(l10n.storeUnavailableMessage, isNotEmpty);
        expect(l10n.productUnavailableMessage('X'), contains('X'));
        expect(l10n.purchasePendingMessage, isNotEmpty);
        expect(l10n.purchaseCancelledMessage, isNotEmpty);
        expect(l10n.purchaseFailedMessage, isNotEmpty);
        expect(l10n.themePackPurchaseSuccessMessage, isNotEmpty);
        expect(l10n.removeAdsPurchaseSuccessMessage, isNotEmpty);
        expect(l10n.alreadyOwnedMessage('X'), contains('X'));
        expect(l10n.restoreSuccessMessage('X'), contains('X'));
        expect(l10n.restoreEmptyMessage, isNotEmpty);
        expect(l10n.restoreFailedMessage, isNotEmpty);
        expect(l10n.gameAppBarTitle, isNotEmpty);
        expect(l10n.settingsTitle, isNotEmpty);
        expect(l10n.timeLabel, isNotEmpty);
        expect(l10n.movesLabel, isNotEmpty);
        expect(l10n.hintTooltip, isNotEmpty);
        expect(l10n.newGameTooltip, isNotEmpty);
        expect(l10n.settingsSubtitle, isNotEmpty);
        expect(l10n.gridSizeSectionHeader, isNotEmpty);
        expect(l10n.darkModeLabel, isNotEmpty);
        expect(l10n.speedRunModeLabel, isNotEmpty);
        expect(l10n.speedRunModeSubtitle, isNotEmpty);
        expect(l10n.soundEffectsLabel, isNotEmpty);
        expect(l10n.adsRemovedTitle, isNotEmpty);
        expect(l10n.adsRemovedSubtitle, isNotEmpty);
        expect(l10n.removeAdsTitle, isNotEmpty);
        expect(l10n.removeAdsSubtitle, isNotEmpty);
        expect(l10n.restorePurchasesTitle, isNotEmpty);
        expect(l10n.unavailableLabel, isNotEmpty);
        expect(l10n.themesSectionHeader, isNotEmpty);
        expect(l10n.unlockThemesTitle, isNotEmpty);
        expect(l10n.unlockThemesSubtitle, isNotEmpty);
        expect(l10n.photoModeTitle, isNotEmpty);
        expect(l10n.photoModeSubtitle, isNotEmpty);
        expect(l10n.themeSwatchLabel('X'), contains('X'));
        expect(l10n.themeSwatchLockedLabel('X'), contains('X'));
        expect(l10n.themeNameClassic, isNotEmpty);
        expect(l10n.themeNameMidnight, isNotEmpty);
        expect(l10n.themeNameSunset, isNotEmpty);
        expect(l10n.themeNameMint, isNotEmpty);
        expect(l10n.tutorialStep1Title, isNotEmpty);
        expect(l10n.tutorialStep1Description, isNotEmpty);
        expect(l10n.tutorialStep2Title, isNotEmpty);
        expect(l10n.tutorialStep2Description, isNotEmpty);
        expect(l10n.tutorialStep3Title, isNotEmpty);
        expect(l10n.tutorialStep3Description, isNotEmpty);
        expect(l10n.skipButton, isNotEmpty);
        expect(l10n.nextButton, isNotEmpty);
        expect(l10n.getStartedButton, isNotEmpty);
        expect(l10n.shareButton, isNotEmpty);
        expect(l10n.shareText('4', '1:23', '30'), contains('30'));
        expect(l10n.rankingsButton, isNotEmpty);
        expect(l10n.victoryTitle, isNotEmpty);
        expect(l10n.victoryDescription('4'), contains('4'));
        expect(l10n.advertisementLabel, isNotEmpty);
      },
    );
  }
}
