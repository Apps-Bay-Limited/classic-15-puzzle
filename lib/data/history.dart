import 'package:classic_15_puzzle/utils/serializable.dart';
import 'result.dart';

class GameHistory implements Serializable {
  final List<Result> log;
  final Map<int, Result> bestTime;
  final Map<int, Result> bestMoves;

  GameHistory({
    required this.log,
    required this.bestTime,
    required this.bestMoves,
  });

  factory GameHistory.empty() => GameHistory(
        log: [],
        bestTime: {},
        bestMoves: {},
      );

  void addResult(Result result) {
    // Add to log, keeping only last 100
    log.insert(0, result);
    if (log.length > 100) {
      log.removeLast();
    }

    // Update best time
    final currentBestTime = bestTime[result.size];
    if (currentBestTime == null || result.time < currentBestTime.time) {
      bestTime[result.size] = result;
    }

    // Update best moves
    final currentBestMoves = bestMoves[result.size];
    if (currentBestMoves == null || result.steps < currentBestMoves.steps) {
      bestMoves[result.size] = result;
    }
  }

  @override
  void serialize(SerializeOutput output) {
    output.writeInt(log.length);
    for (final result in log) {
      output.writeSerializable(result);
    }

    output.writeInt(bestTime.length);
    bestTime.forEach((size, result) {
      output.writeInt(size);
      output.writeSerializable(result);
    });

    output.writeInt(bestMoves.length);
    bestMoves.forEach((size, result) {
      output.writeInt(size);
      output.writeSerializable(result);
    });
  }
}

class GameHistoryDeserializableFactory extends DeserializableHelper<GameHistory> {
  const GameHistoryDeserializableFactory() : super();

  @override
  GameHistory deserialize(SerializeInput input) {
    final logCount = input.readInt();
    const resultFactory = ResultDeserializableFactory();
    final log = List<Result>.generate(logCount, (_) => input.readDeserializable(resultFactory));

    final bestTimeCount = input.readInt();
    final bestTime = <int, Result>{};
    for (var i = 0; i < bestTimeCount; i++) {
      final size = input.readInt();
      bestTime[size] = input.readDeserializable(resultFactory);
    }

    final bestMovesCount = input.readInt();
    final bestMoves = <int, Result>{};
    for (var i = 0; i < bestMovesCount; i++) {
      final size = input.readInt();
      bestMoves[size] = input.readDeserializable(resultFactory);
    }

    return GameHistory(log: log, bestTime: bestTime, bestMoves: bestMoves);
  }
}
