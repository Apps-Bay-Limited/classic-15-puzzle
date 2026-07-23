import 'dart:async';

import 'package:classic_15_puzzle/l10n/generated/app_localizations.dart';
import 'package:classic_15_puzzle/widgets/game/format.dart';
import 'package:flutter/material.dart';

/// Live "racing your personal best" readout shown under the timer.
///
/// Before the clock passes the personal best it counts down the margin still
/// in hand; once it passes, it counts up how far over the record you are. With
/// no record yet for this grid size it just advertises that any finish sets
/// one.
class PbPaceText extends StatefulWidget {
  /// Personal best for the current grid size, or `null` if none is set yet.
  final int? personalBestMs;
  final int Function() getElapsedMs;
  final bool isRunning;

  const PbPaceText({
    super.key,
    required this.personalBestMs,
    required this.getElapsedMs,
    required this.isRunning,
  });

  @override
  State<PbPaceText> createState() => _PbPaceTextState();
}

class _PbPaceTextState extends State<PbPaceText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(PbPaceText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      _syncTimer();
    }
  }

  void _syncTimer() {
    _timer?.cancel();
    if (widget.isRunning) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 200),
        (_) => setState(() {}),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final personalBest = widget.personalBestMs;

    final String label;
    final Color color;

    if (personalBest == null) {
      label = l10n.noRecordYetLabel;
      color = colorScheme.outline;
    } else if (!widget.isRunning) {
      // Between games, just show the target to beat.
      label = l10n.personalBestLabel(formatElapsedTime(personalBest));
      color = colorScheme.outline;
    } else {
      final delta = widget.getElapsedMs() - personalBest;
      if (delta < 0) {
        label = l10n.aheadOfBestLabel(formatElapsedTime(-delta));
        color = colorScheme.primary;
      } else {
        label = l10n.behindBestLabel(formatElapsedTime(delta));
        color = colorScheme.error;
      }
    }

    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
  }
}
