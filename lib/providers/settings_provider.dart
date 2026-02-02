import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _autoSaveKey = 'auto_save';
  static const String _notificationsKey = 'notifications';

  ThemeMode _themeMode = ThemeMode.system;
  bool _autoSave = false;
  bool _notifications = true;

  ThemeMode get themeMode => _themeMode;
  bool get autoSave => _autoSave;
  bool get notifications => _notifications;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];

    _autoSave = prefs.getBool(_autoSaveKey) ?? false;
    _notifications = prefs.getBool(_notificationsKey) ?? true;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> setAutoSave(bool value) async {
    _autoSave = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSaveKey, value);
  }

  Future<void> setNotifications(bool value) async {
    _notifications = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }
}
