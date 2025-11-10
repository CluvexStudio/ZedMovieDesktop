import 'genre.dart';
import 'country.dart';
import 'source.dart';

class Movie {
  final int id;
  final String type;
  final String title;
  final String description;
  final int year;
  final double imdb;
  final double rating;
  final String? duration;
  final String image;
  final String cover;
  final List<Genre> genres;
  final List<Source> sources;
  final List<Country> countries;

  Movie({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.year,
    required this.imdb,
    required this.rating,
    this.duration,
    required this.image,
    required this.cover,
    required this.genres,
    required this.sources,
    required this.countries,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      description: json['description'] ?? 'No description available',
      year: json['year'] ?? 0,
      imdb: (json['imdb'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      duration: json['duration']?.toString().isNotEmpty == true && 
                json['duration'] != 'null' && 
                json['duration'] != 'N/A' 
          ? json['duration'] 
          : null,
      image: json['image'] ?? '',
      cover: json['cover'] ?? '',
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e))
          .toList() ?? [],
      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => Source.fromJson(e))
          .toList() ?? [],
      countries: (json['country'] as List<dynamic>?)
          ?.map((e) => Country.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'year': year,
      'imdb': imdb,
      'rating': rating,
      'duration': duration,
      'image': image,
      'cover': cover,
      'genres': genres.map((e) => e.toJson()).toList(),
      'sources': sources.map((e) => e.toJson()).toList(),
      'country': countries.map((e) => e.toJson()).toList(),
    };
  }
}

