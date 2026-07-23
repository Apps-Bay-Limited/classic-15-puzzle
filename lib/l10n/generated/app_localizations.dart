import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// The app's display name.
  ///
  /// In en, this message translates to:
  /// **'Classic 15 Puzzle'**
  String get appTitle;

  /// Button that closes a dialog.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get close;

  /// Accessibility label for a numbered puzzle tile.
  ///
  /// In en, this message translates to:
  /// **'Tile {number}'**
  String tileLabel(String number);

  /// No description provided for @emptyTileLabel.
  ///
  /// In en, this message translates to:
  /// **'Empty tile'**
  String get emptyTileLabel;

  /// Title of the Hall of Fame dialog, and the tooltip on the button that opens it.
  ///
  /// In en, this message translates to:
  /// **'Hall of Fame'**
  String get hallOfFameTitle;

  /// Compact grid-size label, e.g. 4x4.
  ///
  /// In en, this message translates to:
  /// **'{size}x{size}'**
  String gridSizeLabel(String size);

  /// Accessibility label for a grid-size selector tile.
  ///
  /// In en, this message translates to:
  /// **'{size}x{size} grid'**
  String gridSizeSemanticsLabel(String size);

  /// Accessibility label for the currently selected grid-size tile.
  ///
  /// In en, this message translates to:
  /// **'{size}x{size} grid, selected'**
  String gridSizeSelectedSemanticsLabel(String size);

  /// No description provided for @noGamesYet.
  ///
  /// In en, this message translates to:
  /// **'No games yet'**
  String get noGamesYet;

  /// No description provided for @solveToSeeRecords.
  ///
  /// In en, this message translates to:
  /// **'Solve a puzzle to see your records here'**
  String get solveToSeeRecords;

  /// No description provided for @bestTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'BEST TIME'**
  String get bestTimeLabel;

  /// No description provided for @minMovesLabel.
  ///
  /// In en, this message translates to:
  /// **'MIN MOVES'**
  String get minMovesLabel;

  /// No description provided for @noDataPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get noDataPlaceholder;

  /// No description provided for @recentLogLabel.
  ///
  /// In en, this message translates to:
  /// **'RECENT LOG'**
  String get recentLogLabel;

  /// Compact date/time shown next to a recent result.
  ///
  /// In en, this message translates to:
  /// **'{day}/{month} {hour}:{minute}'**
  String recentLogTimestamp(
      String day, String month, String hour, String minute);

  /// Number of moves used to solve a puzzle.
  ///
  /// In en, this message translates to:
  /// **'{steps} moves'**
  String movesCount(String steps);

  /// No description provided for @photoLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'That saved photo couldn\'t be loaded. Switched back to Classic.'**
  String get photoLoadFailedMessage;

  /// No description provided for @productNameRemoveAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get productNameRemoveAds;

  /// No description provided for @productNameGeneric.
  ///
  /// In en, this message translates to:
  /// **'That purchase'**
  String get productNameGeneric;

  /// No description provided for @storeUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The App Store is unavailable right now. Please try again later.'**
  String get storeUnavailableMessage;

  /// No description provided for @productUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'{productName} is not available right now. Please try again later.'**
  String productUnavailableMessage(String productName);

  /// No description provided for @purchasePendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is pending approval.'**
  String get purchasePendingMessage;

  /// No description provided for @purchaseCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled.'**
  String get purchaseCancelledMessage;

  /// No description provided for @purchaseFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get purchaseFailedMessage;

  /// No description provided for @removeAdsPurchaseSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Ads removed. Thank you for your support!'**
  String get removeAdsPurchaseSuccessMessage;

  /// No description provided for @rewardedAdUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Ad not available right now. Please try again shortly.'**
  String get rewardedAdUnavailableMessage;

  /// No description provided for @rewardedAdDismissedMessage.
  ///
  /// In en, this message translates to:
  /// **'Watch the full ad to unlock themes and photo mode.'**
  String get rewardedAdDismissedMessage;

  /// No description provided for @themesUnlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Themes and photo mode unlocked. Enjoy!'**
  String get themesUnlockedMessage;

  /// No description provided for @alreadyOwnedMessage.
  ///
  /// In en, this message translates to:
  /// **'You already own {productName}.'**
  String alreadyOwnedMessage(String productName);

  /// No description provided for @restoreSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{productName} restored.'**
  String restoreSuccessMessage(String productName);

  /// No description provided for @restoreEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No previous purchase found to restore.'**
  String get restoreEmptyMessage;

  /// No description provided for @restoreFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. Please try again.'**
  String get restoreFailedMessage;

  /// No description provided for @gameAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Classic 15'**
  String get gameAppBarTitle;

  /// Title of the Settings sheet, and the tooltip on the button that opens it.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get timeLabel;

  /// No description provided for @movesLabel.
  ///
  /// In en, this message translates to:
  /// **'MOVES'**
  String get movesLabel;

  /// No description provided for @hintTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hintTooltip;

  /// No description provided for @undoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoTooltip;

  /// No description provided for @pauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTooltip;

  /// No description provided for @resumeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeTooltip;

  /// No description provided for @pausedTapToResumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused — tap to resume'**
  String get pausedTapToResumeLabel;

  /// No description provided for @newGameTooltip.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGameTooltip;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your puzzle experience'**
  String get settingsSubtitle;

  /// No description provided for @gridSizeSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'GRID SIZE'**
  String get gridSizeSectionHeader;

  /// No description provided for @darkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkModeLabel;

  /// No description provided for @speedRunModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed run mode'**
  String get speedRunModeLabel;

  /// No description provided for @speedRunModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Faster animations, tap-only tiles'**
  String get speedRunModeSubtitle;

  /// No description provided for @speedRunModeInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'About Speed run mode'**
  String get speedRunModeInfoTooltip;

  /// No description provided for @speedRunModeExplanation.
  ///
  /// In en, this message translates to:
  /// **'In Speed Run Mode, tap any tile to slide it toward the empty space — you don\'t need to tap only tiles directly next to it. Animations are faster too, so you can solve puzzles as quickly as possible.'**
  String get speedRunModeExplanation;

  /// No description provided for @soundEffectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffectsLabel;

  /// No description provided for @adsRemovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ads removed'**
  String get adsRemovedTitle;

  /// No description provided for @adsRemovedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting the app!'**
  String get adsRemovedSubtitle;

  /// No description provided for @removeAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAdsTitle;

  /// No description provided for @removeAdsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove ads permanently from this app.'**
  String get removeAdsSubtitle;

  /// No description provided for @restorePurchasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchasesTitle;

  /// No description provided for @unavailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailableLabel;

  /// No description provided for @themesSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'THEMES'**
  String get themesSectionHeader;

  /// No description provided for @unlockThemesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Themes'**
  String get unlockThemesTitle;

  /// No description provided for @unlockThemesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extra tile palettes + photo puzzle mode.'**
  String get unlockThemesSubtitle;

  /// No description provided for @photoModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Mode'**
  String get photoModeTitle;

  /// No description provided for @photoModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn a photo into your puzzle.'**
  String get photoModeSubtitle;

  /// No description provided for @themeSwatchLabel.
  ///
  /// In en, this message translates to:
  /// **'{themeName} theme'**
  String themeSwatchLabel(String themeName);

  /// No description provided for @themeSwatchLockedLabel.
  ///
  /// In en, this message translates to:
  /// **'{themeName} theme, locked'**
  String themeSwatchLockedLabel(String themeName);

  /// No description provided for @themeNameClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get themeNameClassic;

  /// No description provided for @themeNameMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get themeNameMidnight;

  /// No description provided for @themeNameSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get themeNameSunset;

  /// No description provided for @themeNameMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get themeNameMint;

  /// No description provided for @tutorialStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Slide to solve'**
  String get tutorialStep1Title;

  /// No description provided for @tutorialStep1Description.
  ///
  /// In en, this message translates to:
  /// **'Tap a tile next to the empty space to slide it into place. Arrange every tile in order to win.'**
  String get tutorialStep1Description;

  /// No description provided for @tutorialStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Stuck? Get a hint'**
  String get tutorialStep2Title;

  /// No description provided for @tutorialStep2Description.
  ///
  /// In en, this message translates to:
  /// **'Tap the hint button anytime to see the best next move.'**
  String get tutorialStep2Description;

  /// No description provided for @tutorialStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get tutorialStep3Title;

  /// No description provided for @tutorialStep3Description.
  ///
  /// In en, this message translates to:
  /// **'Open Settings to change the grid size, tile themes, sound, and more.'**
  String get tutorialStep3Description;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skipButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get nextButton;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStartedButton;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get shareButton;

  /// Text shared to the OS share sheet after winning.
  ///
  /// In en, this message translates to:
  /// **'I solved the Classic 15 Puzzle {size}x{size} in {time} with {steps} moves!'**
  String shareText(String size, String time, String steps);

  /// No description provided for @rankingsButton.
  ///
  /// In en, this message translates to:
  /// **'RANKINGS'**
  String get rankingsButton;

  /// No description provided for @victoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Magnificent!'**
  String get victoryTitle;

  /// No description provided for @victoryDescription.
  ///
  /// In en, this message translates to:
  /// **'You completed the {size}x{size} puzzle in record time.'**
  String victoryDescription(String size);

  /// No description provided for @advertisementLabel.
  ///
  /// In en, this message translates to:
  /// **'ADVERTISEMENT'**
  String get advertisementLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
