import 'source.dart';

class Episode {
  final int id;
  final String title;
  final String description;
  final String? duration;
  final String image;
  final List<Source> sources;

  Episode({
    required this.id,
    required this.title,
    required this.description,
    this.duration,
    required this.image,
    required this.sources,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Episode',
      description: json['description'] ?? '',
      duration: json['duration']?.toString().isNotEmpty == true && 
                json['duration'] != 'null' 
          ? json['duration'] 
          : null,
      image: json['image'] ?? '',
      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => Source.fromJson(e))
          .toList() ?? [],
    );
  }
}

