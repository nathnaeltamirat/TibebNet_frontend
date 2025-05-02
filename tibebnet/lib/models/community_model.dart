class Community {
  final int id;
  final String name;
  final String description;
  final String image;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'], // <-- this must be your numeric ID
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
