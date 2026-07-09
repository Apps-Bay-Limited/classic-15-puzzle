import 'dart:math';
import 'package:classic_15_puzzle/data/board.dart';

class PuzzleSolver {
  static const int _found = -1;
  static const int _notFound = -2;

  static Point<int>? findNextMove(Board board) {
    if (board.isSolved()) return null;

    final solution = _solve(board);
    if (solution != null && solution.isNotEmpty) {
      return solution.first;
    }
    return null;
  }

  static List<Point<int>>? _solve(Board board) {
    final int size = board.size;
    final targetState = List<int>.generate(size * size - 1, (i) => i + 1)..add(0);
    
    final initialState = List<int>.filled(size * size, 0);
    for (final chip in board.chips) {
      initialState[chip.currentPoint.y * size + chip.currentPoint.x] = chip.number + 1;
    }
    initialState[board.blank.y * size + board.blank.x] = 0;

    int threshold = _calculateHeuristic(initialState, size);
    final path = <Point<int>>[];
    final pathStates = <String>{String.fromCharCodes(initialState)};
    int blankIndex = board.blank.y * size + board.blank.x;

    int totalNodesEvaluated = 0;
    // Set a safe node evaluation limit. 100,000 nodes evaluates in under 50ms in Dart.
    const maxNodes = 100000;

    int search(
      List<int> state,
      int blankIdx,
      int g,
      int thresh,
    ) {
      totalNodesEvaluated++;
      if (totalNodesEvaluated > maxNodes) {
        return _notFound;
      }

      final h = _calculateHeuristic(state, size);
      final f = g + h;
      if (f > thresh) {
        return f;
      }
      if (_isGoal(state, targetState)) {
        return _found;
      }

      int minVal = 999999;

      final x = blankIdx % size;
      final y = blankIdx ~/ size;

      final moves = [
        Point(0, 1),  // Down
        Point(0, -1), // Up
        Point(1, 0),  // Right
        Point(-1, 0), // Left
      ];

      for (final move in moves) {
        final nx = x + move.x;
        final ny = y + move.y;

        if (nx >= 0 && nx < size && ny >= 0 && ny < size) {
          final newBlankIdx = ny * size + nx;
          
          // Swap
          final temp = state[blankIdx];
          state[blankIdx] = state[newBlankIdx];
          state[newBlankIdx] = temp;

          final stateKey = String.fromCharCodes(state);
          if (!pathStates.contains(stateKey)) {
            pathStates.add(stateKey);
            path.add(Point(nx, ny));

            final t = search(state, newBlankIdx, g + 1, thresh);
            if (t == _found) {
              return _found;
            }
            if (t == _notFound) {
              return _notFound;
            }
            if (t < minVal) {
              minVal = t;
            }

            path.removeLast();
            pathStates.remove(stateKey);
          }

          // Swap back
          state[newBlankIdx] = state[blankIdx];
          state[blankIdx] = temp;
        }
      }

      return minVal;
    }

    while (totalNodesEvaluated <= maxNodes) {
      final res = search(initialState, blankIndex, 0, threshold);
      if (res == _found) {
        return path;
      }
      if (res == _notFound || res >= 999999) {
        break;
      }
      threshold = res;
    }

    return null;
  }

  static bool _isGoal(List<int> state, List<int> target) {
    for (int i = 0; i < state.length; i++) {
      if (state[i] != target[i]) return false;
    }
    return true;
  }

  static int _calculateHeuristic(List<int> state, int size) {
    int distance = 0;
    
    // Manhattan distance
    for (int i = 0; i < state.length; i++) {
      final value = state[i];
      if (value == 0) continue;

      final targetX = (value - 1) % size;
      final targetY = (value - 1) ~/ size;
      final currentX = i % size;
      final currentY = i ~/ size;

      distance += (targetX - currentX).abs() + (targetY - currentY).abs();
    }

    // Linear conflict - rows
    for (int r = 0; r < size; r++) {
      for (int i = 0; i < size; i++) {
        final idx1 = r * size + i;
        final v1 = state[idx1];
        if (v1 == 0) continue;
        
        final targetRow1 = (v1 - 1) ~/ size;
        if (targetRow1 != r) continue;
        
        for (int j = i + 1; j < size; j++) {
          final idx2 = r * size + j;
          final v2 = state[idx2];
          if (v2 == 0) continue;
          
          final targetRow2 = (v2 - 1) ~/ size;
          if (targetRow2 != r) continue;
          
          final targetCol1 = (v1 - 1) % size;
          final targetCol2 = (v2 - 1) % size;
          
          if (targetCol1 > targetCol2) {
            distance += 2;
          }
        }
      }
    }

    // Linear conflict - columns
    for (int c = 0; c < size; c++) {
      for (int i = 0; i < size; i++) {
        final idx1 = i * size + c;
        final v1 = state[idx1];
        if (v1 == 0) continue;
        
        final targetCol1 = (v1 - 1) % size;
        if (targetCol1 != c) continue;
        
        for (int j = i + 1; j < size; j++) {
          final idx2 = j * size + c;
          final v2 = state[idx2];
          if (v2 == 0) continue;
          
          final targetCol2 = (v2 - 1) % size;
          if (targetCol2 != c) continue;
          
          final targetRow1 = (v1 - 1) ~/ size;
          final targetRow2 = (v2 - 1) ~/ size;
          
          if (targetRow1 > targetRow2) {
            distance += 2;
          }
        }
      }
    }

    return distance;
  }
}
