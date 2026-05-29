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

class UserStatsModel {
  final String userId;
  final String name;
  final int duasCreated;
  final int poemsCreated;
  final List<UserBadgeModel> badges;

  UserStatsModel({
    required this.userId,
    required this.name,
    required this.duasCreated,
    required this.poemsCreated,
    required this.badges,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      duasCreated: json['duasCreated'] as int? ?? 0,
      poemsCreated: json['poemsCreated'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => UserBadgeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
