// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Puzzle Classique 15';

  @override
  String get close => 'FERMER';

  @override
  String tileLabel(String number) {
    return 'Tuile $number';
  }

  @override
  String get emptyTileLabel => 'Case vide';

  @override
  String get hallOfFameTitle => 'Tableau d\'honneur';

  @override
  String gridSizeLabel(String size) {
    return '${size}x$size';
  }

  @override
  String gridSizeSemanticsLabel(String size) {
    return 'Grille ${size}x$size';
  }

  @override
  String gridSizeSelectedSemanticsLabel(String size) {
    return 'Grille ${size}x$size, sélectionnée';
  }

  @override
  String get noGamesYet => 'Aucune partie pour l\'instant';

  @override
  String get solveToSeeRecords =>
      'Résolvez un puzzle pour voir vos records ici';

  @override
  String get bestTimeLabel => 'MEILLEUR TEMPS';

  @override
  String get minMovesLabel => 'MOINS DE COUPS';

  @override
  String get noDataPlaceholder => '--';

  @override
  String get recentLogLabel => 'HISTORIQUE RÉCENT';

  @override
  String recentLogTimestamp(
      String day, String month, String hour, String minute) {
    return '$day/$month $hour:$minute';
  }

  @override
  String movesCount(String steps) {
    return '$steps coups';
  }

  @override
  String get photoLoadFailedMessage =>
      'Impossible de charger cette photo enregistrée. Retour au thème Classique.';

  @override
  String get productNameRemoveAds => 'Suppression des pubs';

  @override
  String get productNameGeneric => 'Cet achat';

  @override
  String get storeUnavailableMessage =>
      'L\'App Store est actuellement indisponible. Veuillez réessayer plus tard.';

  @override
  String productUnavailableMessage(String productName) {
    return '$productName n\'est pas disponible pour le moment. Veuillez réessayer plus tard.';
  }

  @override
  String get purchasePendingMessage =>
      'Votre achat est en attente d\'approbation.';

  @override
  String get purchaseCancelledMessage => 'Achat annulé.';

  @override
  String get purchaseFailedMessage => 'Échec de l\'achat. Veuillez réessayer.';

  @override
  String get removeAdsPurchaseSuccessMessage =>
      'Publicités supprimées. Merci pour votre soutien !';

  @override
  String get rewardedAdUnavailableMessage =>
      'Publicité indisponible pour le moment. Veuillez réessayer bientôt.';

  @override
  String get rewardedAdDismissedMessage =>
      'Regardez la publicité jusqu\'au bout pour débloquer les thèmes et le mode photo.';

  @override
  String get themesUnlockedMessage =>
      'Thèmes et mode photo débloqués. Profitez-en !';

  @override
  String alreadyOwnedMessage(String productName) {
    return 'Vous possédez déjà $productName.';
  }

  @override
  String restoreSuccessMessage(String productName) {
    return '$productName restauré.';
  }

  @override
  String get restoreEmptyMessage => 'Aucun achat précédent à restaurer.';

  @override
  String get restoreFailedMessage =>
      'Échec de la restauration. Veuillez réessayer.';

  @override
  String get gameAppBarTitle => 'Classique 15';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get timeLabel => 'TEMPS';

  @override
  String get movesLabel => 'COUPS';

  @override
  String get noRecordYetLabel => 'Aucun record — terminez pour en établir un';

  @override
  String get dailyChallengeTitle => 'Défi du jour';

  @override
  String get dailyChallengeDoneToday => 'Résolu aujourd\'hui ✓';

  @override
  String get dailyChallengeStartButton => 'COMMENCER';

  @override
  String get dailyChallengeReplayButton => 'REJOUER';

  @override
  String dailyChallengeDescription(int size) {
    return 'Tous les joueurs reçoivent la même grille ${size}x$size aujourd\'hui. Commencer remplacera votre partie en cours.';
  }

  @override
  String dailyStreakLabel(int streak, int best) {
    return 'Série : $streak · Record : $best';
  }

  @override
  String personalBestLabel(String time) {
    return 'Record $time';
  }

  @override
  String aheadOfBestLabel(String time) {
    return '$time d\'avance sur le record';
  }

  @override
  String behindBestLabel(String time) {
    return '$time de retard sur le record';
  }

  @override
  String get hintTooltip => 'Indice';

  @override
  String get undoTooltip => 'Annuler';

  @override
  String get outOfHintsTitle => 'Plus d\'indices';

  @override
  String get watchAdButton => 'REGARDER UNE PUB';

  @override
  String outOfHintsMessage(int count) {
    return 'Vous avez utilisé tous vos indices pour ce puzzle. Regardez une courte publicité pour en obtenir $count de plus.';
  }

  @override
  String hintsRefilledMessage(int count) {
    return '$count indices ajoutés.';
  }

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get resumeTooltip => 'Reprendre';

  @override
  String get pausedTapToResumeLabel => 'En pause — touchez pour reprendre';

  @override
  String get newGameTooltip => 'Nouvelle partie';

  @override
  String get settingsSubtitle => 'Personnalisez votre expérience de puzzle';

  @override
  String get gridSizeSectionHeader => 'TAILLE DE LA GRILLE';

  @override
  String get darkModeLabel => 'Mode sombre';

  @override
  String get speedRunModeLabel => 'Mode rapide';

  @override
  String get speedRunModeSubtitle =>
      'Animations plus rapides, déplacement au toucher uniquement';

  @override
  String get speedRunModeInfoTooltip => 'À propos du mode rapide';

  @override
  String get speedRunModeExplanation =>
      'En mode rapide, touchez n\'importe quelle tuile pour la faire glisser vers l\'espace vide — inutile de toucher uniquement les tuiles directement adjacentes. Les animations sont aussi plus rapides, pour résoudre le puzzle le plus vite possible.';

  @override
  String get soundEffectsLabel => 'Effets sonores';

  @override
  String get adsRemovedTitle => 'Publicités supprimées';

  @override
  String get adsRemovedSubtitle => 'Merci de soutenir l\'application !';

  @override
  String get removeAdsTitle => 'Suppression des pubs';

  @override
  String get removeAdsSubtitle =>
      'Supprimez définitivement les publicités de cette application.';

  @override
  String get restorePurchasesTitle => 'Restaurer les achats';

  @override
  String get unavailableLabel => 'Indisponible';

  @override
  String get themesSectionHeader => 'THÈMES';

  @override
  String get unlockThemesTitle => 'Débloquer les thèmes';

  @override
  String get unlockThemesSubtitle =>
      'Thèmes supplémentaires + mode puzzle photo.';

  @override
  String get photoModeTitle => 'Mode photo';

  @override
  String get photoModeSubtitle => 'Transformez une photo en puzzle.';

  @override
  String themeSwatchLabel(String themeName) {
    return 'Thème $themeName';
  }

  @override
  String themeSwatchLockedLabel(String themeName) {
    return 'Thème $themeName, verrouillé';
  }

  @override
  String get themeNameClassic => 'Classique';

  @override
  String get themeNameMidnight => 'Minuit';

  @override
  String get themeNameSunset => 'Coucher de soleil';

  @override
  String get themeNameMint => 'Menthe';

  @override
  String get tutorialStep1Title => 'Glissez pour résoudre';

  @override
  String get tutorialStep1Description =>
      'Touchez une tuile à côté de l\'espace vide pour la faire glisser. Rangez toutes les tuiles dans l\'ordre pour gagner.';

  @override
  String get tutorialStep2Title => 'Bloqué ? Obtenez un indice';

  @override
  String get tutorialStep2Description =>
      'Touchez le bouton d\'indice à tout moment pour voir le meilleur coup suivant.';

  @override
  String get tutorialStep3Title => 'Personnalisez votre expérience';

  @override
  String get tutorialStep3Description =>
      'Ouvrez les réglages pour changer la taille de la grille, les thèmes, le son et plus encore.';

  @override
  String get skipButton => 'PASSER';

  @override
  String get nextButton => 'SUIVANT';

  @override
  String get getStartedButton => 'COMMENCER';

  @override
  String get shareButton => 'PARTAGER';

  @override
  String shareText(String size, String time, String steps) {
    return 'J\'ai résolu le puzzle classique 15 en ${size}x$size en $time avec $steps coups !';
  }

  @override
  String get rankingsButton => 'CLASSEMENT';

  @override
  String get victoryTitle => 'Magnifique !';

  @override
  String victoryDescription(String size) {
    return 'Vous avez terminé le puzzle ${size}x$size en un temps record.';
  }

  @override
  String get advertisementLabel => 'PUBLICITÉ';
}
