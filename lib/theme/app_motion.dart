import 'package:flutter/material.dart';

/// Motion helpers that respect the system Reduce Motion setting.
abstract final class AppMotion {
  static bool disableAnimations(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  static Duration duration(BuildContext context, int milliseconds) {
    if (disableAnimations(context)) {
      return Duration.zero;
    }
    return Duration(milliseconds: milliseconds);
  }
}
