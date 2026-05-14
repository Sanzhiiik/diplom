import 'package:flutter/material.dart';

/// Настройки приложения — хранит все пользовательские предпочтения
/// В будущем можно сохранять через SharedPreferences
class AppSettings extends ChangeNotifier {
  // =================== ТЕМА ===================
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // =================== ПОРОГИ РАССТОЯНИЙ ===================
  double _dangerThreshold = 5.0; // метров — красная зона
  double _warningThreshold = 10.0; // метров — жёлтая зона

  double get dangerThreshold => _dangerThreshold;
  double get warningThreshold => _warningThreshold;

  void setDangerThreshold(double value) {
    _dangerThreshold = value.clamp(1.0, _warningThreshold - 1);
    notifyListeners();
  }

  void setWarningThreshold(double value) {
    _warningThreshold = value.clamp(_dangerThreshold + 1, 30.0);
    notifyListeners();
  }

  // =================== ЗВУК И ВИБРАЦИЯ ===================
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  void setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    notifyListeners();
  }

  // =================== ЯЗЫК ===================
  String _language = 'ru';
  String get language => _language;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  // =================== КУЛДАУН ОПОВЕЩЕНИЙ ===================
  int _alertCooldownSeconds = 10;
  int get alertCooldownSeconds => _alertCooldownSeconds;

  void setAlertCooldown(int seconds) {
    _alertCooldownSeconds = seconds.clamp(3, 60);
    notifyListeners();
  }
}
