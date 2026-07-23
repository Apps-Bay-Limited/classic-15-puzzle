import 'dart:math';

import 'package:classic_15_puzzle/data/board.dart';
import 'package:classic_15_puzzle/domain/game.dart';
import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/widgets/game/board.dart';
import 'package:classic_15_puzzle/widgets/util/daily_challenge_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BoardWidget resizing mid-animation', () {
    // dailyChallengeBoardSize (3) is smaller than the default game size
    // (4), so starting the daily challenge from an in-progress bigger game
    // swaps BoardWidget's board for a smaller one on the same State. If a
    // move animation from the bigger board is still in flight when that
    // happens, its completion callback used to index the freshly (and now
    // smaller) rebuilt chips list with a chip number from the old, bigger
    // board — throwing a RangeError instead of just quietly finishing.
    testWidgets(
        'starting a smaller daily challenge mid-move on a bigger game does not throw',
        (tester) async {
      final board4 = Board.createNormal(4);
      final adjacent = board4.blank.x > 0
          ? Point<int>(board4.blank.x - 1, board4.blank.y)
          : Point<int>(board4.blank.x + 1, board4.blank.y);
      final movedBoard4 = Game.instance.tap(board4, point: adjacent);

      Widget wrap(Board board) => MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: BoardWidget(board: board, size: 300),
            ),
          );

      await tester.pumpWidget(wrap(board4));
      // Same size, one chip moved — starts a ~350ms move animation.
      await tester.pumpWidget(wrap(movedBoard4));
      await tester.pump(const Duration(milliseconds: 50));

      // Resize down to a 3x3 board mid-animation, as playDaily() does.
      await tester.pumpWidget(wrap(Board.createNormal(dailyChallengeBoardSize)));

      // Let the stale 4x4 animation's completion callback fire.
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('seeded shuffle', () {
    test('the same seed always produces the same board', () {
      final game = Game.instance;

      Board build(int seed) => game.shuffle(
            game.hardest(Board.createNormal(4), random: Random(seed)),
            amount: 16,
            random: Random(seed),
          );

      final a = build(20260724);
      final b = build(20260724);

      expect(a.blank, b.blank);
      for (var i = 0; i < a.chips.length; i++) {
        expect(a.chips[i].currentPoint, b.chips[i].currentPoint,
            reason: 'chip $i should land on the same square');
      }
    });

    test('different seeds produce different boards', () {
      final game = Game.instance;

      Board build(int seed) => game.shuffle(
            game.hardest(Board.createNormal(4), random: Random(seed)),
            amount: 16,
            random: Random(seed),
          );

      final a = build(20260724);
      final b = build(20260725);

      final same = a.blank == b.blank &&
          List.generate(a.chips.length, (i) => i).every(
            (i) => a.chips[i].currentPoint == b.chips[i].currentPoint,
          );
      expect(same, isFalse);
    });
  });

  group('day key', () {
    test('is derived from the UTC date, not the local one', () {
      // 23:30 UTC-tagged instants on the same UTC day share a key even though
      // local calendars would disagree.
      final a = DateTime.utc(2026, 7, 24, 23, 30);
      final b = DateTime.utc(2026, 7, 24, 1, 15);
      expect(dailyChallengeDayKey(a), dailyChallengeDayKey(b));
      expect(dailyChallengeDayKey(a), 20260724);
    });

    test('rolls over to a new key the next day', () {
      expect(
        dailyChallengeDayKey(DateTime.utc(2026, 7, 25)),
        isNot(dailyChallengeDayKey(DateTime.utc(2026, 7, 24))),
      );
    });
  });

  group('streak tracking', () {
    Future<DailyChallengeContainerState> pump(
      WidgetTester tester,
      DateTime now,
    ) async {
      late DailyChallengeContainerState state;
      await tester.pumpWidget(
        DailyChallengeContainer(
          clock: () => now,
          child: Builder(
            builder: (context) {
              state = DailyChallengeContainer.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      return state;
    }

    testWidgets('starts at zero with nothing persisted', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = await pump(tester, DateTime.utc(2026, 7, 24));

      expect(state.isCompletedToday, isFalse);
      expect(state.streak, 0);
    });

    testWidgets('completing today starts a streak of one', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = await pump(tester, DateTime.utc(2026, 7, 24));

      await state.markCompletedToday();
      await tester.pump();

      expect(state.isCompletedToday, isTrue);
      expect(state.streak, 1);
      expect(state.bestStreak, 1);
    });

    testWidgets('completing twice in a day does not inflate the streak',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = await pump(tester, DateTime.utc(2026, 7, 24));

      await state.markCompletedToday();
      await state.markCompletedToday();
      await tester.pump();

      expect(state.streak, 1);
    });

    testWidgets('a completion yesterday extends the streak', (tester) async {
      SharedPreferences.setMockInitialValues({
        'daily::last_completed_day': 20260723,
        'daily::streak': 4,
        'daily::best_streak': 4,
      });
      final state = await pump(tester, DateTime.utc(2026, 7, 24));

      expect(state.streak, 4);
      expect(state.isCompletedToday, isFalse);

      await state.markCompletedToday();
      await tester.pump();

      expect(state.streak, 5);
      expect(state.bestStreak, 5);
    });

    testWidgets('a gap of two days resets the streak on load', (tester) async {
      SharedPreferences.setMockInitialValues({
        'daily::last_completed_day': 20260721,
        'daily::streak': 9,
        'daily::best_streak': 9,
      });
      final state = await pump(tester, DateTime.utc(2026, 7, 24));

      expect(state.streak, 0);
      expect(state.bestStreak, 9, reason: 'best streak is never lost');

      await state.markCompletedToday();
      await tester.pump();

      expect(state.streak, 1);
      expect(state.bestStreak, 9);
    });
  });
}
