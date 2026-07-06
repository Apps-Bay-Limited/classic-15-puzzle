import 'package:flutter/foundation.dart';

@immutable
class Result {
  final int steps;
  final int time;
  final int size;

  const Result({required this.steps, required this.time, required this.size});
}
