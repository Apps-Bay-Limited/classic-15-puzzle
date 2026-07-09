import 'dart:math';
import 'package:classic_15_puzzle/data/board.dart';

class PuzzleSolver {
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

    final openSet = _PriorityQueue<_Node>();
    final closedSet = <String>{};

    final startNode = _Node(
      state: initialState,
      blankIndex: board.blank.y * size + board.blank.x,
      g: 0,
      h: _calculateHeuristic(initialState, size),
    );

    openSet.add(startNode);

    // Limit search to prevent hangs, especially for 4x4 and 5x5
    int iterations = 0;
    const maxIterations = 5000;

    while (openSet.isNotEmpty && iterations < maxIterations) {
      iterations++;
      final current = openSet.removeFirst();

      if (_isGoal(current.state, targetState)) {
        return _reconstructPath(current);
      }

      closedSet.add(current.state.join(','));

      for (final neighbor in _getNeighbors(current, size)) {
        if (closedSet.contains(neighbor.state.join(','))) continue;
        openSet.add(neighbor);
      }
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
    for (int i = 0; i < state.length; i++) {
      final value = state[i];
      if (value == 0) continue;

      final targetX = (value - 1) % size;
      final targetY = (value - 1) ~/ size;
      final currentX = i % size;
      final currentY = i ~/ size;

      distance += (targetX - currentX).abs() + (targetY - currentY).abs();
    }
    return distance;
  }

  static List<_Node> _getNeighbors(_Node node, int size) {
    final neighbors = <_Node>[];
    final x = node.blankIndex % size;
    final y = node.blankIndex ~/ size;

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
        final newBlankIndex = ny * size + nx;
        final newState = List<int>.from(node.state);
        newState[node.blankIndex] = newState[newBlankIndex];
        newState[newBlankIndex] = 0;

        neighbors.add(_Node(
          state: newState,
          blankIndex: newBlankIndex,
          move: Point(nx, ny),
          parent: node,
          g: node.g + 1,
          h: _calculateHeuristic(newState, size),
        ));
      }
    }
    return neighbors;
  }

  static List<Point<int>> _reconstructPath(_Node? node) {
    final path = <Point<int>>[];
    while (node != null && node.move != null) {
      path.add(node.move!);
      node = node.parent;
    }
    return path.reversed.toList();
  }
}

class _Node implements Comparable<_Node> {
  final List<int> state;
  final int blankIndex;
  final int g;
  final int h;
  final Point<int>? move;
  final _Node? parent;

  _Node({
    required this.state,
    required this.blankIndex,
    required this.g,
    required this.h,
    this.move,
    this.parent,
  });

  int get f => g + h;

  @override
  int compareTo(_Node other) => f.compareTo(other.f);
}

class _PriorityQueue<T extends Comparable<T>> {
  final List<T> _list = [];

  bool get isNotEmpty => _list.isNotEmpty;

  void add(T element) {
    _list.add(element);
    _list.sort();
  }

  T removeFirst() => _list.removeAt(0);
}
