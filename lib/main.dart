import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/play_games.dart';
import 'package:classic_15_puzzle/theme/app_theme.dart';
import 'package:classic_15_puzzle/utils/platform.dart';
import 'package:classic_15_puzzle/widgets/game/page.dart';
import 'package:classic_15_puzzle/widgets/util/ads_manager.dart';
import 'package:classic_15_puzzle/widgets/util/in_app_reviewer_helper.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  _setTargetPlatformForDesktop();

  WidgetsFlutterBinding.ensureInitialized();

  // Fast local read so a purchased user's cold start never spins up the ads
  // SDK in the first place. The real entitlement is reconciled with the
  // store shortly after, once PurchaseContainer mounts.
  final adsRemoved = await readCachedAdsRemoved();

  if (!adsRemoved) {
    await AdsManager.initialize();
    MobileAds.instance.initialize();

    Future.delayed(const Duration(seconds: 1), () {
      AppTrackingTransparency.requestTrackingAuthorization();
    });

    AdsManager.debugPrintID();
  }

  InAppReviewHelper.checkAndAskForReview();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      const PurchaseContainer(
        child: PlayGamesContainer(
          child: ConfigUiContainer(
            child: MyApp(),
          ),
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
    return const _MyMaterialApp();
  }
}

/// Base class for all platforms, such as
/// [Platform.isIOS] or [Platform.isAndroid].
abstract class _MyPlatformApp extends StatelessWidget {
  const _MyPlatformApp();
}

class _MyMaterialApp extends _MyPlatformApp {
  const _MyMaterialApp();

  @override
  Widget build(BuildContext context) {
    final ui = ConfigUiContainer.of(context);
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    final lightTheme = AppTheme.applyPlatformDecor(AppTheme.light(), isIOS: isIOS);
    final darkTheme = AppTheme.applyPlatformDecor(AppTheme.dark(), isIOS: isIOS);

    final ThemeMode themeMode;
    if (ui?.useDarkTheme == null) {
      themeMode = ThemeMode.system;
    } else {
      themeMode = ui!.useDarkTheme! ? ThemeMode.dark : ThemeMode.light;
    }

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 2.0,
            ),
          ),
          child: child!,
        );
      },
      home: Builder(
        builder: (context) {
          final brightness = Theme.of(context).brightness;
          final overlay = brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark;
          SystemChrome.setSystemUIOverlayStyle(
            overlay.copyWith(statusBarColor: Colors.transparent),
          );
          return const GamePage();
        },
      ),
    );
  }
}
