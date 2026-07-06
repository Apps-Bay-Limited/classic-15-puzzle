import 'dart:io';

import 'package:classic_15_puzzle/utils/platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _leaderboard3x3 = 'CgkI25T8-IoFEAIQBQ';
const _leaderboard4x4 = 'CgkI25T8-IoFEAIQBg';
const _leaderboard5x5 = 'CgkI25T8-IoFEAIQBw';

class PlayGames {
  /// Returns the key to a leaderboard
  /// of a puzzle
  static String getLeaderboardOfSize(int size) {
    String? id;
    if (size == 3) {
      id = _leaderboard3x3;
    } else if (size == 4) {
      id = _leaderboard4x4;
    } else if (size == 5) {
      id = _leaderboard5x5;
    }

    return id ?? "";
  }
}

class PlayGamesContainer extends StatefulWidget {
  final Widget child;

  const PlayGamesContainer({super.key, required this.child});

  static PlayGamesContainerState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        ?.data;
  }

  @override
  PlayGamesContainerState createState() => PlayGamesContainerState();
}

class PlayGamesContainerState extends State<PlayGamesContainer> {
  static const playGames =
      MethodChannel('com.artemchep.flutter/google_play_games');

  bool isSupported = false;

  @override
  void initState() {
    super.initState();

    () async {
      final result = await () async {
        if (_isSupportedInternal()) {
          try {
            return await playGames.invokeMethod("isSupported");
          } on MissingPluginException {
            debugPrint("Play Games plugin not found.");
          } on PlatformException {
            // Ignored
          }
        }
        return false;
      }();

      setState(() {
        isSupported = result;
      });
    }();
  }

  void submitScore({required String key, required int time}) async {
    if (_isSupportedInternal()) {
      try {
        await playGames.invokeMethod(
          'submitScore',
          <String, dynamic>{
            'id': key,
            'score': time,
          },
        );
      } on PlatformException {
        // Ignored
      }
    }
  }

  void showLeaderboard({required String key}) async {
    if (_isSupportedInternal()) {
      try {
        await playGames.invokeMethod(
          "showLeaderboard",
          <String, dynamic>{
            'id': key,
          },
        );
      } on PlatformException {
        // Ignored
      }
    }
  }

  bool _isSupportedInternal() => platformCheck(() => Platform.isAndroid);

  // So the WidgetTree is actually
  // AppStateContainer --> InheritedStateContainer --> The rest of an app.
  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final PlayGamesContainerState data;

  const _InheritedStateContainer({
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
