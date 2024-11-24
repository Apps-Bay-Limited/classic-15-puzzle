import 'dart:math';

import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/data/board.dart';
import 'package:classic_15_puzzle/widgets/game/board.dart';
import 'package:classic_15_puzzle/widgets/game/material/page.dart';
import 'package:flutter/material.dart' hide AboutDialog;
import 'package:flutter/widgets.dart';

Widget createMoreBottomSheet(
  BuildContext context, {
  @required Function(int) call,
}) {
  final config = ConfigUiContainer.of(context);

  Widget createBoard({int size}) => Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black54
                    : Colors.black12,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Semantics(
                label: '${size}x$size',
                child: InkWell(
                  onTap: () {
                    call(size);
                    Navigator.of(context).pop();
                  },
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final puzzleSize = min(
                        min(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                        96.0,
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
            Semantics(
              excludeSemantics: true,
              child: Align(
                alignment: Alignment.center,
                child: Text('${size}x$size'),
              ),
            ),
          ],
        ),
      );

  final items = <Widget>[
    Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Text("Choose game mode")),
    Row(
      children: <Widget>[
        SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: createBoard(size: 3),
          ),
        ),
        Expanded(child: createBoard(size: 4)),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: createBoard(size: 5),
          ),
        ),
        SizedBox(width: 8),
      ],
    ),
    SizedBox(height: 40),
  ];

  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final width = min(
          constraints.maxWidth,
          GameMaterialPage.kMaxBoardSize,
        );

        return Column(
          children: [
            Container(
              width: width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              ),
            ),
          ],
        );
      },
    ),
  );
}
