import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/data/result.dart';
import 'package:classic_15_puzzle/play_games.dart';
import 'package:classic_15_puzzle/widgets/game/material/page.dart';
import 'package:classic_15_puzzle/widgets/game/material/victory.dart';
import 'package:classic_15_puzzle/widgets/game/presenter/main.dart';
import 'package:classic_15_puzzle/widgets/util/daily_challenge_container.dart';
import 'package:classic_15_puzzle/widgets/util/sound_manager.dart';
import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rootWidget = _buildRoot(context);
    return GamePresenterWidget(
      child: rootWidget,
      onSolve: (result, wasDailyChallenge) {
        _playVictorySound(context);
        _submitResult(context, result);
        if (wasDailyChallenge) {
          DailyChallengeContainer.of(context)?.markCompletedToday();
        }
        _showVictoryDialog(context, result);
      },
    );
  }

  void _playVictorySound(BuildContext context) {
    if (ConfigUiContainer.of(context)?.isSoundEnabled ?? true) {
      SoundManager.playVictory();
    }
  }

  Widget _buildRoot(BuildContext context) {
    return const GameMaterialPage();
  }

  void _showVictoryDialog(BuildContext context, Result result) {
    showDialog(
      context: context,
      builder: (context) => GameVictoryDialog(result: result),
    );
  }

  void _submitResult(BuildContext context, Result result) {
    final playGames = PlayGamesContainer.of(context);
    playGames?.submitScore(
      key: PlayGames.getLeaderboardOfSize(result.size),
      time: result.time,
    );
  }
}
