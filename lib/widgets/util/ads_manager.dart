import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/ad_config.dart';

class AdsManager {
  static bool disableAllAdsForScreenshot = false;
  static String? _bannerAdUnitId;
  static String? _openAdUnitID;

  static Future<void> initialize() async {
    try {
      _bannerAdUnitId = await AdConfig.bannerAdUnitId;
      _openAdUnitID = await AdConfig.openAdUnitId;
    } catch (e) {
      debugPrint("AdsManager initialization failed: $e");
    }
    debugPrint("AdsManager initialized: banner=$_bannerAdUnitId, open=$_openAdUnitID");
  }

  static String get bannerAdUnitId {
    if (disableAllAdsForScreenshot) return "";
    return _bannerAdUnitId ?? "";
  }

  static String get openAdUnitID {
    if (disableAllAdsForScreenshot) return "";
    return _openAdUnitID ?? "";
  }

  static void debugPrintID() {
    debugPrint("bannerAdUnitId: ${AdsManager.bannerAdUnitId}");
    debugPrint("openAdUnitID: ${AdsManager.openAdUnitID}");
  }
}

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Maximum duration allowed between loading and showing the ad.
  static const Duration maxCacheDuration = Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  /// Load an AppOpenAd.
  void loadAd() {
    AppOpenAd.load(
      adUnitId: AdsManager.openAdUnitID,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAdIfAvailable() {
    if (!isAdAvailable) {
      debugPrint('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }
    if (_appOpenLoadTime != null && DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      debugPrint('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd?.dispose();
      _appOpenAd = null;
      loadAd();
      return;
    }

    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd?.show();
  }
}

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor extends WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;

  bool hasEnterBackground = false;

  AppLifecycleReactor({required this.appOpenAdManager});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    // print("didChangeAppLifecycleState: $state");
    if (state == AppLifecycleState.paused) {
      hasEnterBackground = true;
    }
    if (state == AppLifecycleState.resumed && hasEnterBackground) {
      appOpenAdManager.showAdIfAvailable();
      hasEnterBackground = false;
    }
  }
}
