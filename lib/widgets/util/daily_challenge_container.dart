import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefsKeyLastCompletedDay = 'daily::last_completed_day';
const String _prefsKeyStreak = 'daily::streak';
const String _prefsKeyBestStreak = 'daily::best_streak';

/// The grid size every daily challenge uses. Fixed so that everyone's board —
/// and therefore everyone's time — is comparable. Kept at 3x3 (8-puzzle) to
/// keep the daily challenge quick and approachable.
const int dailyChallengeBoardSize = 3;

/// Identifies a day as `yyyymmdd` in UTC, so the challenge rolls over at the
/// same instant worldwide and two players in different time zones are always
/// solving the same board.
int dailyChallengeDayKey([DateTime? now]) {
  final utc = (now ?? DateTime.now()).toUtc();
  return utc.year * 10000 + utc.month * 100 + utc.day;
}

/// Tracks the daily challenge: whether today's board has been solved, and the
/// player's consecutive-day streak.
///
/// Follows the same Container/InheritedWidget pattern as [PurchaseContainer]
/// and [ThemeUnlockContainer].
class DailyChallengeContainer extends StatefulWidget {
  final Widget child;

  /// Overrides "now", for tests.
  final DateTime Function()? clock;

  const DailyChallengeContainer({super.key, required this.child, this.clock});

  static DailyChallengeContainerState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        ?.data;
  }

  @override
  DailyChallengeContainerState createState() => DailyChallengeContainerState();
}

class DailyChallengeContainerState extends State<DailyChallengeContainer> {
  int _lastCompletedDay = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _isLoaded = false;

  DateTime _now() => widget.clock?.call() ?? DateTime.now();

  int get todayKey => dailyChallengeDayKey(_now());

  /// Seed for today's board. Every player gets the same one.
  int get todaySeed => todayKey;

  bool get isCompletedToday => _lastCompletedDay == todayKey;

  int get streak => _streak;

  int get bestStreak => _bestStreak;

  bool get isLoaded => _isLoaded;

  @override
  void initState() {
    super.initState();
    _loadPersisted();
  }

  Future<void> _loadPersisted() async {
    var lastDay = 0;
    var streak = 0;
    var bestStreak = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      lastDay = prefs.getInt(_prefsKeyLastCompletedDay) ?? 0;
      streak = prefs.getInt(_prefsKeyStreak) ?? 0;
      bestStreak = prefs.getInt(_prefsKeyBestStreak) ?? 0;
    } on Exception {
      // Ignored — a fresh streak is the safe default.
    }

    // A streak only survives if the last completion was today or yesterday.
    if (lastDay != 0 && !_isTodayOrYesterday(lastDay)) {
      streak = 0;
    }

    if (!mounted) {
      _lastCompletedDay = lastDay;
      _streak = streak;
      _bestStreak = bestStreak;
      _isLoaded = true;
      return;
    }

    setState(() {
      _lastCompletedDay = lastDay;
      _streak = streak;
      _bestStreak = bestStreak;
      _isLoaded = true;
    });
  }

  bool _isTodayOrYesterday(int dayKey) {
    if (dayKey == todayKey) return true;
    return dayKey == dailyChallengeDayKey(
      _now().toUtc().subtract(const Duration(days: 1)),
    );
  }

  /// Records today's challenge as solved and advances the streak. Idempotent —
  /// solving the same day's board twice doesn't inflate the count.
  Future<void> markCompletedToday() async {
    final today = todayKey;
    if (_lastCompletedDay == today) return;

    final yesterday = dailyChallengeDayKey(
      _now().toUtc().subtract(const Duration(days: 1)),
    );
    final nextStreak = _lastCompletedDay == yesterday ? _streak + 1 : 1;
    final nextBest = nextStreak > _bestStreak ? nextStreak : _bestStreak;

    if (mounted) {
      setState(() {
        _lastCompletedDay = today;
        _streak = nextStreak;
        _bestStreak = nextBest;
      });
    } else {
      _lastCompletedDay = today;
      _streak = nextStreak;
      _bestStreak = nextBest;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKeyLastCompletedDay, today);
      await prefs.setInt(_prefsKeyStreak, nextStreak);
      await prefs.setInt(_prefsKeyBestStreak, nextBest);
    } on Exception {
      // Ignored — the in-memory streak still applies for this session.
    }
  }

  /// Debug-only: clears daily progress so the flow can be re-tested without
  /// waiting for tomorrow. No-ops in release as a safeguard.
  Future<void> resetForDebug() async {
    if (!kDebugMode) return;

    setState(() {
      _lastCompletedDay = 0;
      _streak = 0;
      _bestStreak = 0;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKeyLastCompletedDay);
      await prefs.remove(_prefsKeyStreak);
      await prefs.remove(_prefsKeyBestStreak);
    } on Exception {
      // Ignored
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final DailyChallengeContainerState data;

  const _InheritedStateContainer({
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
