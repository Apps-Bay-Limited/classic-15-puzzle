import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/ad_config.dart';

class AdsManager {
  static bool disableAllAdsForScreenshot = false;
  static String? _bannerAdUnitId;
  static String? _openAdUnitID;
  static String? _interstitialAdUnitId;

  static Future<void> initialize() async {
    try {
      _bannerAdUnitId = await AdConfig.bannerAdUnitId;
      _openAdUnitID = await AdConfig.openAdUnitId;
      _interstitialAdUnitId = await AdConfig.interstitialAdUnitId;
    } catch (e) {
      debugPrint("AdsManager initialization failed: $e");
    }
    debugPrint("AdsManager initialized: banner=$_bannerAdUnitId, open=$_openAdUnitID, interstitial=$_interstitialAdUnitId");
  }

  static String get bannerAdUnitId {
    if (disableAllAdsForScreenshot) return "";
    return _bannerAdUnitId ?? "";
  }

  static String get openAdUnitID {
    if (disableAllAdsForScreenshot) return "";
    return _openAdUnitID ?? "";
  }

  static String get interstitialAdUnitId {
    if (disableAllAdsForScreenshot) return "";
    if (_interstitialAdUnitId != null && _interstitialAdUnitId!.isNotEmpty) {
      return _interstitialAdUnitId!;
    }
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/1033173712";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910";
    }
    return "";
  }

  static void debugPrintID() {
    debugPrint("bannerAdUnitId: ${AdsManager.bannerAdUnitId}");
    debugPrint("openAdUnitID: ${AdsManager.openAdUnitID}");
    debugPrint("interstitialAdUnitId: ${AdsManager.interstitialAdUnitId}");
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

  /// Disposes an already-loaded ad, e.g. when the ads-removed entitlement
  /// activates mid-session.
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _appOpenLoadTime = null;
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

  /// Consulted before showing an app open ad; return `true` while a
  /// purchase is in progress so we don't interrupt it with a full-screen ad.
  final bool Function()? isPurchaseInProgress;

  bool hasEnterBackground = false;

  AppLifecycleReactor({
    required this.appOpenAdManager,
    this.isPurchaseInProgress,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    // print("didChangeAppLifecycleState: $state");
    if (state == AppLifecycleState.paused) {
      hasEnterBackground = true;
    }
    if (state == AppLifecycleState.resumed && hasEnterBackground) {
      hasEnterBackground = false;
      if (isPurchaseInProgress?.call() ?? false) return;
      appOpenAdManager.showAdIfAvailable();
    }
  }
}

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isShowingAd = false;
  bool _isLoading = false;

  void loadAd() {
    if (_isLoading || _interstitialAd != null) return;
    _isLoading = true;

    final adUnitId = AdsManager.interstitialAdUnitId;
    if (adUnitId.isEmpty) {
      _isLoading = false;
      return;
    }

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded');
          _interstitialAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  bool get isAdAvailable => _interstitialAd != null;

  /// Disposes an already-loaded ad, e.g. when the ads-removed entitlement
  /// activates mid-session.
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  void showAdIfAvailable({VoidCallback? onAdClosed}) {
    if (!isAdAvailable) {
      debugPrint('Tried to show interstitial ad before available.');
      loadAd();
      onAdClosed?.call();
      return;
    }
    if (_isShowingAd) {
      debugPrint('Tried to show interstitial ad while already showing an ad.');
      onAdClosed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _interstitialAd = null;
        loadAd();
        onAdClosed?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _interstitialAd = null;
        loadAd();
        onAdClosed?.call();
      },
    );
    _interstitialAd!.show();
  }
}
