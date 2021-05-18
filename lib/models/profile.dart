class Profile {
  Profile({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  static Profile fromData(Map<String, dynamic> data) {
    return Profile(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      imageUrl: data['image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}
