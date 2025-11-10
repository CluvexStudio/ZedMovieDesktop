class Genre {
  final int id;
  final String title;

  Genre({
    required this.id,
    required this.title,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  Genre copyWith({int? id, String? title}) {
    return Genre(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}

