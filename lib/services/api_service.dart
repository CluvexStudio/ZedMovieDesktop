import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/series.dart';
import '../models/genre.dart';
import '../models/country.dart';
import '../models/season.dart';
import '../models/filter_type.dart';

class ApiService {
  static const String apiKey = '4F5A9C3D9A86FA54EACEDDD635185';
  static const String baseUrl = 'https://hostinnegar.com/api';
  static const String helperServer = 'https://server-hi-speed-iran.info/api';
  
  static final http.Client _client = http.Client();

  static Future<dynamic> _makeRequest(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      try {
        final helperUrl = url.replaceFirst(baseUrl, helperServer);
        final response = await _client.get(
          Uri.parse(helperUrl),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          return json.decode(response.body);
        }
      } catch (_) {}
      
      throw Exception('Failed to load data: $e');
    }
  }

  static Future<List<Movie>> getMovies({
    int page = 0,
    int genreId = 0,
    FilterType filterType = FilterType.latest,
  }) async {
    String filterPath;
    switch (filterType) {
      case FilterType.latest:
        filterPath = 'created';
        break;
      case FilterType.byYear:
        filterPath = 'year';
        page = 0;
        break;
      case FilterType.byImdb:
        filterPath = 'imdb';
        page = 0;
        break;
    }

    final url = '$baseUrl/movie/by/filtres/$genreId/$filterPath/$page/$apiKey';
    final data = await _makeRequest(url);
    
    if (data is List) {
      return data.map((json) => Movie.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Series>> getSeries({
    int page = 0,
    int genreId = 0,
    FilterType filterType = FilterType.latest,
  }) async {
    String filterPath;
    switch (filterType) {
      case FilterType.latest:
        filterPath = 'created';
        break;
      case FilterType.byYear:
        filterPath = 'year';
        page = 0;
        break;
      case FilterType.byImdb:
        filterPath = 'imdb';
        page = 0;
        break;
    }

    final url = '$baseUrl/serie/by/filtres/$genreId/$filterPath/$page/$apiKey';
    final data = await _makeRequest(url);
    
    if (data is List) {
      return data.map((json) => Series.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Genre>> getGenres({int page = 0}) async {
    final url = '$baseUrl/genre/all/$page/$apiKey/';
    final data = await _makeRequest(url);
    
    if (data is List) {
      return data.map((json) => Genre.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Country>> getCountries() async {
    final url = '$baseUrl/country/all/$apiKey/';
    final data = await _makeRequest(url);
    
    if (data is List) {
      return data.map((json) => Country.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Season>> getSeasons(int seriesId) async {
    final url = '$baseUrl/season/by/serie/$seriesId/$apiKey/';
    final data = await _makeRequest(url);
    
    if (data is List) {
      return data.map((json) => Season.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<dynamic>> search(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = '$baseUrl/search/$encodedQuery/$apiKey/';
    final data = await _makeRequest(url);
    
    if (data is Map && data['posters'] is List) {
      return (data['posters'] as List).map((json) {
        final type = json['type'] ?? '';
        if (type == 'movie') {
          return Movie.fromJson(json);
        } else {
          return Series.fromJson(json);
        }
      }).toList();
    }
    return [];
  }

  static Future<List<dynamic>> getContentByCountry(int countryId, {int page = 0}) async {
    final url = '$baseUrl/poster/by/filtres/0/$countryId/created/$page/$apiKey/';
    final data = await _makeRequest(url);
    
    if (data is List) {
      return data.map((json) {
        final type = json['type'] ?? '';
        if (type == 'movie') {
          return Movie.fromJson(json);
        } else {
          return Series.fromJson(json);
        }
      }).toList();
    }
    return [];
  }
}
