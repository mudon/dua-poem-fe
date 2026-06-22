class BadgeRevokedModel {
  final String slug;
  final String name;
  final String? color;

  BadgeRevokedModel({required this.slug, required this.name, this.color});

  factory BadgeRevokedModel.fromJson(Map<String, dynamic> json) {
    return BadgeRevokedModel(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      color: json['color'] as String?,
    );
  }
}
