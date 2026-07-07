import 'package:classic_15_puzzle/data/result.dart';
import 'package:classic_15_puzzle/play_games.dart';
import 'package:classic_15_puzzle/widgets/game/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class GameVictoryDialog extends StatefulWidget {
  final Result result;
  final String Function(int) timeFormatter;

  const GameVictoryDialog({
    super.key,
    required this.result,
    this.timeFormatter = formatElapsedTime,
  });

  @override
  State<GameVictoryDialog> createState() => _GameVictoryDialogState();
}

class _GameVictoryDialogState extends State<GameVictoryDialog> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatted = widget.timeFormatter(widget.result.time);
    final colorScheme = Theme.of(context).colorScheme;

    final actions = <Widget>[
      TextButton(
        child: const Text("CLOSE"),
        onPressed: () => Navigator.of(context).pop(),
      ),
      FilledButton.icon(
        icon: const Icon(Icons.share_rounded, size: 18),
        label: const Text("SHARE"),
        onPressed: () {
          Share.share("I solved the Classic 15 Puzzle "
              "${widget.result.size}x${widget.result.size} in $timeFormatted "
              "with ${widget.result.steps} moves!");
        },
      ),
    ];

    if (PlayGamesContainer.of(context)?.isSupported == true) {
      actions.insert(
        0,
        TextButton.icon(
          icon: const Icon(Icons.leaderboard_rounded, size: 18),
          label: const Text("RANKINGS"),
          onPressed: () {
            final playGames = PlayGamesContainer.of(context);
            playGames?.showLeaderboard(
              key: PlayGames.getLeaderboardOfSize(widget.result.size),
            );
          },
        ),
      );
    }

    return AlertDialog(
      icon: Icon(Icons.stars_rounded, size: 48, color: colorScheme.primary),
      title: const Text(
        "Magnificent!",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "You completed the ${widget.result.size}x${widget.result.size} puzzle in record time.",
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _ResultItem(label: "TIME", value: timeFormatted),
                _ResultItem(label: "MOVES", value: "${widget.result.steps}"),
              ],
            ),
          ),
        ],
      ),
      actions: actions,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final String value;

  const _ResultItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
