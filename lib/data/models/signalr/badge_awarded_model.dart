class BadgeAwardedModel {
  final String slug;
  final String name;
  final String? color;

  BadgeAwardedModel({required this.slug, required this.name, this.color});

  factory BadgeAwardedModel.fromJson(Map<String, dynamic> json) {
    return BadgeAwardedModel(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      color: json['color'] as String?,
    );
  }
}
