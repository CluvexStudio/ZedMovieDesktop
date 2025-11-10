import 'episode.dart';

class Season {
  final int id;
  final String title;
  final List<Episode> episodes;

  Season({
    required this.id,
    required this.title,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Season',
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map((e) => Episode.fromJson(e))
          .toList() ?? [],
    );
  }
}

