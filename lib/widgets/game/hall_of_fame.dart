import 'package:classic_15_puzzle/data/history.dart';
import 'package:classic_15_puzzle/data/result.dart';
import 'package:classic_15_puzzle/widgets/game/format.dart';
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
        title: const Text("Hall of Fame", style: TextStyle(fontWeight: FontWeight.w800)),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              TabBar(
                tabs: const [
                  Tab(text: "3x3"),
                  Tab(text: "4x4"),
                  Tab(text: "5x5"),
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
            child: const Text("CLOSE"),
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
            Icon(Icons.history_rounded, size: 48, color: colorScheme.outline.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text("No games yet", style: TextStyle(color: colorScheme.outline)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _BestCard(
                label: "BEST TIME",
                value: bestTime != null ? formatElapsedTime(bestTime.time) : "--",
                icon: Icons.timer_rounded,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BestCard(
                label: "MIN MOVES",
                value: bestMoves != null ? "${bestMoves.steps}" : "--",
                icon: Icons.bolt_rounded,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          "RECENT LOG",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
                color: colorScheme.outline,
              ),
        ),
        const SizedBox(height: 8),
        ...recent.map((result) => _LogItem(result: result)),
      ],
    );
  }
}

class _BestCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BestCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
          ),
        ],
      ),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 12, color: colorScheme.outline, fontWeight: FontWeight.w600),
              ),
              Text(
                "${result.steps} moves",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Spacer(),
          Text(
            formatElapsedTime(result.time),
            style: TextStyle(fontWeight: FontWeight.w800, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
