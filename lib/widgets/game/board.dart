import 'dart:math';

import 'package:classic_15_puzzle/data/board.dart';
import 'package:classic_15_puzzle/data/chip.dart';
import 'package:classic_15_puzzle/domain/game.dart';
import 'package:classic_15_puzzle/theme/app_colors.dart';
import 'package:classic_15_puzzle/theme/app_motion.dart';
import 'package:classic_15_puzzle/widgets/game/chip.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:flutter/services.dart';

class BoardWidget extends StatefulWidget {
  final Board board;
  final double size;
  final bool showNumbers;
  final void Function(Point<int>)? onTap;
  final bool isSpeedRunModeEnabled;

  const BoardWidget({
    super.key,
    required this.board,
    required this.size,
    this.showNumbers = true,
    this.isSpeedRunModeEnabled = false,
    this.onTap,
  });

  @override
  BoardWidgetState createState() => BoardWidgetState();
}

class BoardWidgetState extends State<BoardWidget>
    with TickerProviderStateMixin {
  static const _animColorOverlayTag = "color_overlay";
  static const _animMoveTag = "move";
  static const _animScaleTag = "scale";

  static const num _animDurationMultiplierNormal = 1.0;
  static const num _animDurationMultiplierSpeedRun = 0.6;

  static const int _animDurationBlinkHalf = 200;
  static const int _animDurationMove = 350;
  static const int _animDurationColorOverlay = 1200;

  static const double _kFriction = 0.015;

  static final double _kDecelerationRate = log(0.78) / log(0.9);

  static const double _initialVelocityPenetration = 3.065;

  static const Color rightColor = AppColors.tileFill;
  static const Color rightFontColor = AppColors.tileText;

  static double _decelerationForFriction(double friction) {
    return friction * 61774.04968;
  }

  static double _flingDuration({double friction = _kFriction, required double velocity}) {
    // See mPhysicalCoeff
    final double scaledFriction = friction * _decelerationForFriction(0.84);

    // See getSplineDeceleration().
    final double deceleration = log(0.35 * velocity.abs() / scaledFriction);

    return exp(deceleration / (_kDecelerationRate - 1.0));
  }

  static double _flingOffset({double friction = _kFriction, required double velocity}) {
    var duration = _flingDuration(friction: friction, velocity: velocity);
    return velocity * duration / _initialVelocityPenetration;
  }

  late List<_Chip> chips = [];

  Function(double, double)? _onPanEndDelegate;

  Function(double, double)? _onPanUpdateDelegate;

  bool _isSpeedRunModeEnabled = false;

  /// Applies normal/speed run duration modifiers and respects Reduce Motion.
  int _animDurationMs(int duration) {
    if (AppMotion.disableAnimations(context)) {
      return 0;
    }
    return _applyAnimationMultiplier(duration);
  }

  int _applyAnimationMultiplier(int duration) {
    if (_isSpeedRunModeEnabled) {
      return (duration.toDouble() * _animDurationMultiplierSpeedRun)
          .toInt();
    } else {
      return (duration.toDouble() * _animDurationMultiplierNormal).toInt();
    }
  }

  @override
  void initState() {
    super.initState();
    _isSpeedRunModeEnabled = widget.isSpeedRunModeEnabled;
    _performSetBoard(
      newBoard: widget.board,
    );
  }

  @override
  void didUpdateWidget(BoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _isSpeedRunModeEnabled = widget.isSpeedRunModeEnabled;
    });
    _performSetBoard(
      newBoard: widget.board,
      oldBoard: oldWidget.board,
    );
  }

  void _performSetPrevBoard() =>
      _performSetBoard(newBoard: widget.board, oldBoard: widget.board);

  void _performSetBoard({required final Board newBoard, final Board? oldBoard}) {
    final board = newBoard;
    if (oldBoard == null || board.chips.length != oldBoard.chips.length) {
      // The size of the board has been changed or it's the initial load.
      setState(() {
        // Create our extras
        chips = board.chips.map((chip) {
          final x = chip.currentPoint.x / board.size;
          final y = chip.currentPoint.y / board.size;
          const color = rightColor;
          const colorFont = rightFontColor;
          return _Chip(x, y, chip.currentPoint,
              backgroundColor: color, fontColor: colorFont);
        }).toList();
      });
      return;
    }

    for (var chip in board.chips) {
      final extra = chips[chip.number];
      if (extra.currentPoint != chip.currentPoint || extra.touched) {
        // The chip has been moved somewhere...
        // animate the change!
        final wasTouched = extra.touched;
        final wasCurrentPoint = extra.currentPoint;
        extra.touched = false;
        extra.currentPoint = chip.currentPoint;
        _onChipChangePosition(chip, wasCurrentPoint, chip.currentPoint,
            enableColorAnimation: !wasTouched);
      }
    }
  }

  // ---- Shuffle the chips ----

  void _onChipChangePosition(
    Chip chip,
    Point<int> from,
    Point<int> to, {
    bool enableColorAnimation = true,
  }) {
    HapticFeedback.lightImpact();
    if (from.x != to.x && from.y != to.y) {
      // Chip can not be physically moved this way, play
      // the blink animation along with move animation.
      _startBlinkAnimation(chip, to);
    } else {
      _startMoveAnimation(chip, to);
    }

    if (enableColorAnimation) _startColorOverlayAnimation(chip);
  }

  void _startMoveAnimation(Chip chip, Point<int> point) {
    final controller = AnimationController(
      duration: Duration(
          milliseconds: _animDurationMs(_animDurationMove)),
      vsync: this,
    );

    final target = chips[chip.number];
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );

    final board = widget.board;
    final oldX = target.x * board.size;
    final oldY = target.y * board.size;
    animation.addListener(() {
      // Calculate current point
      // of the chip.
      final x = (oldX * (1.0 - animation.value) + point.x * animation.value) /
          board.size;
      final y = (oldY * (1.0 - animation.value) + point.y * animation.value) /
          board.size;

      setState(() {
        target.x = x;
        target.y = y;
      });
    });

    // Start and dispose the animation
    // after its finish.
    _addAnimation(chip, _animMoveTag, controller);
    controller
        .forward()
        .then<void>((_) => _disposeAnimation(chip, _animMoveTag));
  }

  void _startBlinkAnimation(Chip chip, Point<int> point) {
    final duration = Duration(
        milliseconds: _animDurationMs(_animDurationBlinkHalf) * 2);
    const curve = Curves.easeInOut;

    void startScaleAnimation(Chip chip, Point<int> point) {
      final controller = AnimationController(
        duration: duration,
        vsync: this,
      );

      final target = chips[chip.number];
      final animation = CurvedAnimation(
        parent: controller,
        curve: curve,
      );
      animation.addListener(() {
        final scale = cos(animation.value * 2.0 * pi) / 2.0 + 0.5;
        setState(() {
          target.scale = scale;
        });
      });

      _addAnimation(chip, _animScaleTag, controller);
      controller
          .forward()
          .then<void>((_) => _disposeAnimation(chip, _animScaleTag));
    }

    void startMoveAnimation(Chip chip, Point<int> point) {
      final controller = AnimationController(
        duration: duration,
        vsync: this,
      );

      final target = chips[chip.number];
      final animation = CurvedAnimation(
        parent: controller,
        curve: curve,
      );

      final board = widget.board;
      var wasHalfwayOrMore = false;
      animation.addListener(() {
        final isHalfwayOrMore = animation.value >= 0.5;
        if (isHalfwayOrMore != wasHalfwayOrMore) {
          wasHalfwayOrMore = isHalfwayOrMore;

          final x = point.x.toDouble() / board.size;
          final y = point.y.toDouble() / board.size;
          setState(() {
            target.x = x;
            target.y = y;
          });
        }
      });

      _addAnimation(chip, _animMoveTag, controller);
      controller
          .forward()
          .then<void>((_) => _disposeAnimation(chip, _animMoveTag));
    }

    startScaleAnimation(chip, point);
    startMoveAnimation(chip, point);
  }

  void _startColorOverlayAnimation(Chip chip) {
    final controller = AnimationController(
      duration: Duration(
          milliseconds:
              _animDurationMs(_animDurationColorOverlay)),
      vsync: this,
    );

    final target = chips[chip.number];
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );
    animation.addListener(() {
      final opacity = sin(sqrt(animation.value) * pi) * 0.15;
      setState(() {
        target.overlayColor = Color.fromRGBO(255, 255, 255, opacity);
      });
    });

    _addAnimation(chip, _animColorOverlayTag, controller);
    controller
        .forward()
        .then<void>((_) => _disposeAnimation(chip, _animColorOverlayTag));
  }

  void _addAnimation(
    Chip chip,
    String tag,
    AnimationController controller,
  ) {
    final map = chips[chip.number].animations;

    // Replace previous animation.
    map[tag]?.dispose();
    map[tag] = controller;
  }

  void _disposeAnimation(
    Chip chip,
    String tag,
  ) {
    final map = chips[chip.number].animations;
    map.remove(tag)?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.board;
    final blank = _buildChipWidgetSkeleton(
      x: board.blank.x.toDouble() / board.size.toDouble(),
      y: board.blank.y.toDouble() / board.size.toDouble(),
      scale: 1.0,
      chip: (chipSize) => Semantics(
        label: 'Blank space',
        child: const SizedBox.shrink(),
      ),
    );
    final chipsWidgets = board.chips.map(_buildChipWidget).toList();
    chipsWidgets.add(blank);
    final boardStack = Stack(children: chipsWidgets);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
              onPanStart: (DragStartDetails details) =>
                  onPanStart(context, details),
              onPanCancel: onPanCancel,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
              onTapDown: onTapDown,
              child: boardStack,
            ),
    );
  }

  Widget _buildChipWidget(Chip chip) {
    final board = widget.board;
    final extra = chips[chip.number];

    // Calculate the distance between current absolute position
    // and target position.
    final dstHorizontal = extra.x * board.size - chip.targetPoint.x;
    final dstVertical = extra.y * board.size - chip.targetPoint.y;
    final dst = sqrt(pow(dstHorizontal, 2) + pow(dstVertical, 2));

    // Calculate the colors.
    final overlayColor = extra.overlayColor;
    final backgroundColor =
        extra.backgroundColor.withValues(alpha: dst < 1 ? 1 - dst : 0);
    final fontColor = extra.fontColor;

    return _buildChipWidgetSkeleton(
      x: extra.x,
      y: extra.y,
      scale: extra.scale,
      chip: (chipSize) => ChipWidget(
        widget.showNumbers ? "${chip.number + 1}" : null,
        overlayColor,
        backgroundColor,
        fontColor,
        chipSize / 3 + 10,
        size: widget.size,
        onPressed: !_isSpeedRunModeEnabled
            ? () {
                widget.onTap?.call(chip.currentPoint);
              }
            : null,
      ),
    );
  }

  Widget _buildChipWidgetSkeleton({
    required double x,
    required double y,
    required double scale,
    required Widget Function(double) chip,
  }) {
    final board = widget.board;
    final chipSize = widget.size / board.size;
    return Positioned(
      width: chipSize,
      height: chipSize,
      left: x * widget.size,
      top: y * widget.size,
      child: Transform.scale(
        scale: scale,
        child: chip(chipSize),
      ),
    );
  }

  void onTapDown(TapDownDetails details) {
    if (!_isSpeedRunModeEnabled) {
      return;
    }

    _Chip? activeChip = _findActiveChip(details.globalPosition);

    if (activeChip != null) {
      widget.onTap?.call(activeChip.currentPoint);
    }
  }

  void onPanStart(BuildContext context, DragStartDetails details) {
    final board = widget.board;

    if (_isSpeedRunModeEnabled) {
      _onPanUpdateDelegate = null;
      _onPanEndDelegate = null;
      return;
    }

    final boardWidgetSize = widget.size;
    final chipWidgetSize = boardWidgetSize / board.size;

    _Chip? activeChip = _findActiveChip(details.globalPosition);
    if (activeChip == null) {
      return;
    }

    final game = Game.instance;

    // Calculate the range of possible movement of
    // a touched chip.
    final aPointInt = activeChip.currentPoint;
    final aPoint =
        Point<double>(aPointInt.x.toDouble(), aPointInt.y.toDouble());
    final aPointScaled = aPoint * chipWidgetSize;
    final bPointInt = game.findChipPositionAfterTap(board, point: aPointInt);
    final bPoint =
        Point<double>(bPointInt.x.toDouble(), bPointInt.y.toDouble());
    final bPointScaled = bPoint * chipWidgetSize;

    Point<double> fromPointScaled;
    Point<double> toPointScaled;
    if (aPoint.x > bPoint.x || aPoint.y > bPoint.y) {
      fromPointScaled = bPointScaled;
      toPointScaled = aPointScaled;
    } else {
      fromPointScaled = aPointScaled;
      toPointScaled = bPointScaled;
    }

    // Find the dependent on this movement chips.
    final group =
        (game.findChips(board, point: activeChip.currentPoint).toList()
              ..sort((a, b) {
                final aDst = a.currentPoint.distanceTo(aPointInt);
                final bDst = b.currentPoint.distanceTo(aPointInt);
                return aDst.compareTo(bDst);
              }))
            .map((chip) =>
                chips.firstWhere((c) => chip.currentPoint == c.currentPoint))
            .toList();

    //
    // Create an update delegate
    //

    _onPanUpdateDelegate = (double dx, double dy) {
      final x = max(min(activeChip.x * boardWidgetSize + dx, toPointScaled.x),
              fromPointScaled.x) /
          boardWidgetSize;
      final y = max(min(activeChip.y * boardWidgetSize + dy, toPointScaled.y),
              fromPointScaled.y) /
          boardWidgetSize;

      setState(() {
        activeChip.x = x;
        activeChip.y = y;

        activeChip.touched = true;
        activeChip.animations.remove(_animMoveTag)?.dispose();

        for (int i = 1; i < group.length; i++) {
          final _Chip prev = group[i - 1];
          final _Chip next = group[i];

          if (prev.currentPoint.x != next.currentPoint.x) {
            var dx = chipWidgetSize - (next.x - prev.x).abs() * boardWidgetSize;
            if (dx > 0) {
              if (next.currentPoint.x > prev.currentPoint.x) {
                next.x = (next.x * boardWidgetSize + dx) / boardWidgetSize;
              } else {
                next.x = (next.x * boardWidgetSize - dx) / boardWidgetSize;
              }

              next.touched = true;
              next.animations.remove(_animMoveTag)?.dispose();
            }
          } else {
            var dy = chipWidgetSize - (next.y - prev.y).abs() * boardWidgetSize;
            if (dy > 0) {
              if (next.currentPoint.y > prev.currentPoint.y) {
                next.y = (next.y * boardWidgetSize + dy) / boardWidgetSize;
              } else {
                next.y = (next.y * boardWidgetSize - dy) / boardWidgetSize;
              }

              next.touched = true;
              next.animations.remove(_animMoveTag)?.dispose();
            }
          }
        }
      });
    };

    //
    // Create an end delegate
    //

    _onPanEndDelegate = (double vx, double vy) {
      final offsetX = _flingOffset(velocity: vx);
      final offsetY = _flingOffset(velocity: vy);
      final x = max(
              min(activeChip.x * boardWidgetSize + offsetX, toPointScaled.x),
              fromPointScaled.x) /
          boardWidgetSize;
      final y = max(
              min(activeChip.y * boardWidgetSize + offsetY, toPointScaled.y),
              fromPointScaled.y) /
          boardWidgetSize;

      // Convert this gesture into a single tap
      // and clean-up delegates.
      final newTouchChipPoint = Point(
        (x * board.size).round(),
        (y * board.size).round(),
      );

      if (newTouchChipPoint != activeChip.currentPoint) {
        widget.onTap?.call(activeChip.currentPoint);
      } else if (group.length >= 2) {
        final nextToTouchChip = group[1];
        final nextToTouchChipPoint = Point(
          (nextToTouchChip.x * board.size).round(),
          (nextToTouchChip.y * board.size).round(),
        );

        if (nextToTouchChipPoint != nextToTouchChip.currentPoint) {
          widget.onTap?.call(nextToTouchChip.currentPoint);
        } else {
          _performSetPrevBoard();
        }
      } else {
        _performSetPrevBoard();
      }

      // Clean-up delegates
      _onPanEndDelegate = null;
      _onPanUpdateDelegate = null;
    };
  }

  _Chip? _findActiveChip(Offset globalPosition) {
    final board = widget.board;
    final boardWidgetSize = widget.size;
    final chipWidgetSize = boardWidgetSize / board.size;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(globalPosition);
    final touchX = localPos.dx;
    final touchY = localPos.dy;

    for (_Chip chip in chips) {
      if (chip.x * boardWidgetSize <= touchX &&
          chip.x * boardWidgetSize + chipWidgetSize >= touchX &&
          chip.y * boardWidgetSize <= touchY &&
          chip.y * boardWidgetSize + chipWidgetSize >= touchY) {
        return chip;
      }
    }

    return null;
  }

  void onPanCancel() {
    if (_onPanEndDelegate == null && _onPanUpdateDelegate == null) {
      return;
    }

    _onPanEndDelegate = null;
    _onPanUpdateDelegate = null;

    _performSetPrevBoard();
  }

  void onPanUpdate(DragUpdateDetails details) {
    _onPanUpdateDelegate?.call(
      details.delta.dx,
      details.delta.dy,
    );
  }

  void onPanEnd(DragEndDetails details) {
    _onPanEndDelegate?.call(
      details.velocity.pixelsPerSecond.dx,
      details.velocity.pixelsPerSecond.dy,
    );
  }
}

class _Chip {
  double x = 0;
  double y = 0;

  bool touched = false;

  /// Current X and Y scale of the chip, used for a
  /// blink animation.
  double scale = 1;

  Color backgroundColor = Colors.white;

  Color overlayColor = Colors.white;

  Color fontColor = Colors.black;

  Map<String, AnimationController> animations = {};

  Point<int> currentPoint;

  _Chip(
    this.x,
    this.y,
    this.currentPoint, {
    this.scale = 1,
    required this.backgroundColor,
    required this.fontColor,
  });
}
