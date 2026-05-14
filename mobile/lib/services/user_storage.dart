import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Сервис хранения данных пользователя на устройстве
class UserStorage {
  static const _userKey = 'saved_user';
  static const _loggedInKey = 'is_logged_in';

  /// Сохранить пользователя и пометить как залогиненного
  static Future<void> saveUser(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJsonString());
    await prefs.setBool(_loggedInKey, true);
  }

  /// Загрузить пользователя (если залогинен)
  static Future<UserData?> loadLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_loggedInKey) ?? false;
    if (!loggedIn) return null;
    final json = prefs.getString(_userKey);
    if (json == null || json.isEmpty) return null;
    try {
      return UserData.fromJsonString(json);
    } catch (_) {
      return null;
    }
  }

  /// Загрузить сохранённого пользователя (даже если разлогинен)
  /// Для проверки при входе
  static Future<UserData?> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null || json.isEmpty) return null;
    try {
      return UserData.fromJsonString(json);
    } catch (_) {
      return null;
    }
  }

  /// Выход — НЕ удаляем данные, только снимаем флаг
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }

  /// Полное удаление данных
  static Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_loggedInKey);
  }
}
