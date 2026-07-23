// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Classic 15 Puzzle';

  @override
  String get close => 'CLOSE';

  @override
  String tileLabel(String number) {
    return 'Tile $number';
  }

  @override
  String get emptyTileLabel => 'Empty tile';

  @override
  String get hallOfFameTitle => 'Hall of Fame';

  @override
  String gridSizeLabel(String size) {
    return '${size}x$size';
  }

  @override
  String gridSizeSemanticsLabel(String size) {
    return '${size}x$size grid';
  }

  @override
  String gridSizeSelectedSemanticsLabel(String size) {
    return '${size}x$size grid, selected';
  }

  @override
  String get noGamesYet => 'No games yet';

  @override
  String get solveToSeeRecords => 'Solve a puzzle to see your records here';

  @override
  String get bestTimeLabel => 'BEST TIME';

  @override
  String get minMovesLabel => 'MIN MOVES';

  @override
  String get noDataPlaceholder => '--';

  @override
  String get recentLogLabel => 'RECENT LOG';

  @override
  String recentLogTimestamp(
      String day, String month, String hour, String minute) {
    return '$day/$month $hour:$minute';
  }

  @override
  String movesCount(String steps) {
    return '$steps moves';
  }

  @override
  String get photoLoadFailedMessage =>
      'That saved photo couldn\'t be loaded. Switched back to Classic.';

  @override
  String get productNameRemoveAds => 'Remove Ads';

  @override
  String get productNameGeneric => 'That purchase';

  @override
  String get storeUnavailableMessage =>
      'The App Store is unavailable right now. Please try again later.';

  @override
  String productUnavailableMessage(String productName) {
    return '$productName is not available right now. Please try again later.';
  }

  @override
  String get purchasePendingMessage => 'Your purchase is pending approval.';

  @override
  String get purchaseCancelledMessage => 'Purchase cancelled.';

  @override
  String get purchaseFailedMessage => 'Purchase failed. Please try again.';

  @override
  String get removeAdsPurchaseSuccessMessage =>
      'Ads removed. Thank you for your support!';

  @override
  String get rewardedAdUnavailableMessage =>
      'Ad not available right now. Please try again shortly.';

  @override
  String get rewardedAdDismissedMessage =>
      'Watch the full ad to unlock themes and photo mode.';

  @override
  String get themesUnlockedMessage => 'Themes and photo mode unlocked. Enjoy!';

  @override
  String alreadyOwnedMessage(String productName) {
    return 'You already own $productName.';
  }

  @override
  String restoreSuccessMessage(String productName) {
    return '$productName restored.';
  }

  @override
  String get restoreEmptyMessage => 'No previous purchase found to restore.';

  @override
  String get restoreFailedMessage => 'Restore failed. Please try again.';

  @override
  String get gameAppBarTitle => 'Classic 15';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get timeLabel => 'TIME';

  @override
  String get movesLabel => 'MOVES';

  @override
  String get hintTooltip => 'Hint';

  @override
  String get undoTooltip => 'Undo';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get resumeTooltip => 'Resume';

  @override
  String get pausedTapToResumeLabel => 'Paused — tap to resume';

  @override
  String get newGameTooltip => 'New game';

  @override
  String get settingsSubtitle => 'Customize your puzzle experience';

  @override
  String get gridSizeSectionHeader => 'GRID SIZE';

  @override
  String get darkModeLabel => 'Dark mode';

  @override
  String get speedRunModeLabel => 'Speed run mode';

  @override
  String get speedRunModeSubtitle => 'Faster animations, tap-only tiles';

  @override
  String get speedRunModeInfoTooltip => 'About Speed run mode';

  @override
  String get speedRunModeExplanation =>
      'In Speed Run Mode, tap any tile to slide it toward the empty space — you don\'t need to tap only tiles directly next to it. Animations are faster too, so you can solve puzzles as quickly as possible.';

  @override
  String get soundEffectsLabel => 'Sound effects';

  @override
  String get adsRemovedTitle => 'Ads removed';

  @override
  String get adsRemovedSubtitle => 'Thank you for supporting the app!';

  @override
  String get removeAdsTitle => 'Remove Ads';

  @override
  String get removeAdsSubtitle => 'Remove ads permanently from this app.';

  @override
  String get restorePurchasesTitle => 'Restore Purchases';

  @override
  String get unavailableLabel => 'Unavailable';

  @override
  String get themesSectionHeader => 'THEMES';

  @override
  String get unlockThemesTitle => 'Unlock Themes';

  @override
  String get unlockThemesSubtitle => 'Extra tile palettes + photo puzzle mode.';

  @override
  String get photoModeTitle => 'Photo Mode';

  @override
  String get photoModeSubtitle => 'Turn a photo into your puzzle.';

  @override
  String themeSwatchLabel(String themeName) {
    return '$themeName theme';
  }

  @override
  String themeSwatchLockedLabel(String themeName) {
    return '$themeName theme, locked';
  }

  @override
  String get themeNameClassic => 'Classic';

  @override
  String get themeNameMidnight => 'Midnight';

  @override
  String get themeNameSunset => 'Sunset';

  @override
  String get themeNameMint => 'Mint';

  @override
  String get tutorialStep1Title => 'Slide to solve';

  @override
  String get tutorialStep1Description =>
      'Tap a tile next to the empty space to slide it into place. Arrange every tile in order to win.';

  @override
  String get tutorialStep2Title => 'Stuck? Get a hint';

  @override
  String get tutorialStep2Description =>
      'Tap the hint button anytime to see the best next move.';

  @override
  String get tutorialStep3Title => 'Make it yours';

  @override
  String get tutorialStep3Description =>
      'Open Settings to change the grid size, tile themes, sound, and more.';

  @override
  String get skipButton => 'SKIP';

  @override
  String get nextButton => 'NEXT';

  @override
  String get getStartedButton => 'GET STARTED';

  @override
  String get shareButton => 'SHARE';

  @override
  String shareText(String size, String time, String steps) {
    return 'I solved the Classic 15 Puzzle ${size}x$size in $time with $steps moves!';
  }

  @override
  String get rankingsButton => 'RANKINGS';

  @override
  String get victoryTitle => 'Magnificent!';

  @override
  String victoryDescription(String size) {
    return 'You completed the ${size}x$size puzzle in record time.';
  }

  @override
  String get advertisementLabel => 'ADVERTISEMENT';
}
