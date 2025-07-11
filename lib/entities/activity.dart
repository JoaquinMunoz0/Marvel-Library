import 'package:shared_preferences/shared_preferences.dart';

class ActivityPreferences {
  static const _heroCountKey = 'heroCount';
  static const _usernameKey = 'username';

  static Future<int> loadHeroCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_heroCountKey) ?? 30;
  }

  static Future<void> saveHeroCount(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_heroCountKey, value);
  }

  static Future<String> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? 'Nombre de Usuario';
  }

  static Future<void> saveUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, name);
  }
}
