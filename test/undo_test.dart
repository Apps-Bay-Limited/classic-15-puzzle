import 'dart:math';

import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/widgets/game/presenter/main.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_purchase_service.dart';

void main() {
  /// Mounts the presenter with ads already "removed" so `didChangeDependencies`
  /// disposes the interstitial manager instead of calling into the real ads
  /// SDK, and with sound off so no audio plugin channel is touched.
  Future<GamePresenterWidgetState> pumpPresenter(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    late GamePresenterWidgetState presenter;
    late ConfigUiContainerState config;

    await tester.pumpWidget(
      PurchaseContainer(
        service: FakePurchaseService(isAdsRemoved: true),
        child: ConfigUiContainer(
          child: MaterialApp(
            home: GamePresenterWidget(
              child: Builder(
                builder: (context) {
                  presenter = GamePresenterWidget.of(context);
                  config = ConfigUiContainer.of(context)!;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    config.setSoundEnabled(false, save: false);
    await tester.pump();

    return presenter;
  }

  /// Any tile orthogonally adjacent to the blank is always a legal move.
  Point<int> movablePointNextToBlank(GamePresenterWidgetState presenter) {
    final blank = presenter.board.blank;
    return blank.x > 0
        ? Point(blank.x - 1, blank.y)
        : Point(blank.x + 1, blank.y);
  }

  testWidgets('nothing to undo before a move has been made', (tester) async {
    final presenter = await pumpPresenter(tester);

    presenter.play();
    await tester.pump();

    expect(presenter.canUndo, isFalse);
  });

  testWidgets('undo restores the previous board and step count',
      (tester) async {
    final presenter = await pumpPresenter(tester);

    presenter.play();
    await tester.pump();

    final boardBefore = presenter.board;
    final stepsBefore = presenter.steps;

    presenter.tap(point: movablePointNextToBlank(presenter));
    await tester.pump();

    expect(presenter.steps, stepsBefore + 1);
    expect(presenter.board, isNot(same(boardBefore)));
    expect(presenter.canUndo, isTrue);

    presenter.undo();
    await tester.pump();

    expect(presenter.board, same(boardBefore));
    expect(presenter.steps, stepsBefore);
    expect(presenter.canUndo, isFalse);
  });

  testWidgets('undo unwinds several moves in order', (tester) async {
    final presenter = await pumpPresenter(tester);

    presenter.play();
    await tester.pump();

    final boards = <dynamic>[];
    for (var i = 0; i < 3; i++) {
      boards.add(presenter.board);
      presenter.tap(point: movablePointNextToBlank(presenter));
      await tester.pump();
    }

    expect(presenter.steps, 3);

    for (var i = 2; i >= 0; i--) {
      presenter.undo();
      await tester.pump();
      expect(presenter.board, same(boards[i]));
      expect(presenter.steps, i);
    }

    expect(presenter.canUndo, isFalse);
  });

  testWidgets('undo is unavailable while paused', (tester) async {
    final presenter = await pumpPresenter(tester);

    presenter.play();
    await tester.pump();

    presenter.tap(point: movablePointNextToBlank(presenter));
    await tester.pump();
    expect(presenter.canUndo, isTrue);

    presenter.togglePause();
    await tester.pump();
    expect(presenter.canUndo, isFalse);

    presenter.togglePause();
    await tester.pump();
    expect(presenter.canUndo, isTrue);
  });

  testWidgets('starting a new game clears the undo stack', (tester) async {
    final presenter = await pumpPresenter(tester);

    presenter.play();
    await tester.pump();

    presenter.tap(point: movablePointNextToBlank(presenter));
    await tester.pump();
    expect(presenter.canUndo, isTrue);

    presenter.play();
    await tester.pump();

    expect(presenter.canUndo, isFalse);
    expect(presenter.steps, 0);
  });
}
