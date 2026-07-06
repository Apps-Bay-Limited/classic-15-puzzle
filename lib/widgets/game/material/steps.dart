import 'package:flutter/material.dart';

/// Widget shows the current steps counter of
/// a game.
class GameStepsWidget extends StatefulWidget {
  final int steps;

  const GameStepsWidget({super.key, required this.steps});

  @override
  GameStepsState createState() => GameStepsState();
}

class GameStepsState extends State<GameStepsWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.steps} steps',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
