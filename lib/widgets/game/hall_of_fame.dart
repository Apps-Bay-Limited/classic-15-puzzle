import 'package:classic_15_puzzle/data/history.dart';
import 'package:classic_15_puzzle/data/result.dart';
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

    return DefaultTabController(
      length: 3,
      child: AlertDialog(
        title: Text('Hall of Fame', style: AppTypography.dialogTitle(context)),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          height: AppSpacing.dialogContentHeight,
          child: Column(
            children: [
              TabBar(
                tabs: const [
                  Tab(text: '3x3'),
                  Tab(text: '4x4'),
                  Tab(text: '5x5'),
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
            child: const Text('CLOSE'),
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
            Text('No games yet', style: TextStyle(color: colorScheme.outline)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Solve a puzzle to see your records here',
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
                label: 'BEST TIME',
                value: bestTime != null ? formatElapsedTime(bestTime.time) : '--',
                icon: Icons.timer_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AccentStatCard.slate(
                label: 'MIN MOVES',
                value: bestMoves != null ? '${bestMoves.steps}' : '--',
                icon: Icons.bolt_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('RECENT LOG', style: AppTypography.sectionHeader(context)),
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
                '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${result.steps} moves',
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
