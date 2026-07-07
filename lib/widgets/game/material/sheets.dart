import 'dart:math';
import 'dart:ui';

import 'package:classic_15_puzzle/data/board.dart';
import 'package:classic_15_puzzle/widgets/game/board.dart';
import 'package:flutter/material.dart' hide AboutDialog;
import 'package:flutter/services.dart';

Widget createMoreBottomSheet(
  BuildContext context, {
  required void Function(int) call,
}) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  final colorScheme = Theme.of(context).colorScheme;

  Widget createBoard({required int size}) => Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Semantics(
              label: '${size}x$size grid',
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  call(size);
                  Navigator.of(context).pop();
                },
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final puzzleSize = min(
                      min(constraints.maxWidth, constraints.maxHeight),
                      80.0,
                    );

                    return Semantics(
                      excludeSemantics: true,
                      child: BoardWidget(
                        board: Board.createNormal(size),
                        onTap: null,
                        showNumbers: false,
                        size: puzzleSize,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${size}x$size',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      );

  Widget content = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    decoration: BoxDecoration(
      color: isIOS ? colorScheme.surface.withValues(alpha: 0.7) : colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isIOS)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        Text(
          "Select Grid Size",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          "Choose your challenge level",
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            createBoard(size: 3),
            createBoard(size: 4),
            createBoard(size: 5),
          ],
        ),
        const SizedBox(height: 24),
      ],
    ),
  );

  if (isIOS) {
    content = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: content,
      ),
    );
  }

  return content;
}
