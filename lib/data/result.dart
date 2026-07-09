import 'package:flutter/foundation.dart';
import 'package:classic_15_puzzle/utils/serializable.dart';

@immutable
class Result implements Serializable {
  final int steps;
  final int time;
  final int size;
  final int timestamp;

  const Result({
    required this.steps,
    required this.time,
    required this.size,
    required this.timestamp,
  });

  @override
  void serialize(SerializeOutput output) {
    output.writeInt(steps);
    output.writeInt(time);
    output.writeInt(size);
    output.writeInt(timestamp);
  }
}

class ResultDeserializableFactory extends DeserializableHelper<Result> {
  const ResultDeserializableFactory() : super();

  @override
  Result deserialize(SerializeInput input) {
    return Result(
      steps: input.readInt(),
      time: input.readInt(),
      size: input.readInt(),
      timestamp: input.readInt(),
    );
  }
}
