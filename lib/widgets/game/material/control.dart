import 'dart:math';

import 'package:flutter/material.dart';

/// Widget that can start / stop
/// a game.
class GamePlayStopButton extends StatefulWidget {
  final bool isPlaying;

  final void Function()? onTap;

  const GamePlayStopButton({super.key, 
    required this.isPlaying,
    this.onTap,
  });

  @override
  GamePlayStopButtonState createState() => GamePlayStopButtonState();
}

class GamePlayStopButtonState extends State<GamePlayStopButton>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 140),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    animation.addListener(() => setState(() {}));

    super.initState();

    // Don't play the initial animation.
    final isPlaying = widget.isPlaying;
    controller.value = isPlaying ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(GamePlayStopButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasPlaying = oldWidget.isPlaying;
    final isPlaying = widget.isPlaying;
    if (isPlaying != wasPlaying) {
      _performSetIsPlaying(isPlaying);
    }
  }

  void _performSetIsPlaying(bool isPlaying) {
    if (isPlaying) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final animRatioPlay = _range(1.0 - animation.value, begin: 0.0, end: 1.0);
    final animRatioStop = _range(animation.value, begin: 0.0, end: 1.0);

    // Calculate the background color of the FAB.
    final backgroundColorAccent = theme.colorScheme.secondary.withValues(alpha: animRatioPlay);
    final backgroundColorCard = theme.cardColor.withValues(alpha: animRatioStop);
    final backgroundColor =
        Color.alphaBlend(backgroundColorAccent, backgroundColorCard);

    return FloatingActionButton(
      backgroundColor: backgroundColor,
      tooltip: widget.isPlaying ? "Stop" : "Play",
      onPressed: () => widget.onTap?.call(),
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: animRatioPlay,
            child: Transform.rotate(
              angle: animation.value * pi / 2.0,
              child: Icon(
                Icons.play_arrow,
                color: theme.iconTheme.color,
              ),
            ),
          ),
          Opacity(
            opacity: animRatioStop,
            child: Transform.rotate(
              angle: animation.value * pi / 2.0,
              child: Icon(
                Icons.stop,
                color: theme.iconTheme.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _range(double v, {required double begin, required double end}) =>
      max(min(v, end), begin);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
