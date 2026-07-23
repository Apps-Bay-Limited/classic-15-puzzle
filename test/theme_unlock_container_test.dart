import 'package:classic_15_puzzle/widgets/util/theme_unlock_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_rewarded_ad_source.dart';

void main() {
  Widget wrap(FakeRewardedAdSource adSource, Widget child) {
    return MaterialApp(
      home: ThemeUnlockContainer(adSource: adSource, child: child),
    );
  }

  testWidgets('starts locked and loads an ad when nothing is persisted',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final adSource = FakeRewardedAdSource();
    late ThemeUnlockContainerState state;

    await tester.pumpWidget(
      wrap(adSource, Builder(builder: (context) {
        state = ThemeUnlockContainer.of(context)!;
        return const SizedBox.shrink();
      })),
    );
    await tester.pump();

    expect(state.isUnlocked, isFalse);
    expect(adSource.loadAdCallCount, 1);
  });

  testWidgets('starts unlocked when previously persisted, skips loading an ad',
      (tester) async {
    SharedPreferences.setMockInitialValues({'theme_unlock::unlocked': true});
    final adSource = FakeRewardedAdSource();
    late ThemeUnlockContainerState state;

    await tester.pumpWidget(
      wrap(adSource, Builder(builder: (context) {
        state = ThemeUnlockContainer.of(context)!;
        return const SizedBox.shrink();
      })),
    );
    await tester.pump();

    expect(state.isUnlocked, isTrue);
    expect(adSource.loadAdCallCount, 0);
  });

  testWidgets('watching the ad to completion grants and persists the unlock',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final adSource = FakeRewardedAdSource(isAdAvailable: true)
      ..nextShowEarnsReward = true;
    late ThemeUnlockContainerState state;

    await tester.pumpWidget(
      wrap(adSource, Builder(builder: (context) {
        state = ThemeUnlockContainer.of(context)!;
        return const SizedBox.shrink();
      })),
    );
    await tester.pump();

    final feedback = state.feedback.first;
    await state.watchAdToUnlock();
    await tester.pump();

    expect(adSource.showAdCallCount, 1);
    expect(state.isUnlocked, isTrue);
    expect(await feedback, ThemeUnlockFeedback.unlocked);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('theme_unlock::unlocked'), isTrue);
  });

  testWidgets('dismissing the ad without a reward keeps it locked',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final adSource = FakeRewardedAdSource(isAdAvailable: true)
      ..nextShowEarnsReward = false;
    late ThemeUnlockContainerState state;

    await tester.pumpWidget(
      wrap(adSource, Builder(builder: (context) {
        state = ThemeUnlockContainer.of(context)!;
        return const SizedBox.shrink();
      })),
    );
    await tester.pump();

    final feedback = state.feedback.first;
    await state.watchAdToUnlock();
    await tester.pump();

    expect(state.isUnlocked, isFalse);
    expect(await feedback, ThemeUnlockFeedback.adDismissedWithoutReward);
  });

  testWidgets('no ad available emits feedback and retries loading',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final adSource = FakeRewardedAdSource(isAdAvailable: false);
    late ThemeUnlockContainerState state;

    await tester.pumpWidget(
      wrap(adSource, Builder(builder: (context) {
        state = ThemeUnlockContainer.of(context)!;
        return const SizedBox.shrink();
      })),
    );
    await tester.pump();
    final loadsAfterInit = adSource.loadAdCallCount;

    final feedback = state.feedback.first;
    await state.watchAdToUnlock();
    await tester.pump();

    expect(state.isUnlocked, isFalse);
    expect(adSource.showAdCallCount, 0);
    expect(adSource.loadAdCallCount, greaterThan(loadsAfterInit));
    expect(await feedback, ThemeUnlockFeedback.adUnavailable);
  });

  testWidgets('debug reset clears the persisted unlock and reloads an ad',
      (tester) async {
    SharedPreferences.setMockInitialValues({'theme_unlock::unlocked': true});
    final adSource = FakeRewardedAdSource();
    late ThemeUnlockContainerState state;

    await tester.pumpWidget(
      wrap(adSource, Builder(builder: (context) {
        state = ThemeUnlockContainer.of(context)!;
        return const SizedBox.shrink();
      })),
    );
    await tester.pump();
    expect(state.isUnlocked, isTrue);

    await state.resetForDebug();
    await tester.pump();

    expect(state.isUnlocked, isFalse);
    expect(adSource.loadAdCallCount, 1);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('theme_unlock::unlocked'), isNull);
  });
}
