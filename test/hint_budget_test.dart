import 'dart:math';

import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/widgets/game/presenter/main.dart';
import 'package:classic_15_puzzle/widgets/util/purchase_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_purchase_service.dart';

void main() {
  Future<GamePresenterWidgetState> pumpPresenter(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    late GamePresenterWidgetState presenter;

    await tester.pumpWidget(
      PurchaseContainer(
        service: FakePurchaseService(isAdsRemoved: true),
        child: ConfigUiContainer(
          child: MaterialApp(
            home: GamePresenterWidget(
              child: Builder(
                builder: (context) {
                  presenter = GamePresenterWidget.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return presenter;
  }

  testWidgets('a new game starts with a full hint budget', (tester) async {
    final presenter = await pumpPresenter(tester);

    presenter.play();
    await tester.pump();

    expect(presenter.hintsRemaining, GamePresenterWidgetState.hintsPerGame);
    expect(presenter.canUseHint, isTrue);
  });

  testWidgets('an exhausted budget blocks further hints', (tester) async {
    final presenter = await pumpPresenter(tester);

    presenter.play();
    await tester.pump();

    // Drain the budget without invoking the solver isolate.
    presenter.grantHints(-GamePresenterWidgetState.hintsPerGame);
    expect(presenter.hintsRemaining, GamePresenterWidgetState.hintsPerGame,
        reason: 'granting a negative amount is a no-op');

    while (presenter.hintsRemaining > 0) {
      presenter.debugSpendHint();
      await tester.pump();
    }

    expect(presenter.hintsRemaining, 0);
    expect(presenter.canUseHint, isFalse);
  });

  testWidgets('granting hints tops the budget back up but never over the cap',
      (tester) async {
    final presenter = await pumpPresenter(tester);

    presenter.play();
    await tester.pump();

    presenter.debugSpendHint();
    presenter.debugSpendHint();
    await tester.pump();
    expect(presenter.hintsRemaining, GamePresenterWidgetState.hintsPerGame - 2);

    presenter.grantHints(1);
    await tester.pump();
    expect(presenter.hintsRemaining, GamePresenterWidgetState.hintsPerGame - 1);

    presenter.grantHints(99);
    await tester.pump();
    expect(presenter.hintsRemaining, GamePresenterWidgetState.hintsPerGame);
  });

  testWidgets('starting a new game refills the budget', (tester) async {
    final presenter = await pumpPresenter(tester);

    presenter.play();
    await tester.pump();
    presenter.debugSpendHint();
    presenter.debugSpendHint();
    presenter.debugSpendHint();
    await tester.pump();
    expect(presenter.hintsRemaining, 0);

    presenter.play();
    await tester.pump();

    expect(presenter.hintsRemaining, GamePresenterWidgetState.hintsPerGame);
  });

  testWidgets('hints cannot be spent while paused', (tester) async {
    final presenter = await pumpPresenter(tester);

    presenter.play();
    await tester.pump();

    // The clock only starts on the first move, and pausing requires a running
    // clock — so make a move before pausing.
    final blank = presenter.board.blank;
    presenter.tap(
      point: blank.x > 0
          ? Point(blank.x - 1, blank.y)
          : Point(blank.x + 1, blank.y),
    );
    await tester.pump();
    expect(presenter.canUseHint, isTrue);

    presenter.togglePause();
    await tester.pump();
    expect(presenter.canUseHint, isFalse);

    presenter.togglePause();
    await tester.pump();
    expect(presenter.canUseHint, isTrue);
  });
}
