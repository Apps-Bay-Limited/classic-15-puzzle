import 'dart:async';

import 'package:classic_15_puzzle/widgets/game/format.dart';
import 'package:flutter/material.dart';

/// Live elapsed-time display driven by [getElapsedMs].
class LiveTimerText extends StatefulWidget {
  final int Function() getElapsedMs;
  final bool isRunning;
  final TextStyle style;

  const LiveTimerText({
    super.key,
    required this.getElapsedMs,
    required this.isRunning,
    required this.style,
  });

  @override
  State<LiveTimerText> createState() => _LiveTimerTextState();
}

class _LiveTimerTextState extends State<LiveTimerText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(LiveTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      _syncTimer();
    }
  }

  void _syncTimer() {
    _timer?.cancel();
    if (widget.isRunning) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 100),
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
    return Text(
      formatElapsedTime(widget.getElapsedMs()),
      style: widget.style,
      maxLines: 1,
      softWrap: false,
    );
  }
}
