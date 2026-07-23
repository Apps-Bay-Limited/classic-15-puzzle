import 'package:classic_15_puzzle/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum TileThemeId { classic, midnight, sunset, mint }

/// A sellable tile color palette. [TileThemeId.classic] is always free; the
/// rest unlock with the Theme Pack purchase (or are free on platforms where
/// there's no way to sell it — see [PurchaseService]). Display names are
/// localized separately (see `themeDisplayName` in sheets.dart) since this
/// model has no [BuildContext]/l10n access.
class TileTheme {
  final TileThemeId id;
  final Color backgroundColor;
  final Color textColor;

  const TileTheme({
    required this.id,
    required this.backgroundColor,
    required this.textColor,
  });

  static const classic = TileTheme(
    id: TileThemeId.classic,
    backgroundColor: AppColors.tileFill,
    textColor: AppColors.tileText,
  );

  static const midnight = TileTheme(
    id: TileThemeId.midnight,
    backgroundColor: Color(0xFF3B4B6B),
    textColor: Color(0xFFE8ECF5),
  );

  static const sunset = TileTheme(
    id: TileThemeId.sunset,
    backgroundColor: Color(0xFFE8664A),
    textColor: Color(0xFFFFF3EC),
  );

  static const mint = TileTheme(
    id: TileThemeId.mint,
    backgroundColor: Color(0xFF7FC7A4),
    textColor: Color(0xFF1E3D30),
  );

  static const List<TileTheme> all = [classic, midnight, sunset, mint];

  static TileTheme byId(TileThemeId id) =>
      all.firstWhere((theme) => theme.id == id, orElse: () => classic);
}
