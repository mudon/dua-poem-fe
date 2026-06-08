class UserBadgeModel {
  final String slug;
  final String name;
  final String? description;
  final String? iconUrl;
  final DateTime awardedAt;

  UserBadgeModel({
    required this.slug,
    required this.name,
    this.description,
    this.iconUrl,
    required this.awardedAt,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    return UserBadgeModel(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      awardedAt: DateTime.tryParse(json['awardedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class CatalogBadgeModel {
  final String slug;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isEarned;
  final DateTime? awardedAt;

  CatalogBadgeModel({
    required this.slug,
    required this.name,
    this.description,
    this.iconUrl,
    required this.isEarned,
    this.awardedAt,
  });

  String get category {
    if (slug.startsWith('duas_')) return 'Duas';
    if (slug.startsWith('poems_')) return 'Poems';
    if (slug.startsWith('likes_')) return 'Likes';
    if (slug.startsWith('views_')) return 'Views';
    if (slug.startsWith('streak_')) return 'Streak';
    return 'Other';
  }

  factory CatalogBadgeModel.fromJson(Map<String, dynamic> json) {
    return CatalogBadgeModel(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      isEarned: json['isEarned'] as bool? ?? false,
      awardedAt: json['awardedAt'] != null
          ? DateTime.tryParse(json['awardedAt'] as String)
          : null,
    );
  }
}

class UserStatsModel {
  final String userId;
  final String firstName;
  final String lastName;
  final int duasCreated;
  final int poemsCreated;
  final List<UserBadgeModel> badges;
  final List<CatalogBadgeModel> allBadges;

  String get fullName => '$firstName $lastName';

  UserStatsModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.duasCreated,
    required this.poemsCreated,
    required this.badges,
    required this.allBadges,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['userId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      duasCreated: json['duasCreated'] as int? ?? 0,
      poemsCreated: json['poemsCreated'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => UserBadgeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      allBadges: (json['allBadges'] as List<dynamic>?)
              ?.map((e) => CatalogBadgeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
