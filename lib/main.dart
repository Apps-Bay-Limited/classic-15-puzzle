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
import 'package:classic_15_puzzle/widgets/util/theme_unlock_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  _setTargetPlatformForDesktop();

  WidgetsFlutterBinding.ensureInitialized();

  // The ads SDK is always initialized, even for Remove Ads purchasers —
  // rewarded ads (used to unlock themes/photo mode) are opt-in and offered
  // regardless of that purchase; only the banner/interstitial/app-open ad
  // surfaces are skipped for them, gated separately at their call sites.
  await AdsManager.initialize();
  MobileAds.instance.initialize();

  Future.delayed(const Duration(seconds: 1), () {
    AppTrackingTransparency.requestTrackingAuthorization();
  });

  AdsManager.debugPrintID();

  InAppReviewHelper.checkAndAskForReview();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      const PurchaseContainer(
        child: ThemeUnlockContainer(
          child: PlayGamesContainer(
            child: ConfigUiContainer(
              child: MyApp(),
            ),
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
      // Status bar styling is set declaratively on GameMaterialPage's AppBar
      // (via systemOverlayStyle) instead of imperatively here — an
      // AppBar's own overlay-style region always wins over an ancestor's,
      // so setting it here as well was fragile and got silently overridden.
      home: const GamePage(),
    );
  }
}
