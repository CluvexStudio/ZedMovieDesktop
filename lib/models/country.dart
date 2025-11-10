class Country {
  final int id;
  final String title;
  final String image;

  Country({
    required this.id,
    required this.title,
    required this.image,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
    };
  }
}

