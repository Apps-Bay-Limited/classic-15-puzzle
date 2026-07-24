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
import 'package:classic_15_puzzle/widgets/util/daily_challenge_container.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:classic_15_puzzle/widgets/util/theme_unlock_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  _setTargetPlatformForDesktop();

  WidgetsFlutterBinding.ensureInitialized();

  _requestConsentAndInitializeAds();

  InAppReviewHelper.checkAndAskForReview();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      const PurchaseContainer(
        child: ThemeUnlockContainer(
          child: DailyChallengeContainer(
            child: PlayGamesContainer(
              child: ConfigUiContainer(
                child: MyApp(),
              ),
            ),
          ),
        ),
      ),
    );
  });
}

/// Gathers UMP consent (required under GDPR before an ad request is made to
/// a user in the EEA/UK) and only initializes the Mobile Ads SDK — and
/// therefore allows any ad to load — once that's resolved. The SDK decides
/// internally whether a form is actually needed for this user; elsewhere in
/// the world this resolves immediately with no form shown.
void _requestConsentAndInitializeAds() {
  final consentInfo = ConsentInformation.instance;
  final params = ConsentRequestParameters(
    consentDebugSettings: kDebugMode
        ? ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea)
        : null,
  );
  consentInfo.requestConsentInfoUpdate(
    params,
    () {
      ConsentForm.loadAndShowConsentFormIfRequired((FormError? formError) {
        if (formError != null) {
          debugPrint(
              'Consent form error ${formError.errorCode}: ${formError.message}');
        }
        _initializeMobileAdsSdk();
      });
    },
    (FormError error) {
      debugPrint(
          'Consent info update failed ${error.errorCode}: ${error.message}');
      // Google's guidance: proceed with SDK init on failure rather than
      // blocking ads entirely — the SDK still applies its own defaults.
      _initializeMobileAdsSdk();
    },
  );
}

bool _mobileAdsInitialized = false;

/// The ads SDK is always initialized, even for Remove Ads purchasers —
/// rewarded ads (used to unlock themes/photo mode) are opt-in and offered
/// regardless of that purchase; only the banner/interstitial/app-open ad
/// surfaces are skipped for them, gated separately at their call sites.
void _initializeMobileAdsSdk() async {
  if (_mobileAdsInitialized) return;
  _mobileAdsInitialized = true;
  await AdsManager.initialize();
  MobileAds.instance.initialize();
  AdsManager.debugPrintID();
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Request ATT only once the first frame is actually on screen — calling
    // it from a bare timer in main() (the previous approach) races
    // independently of whether the app's window is truly key/active yet,
    // and iOS silently no-ops the request if it isn't. This was flagged by
    // App Review (Guideline 2.1): the prompt never appeared on a real
    // device, even though it worked fine in Simulator testing where launch
    // timing happens to be more forgiving.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {
        // A brief extra margin after the first frame, matching the
        // package's own recommended pattern, so the window has definitely
        // finished becoming key before the system dialog is requested.
        await Future.delayed(const Duration(milliseconds: 500));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    });
  }

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
