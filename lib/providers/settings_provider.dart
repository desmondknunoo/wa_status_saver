import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_active';
  static const String _autoSaveKey = 'auto_save_active';

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsActive = true;
  bool _autoSaveActive = false;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsActive => _notificationsActive;
  bool get autoSaveActive => _autoSaveActive;
  bool get isInitialized => _isInitialized;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeIndex =
        _prefs.getInt(_themeModeKey) ?? 0; // 0: system, 1: light, 2: dark
    _themeMode = ThemeMode.values[themeIndex];

    // Load other settings
    _notificationsActive = _prefs.getBool(_notificationsKey) ?? true;
    _autoSaveActive = _prefs.getBool(_autoSaveKey) ?? false;

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setNotificationsActive(bool value) async {
    _notificationsActive = value;
    await _prefs.setBool(_notificationsKey, value);
    notifyListeners();
  }

  Future<void> setAutoSaveActive(bool value) async {
    _autoSaveActive = value;
    await _prefs.setBool(_autoSaveKey, value);
    notifyListeners();
  }
}
