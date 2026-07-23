import 'package:classic_15_puzzle/theme/tile_theme.dart';
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
  static const _defaultSoundEnabled = true;
  static const _defaultHasSeenTutorial = false;
  static const _defaultTileThemeId = TileThemeId.classic;
  static const _defaultPhotoModeEnabled = false;
  static const _defaultPhotoFilename = null;

  static const _keyUseDarkTheme = 'ui::dark_theme_enabled';
  static const _keySpeedRunModeEnabled = 'ui::speed_run_mode_enabled';
  static const _keySoundEnabled = 'ui::sound_enabled';
  static const _keyHasSeenTutorial = 'ui::has_seen_tutorial';
  static const _keyTileThemeId = 'ui::tile_theme_id';
  static const _keyPhotoModeEnabled = 'ui::photo_mode_enabled';
  static const _keyPhotoFilename = 'ui::photo_mode_filename';

  /// `true` if the app uses a global dark theme,
  /// `false` otherwise.
  bool? useDarkTheme;

  bool isSpeedRunModeEnabled = _defaultSpeedRunModeEnabled;

  bool isSoundEnabled = _defaultSoundEnabled;

  bool hasSeenTutorial = _defaultHasSeenTutorial;

  /// The currently selected tile palette. Selection only — whether it may
  /// actually be rendered (i.e. is owned) is checked at the render call
  /// site, never trusted from this persisted value alone.
  TileThemeId selectedTileThemeId = _defaultTileThemeId;

  bool isPhotoModeEnabled = _defaultPhotoModeEnabled;

  /// Filename (not a full path — app container paths can change across
  /// updates/reinstalls) of the saved photo-mode image under the app's
  /// documents directory, or `null` if none has been picked yet.
  String? photoFilename = _defaultPhotoFilename;

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
    _loadSoundPreferences(prefs);
    _loadTutorialPreferences(prefs);
    _loadTilePalettePreferences(prefs);
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

  void _loadSoundPreferences(final SharedPreferences prefs) {
    final isSoundEnabled =
        prefs.getBool(_keySoundEnabled) ?? this.isSoundEnabled;
    setSoundEnabled(isSoundEnabled);
  }

  void _loadTutorialPreferences(final SharedPreferences prefs) {
    final hasSeenTutorial =
        prefs.getBool(_keyHasSeenTutorial) ?? this.hasSeenTutorial;
    setHasSeenTutorial(hasSeenTutorial);
  }

  void _loadTilePalettePreferences(final SharedPreferences prefs) {
    final storedId = prefs.getString(_keyTileThemeId);
    final tileThemeId = TileThemeId.values.firstWhere(
      (id) => id.name == storedId,
      orElse: () => selectedTileThemeId,
    );
    setSelectedTileTheme(tileThemeId);

    final isPhotoModeEnabled =
        prefs.getBool(_keyPhotoModeEnabled) ?? this.isPhotoModeEnabled;
    final storedPhotoFilename =
        prefs.getString(_keyPhotoFilename) ?? photoFilename;
    setPhotoMode(isPhotoModeEnabled, filename: storedPhotoFilename);
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

  void setSoundEnabled(final bool isEnabled, {final bool save = false}) async {
    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(_keySoundEnabled, isEnabled);
      } on Exception {
        // Ignored
      }
    }

    setState(() {
      isSoundEnabled = isEnabled;
    });
  }

  void setHasSeenTutorial(final bool hasSeen, {final bool save = false}) async {
    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(_keyHasSeenTutorial, hasSeen);
      } on Exception {
        // Ignored
      }
    }

    setState(() {
      hasSeenTutorial = hasSeen;
    });
  }

  /// Selects a tile palette. Also turns off photo mode, since the two are
  /// mutually exclusive display modes.
  void setSelectedTileTheme(final TileThemeId id, {final bool save = false}) async {
    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(_keyTileThemeId, id.name);
        prefs.setBool(_keyPhotoModeEnabled, false);
      } on Exception {
        // Ignored
      }
    }

    setState(() {
      selectedTileThemeId = id;
      isPhotoModeEnabled = false;
    });
  }

  /// Enables/disables photo mode. When enabling, [filename] must be the
  /// saved photo's filename (see [photoFilename]); when disabling, the
  /// filename is left as-is so the same photo can be re-enabled later
  /// without re-picking.
  void setPhotoMode(
    final bool isEnabled, {
    final String? filename,
    final bool save = false,
  }) async {
    if (save) {
      try {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(_keyPhotoModeEnabled, isEnabled);
        if (filename != null) {
          prefs.setString(_keyPhotoFilename, filename);
        }
      } on Exception {
        // Ignored
      }
    }

    setState(() {
      isPhotoModeEnabled = isEnabled;
      photoFilename = filename ?? photoFilename;
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
