import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/play_games.dart';
import 'package:classic_15_puzzle/utils/platform.dart';
import 'package:classic_15_puzzle/widgets/game/page.dart';
import 'package:classic_15_puzzle/widgets/util/ads_manager.dart';
import 'package:classic_15_puzzle/widgets/util/in_app_reviewer_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  _setTargetPlatformForDesktop();

  WidgetsFlutterBinding.ensureInitialized();

  Future.delayed(const Duration(seconds: 1), () {
    AppTrackingTransparency.requestTrackingAuthorization();
  });

  MobileAds.instance.initialize();

  AdsManager.debugPrintID();

  InAppReviewHelper.checkAndAskForReview();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      PlayGamesContainer(
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
  TargetPlatform targetPlatform;
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
  @override
  Widget build(BuildContext context) {
    final title = 'Classic 15 Puzzle';
    return _MyMaterialApp(title: title);
  }
}

/// Base class for all platforms, such as
/// [Platform.isIOS] or [Platform.isAndroid].
abstract class _MyPlatformApp extends StatelessWidget {
  final String title;

  _MyPlatformApp({@required this.title});
}

class _MyMaterialApp extends _MyPlatformApp {
  _MyMaterialApp({@required String title}) : super(title: title);

  @override
  Widget build(BuildContext context) {
    final ui = ConfigUiContainer.of(context);

    ThemeData applyDecor(ThemeData theme) => theme.copyWith(
          primaryColor: Colors.blue,
          accentColor: Colors.amberAccent,
          accentIconTheme: theme.iconTheme.copyWith(color: Colors.black),
          dialogTheme: const DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
          ),
          textTheme: theme.textTheme.apply(fontFamily: 'ManRope'),
          primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'ManRope'),
          accentTextTheme: theme.accentTextTheme.apply(fontFamily: 'ManRope'),
        );

    final baseDarkTheme = applyDecor(ThemeData(
      brightness: Brightness.dark,
      canvasColor: Color(0xFF121212),
      backgroundColor: Color(0xFF121212),
      cardColor: Color(0xFF1E1E1E),
    ));
    final baseLightTheme = applyDecor(ThemeData.light());

    ThemeData darkTheme;
    ThemeData lightTheme;
    if (ui.useDarkTheme == null) {
      // auto
      darkTheme = baseDarkTheme;
      lightTheme = baseLightTheme;
    } else if (ui.useDarkTheme == true) {
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
          if (ui.useDarkTheme == null) {
            var platformBrightness = MediaQuery.of(context).platformBrightness;
            useDarkTheme = platformBrightness == Brightness.dark;
          } else {
            useDarkTheme = ui.useDarkTheme;
          }
          final overlay = useDarkTheme ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
          SystemChrome.setSystemUIOverlayStyle(
            overlay.copyWith(
              statusBarColor: Colors.transparent,
            ),
          );
          return GamePage();
        },
      ),
    );
  }
}

class _MyCupertinoApp extends _MyPlatformApp {
  _MyCupertinoApp({@required String title}) : super(title: title);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: title,
    );
  }
}
