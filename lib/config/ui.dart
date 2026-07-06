import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the configuration of the
/// user interface.
class ConfigUiContainer extends StatefulWidget {
  final Widget child;

  const ConfigUiContainer({super.key, required this.child});

  static ConfigUiContainerState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        ?.data;
  }

  @override
  ConfigUiContainerState createState() => ConfigUiContainerState();
}

class ConfigUiContainerState extends State<ConfigUiContainer> {
  static const _defaultUseDarkTheme = null;
  static const _defaultSpeedRunModeEnabled = false;
  static const _keyUseDarkTheme = 'ui::dark_theme_enabled';
  static const _keySpeedRunModeEnabled = 'ui::speed_run_mode_enabled';

  /// `true` if the app uses a global dark theme,
  /// `false` otherwise.
  bool? useDarkTheme;

  bool isSpeedRunModeEnabled = _defaultSpeedRunModeEnabled;

  @override
  void initState() {
    super.initState();
    useDarkTheme = _defaultUseDarkTheme;

    _loadPreferences();
  }

  void _loadPreferences() async {
    late SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } on Exception {
      return;
    }
    _loadThemePreferences(prefs);
    _loadSpeedRunPreferences(prefs);
  }

  void _loadThemePreferences(final SharedPreferences prefs) {
    final useDarkTheme = prefs.getBool(_keyUseDarkTheme);
    setUseDarkTheme(useDarkTheme);
  }

  void _loadSpeedRunPreferences(final SharedPreferences prefs) {
    final isSpeedRunModeEnabled = prefs.getBool(_keySpeedRunModeEnabled) ??
        this.isSpeedRunModeEnabled;
    setSpeedRunModeEnabled(isSpeedRunModeEnabled);
  }

  /// Sets if user want app to show up in a dark theme or
  /// a white theme.
  void setUseDarkTheme(final bool? useDarkTheme,
      {final bool save = false}) async {
    // Save the choice if we
    // want to.
    if (save && useDarkTheme != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(_keyUseDarkTheme, useDarkTheme);
      } on Exception {
        // Ignored
      }
    }

    setState(() {
      this.useDarkTheme = useDarkTheme;
    });
  }

  void setSpeedRunModeEnabled(final bool isEnabled,
      {final bool save = false}) async {
    // Save the choice if we
    // want to.
    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(_keySpeedRunModeEnabled, isEnabled);
      } on Exception {
        // Ignored
      }
    }

    setState(() {
      isSpeedRunModeEnabled = isEnabled;
    });
  }

  // So the WidgetTree is actually
  // AppStateContainer --> InheritedStateContainer --> The rest of an app.
  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final ConfigUiContainerState data;

  const _InheritedStateContainer({
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
