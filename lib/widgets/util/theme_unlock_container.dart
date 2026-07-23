import 'dart:async';

import 'package:classic_15_puzzle/widgets/util/ads_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One-shot feedback events the UI should surface to the user after a
/// watch-ad-to-unlock attempt.
enum ThemeUnlockFeedback { adUnavailable, adDismissedWithoutReward, unlocked }

const String _prefsKeyUnlocked = 'theme_unlock::unlocked';

/// Exposes tile-theme/photo-mode unlock state to the widget tree, following
/// the same Container/InheritedWidget pattern as [PurchaseContainer] and
/// [ConfigUiContainer].
///
/// Unlocking here isn't a purchase — it's watching one rewarded ad to
/// completion, after which the entitlement is permanent (persisted locally,
/// same as the old Theme Pack IAP was), and it's offered on both platforms
/// and regardless of Remove Ads status, since a rewarded ad is opt-in.
class ThemeUnlockContainer extends StatefulWidget {
  final Widget child;

  /// Overrides the real ad-backed source, for tests to inject a fake.
  final RewardedAdSource? adSource;

  const ThemeUnlockContainer({super.key, required this.child, this.adSource});

  static ThemeUnlockContainerState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        ?.data;
  }

  @override
  ThemeUnlockContainerState createState() => ThemeUnlockContainerState();
}

class ThemeUnlockContainerState extends State<ThemeUnlockContainer> {
  late final RewardedAdSource _adSource =
      widget.adSource ?? RewardedAdManager();

  bool _isUnlocked = false;
  bool _isShowingAd = false;

  final _feedbackController =
      StreamController<ThemeUnlockFeedback>.broadcast();

  bool get isUnlocked => _isUnlocked;

  bool get isAdAvailable => _adSource.isAdAvailable;

  bool get isShowingAd => _isShowingAd;

  Stream<ThemeUnlockFeedback> get feedback => _feedbackController.stream;

  @override
  void initState() {
    super.initState();
    _loadPersisted();
  }

  Future<void> _loadPersisted() async {
    var unlocked = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      unlocked = prefs.getBool(_prefsKeyUnlocked) ?? false;
    } on Exception {
      // Ignored — stays locked, the cautious default.
    }

    if (mounted) {
      setState(() => _isUnlocked = unlocked);
    } else {
      _isUnlocked = unlocked;
    }

    if (!unlocked) {
      _adSource.loadAd();
    }
  }

  /// Shows the rewarded ad; grants and persists the unlock only if the user
  /// watches to completion (reward actually earned).
  Future<void> watchAdToUnlock() async {
    if (_isUnlocked || _isShowingAd) return;

    if (!_adSource.isAdAvailable) {
      _adSource.loadAd();
      _emit(ThemeUnlockFeedback.adUnavailable);
      return;
    }

    setState(() => _isShowingAd = true);
    var earnedReward = false;

    _adSource.showAdIfAvailable(
      onUserEarnedReward: () {
        earnedReward = true;
      },
      onAdClosed: () async {
        if (mounted) {
          setState(() => _isShowingAd = false);
        } else {
          _isShowingAd = false;
        }

        if (earnedReward) {
          await _grantUnlock();
        } else {
          _emit(ThemeUnlockFeedback.adDismissedWithoutReward);
        }
      },
    );
  }

  Future<void> _grantUnlock() async {
    if (mounted) {
      setState(() => _isUnlocked = true);
    } else {
      _isUnlocked = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKeyUnlocked, true);
    } on Exception {
      // Ignored — the in-memory unlock still applies for this session.
    }

    _emit(ThemeUnlockFeedback.unlocked);
  }

  void _emit(ThemeUnlockFeedback event) {
    if (!_feedbackController.isClosed) {
      _feedbackController.add(event);
    }
  }

  /// Debug-only: clears the locally persisted unlock so QA can re-test the
  /// watch-ad flow without reinstalling. Mirrors [PurchaseContainerState.
  /// resetForDebug] — callers must gate the UI for this behind `kDebugMode`;
  /// this method also no-ops in release as a safeguard.
  Future<void> resetForDebug() async {
    if (!kDebugMode) return;

    setState(() => _isUnlocked = false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKeyUnlocked);
    } on Exception {
      // Ignored
    }
    _adSource.loadAd();
  }

  @override
  void dispose() {
    _adSource.dispose();
    _feedbackController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final ThemeUnlockContainerState data;

  const _InheritedStateContainer({
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
