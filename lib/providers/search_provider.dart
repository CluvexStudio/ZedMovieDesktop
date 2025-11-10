import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class SearchProvider with ChangeNotifier {
  List<dynamic> _results = [];
  bool _isLoading = false;
  String? _error;
  String _lastQuery = '';

  List<dynamic> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get lastQuery => _lastQuery;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _results = [];
      _lastQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _lastQuery = query;
    notifyListeners();

    try {
      _results = await ApiService.search(query);
    } catch (e) {
      _error = e.toString();
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _results = [];
    _lastQuery = '';
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

