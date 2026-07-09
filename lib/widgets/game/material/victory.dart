import 'package:classic_15_puzzle/data/result.dart';
import 'package:classic_15_puzzle/play_games.dart';
import 'package:classic_15_puzzle/theme/app_radii.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:classic_15_puzzle/widgets/game/format.dart';
import 'package:classic_15_puzzle/widgets/shared/result_stat_item.dart';
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
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('CLOSE'),
      ),
      FilledButton.icon(
        icon: const Icon(Icons.share_rounded, size: 18),
        label: const Text('SHARE'),
        onPressed: () {
          SharePlus.instance.share(
            ShareParams(
              text: 'I solved the Classic 15 Puzzle '
                  '${widget.result.size}x${widget.result.size} in $timeFormatted '
                  'with ${widget.result.steps} moves!',
            ),
          );
        },
      ),
    ];

    if (PlayGamesContainer.of(context)?.isSupported == true) {
      actions.insert(
        0,
        TextButton.icon(
          icon: const Icon(Icons.leaderboard_rounded, size: 18),
          label: const Text('RANKINGS'),
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
      title: Text(
        'Magnificent!',
        textAlign: TextAlign.center,
        style: AppTypography.dialogTitle(context),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'You completed the ${widget.result.size}x${widget.result.size} puzzle in record time.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ResultStatItem(label: 'TIME', value: timeFormatted),
                ResultStatItem(
                  label: 'MOVES',
                  value: '${widget.result.steps}',
                ),
              ],
            ),
          ),
        ],
      ),
      actions: actions,
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
    );
  }
}
