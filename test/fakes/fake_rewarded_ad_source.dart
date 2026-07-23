import 'package:classic_15_puzzle/widgets/util/ads_manager.dart';
import 'package:flutter/foundation.dart';

/// Controllable test double for [RewardedAdSource]. Never touches the real
/// ads SDK — tests drive availability/reward outcome directly.
class FakeRewardedAdSource implements RewardedAdSource {
  FakeRewardedAdSource({bool isAdAvailable = true})
      : _isAdAvailable = isAdAvailable;

  bool _isAdAvailable;

  /// Controls whether the next [showAdIfAvailable] call reports the reward
  /// as earned before closing.
  bool nextShowEarnsReward = true;

  int loadAdCallCount = 0;
  int showAdCallCount = 0;
  int disposeCallCount = 0;

  @override
  bool get isAdAvailable => _isAdAvailable;

  void setIsAdAvailable(bool value) {
    _isAdAvailable = value;
  }

  @override
  void loadAd() {
    loadAdCallCount++;
  }

  @override
  void dispose() {
    disposeCallCount++;
  }

  @override
  void showAdIfAvailable({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) {
    showAdCallCount++;
    if (nextShowEarnsReward) {
      onUserEarnedReward();
    }
    onAdClosed?.call();
  }
}
