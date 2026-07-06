import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/play_games.dart';
import 'package:classic_15_puzzle/utils/platform.dart';
import 'package:classic_15_puzzle/widgets/game/page.dart';
import 'package:classic_15_puzzle/widgets/util/ads_manager.dart';
import 'package:classic_15_puzzle/widgets/util/in_app_reviewer_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  _setTargetPlatformForDesktop();

  WidgetsFlutterBinding.ensureInitialized();

  await AdsManager.initialize();
  MobileAds.instance.initialize();

  Future.delayed(const Duration(seconds: 1), () {
    AppTrackingTransparency.requestTrackingAuthorization();
  });

  AdsManager.debugPrintID();

  InAppReviewHelper.checkAndAskForReview();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      const PlayGamesContainer(
        child: ConfigUiContainer(
          child: MyApp(),
        ),
      ),
    );
  });
}

/// If the current platform is desktop, override the default platform to
/// a supported platform (iOS for macOS, Android for Linux and Windows).
/// Otherwise, do nothing.
void _setTargetPlatformForDesktop() {
  TargetPlatform? targetPlatform;
  if (platformCheck(() => Platform.isMacOS)) {
    targetPlatform = TargetPlatform.iOS;
  } else if (platformCheck(() => Platform.isLinux || Platform.isWindows)) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Classic 15 Puzzle';
    return const _MyMaterialApp(title: title);
  }
}

/// Base class for all platforms, such as
/// [Platform.isIOS] or [Platform.isAndroid].
abstract class _MyPlatformApp extends StatelessWidget {
  final String title;

  const _MyPlatformApp({required this.title});
}

class _MyMaterialApp extends _MyPlatformApp {
  const _MyMaterialApp({required super.title});

  @override
  Widget build(BuildContext context) {
    final ui = ConfigUiContainer.of(context);

    ThemeData applyDecor(ThemeData theme) => theme.copyWith(
          primaryColor: Colors.blue,
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          ),
          textTheme: theme.textTheme.apply(fontFamily: 'ManRope'),
          primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'ManRope'),
          colorScheme: theme.colorScheme.copyWith(secondary: Colors.amberAccent),
        );

    final baseDarkTheme = applyDecor(ThemeData(
      brightness: Brightness.dark,
      canvasColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      colorScheme: const ColorScheme.dark().copyWith(surface: const Color(0xFF121212)),
    ));
    final baseLightTheme = applyDecor(ThemeData.light());

    ThemeData darkTheme;
    ThemeData lightTheme;
    if (ui?.useDarkTheme == true) {
      // dark
      darkTheme = baseDarkTheme;
      lightTheme = baseDarkTheme;
    } else {
      // light
      darkTheme = baseLightTheme;
      lightTheme = baseLightTheme;
    }

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      darkTheme: darkTheme,
      theme: lightTheme,
      home: Builder(
        builder: (context) {
          bool useDarkTheme;
          useDarkTheme = ui?.useDarkTheme ?? false;
          final overlay = useDarkTheme ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
          SystemChrome.setSystemUIOverlayStyle(
            overlay.copyWith(
              statusBarColor: Colors.transparent,
            ),
          );
          return const GamePage();
        },
      ),
    );
  }
}

