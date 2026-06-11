import 'package:flutter/material.dart';

import '../services/local_store.dart';

/// App-wide preferences: theme mode, units, and notification toggle.
/// Persisted locally so they apply to guests and signed-in users alike.
class SettingsState extends ChangeNotifier {
  SettingsState(this._store)
      : _themeMode = _parseTheme(_store.themeMode),
        _unitsMetric = _store.unitsMetric,
        _notificationsEnabled = _store.notificationsEnabled;

  final LocalStore _store;

  ThemeMode _themeMode;
  bool _unitsMetric;
  bool _notificationsEnabled;

  ThemeMode get themeMode => _themeMode;
  bool get unitsMetric => _unitsMetric;
  bool get notificationsEnabled => _notificationsEnabled;

  static ThemeMode _parseTheme(String raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _store.setThemeMode(mode.name);
    notifyListeners();
  }

  Future<void> setUnitsMetric(bool metric) async {
    _unitsMetric = metric;
    await _store.setUnitsMetric(metric);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _store.setNotificationsEnabled(enabled);
    notifyListeners();
  }
}
