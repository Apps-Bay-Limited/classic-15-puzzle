import 'package:classic_15_puzzle/data/result.dart';
import 'package:classic_15_puzzle/play_games.dart';
import 'package:classic_15_puzzle/widgets/game/format.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class GameVictoryDialog extends StatelessWidget {
  final Result result;

  final String Function(int) timeFormatter;

  const GameVictoryDialog({super.key, 
    required this.result,
    this.timeFormatter = formatElapsedTime,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormatted = timeFormatter(result.time);
    final actions = <Widget>[
      TextButton(
        child: const Text("Share"),
        onPressed: () {
          Share.share("I have solved the Classic 15 Puzzle "
              "${result.size}x${result.size} puzzle in $timeFormatted "
              "with just ${result.steps} steps!");
        },
      ),
      TextButton(
        child: const Text("Close"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ];

    if (PlayGamesContainer.of(context)?.isSupported == true) {
      actions.insert(
        0,
        TextButton(
          child: const Text("Leaderboard"),
          onPressed: () {
            final playGames = PlayGamesContainer.of(context);
            playGames?.showLeaderboard(
              key: PlayGames.getLeaderboardOfSize(result.size),
            );
          },
        ),
      );
    }

    return AlertDialog(
      title: Center(
        child: Text(
          "Congratulations!",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
              "You've successfuly completed the ${result.size}x${result.size} puzzle"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Time:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    timeFormatted,
                    style: (Theme.of(context).textTheme.displaySmall ?? const TextStyle()).copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Steps:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${result.steps}',
                    style: (Theme.of(context).textTheme.displaySmall ?? const TextStyle()).copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: actions,
    );
  }
}
