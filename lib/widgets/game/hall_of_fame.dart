import 'package:classic_15_puzzle/data/history.dart';
import 'package:classic_15_puzzle/data/result.dart';
import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/theme/app_spacing.dart';
import 'package:classic_15_puzzle/theme/app_typography.dart';
import 'package:classic_15_puzzle/widgets/game/format.dart';
import 'package:classic_15_puzzle/widgets/shared/accent_stat_card.dart';
import 'package:flutter/material.dart';

class HallOfFameDialog extends StatelessWidget {
  final GameHistory history;

  const HallOfFameDialog({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: AlertDialog(
        title:
            Text(l10n.hallOfFameTitle, style: AppTypography.dialogTitle(context)),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          height: AppSpacing.dialogContentHeight,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(child: Text(l10n.gridSizeLabel('3'))),
                  Tab(child: Text(l10n.gridSizeLabel('4'))),
                  Tab(child: Text(l10n.gridSizeLabel('5'))),
                ],
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.outline,
                indicatorColor: colorScheme.primary,
                dividerColor: Colors.transparent,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _SizeStats(size: 3, history: history),
                    _SizeStats(size: 4, history: history),
                    _SizeStats(size: 5, history: history),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

class _SizeStats extends StatelessWidget {
  final int size;
  final GameHistory history;

  const _SizeStats({required this.size, required this.history});

  @override
  Widget build(BuildContext context) {
    final bestTime = history.bestTime[size];
    final bestMoves = history.bestMoves[size];
    final recent = history.log.where((r) => r.size == size).toList();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (recent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.noGamesYet, style: TextStyle(color: colorScheme.outline)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.solveToSeeRecords,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          children: [
            Expanded(
              child: AccentStatCard.gold(
                label: l10n.bestTimeLabel,
                value: bestTime != null
                    ? formatElapsedTime(bestTime.time)
                    : l10n.noDataPlaceholder,
                icon: Icons.timer_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AccentStatCard.slate(
                label: l10n.minMovesLabel,
                value: bestMoves != null
                    ? '${bestMoves.steps}'
                    : l10n.noDataPlaceholder,
                icon: Icons.bolt_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.recentLogLabel, style: AppTypography.sectionHeader(context)),
        const SizedBox(height: AppSpacing.xs),
        ...recent.map((result) => _LogItem(result: result)),
      ],
    );
  }
}

class _LogItem extends StatelessWidget {
  final Result result;

  const _LogItem({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final date = DateTime.fromMillisecondsSinceEpoch(result.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.recentLogTimestamp(
                  '${date.day}',
                  '${date.month}',
                  '${date.hour}',
                  date.minute.toString().padLeft(2, '0'),
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.movesCount('${result.steps}'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Spacer(),
          Text(
            formatElapsedTime(result.time),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
