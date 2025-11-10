import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class FavoritesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await StorageService.getFavorites();
      _favorites.sort((a, b) => (b['addedAt'] as int).compareTo(a['addedAt'] as int));
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isFavorite(int id, String type) async {
    return await StorageService.isFavorite(id, type);
  }

  Future<void> toggleFavorite(Map<String, dynamic> item) async {
    final isFav = await isFavorite(item['id'], item['type']);
    
    if (isFav) {
      await StorageService.removeFromFavorites(item['id'], item['type']);
      _favorites.removeWhere((f) => f['id'] == item['id'] && f['type'] == item['type']);
    } else {
      await StorageService.addToFavorites(item);
      _favorites.insert(0, {
        ...item,
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
    
    notifyListeners();
  }

  Future<void> removeFromFavorites(int id, String type) async {
    await StorageService.removeFromFavorites(id, type);
    _favorites.removeWhere((f) => f['id'] == id && f['type'] == type);
    notifyListeners();
  }

  Future<void> clearAll() async {
    for (var fav in _favorites) {
      await StorageService.removeFromFavorites(fav['id'], fav['type']);
    }
    _favorites.clear();
    notifyListeners();
  }
}
