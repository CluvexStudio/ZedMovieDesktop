import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../models/genre.dart';
import '../models/filter_type.dart';
import '../services/api_service.dart';

class MovieProvider with ChangeNotifier {
  List<Movie> _movies = [];
  List<Genre> _genres = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  int _selectedGenreId = 0;
  FilterType _filterType = FilterType.latest;
  bool _hasMore = true;

  List<Movie> get movies => _movies;
  List<Genre> get genres => _genres;
  bool get isLoading => _isLoading;
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

  Future<void> loadMovies({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    if (refresh) {
      _currentPage = 0;
      _movies = [];
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMovies = await ApiService.getMovies(
        page: _currentPage,
        genreId: _selectedGenreId,
        filterType: _filterType,
      );

      if (newMovies.isEmpty) {
        _hasMore = false;
      } else {
        _movies.addAll(newMovies);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setGenreFilter(int genreId) {
    if (_selectedGenreId != genreId) {
      _selectedGenreId = genreId;
      loadMovies(refresh: true);
    }
  }

  void setFilterType(FilterType type) {
    if (_filterType != type) {
      _filterType = type;
      loadMovies(refresh: true);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

