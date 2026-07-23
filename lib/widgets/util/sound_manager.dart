import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays the app's short sound effects. Mirrors [AdsManager]'s simplicity —
/// no internal enabled/disabled state; callers check [ConfigUiContainerState.
/// isSoundEnabled] before calling, the same way ad gating is checked at call
/// sites rather than inside the manager.
abstract final class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playMove() => _play('sounds/move.wav');

  static Future<void> playVictory() => _play('sounds/victory.wav');

  static Future<void> _play(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('SoundManager: failed to play $assetPath: $e');
    }
  }
}
