import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class Serializable {
  void serialize(SerializeOutput output);
}

abstract class DeserializableHelper<T> {
  const DeserializableHelper();

  T deserialize(SerializeInput input);
}

abstract class SerializeOutput {
  void writeInt(int value);

  void writeString(String value);

  void writeSerializable(Serializable value);
}

abstract class SerializeInput {
  int readInt();

  String readString();

  T readDeserializable<T>(DeserializableHelper<T> helper);
}

const _divider = "_";

class SharedPrefSerializeOutput extends SerializeOutput {
  final String key;

  final SharedPreferences? prefs;

  int counter = 0;

  SharedPrefSerializeOutput({required this.key, this.prefs});

  @override
  void writeInt(int value) {
    write((prefs, key) {
      prefs.setInt(key, value);
    });
  }

  @override
  void writeString(String value) {
    write((prefs, key) {
      prefs.setString(key, value);
    });
  }

  @override
  void writeSerializable(Serializable value) {
    write((prefs, key) {
      final worker = SharedPrefSerializeOutput(
        key: key + _divider,
        prefs: prefs,
      );

      value.serialize(worker);
    });
  }

  void write(Function(SharedPreferences, String) block) {
    final key = this.key + counter.toString();
    counter++;

    final prefs = this.prefs;
    if (prefs != null) {
      block(prefs, key);
    }
  }
}

class SharedPrefSerializeInput extends SerializeInput {
  final String key;

  final SharedPreferences? prefs;

  int counter = 0;

  SharedPrefSerializeInput({required this.key, this.prefs});

  @override
  int readInt() => read((prefs, key) => prefs.getInt(key)) ?? 0;

  @override
  String readString() => read((prefs, key) => prefs.getString(key)) ?? "";

  @override
  T readDeserializable<T>(DeserializableHelper<T> helper) {
    return read((prefs, key) {
      final worker = SharedPrefSerializeInput(
        key: key + _divider,
        prefs: prefs,
      );

      return helper.deserialize(worker);
    })!;
  }

  T? read<T>(T? Function(SharedPreferences, String) block) {
    final key = this.key + counter.toString();
    counter++;

    final prefs = this.prefs;
    if (prefs != null) {
      return block(prefs, key);
    }
    return null;
  }
}

class MapSerializeOutput extends SerializeOutput {
  final String key;

  final Map<String, dynamic> map;

  int counter = 0;

  MapSerializeOutput({this.key = "", Map<String, dynamic>? map}) : map = map ?? <String, dynamic>{};

  @override
  void writeInt(int value) {
    write((key) {
      map[key] = value;
    });
  }

  @override
  void writeString(String value) {
    write((key) {
      map[key] = value;
    });
  }

  @override
  void writeSerializable(Serializable value) {
    write((key) {
      final worker = MapSerializeOutput(
        key: key + _divider,
        map: map,
      );

      value.serialize(worker);
    });
  }

  void write(Function(String) block) {
    final key = this.key + counter.toString();
    counter++;

    block(key);
  }

  String toJsonString() => json.encode(map);
}

class MapSerializeInput extends SerializeInput {
  final String key;

  final Map<String, dynamic> map;

  int counter = 0;

  MapSerializeInput({this.key = "", required this.map});

  @override
  int readInt() => read((key) => map[key]);

  @override
  String readString() => read((key) => map[key]);

  @override
  T readDeserializable<T>(DeserializableHelper<T> helper) {
    return read((key) {
      final worker = MapSerializeInput(
        key: key + _divider,
        map: map,
      );

      return helper.deserialize(worker);
    });
  }

  T read<T>(T Function(String) block) {
    final key = this.key + counter.toString();
    counter++;

    return block(key);
  }
}
