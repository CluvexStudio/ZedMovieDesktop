import 'package:flutter/foundation.dart';
import '../models/series.dart';
import '../models/genre.dart';
import '../models/season.dart';
import '../models/filter_type.dart';
import '../services/api_service.dart';

class SeriesProvider with ChangeNotifier {
  List<Series> _series = [];
  List<Genre> _genres = [];
  List<Season> _seasons = [];
  bool _isLoading = false;
  bool _isSeasonsLoading = false;
  String? _error;
  int _currentPage = 0;
  int _selectedGenreId = 0;
  FilterType _filterType = FilterType.latest;
  bool _hasMore = true;

  List<Series> get series => _series;
  List<Genre> get genres => _genres;
  List<Season> get seasons => _seasons;
  bool get isLoading => _isLoading;
  bool get isSeasonsLoading => _isSeasonsLoading;
  String? get error => _error;
  int get selectedGenreId => _selectedGenreId;
  FilterType get filterType => _filterType;
  bool get hasMore => _hasMore;

  Future<void> loadGenres() async {
    if (_genres.isNotEmpty) return;
    
    try {
      _genres = await ApiService.getGenres();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadSeries({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    if (refresh) {
      _currentPage = 0;
      _series = [];
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newSeries = await ApiService.getSeries(
        page: _currentPage,
        genreId: _selectedGenreId,
        filterType: _filterType,
      );

      if (newSeries.isEmpty) {
        _hasMore = false;
      } else {
        _series.addAll(newSeries);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSeasons(int seriesId) async {
    _isSeasonsLoading = true;
    _seasons = [];
    notifyListeners();

    try {
      _seasons = await ApiService.getSeasons(seriesId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSeasonsLoading = false;
      notifyListeners();
    }
  }

  void setGenreFilter(int genreId) {
    if (_selectedGenreId != genreId) {
      _selectedGenreId = genreId;
      loadSeries(refresh: true);
    }
  }

  void setFilterType(FilterType type) {
    if (_filterType != type) {
      _filterType = type;
      loadSeries(refresh: true);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSeasons() {
    _seasons = [];
    notifyListeners();
  }
}

