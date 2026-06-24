import '../../core/enums/badge_category.dart';

class UserBadgeModel {
  final String slug;
  final String name;
  final String? description;
  final String? iconUrl;
  final String? color;
  final DateTime awardedAt;

  UserBadgeModel({
    required this.slug,
    required this.name,
    this.description,
    this.iconUrl,
    this.color,
    required this.awardedAt,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    return UserBadgeModel(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      color: json['color'] as String?,
      awardedAt: DateTime.tryParse(json['awardedAt'] as String? ?? '') ?? DateTime.now().toUtc(),
    );
  }
}

class CatalogBadgeModel {
  final String slug;
  final String name;
  final String? description;
  final String? iconUrl;
  final String? color;
  final bool isEarned;
  final DateTime? awardedAt;

  CatalogBadgeModel({
    required this.slug,
    required this.name,
    this.description,
    this.iconUrl,
    this.color,
    required this.isEarned,
    this.awardedAt,
  });

  String get category => _getCategory().displayName;

  BadgeCategory get badgeCategory => _getCategory();

  BadgeCategory _getCategory() {
    if (slug.startsWith('duas_')) return BadgeCategory.duas;
    if (slug.startsWith('poems_')) return BadgeCategory.poems;
    if (slug.startsWith('likes_')) return BadgeCategory.likes;
    if (slug.startsWith('views_')) return BadgeCategory.views;
    if (slug.startsWith('streak_')) return BadgeCategory.streak;
    return BadgeCategory.other;
  }

  factory CatalogBadgeModel.fromJson(Map<String, dynamic> json) {
    return CatalogBadgeModel(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      color: json['color'] as String?,
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
