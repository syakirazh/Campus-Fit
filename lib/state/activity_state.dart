import 'dart:developer';

import 'package:flutter/material.dart';

import '../models/daily_steps.dart';
import '../services/database_service.dart';
import '../services/local_store.dart';
import '../services/step_service.dart';

/// Owns step tracking, history, streak, and the workouts-completed counter.
///
/// Steps are stored locally per day; when a user is signed in the same data is
/// mirrored to the Realtime Database under their uid. The active uid is set via
/// [attachUser] (driven by a ChangeNotifierProxyProvider on [SessionState]).
class ActivityState extends ChangeNotifier {
  ActivityState({
    required StepService stepService,
    required DatabaseService database,
    required LocalStore store,
  })  : _stepService = stepService,
        _database = database,
        _store = store {
    _stepsByDay = Map<String, int>.from(_store.stepsByDay);
    _stepGoal = _store.stepGoal;
    _workoutsCompleted = _store.workoutsCompleted;
  }

  final StepService _stepService;
  final DatabaseService _database;
  final LocalStore _store;

  Map<String, int> _stepsByDay = {};
  int _stepGoal = 8000;
  int _workoutsCompleted = 0;
  String? _uid;
  bool _permissionGranted = false;
  bool _sensorAvailable = true;

  // --- Public reads ----------------------------------------------------------
  int get stepGoal => _stepGoal;
  int get workoutsCompleted => _workoutsCompleted;
  bool get permissionGranted => _permissionGranted;
  bool get sensorAvailable => _sensorAvailable;

  String get _todayKey => DailySteps.isoKey(DateTime.now());
  int get todaySteps => _stepsByDay[_todayKey] ?? 0;

  double get goalProgress =>
      _stepGoal == 0 ? 0 : (todaySteps / _stepGoal).clamp(0.0, 1.0);

  DailySteps get today =>
      DailySteps(date: DateTime.now(), steps: todaySteps);

  int get lifetimeSteps =>
      _stepsByDay.values.fold(0, (sum, v) => sum + v);

  /// Last [days] days of step data, oldest first, filling gaps with zero.
  List<DailySteps> history({int days = 7}) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: days - 1 - i));
      return DailySteps(date: d, steps: _stepsByDay[DailySteps.isoKey(d)] ?? 0);
    });
  }

  double averageSteps({int days = 7}) {
    final h = history(days: days);
    if (h.isEmpty) return 0;
    return h.fold<int>(0, (s, d) => s + d.steps) / h.length;
  }

  /// Consecutive days up to today that met the step goal.
  int get streak {
    var count = 0;
    final now = DateTime.now();
    for (var i = 0; i < 365; i++) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final steps = _stepsByDay[DailySteps.isoKey(d)] ?? 0;
      if (steps >= _stepGoal) {
        count++;
      } else if (i == 0) {
        // Today not yet hit — streak can still be alive from prior days.
        continue;
      } else {
        break;
      }
    }
    return count;
  }

  // --- Sensor lifecycle ------------------------------------------------------
  Future<void> initTracking() async {
    _permissionGranted = await _stepService.requestPermission();
    notifyListeners();
    if (!_permissionGranted) return;
    _stepService.start(
      onCumulative: _onCumulativeSteps,
      onError: (_) {
        _sensorAvailable = false;
        notifyListeners();
      },
    );
  }

  /// Converts the monotonic since-boot count into "steps today" using a
  /// per-day baseline persisted in [LocalStore].
  void _onCumulativeSteps(int cumulative) {
    final todayKey = _todayKey;
    final baseline = Map<String, dynamic>.from(_store.pedometerBaseline);
    if (baseline['day'] != todayKey || baseline['base'] == null) {
      // First reading today (or after reboot) → anchor the baseline.
      baseline['day'] = todayKey;
      baseline['base'] = cumulative - (_stepsByDay[todayKey] ?? 0);
      _store.setPedometerBaseline(baseline);
    }
    final base = (baseline['base'] as num).toInt();
    var todaySteps = cumulative - base;
    if (todaySteps < 0) todaySteps = cumulative; // reboot guard
    _setSteps(todayKey, todaySteps);
  }

  void _setSteps(String key, int steps) {
    if (_stepsByDay[key] == steps) return;
    _stepsByDay[key] = steps;
    _persistSteps();
    notifyListeners();
  }

  /// Debug / manual helper to add steps when no hardware sensor is present.
  void addSimulatedSteps(int delta) {
    final key = _todayKey;
    _setSteps(key, (todaySteps + delta).clamp(0, 1 << 30));
  }

  Future<void> _persistSteps() async {
    await _store.setStepsByDay(_stepsByDay);
    if (_uid != null) {
      try {
        await _database.writeUserSteps(_uid!, _stepsByDay);
      } catch (e) {
        log('writeUserSteps failed: $e', name: 'ActivityState');
      }
    }
  }

  // --- Workouts --------------------------------------------------------------
  Future<void> recordWorkoutCompleted() async {
    _workoutsCompleted++;
    await _store.setWorkoutsCompleted(_workoutsCompleted);
    if (_uid != null) {
      try {
        await _database.writeWorkoutsCompleted(_uid!, _workoutsCompleted);
      } catch (e) {
        log('writeWorkoutsCompleted failed: $e', name: 'ActivityState');
      }
    }
    notifyListeners();
  }

  Future<void> setStepGoal(int goal) async {
    _stepGoal = goal;
    await _store.setStepGoal(goal);
    notifyListeners();
  }

  // --- Sync target -----------------------------------------------------------
  /// Called when the signed-in user changes. Pulls any cloud data down so the
  /// dashboard reflects cross-device progress.
  Future<void> attachUser(String? uid) async {
    if (_uid == uid) return;
    _uid = uid;
    if (uid == null) return;
    try {
      final data = await _database.fetchUserData(uid);
      final steps = data?['steps'];
      if (steps is Map) {
        steps.forEach((k, v) {
          final remote = (v as num).toInt();
          final local = _stepsByDay[k.toString()] ?? 0;
          _stepsByDay[k.toString()] = remote > local ? remote : local;
        });
        await _store.setStepsByDay(_stepsByDay);
      }
      final wc = data?['workoutsCompleted'];
      if (wc is num && wc.toInt() > _workoutsCompleted) {
        _workoutsCompleted = wc.toInt();
        await _store.setWorkoutsCompleted(_workoutsCompleted);
      }
      notifyListeners();
    } catch (e) {
      log('attachUser sync failed: $e', name: 'ActivityState');
    }
  }
}
