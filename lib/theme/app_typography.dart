import 'package:flutter/material.dart';

/// Typography helpers built on ManRope via [ThemeData.textTheme].
abstract final class AppTypography {
  static const String fontFamily = 'ManRope';

  /// Uppercase stat / section labels (MOVES, TIME, RECENT LOG).
  static TextStyle statLabel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.labelSmall!.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: colorScheme.outline,
        );
  }

  /// Compact uppercase labels inside accent cards.
  static TextStyle accentLabel(BuildContext context, Color color) {
    return statLabel(context).copyWith(fontSize: 9, color: color);
  }

  /// Primary stat values on cards and dialogs.
  static TextStyle statValue(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        );
  }

  /// Large stat values (victory dialog).
  static TextStyle statValueLarge(BuildContext context) {
    return statValue(context).copyWith(fontSize: 22);
  }

  /// Section headers inside scrollable content.
  static TextStyle sectionHeader(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!.copyWith(
          letterSpacing: 1.5,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.outline,
        );
  }

  /// App bar title.
  static TextStyle appBarTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w700,
        );
  }

  /// Dialog titles.
  static TextStyle dialogTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w800,
        );
  }
}
