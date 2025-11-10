import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class HistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await StorageService.getHistory();
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToHistory(Map<String, dynamic> item) async {
    await StorageService.addToHistory(item);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await StorageService.clearHistory();
    _history.clear();
    notifyListeners();
  }

  Future<void> removeFromHistory(int id, String type) async {
    final history = await StorageService.getHistory();
    history.removeWhere((h) => h['id'] == id && h['type'] == type);
    await StorageService.prefs.setString('watch_history', '${history}');
    await loadHistory();
  }
}
