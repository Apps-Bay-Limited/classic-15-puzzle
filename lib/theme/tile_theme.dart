import 'package:classic_15_puzzle/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum TileThemeId { classic, midnight, sunset, mint }

/// A sellable tile color palette. [TileThemeId.classic] is always free; the
/// rest unlock with the Theme Pack purchase (or are free on platforms where
/// there's no way to sell it — see [PurchaseService]). Display names are
/// localized separately (see `themeDisplayName` in sheets.dart) since this
/// model has no [BuildContext]/l10n access.
///
/// Each palette is a single [color]. A tile in its solved position fills
/// solid with [color] and a white number; any other tile shows a light wash
/// of [color] ([unmatchedBackground]) with [color] as the number — see
/// `ChipWidget`/`BoardWidget._tileColors`.
class TileTheme {
  final TileThemeId id;
  final Color color;

  const TileTheme({
    required this.id,
    required this.color,
  });

  static const classic = TileTheme(
    id: TileThemeId.classic,
    color: AppColors.tileFill,
  );

  static const midnight = TileTheme(
    id: TileThemeId.midnight,
    color: Color(0xFF3B4B6B),
  );

  static const sunset = TileTheme(
    id: TileThemeId.sunset,
    color: Color(0xFFE8664A),
  );

  static const mint = TileTheme(
    id: TileThemeId.mint,
    color: Color(0xFF3F8F68),
  );

  static const List<TileTheme> all = [classic, midnight, sunset, mint];

  static TileTheme byId(TileThemeId id) =>
      all.firstWhere((theme) => theme.id == id, orElse: () => classic);

  /// Light wash used for a tile that isn't in its solved position yet. Left
  /// translucent so `ChipWidget` alpha-blends it over the ambient Material
  /// surface color, which already adapts to light/dark mode.
  Color get unmatchedBackground => color.withValues(alpha: 0.16);
}
