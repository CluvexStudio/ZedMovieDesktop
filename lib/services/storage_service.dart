import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../models/series.dart';

class StorageService {
  static const String _favoritesKey = 'favorites_list';
  static const String _historyKey = 'watch_history';
  static const String _resumeKey = 'resume_positions';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'app_language';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return _prefs!;
  }

  static Future<void> addToFavorites(Map<String, dynamic> item) async {
    final favorites = await getFavorites();
    final exists = favorites.any((f) => f['id'] == item['id'] && f['type'] == item['type']);
    
    if (!exists) {
      favorites.add({
        'id': item['id'],
        'type': item['type'],
        'title': item['title'],
        'image': item['image'],
        'imdb': item['imdb'],
        'year': item['year'],
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      });
      await prefs.setString(_favoritesKey, jsonEncode(favorites));
    }
  }

  static Future<void> removeFromFavorites(int id, String type) async {
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f['id'] == id && f['type'] == type);
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final data = prefs.getString(_favoritesKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<bool> isFavorite(int id, String type) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f['id'] == id && f['type'] == type);
  }

  static Future<void> addToHistory(Map<String, dynamic> item) async {
    final history = await getHistory();
    history.removeWhere((h) => h['id'] == item['id'] && h['type'] == item['type']);
    
    history.insert(0, {
      'id': item['id'],
      'type': item['type'],
      'title': item['title'],
      'image': item['image'],
      'watchedAt': DateTime.now().millisecondsSinceEpoch,
    });
    
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final data = prefs.getString(_historyKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<void> clearHistory() async {
    await prefs.remove(_historyKey);
  }

  static Future<void> saveResumePosition(int id, String type, Duration position, Duration duration) async {
    final positions = await getResumePositions();
    positions['${type}_$id'] = {
      'position': position.inSeconds,
      'duration': duration.inSeconds,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_resumeKey, jsonEncode(positions));
  }

  static Future<Map<String, dynamic>> getResumePositions() async {
    final data = prefs.getString(_resumeKey);
    if (data == null) return {};
    return Map<String, dynamic>.from(jsonDecode(data));
  }

  static Future<Duration?> getResumePosition(int id, String type) async {
    final positions = await getResumePositions();
    final key = '${type}_$id';
    if (positions.containsKey(key)) {
      final pos = positions[key]['position'] as int;
      return Duration(seconds: pos);
    }
    return null;
  }

  static Future<void> clearResumePosition(int id, String type) async {
    final positions = await getResumePositions();
    positions.remove('${type}_$id');
    await prefs.setString(_resumeKey, jsonEncode(positions));
  }

  static Future<void> setThemeMode(String mode) async {
    await prefs.setString(_themeKey, mode);
  }

  static String getThemeMode() {
    return prefs.getString(_themeKey) ?? 'system';
  }

  static Future<void> setLanguage(String language) async {
    await prefs.setString(_languageKey, language);
  }

  static String getLanguage() {
    return prefs.getString(_languageKey) ?? 'en';
  }
}
