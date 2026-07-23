import 'package:flutter/material.dart';

/// Semantic color tokens for Classic 15 Puzzle.
abstract final class AppColors {
  static const seed = Color(0xffA2907D);
  static const lightSurface = Color(0xFFFDFCFB);
  static const darkSurface = Color(0xFF121212);
  static const splash = Color(0xFFFAFAFA);

  /// Distinctive puzzle tile palette — a deeper caramel than the original
  /// peach so white numbers stay legible when a tile fills solid on match.
  static const tileFill = Color(0xFFB8712F);

  /// Accent colors derived from the warm brand palette.
  static const accentGold = Color(0xFFFFB300);
  static const accentSlate = Color(0xFF607D8B);
}
