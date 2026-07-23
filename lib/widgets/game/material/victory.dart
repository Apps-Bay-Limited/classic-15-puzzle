import 'package:classic_15_puzzle/data/result.dart';
import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/play_games.dart';
import 'package:classic_15_puzzle/theme/app_motion.dart';
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

class _GameVictoryDialogState extends State<GameVictoryDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconScale;
  late final Animation<double> _statsIn;
  bool _hasStartedEntranceAnimation = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.vibrate();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // Icon bounces in first, stats fade/slide in as it settles.
    _iconScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
    );
    _statsIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery (via AppMotion) can only be read once dependencies are
    // available, not in initState.
    if (_hasStartedEntranceAnimation) return;
    _hasStartedEntranceAnimation = true;
    if (AppMotion.disableAnimations(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatted = widget.timeFormatter(widget.result.time);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final actions = <Widget>[
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(l10n.close),
      ),
      FilledButton.icon(
        icon: const Icon(Icons.share_rounded, size: 18),
        label: Text(l10n.shareButton),
        onPressed: () {
          SharePlus.instance.share(
            ShareParams(
              text: l10n.shareText(
                '${widget.result.size}',
                timeFormatted,
                '${widget.result.steps}',
              ),
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
          label: Text(l10n.rankingsButton),
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
      icon: ScaleTransition(
        scale: _iconScale,
        child: Icon(Icons.stars_rounded, size: 48, color: colorScheme.primary),
      ),
      title: Text(
        l10n.victoryTitle,
        textAlign: TextAlign.center,
        style: AppTypography.dialogTitle(context),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.victoryDescription('${widget.result.size}'),
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          FadeTransition(
            opacity: _statsIn,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(_statsIn),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ResultStatItem(label: l10n.timeLabel, value: timeFormatted),
                    ResultStatItem(
                      label: l10n.movesLabel,
                      value: '${widget.result.steps}',
                    ),
                  ],
                ),
              ),
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
