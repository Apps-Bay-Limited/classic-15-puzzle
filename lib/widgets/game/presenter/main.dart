import 'dart:convert';
import 'dart:math';

import 'package:classic_15_puzzle/data/history.dart';
import 'package:classic_15_puzzle/domain/solver.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:classic_15_puzzle/data/board.dart';
import 'package:classic_15_puzzle/data/result.dart';
import 'package:classic_15_puzzle/domain/game.dart';
import 'package:classic_15_puzzle/utils/serializable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:classic_15_puzzle/config/ui.dart';
import 'package:classic_15_puzzle/widgets/util/sound_manager.dart';

class GamePresenterWidget extends StatefulWidget {
  static const supportedSizes = [3, 4, 5];

  final Widget child;

  /// Called when the board is solved. [wasDailyChallenge] is passed explicitly
  /// rather than read back off the presenter, because the flag is cleared as
  /// soon as the game stops — an async listener would otherwise miss it.
  final void Function(Result result, bool wasDailyChallenge)? onSolve;

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

  late GameHistory history;

  int steps = 0;

  int time = timeStopped;

  bool _gameActive = false;

  int _pausedMs = 0;

  int? _pauseStartedAt;

  bool _isSolving = false;

  bool _isManuallyPaused = false;

  /// Board snapshots from before each counted move, most recent last.
  ///
  /// Only moves made during an active game are pushed, so undo never rewinds
  /// past the shuffle or disagrees with [steps]. Deliberately not persisted
  /// with the rest of the game state — the stack resets on app restart.
  final List<Board> _undoStack = [];

  /// Hints available in the current game. Finite so that asking for one is a
  /// real decision; [grantHints] tops it back up (the UI offers a rewarded ad
  /// for that).
  static const int hintsPerGame = 3;

  int _hintsRemaining = hintsPerGame;

  /// Whether the current game is today's daily challenge, so [onSolve] can
  /// tell the caller to advance the streak.
  bool _isDailyChallenge = false;

  bool get isDailyChallenge => _isDailyChallenge;

  bool get isSolving => _isSolving;

  int get hintsRemaining => _hintsRemaining;

  /// Whether a hint can be spent right now (there's an active, unsolved game
  /// and budget left).
  bool get canUseHint =>
      _gameActive &&
      !_isManuallyPaused &&
      !_isSolving &&
      !board.isSolved() &&
      _hintsRemaining > 0;

  /// Tops the hint budget back up, e.g. after the player watches a rewarded
  /// ad. Capped at [hintsPerGame] so it can't be stockpiled indefinitely.
  void grantHints(int amount) {
    if (amount <= 0) return;
    setState(() {
      _hintsRemaining = min(hintsPerGame, _hintsRemaining + amount);
    });
  }

  /// Test-only: spends a hint without running the A* solver, so budget
  /// behavior can be exercised without paying for an isolate search.
  @visibleForTesting
  void debugSpendHint() {
    if (_hintsRemaining <= 0) return;
    setState(() {
      _hintsRemaining -= 1;
    });
  }

  static const hintPauseDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    board = _createBoard(4);
    history = GameHistory.empty();

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
    GameHistory? history;

    try {
      final deserializer = MapSerializeInput(map: jsonMap);
      const boardFactory = BoardDeserializableFactory();
      const historyFactory = GameHistoryDeserializableFactory();
      
      elapsedTime = deserializer.readInt();
      time = deserializer.readInt();
      steps = deserializer.readInt();
      board = deserializer.readDeserializable(boardFactory);
      history = deserializer.readDeserializable(historyFactory);
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
      this.history = history ?? GameHistory.empty();
      _gameActive = (this.time != timeStopped) || (this.steps > 0);
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
    setState(() {
      _resetForNewGame();
      _isDailyChallenge = false;
      _gameActive = true;
      board =
          game.shuffle(game.hardest(board), amount: board.size * board.size);
    });
  }

  /// Starts the daily challenge: a board generated purely from [seed], so
  /// every player on the same day solves an identical puzzle.
  void playDaily({required int seed, required int size}) {
    setState(() {
      _resetForNewGame();
      _isDailyChallenge = true;
      _gameActive = true;
      final board = _createBoard(size);
      this.board = game.shuffle(
        game.hardest(board, random: Random(seed)),
        amount: size * size,
        random: Random(seed),
      );
    });
  }

  void _resetForNewGame() {
    time = timeStopped;
    steps = 0;
    _pausedMs = 0;
    _pauseStartedAt = null;
    _isManuallyPaused = false;
    _undoStack.clear();
    _hintsRemaining = hintsPerGame;
  }

  void stop() {
    setState(() {
      time = timeStopped;
      steps = 0;
      _gameActive = false;
      _pausedMs = 0;
      _pauseStartedAt = null;
      _isManuallyPaused = false;
      _undoStack.clear();
      _isDailyChallenge = false;
    });
  }

  bool isPlaying() => time != timeStopped;

  bool get isGameActive => _gameActive;

  bool get isManuallyPaused => _isManuallyPaused;

  /// Whether there's a counted move available to take back right now.
  bool get canUndo =>
      _gameActive &&
      !_isManuallyPaused &&
      !_isSolving &&
      _undoStack.isNotEmpty;

  /// Takes back the last counted move, restoring both the board and the step
  /// count. The clock keeps running — undo costs time, not moves.
  void undo() {
    if (!canUndo) return;

    final previous = _undoStack.removeLast();

    if (ConfigUiContainer.of(context)?.isSoundEnabled ?? true) {
      SoundManager.playMove();
    }

    setState(() {
      board = previous;
      if (steps > 0) steps -= 1;
    });
  }

  /// Pauses (blurring the board and freezing the timer) or resumes.
  /// A no-op if there's no active game to pause.
  void togglePause() {
    if (_isManuallyPaused) {
      _resumeFromManualPause();
    } else {
      _pauseManually();
    }
  }

  void _pauseManually() {
    if (!isPlaying() || _isManuallyPaused) return;
    setState(() {
      _isManuallyPaused = true;
      _pauseStartedAt ??= DateTime.now().millisecondsSinceEpoch;
    });
  }

  void _resumeFromManualPause() {
    if (!_isManuallyPaused) return;
    setState(() {
      _isManuallyPaused = false;
      if (_pauseStartedAt != null) {
        _pausedMs += DateTime.now().millisecondsSinceEpoch - _pauseStartedAt!;
        _pauseStartedAt = null;
      }
    });
  }

  int get elapsedMs {
    if (time == timeStopped) return 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    var paused = _pausedMs;
    if (_pauseStartedAt != null) {
      paused += now - _pauseStartedAt!;
    }
    return max(0, now - time - paused);
  }

  bool get isTimerTicking =>
      isPlaying() || _pauseStartedAt != null;

  void resize(int size) {
    setState(() {
      time = timeStopped;
      steps = 0;
      _pausedMs = 0;
      _pauseStartedAt = null;
      _isManuallyPaused = false;
      _undoStack.clear();
      _hintsRemaining = hintsPerGame;
      _isDailyChallenge = false;
      _gameActive = false;
      board = _createBoard(size);
    });
  }

  void tap({required Point<int> point}) {
    if (_isManuallyPaused) return;

    final prevBoard = board;
    final nextBoard = game.tap(board, point: point);

    if (prevBoard == nextBoard) return;

    if (ConfigUiContainer.of(context)?.isSoundEnabled ?? true) {
      SoundManager.playMove();
    }

    setState(() {
      if (_gameActive && !isPlaying()) {
        time = DateTime.now().millisecondsSinceEpoch;
      }

      if (_gameActive) {
        _undoStack.add(prevBoard);
      }

      board = nextBoard;

      if (_gameActive) {
        steps = steps + 1;

        if (board.isSolved()) {
          final result = Result(
            steps: steps,
            time: elapsedMs,
            size: board.size,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          );

          history.addResult(result);
          widget.onSolve?.call(result, _isDailyChallenge);

          stop();
        }
      }
    });
  }

  Future<void> hint() async {
    if (!canUseHint) return;

    setState(() {
      _isSolving = true;
    });

    try {
      final nextMove = await compute(PuzzleSolver.findNextMove, board);
      if (nextMove == null) {
        if (mounted) {
          setState(() {
            _isSolving = false;
          });
        }
        return;
      }

      // Only spend from the budget once the solver actually found a move.
      if (mounted) {
        setState(() {
          _hintsRemaining = max(0, _hintsRemaining - 1);
        });
      }

      if (isPlaying()) {
        await _pauseTimerFor(hintPauseDuration);
      }

      if (mounted) {
        tap(point: nextMove);
        setState(() {
          _isSolving = false;
        });
      }
    } catch (e) {
      debugPrint("Error computing hint: $e");
      if (mounted) {
        setState(() {
          _isSolving = false;
        });
      }
    }
  }

  Future<void> _pauseTimerFor(Duration duration) async {
    if (!isPlaying()) return;

    _pauseStartedAt = DateTime.now().millisecondsSinceEpoch;
    setState(() {});

    await Future<void>.delayed(duration);

    if (!mounted) return;

    _pausedMs += DateTime.now().millisecondsSinceEpoch - _pauseStartedAt!;
    _pauseStartedAt = null;
    setState(() {});
  }

  /// Resets the board, keeping the `isPlaying` state
  /// the same.
  void reset() {
    setState(() {
      final keepActive = _gameActive;
      time = timeStopped;
      _pausedMs = 0;
      _pauseStartedAt = null;
      _undoStack.clear();
      _hintsRemaining = hintsPerGame;

      Board boardFuture;
      if (keepActive) {
        boardFuture =
            game.shuffle(game.hardest(board), amount: board.size * board.size);
      } else {
        boardFuture = _createBoard(board.size);
      }

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
    final elapsedTime = elapsedMs;

    serializer.writeInt(elapsedTime);
    serializer.writeInt(time);
    serializer.writeInt(steps);
    serializer.writeSerializable(board);
    serializer.writeSerializable(history);

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
