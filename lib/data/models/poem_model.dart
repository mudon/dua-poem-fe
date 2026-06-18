import '../../core/enums/avatar_type.dart';

class PoemModel {
  final String id;
  final String title;
  final bool verified;
  final String? content;
  final String? transliteration;
  final String translation;
  final String? description;
  final String? author;
  final String category;
  final int? categoryId;
  final List<String> tags;
  final String userId;
  final String userName;
  final String userAvatar;
  final AvatarType? createdByAvatarType;
  final String? createdByAvatarValue;
  final String? createdBySelectedBadgeSlug;
  final List<Map<String, String>> createdByBadges;
  final int views;
  final int bookmarkCount;
  final int likeCount;
  final int reportCount;
  final int activeReportCount;
  final bool isLiked;
  final bool isFavorited;
  final String? createdAt;
  final String? updatedAt;

  PoemModel({
    required this.id,
    required this.title,
    required this.verified,
    this.content,
    this.transliteration,
    required this.translation,
    this.description,
    this.author,
    required this.category,
    this.categoryId,
    required this.tags,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.createdByAvatarType,
    this.createdByAvatarValue,
    this.createdBySelectedBadgeSlug,
    this.createdByBadges = const [],
    required this.views,
    required this.bookmarkCount,
    required this.likeCount,
    this.reportCount = 0,
    this.activeReportCount = 0,
    this.isLiked = false,
    this.isFavorited = false,
    this.createdAt,
    this.updatedAt,
  });

  factory PoemModel.fromApiJson(Map<String, dynamic> json) {
    final firstName = json['createdByFirstName'] as String? ?? '';
    final lastName = json['createdByLastName'] as String? ?? '';
    final userName = firstName.isNotEmpty
        ? '$firstName $lastName'
        : '';
    return PoemModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      verified: json['isVerified'] ?? false,
      content: json['content'],
      transliteration: json['transliteration'],
      translation: json['translation'] ?? '',
      description: json['description'],
      author: json['author'],
      category: json['categoryName'] ?? '',
      categoryId: json['categoryId'],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t['name']?.toString() ?? '')
              .where((n) => n.isNotEmpty)
              .toList() ??
          [],
      userId: json['createdBy']?.toString() ?? '',
      userName: userName,
      userAvatar: firstName.isNotEmpty
          ? firstName[0].toUpperCase()
          : (userName.isNotEmpty ? userName[0].toUpperCase() : '?'),
      createdByAvatarType: AvatarType.fromValue(json['createdByAvatarType'] as String?),
      createdByAvatarValue: json['createdByAvatarValue'],
      createdBySelectedBadgeSlug: json['createdBySelectedBadgeSlug'],
      createdByBadges: (json['createdByBadges'] as List<dynamic>?)
              ?.map((b) => {
                    'slug': b['slug']?.toString() ?? '',
                    'name': b['name']?.toString() ?? '',
                  })
              .toList() ??
          [],
      views: json['viewsCount'] ?? 0,
      bookmarkCount: json['bookmarkCount'] ?? json['favoritesCount'] ?? 0,
      likeCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isFavorited: json['isFavorited'] ?? false,
      reportCount: json['reportCount'] ?? 0,
      activeReportCount: json['activeReportCount'] ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  PoemModel copyWith({
    String? title,
    String? content,
    String? transliteration,
    String? translation,
    String? userName,
    String? userAvatar,
    AvatarType? createdByAvatarType,
    String? createdByAvatarValue,
    String? createdBySelectedBadgeSlug,
    List<Map<String, String>>? createdByBadges,
    int? views,
    int? bookmarkCount,
    int? likeCount,
    bool? isLiked,
    bool? isFavorited,
    String? description,
    String? author,
    String? category,
    int? categoryId,
    List<String>? tags,
    int? reportCount,
    int? activeReportCount,
    String? updatedAt,
  }) {
    return PoemModel(
      id: id,
      title: title ?? this.title,
      verified: verified,
      content: content ?? this.content,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      description: description ?? this.description,
      author: author ?? this.author,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      userId: userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      createdByAvatarType: createdByAvatarType ?? this.createdByAvatarType,
      createdByAvatarValue: createdByAvatarValue ?? this.createdByAvatarValue,
      createdBySelectedBadgeSlug: createdBySelectedBadgeSlug ?? this.createdBySelectedBadgeSlug,
      createdByBadges: createdByBadges ?? this.createdByBadges,
      views: views ?? this.views,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      reportCount: reportCount ?? this.reportCount,
      activeReportCount: activeReportCount ?? this.activeReportCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
