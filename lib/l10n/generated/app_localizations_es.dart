// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Puzzle Clásico 15';

  @override
  String get close => 'CERRAR';

  @override
  String tileLabel(String number) {
    return 'Ficha $number';
  }

  @override
  String get emptyTileLabel => 'Espacio vacío';

  @override
  String get hallOfFameTitle => 'Salón de la fama';

  @override
  String gridSizeLabel(String size) {
    return '${size}x$size';
  }

  @override
  String gridSizeSemanticsLabel(String size) {
    return 'Cuadrícula ${size}x$size';
  }

  @override
  String gridSizeSelectedSemanticsLabel(String size) {
    return 'Cuadrícula ${size}x$size, seleccionada';
  }

  @override
  String get noGamesYet => 'Aún no hay partidas';

  @override
  String get solveToSeeRecords =>
      'Resuelve un rompecabezas para ver tus récords aquí';

  @override
  String get bestTimeLabel => 'MEJOR TIEMPO';

  @override
  String get minMovesLabel => 'MENOS MOVIMIENTOS';

  @override
  String get noDataPlaceholder => '--';

  @override
  String get recentLogLabel => 'REGISTRO RECIENTE';

  @override
  String recentLogTimestamp(
      String day, String month, String hour, String minute) {
    return '$day/$month $hour:$minute';
  }

  @override
  String movesCount(String steps) {
    return '$steps movimientos';
  }

  @override
  String get photoLoadFailedMessage =>
      'No se pudo cargar esa foto guardada. Se volvió al tema Clásico.';

  @override
  String get productNameRemoveAds => 'Eliminar anuncios';

  @override
  String get productNameGeneric => 'Esa compra';

  @override
  String get storeUnavailableMessage =>
      'La App Store no está disponible en este momento. Inténtalo de nuevo más tarde.';

  @override
  String productUnavailableMessage(String productName) {
    return '$productName no está disponible en este momento. Inténtalo de nuevo más tarde.';
  }

  @override
  String get purchasePendingMessage =>
      'Tu compra está pendiente de aprobación.';

  @override
  String get purchaseCancelledMessage => 'Compra cancelada.';

  @override
  String get purchaseFailedMessage => 'La compra falló. Inténtalo de nuevo.';

  @override
  String get removeAdsPurchaseSuccessMessage =>
      '¡Anuncios eliminados. Gracias por tu apoyo!';

  @override
  String get rewardedAdUnavailableMessage =>
      'El anuncio no está disponible en este momento. Inténtalo de nuevo pronto.';

  @override
  String get rewardedAdDismissedMessage =>
      'Mira el anuncio completo para desbloquear los temas y el modo foto.';

  @override
  String get themesUnlockedMessage =>
      '¡Temas y modo foto desbloqueados! Disfrútalos.';

  @override
  String alreadyOwnedMessage(String productName) {
    return 'Ya tienes $productName.';
  }

  @override
  String restoreSuccessMessage(String productName) {
    return '$productName restaurado.';
  }

  @override
  String get restoreEmptyMessage =>
      'No se encontró ninguna compra anterior para restaurar.';

  @override
  String get restoreFailedMessage =>
      'La restauración falló. Inténtalo de nuevo.';

  @override
  String get gameAppBarTitle => 'Clásico 15';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get timeLabel => 'TIEMPO';

  @override
  String get movesLabel => 'MOVIMIENTOS';

  @override
  String get hintTooltip => 'Pista';

  @override
  String get undoTooltip => 'Deshacer';

  @override
  String get pauseTooltip => 'Pausa';

  @override
  String get resumeTooltip => 'Reanudar';

  @override
  String get pausedTapToResumeLabel => 'En pausa: toca para reanudar';

  @override
  String get newGameTooltip => 'Nueva partida';

  @override
  String get settingsSubtitle => 'Personaliza tu experiencia de rompecabezas';

  @override
  String get gridSizeSectionHeader => 'TAMAÑO DE CUADRÍCULA';

  @override
  String get darkModeLabel => 'Modo oscuro';

  @override
  String get speedRunModeLabel => 'Modo velocidad';

  @override
  String get speedRunModeSubtitle =>
      'Animaciones más rápidas, movimiento solo con toques';

  @override
  String get speedRunModeInfoTooltip => 'Acerca del modo velocidad';

  @override
  String get speedRunModeExplanation =>
      'En el modo velocidad, toca cualquier ficha para deslizarla hacia el espacio vacío; no es necesario tocar solo las fichas directamente adyacentes. Las animaciones también son más rápidas, para que resuelvas el rompecabezas lo más rápido posible.';

  @override
  String get soundEffectsLabel => 'Efectos de sonido';

  @override
  String get adsRemovedTitle => 'Anuncios eliminados';

  @override
  String get adsRemovedSubtitle => '¡Gracias por apoyar la aplicación!';

  @override
  String get removeAdsTitle => 'Eliminar anuncios';

  @override
  String get removeAdsSubtitle =>
      'Elimina los anuncios de esta aplicación de forma permanente.';

  @override
  String get restorePurchasesTitle => 'Restaurar compras';

  @override
  String get unavailableLabel => 'No disponible';

  @override
  String get themesSectionHeader => 'TEMAS';

  @override
  String get unlockThemesTitle => 'Desbloquear temas';

  @override
  String get unlockThemesSubtitle =>
      'Paletas adicionales + modo de rompecabezas con foto.';

  @override
  String get photoModeTitle => 'Modo foto';

  @override
  String get photoModeSubtitle => 'Convierte una foto en tu rompecabezas.';

  @override
  String themeSwatchLabel(String themeName) {
    return 'Tema $themeName';
  }

  @override
  String themeSwatchLockedLabel(String themeName) {
    return 'Tema $themeName, bloqueado';
  }

  @override
  String get themeNameClassic => 'Clásico';

  @override
  String get themeNameMidnight => 'Medianoche';

  @override
  String get themeNameSunset => 'Atardecer';

  @override
  String get themeNameMint => 'Menta';

  @override
  String get tutorialStep1Title => 'Desliza para resolver';

  @override
  String get tutorialStep1Description =>
      'Toca una ficha junto al espacio vacío para deslizarla a su lugar. Ordena todas las fichas para ganar.';

  @override
  String get tutorialStep2Title => '¿Atascado? Obtén una pista';

  @override
  String get tutorialStep2Description =>
      'Toca el botón de pista en cualquier momento para ver el mejor movimiento siguiente.';

  @override
  String get tutorialStep3Title => 'Hazlo a tu manera';

  @override
  String get tutorialStep3Description =>
      'Abre Ajustes para cambiar el tamaño de la cuadrícula, los temas, el sonido y más.';

  @override
  String get skipButton => 'OMITIR';

  @override
  String get nextButton => 'SIGUIENTE';

  @override
  String get getStartedButton => 'EMPEZAR';

  @override
  String get shareButton => 'COMPARTIR';

  @override
  String shareText(String size, String time, String steps) {
    return '¡Resolví el Puzzle Clásico 15 en ${size}x$size en $time con $steps movimientos!';
  }

  @override
  String get rankingsButton => 'CLASIFICACIÓN';

  @override
  String get victoryTitle => '¡Magnífico!';

  @override
  String victoryDescription(String size) {
    return 'Completaste el rompecabezas ${size}x$size en un tiempo récord.';
  }

  @override
  String get advertisementLabel => 'PUBLICIDAD';
}
