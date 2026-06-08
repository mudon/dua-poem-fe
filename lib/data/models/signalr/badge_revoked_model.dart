class BadgeRevokedModel {
  final String slug;
  final String name;

  BadgeRevokedModel({required this.slug, required this.name});

  factory BadgeRevokedModel.fromJson(Map<String, dynamic> json) {
    return BadgeRevokedModel(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
