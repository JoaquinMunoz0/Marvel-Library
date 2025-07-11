import 'dart:convert';
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

  static const _favoritesKey = 'favoriteCharacters';

  static Future<void> saveFavoriteCharacters(List<Map<String, dynamic>> characters) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedCharacters = characters.map((c) => jsonEncode(c)).toList();
    await prefs.setStringList(_favoritesKey, encodedCharacters);
  }

  static Future<List<Map<String, dynamic>>> loadFavoriteCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedCharacters = prefs.getStringList(_favoritesKey);
    if (encodedCharacters == null) return [];
    return encodedCharacters.map((c) => jsonDecode(c) as Map<String, dynamic>).toList();
  }

  static Future<void> addFavoriteCharacter(Map<String, dynamic> character) async {
    final current = await loadFavoriteCharacters();
    if (current.any((c) => c['id'] == character['id'])) return;
    current.add({
      'id': character['id'],
      'name': character['name'],
      'thumbnail': character['thumbnail'],
    });
    await saveFavoriteCharacters(current);
  }

  static Future<void> removeFavoriteCharacter(int id) async {
    final current = await loadFavoriteCharacters();
    current.removeWhere((c) => c['id'] == id);
    await saveFavoriteCharacters(current);
  }

  static Future<bool> isFavorite(int id) async {
    final current = await loadFavoriteCharacters();
    return current.any((c) => c['id'] == id);
  }

  static const _favoriteComicsKey = 'favoriteComics';

  static Future<void> saveFavoriteComics(List<Map<String, dynamic>> comics) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedComics = comics.map((c) => jsonEncode(c)).toList();
    await prefs.setStringList(_favoriteComicsKey, encodedComics);
  }

  static Future<List<Map<String, dynamic>>> loadFavoriteComics() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedComics = prefs.getStringList(_favoriteComicsKey);

    if (encodedComics == null) return [];

    return encodedComics.map((c) => jsonDecode(c) as Map<String, dynamic>).toList();
  }

  static Future<void> addFavoriteComic(Map<String, dynamic> comic) async {
    final current = await loadFavoriteComics();
    if (current.any((c) => c['id'] == comic['id'])) return;

    current.add({
      'id': comic['id'],
      'title': comic['title'],
      'thumbnail': comic['thumbnail'],
    });

    await saveFavoriteComics(current);
  }

  static Future<void> removeFavoriteComic(int id) async {
    final current = await loadFavoriteComics();
    current.removeWhere((c) => c['id'] == id);
    await saveFavoriteComics(current);
  }

  static Future<bool> isComicFavorite(int id) async {
    final current = await loadFavoriteComics();
    return current.any((c) => c['id'] == id);
  }

  
}
