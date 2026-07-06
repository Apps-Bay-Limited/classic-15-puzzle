import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:classic_15_puzzle/data/board.dart';
import 'package:classic_15_puzzle/data/result.dart';
import 'package:classic_15_puzzle/domain/game.dart';
import 'package:classic_15_puzzle/utils/serializable.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePresenterWidget extends StatefulWidget {
  static const supportedSizes = [3, 4, 5];

  final Widget child;

  final void Function(Result)? onSolve;

  const GamePresenterWidget({super.key, required this.child, this.onSolve});

  static GamePresenterWidgetState of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>();
    if (result == null) {
      throw StateError("GamePresenterWidget.of() called with a context that does not contain a GamePresenterWidget.");
    }
    return result.data;
  }

  @override
  GamePresenterWidgetState createState() => GamePresenterWidgetState();
}

class GamePresenterWidgetState extends State<GamePresenterWidget>
    with WidgetsBindingObserver {
  static const timeStopped = 0;

  static final _salsaKey = encrypt.Key.fromUtf8('Ro9ndPUceXQQL8GS');
  static final _salsaIv = encrypt.IV.fromUtf8('84bgee3v');

  static const _keyState = 'state';

  /// Encrypter to protected saved states of the game and
  /// make hacking a lil bit harder.
  final _encrypter = encrypt.Encrypter(encrypt.Salsa20(_salsaKey));

  final Game game = Game.instance;

  late Board board;

  int steps = 0;

  int time = timeStopped;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    board = _createBoard(4);

    _loadState();
  }

  void _loadState() async {
    dynamic jsonMap;
    try {
      final prefs = await SharedPreferences.getInstance();

      final encrypted =
          encrypt.Encrypted.fromBase64(prefs.getString(_keyState) ?? '');
      final plainText = _encrypter.decrypt(encrypted, iv: _salsaIv);

      jsonMap = json.decode(plainText);
    } catch (e) {
      jsonMap = <String, dynamic>{};
    }

    int? elapsedTime;
    int? time;
    int? steps;
    Board? board;

    try {
      final deserializer = MapSerializeInput(map: jsonMap);
      const boardFactory = BoardDeserializableFactory();
      elapsedTime = deserializer.readInt();
      time = deserializer.readInt();
      steps = deserializer.readInt();
      board = deserializer.readDeserializable(boardFactory);
    } catch (e) {
      // Ignored
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if ( // validate time
        time == null ||
            time < 0 ||
            time > now ||
            (time > 0 && elapsedTime != null && elapsedTime > now - time) ||
            steps == null ||
            steps < 0 ||
            board == null) {
      time = timeStopped;
      steps = 0;
      // Initialize empty board with a classic
      // pattern.
      const size = 4;
      board = _createBoard(size);
    }

    setState(() {
      this.time = time ?? timeStopped;
      this.steps = steps ?? 0;
      this.board = board ?? _createBoard(4);
    });
  }

  Board _createBoard(int size) => Board.createNormal(size);

  void playStop() {
    if (isPlaying()) {
      stop();
    } else {
      play();
    }
  }

  void play() {

    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      time = now;
      steps = 0;
      board =
          game.shuffle(game.hardest(board), amount: board.size * board.size);
    });
  }

  void stop() {
    setState(() {
      time = timeStopped;
      steps = 0;
    });
  }

  bool isPlaying() => time != timeStopped;

  void resize(int size) {
    setState(() {
      time = timeStopped;
      steps = 0;
      board = _createBoard(size);
    });
  }

  void tap({required Point<int> point}) {

    setState(() {
      board = game.tap(board, point: point);

      if (isPlaying()) {
        // Increment the amount of steps.
        steps = steps + 1;

        // Stop if a user has solved the
        // board.
        if (board.isSolved()) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final result = Result(
            steps: steps,
            time: now - time,
            size: board.size,
          );

          widget.onSolve?.call(result);

          stop();
        }
      }
    });
  }

  /// Resets the board, keeping the `isPlaying` state
  /// the same.
  void reset() {
    setState(() {
      int timeFuture;
      if (isPlaying()) {
        final now = DateTime.now().millisecondsSinceEpoch;
        timeFuture = now;
      } else {
        timeFuture = timeStopped;
      }

      Board boardFuture;
      if (isPlaying()) {
        boardFuture =
            game.shuffle(game.hardest(board), amount: board.size * board.size);
      } else {
        boardFuture = _createBoard(board.size);
      }

      time = timeFuture;
      steps = 0;
      board = boardFuture;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        try {
          _saveState();
        } on Exception {
          // Ignored
        }
        break;
      default:
        break;
    }
  }

  void _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final serializer = MapSerializeOutput();

    // Write the delta of time, so user can not close the app, change
    // time and go back so easily.
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedTime = now - time;

    serializer.writeInt(elapsedTime);
    serializer.writeInt(time);
    serializer.writeInt(steps);
    serializer.writeSerializable(board);

    final plainText = serializer.toJsonString();
    final encryptedText = _encrypter.encrypt(plainText, iv: _salsaIv).base64;
    prefs.setString(_keyState, encryptedText);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final GamePresenterWidgetState data;

  const _InheritedStateContainer({
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
