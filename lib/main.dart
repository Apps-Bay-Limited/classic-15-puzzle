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
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    ThemeData applyDecor(ThemeData theme) {
      return theme.copyWith(
        dialogTheme: theme.dialogTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          elevation: isIOS ? 0 : 6,
        ),
        cardTheme: theme.cardTheme.copyWith(
          elevation: isIOS ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: isIOS ? 0 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textTheme: theme.textTheme.apply(fontFamily: 'ManRope'),
      );
    }

    final baseDarkTheme = applyDecor(ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xffA2907D),
        brightness: Brightness.dark,
        surface: const Color(0xFF121212),
      ),
    ));

    final baseLightTheme = applyDecor(ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xffA2907D),
        brightness: Brightness.light,
        surface: const Color(0xFFFDFCFB),
      ),
    ));

    ThemeData darkTheme;
    ThemeData lightTheme;
    if (ui?.useDarkTheme == true) {
      darkTheme = baseDarkTheme;
      lightTheme = baseDarkTheme;
    } else {
      darkTheme = baseLightTheme;
      lightTheme = baseLightTheme;
    }

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      darkTheme: darkTheme,
      theme: lightTheme,
      builder: (context, child) {
        return MediaQuery(
          // Ensure accessibility font scaling is respected but doesn't break layout
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.4,
            ),
          ),
          child: child!,
        );
      },
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

