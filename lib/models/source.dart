class Source {
  final int id;
  final String quality;
  final String type;
  final String url;

  Source({
    required this.id,
    required this.quality,
    required this.type,
    required this.url,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] ?? 0,
      quality: json['quality'] ?? 'Unknown',
      type: json['type'] ?? 'Unknown',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quality': quality,
      'type': type,
      'url': url,
    };
  }
}

