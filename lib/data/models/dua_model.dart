class DuaModel {
  final String id;
  final String title;
  final bool verified;
  final String? arabicText;
  final String? transliteration;
  final String translation;
  final String? description;
  final String? whenToRecite;
  final String? occasion;
  final int? repetitionCount;
  final String category;
  final int? categoryId;
  final List<String> tags;
  final String userId;
  final String userName;
  final String userAvatar;
  final int views;
  final int reportCount;
  final int activeReportCount;
  final int bookmarkCount;
  final int likeCount;
  final bool isLiked;
  final bool isFavorited;
  final String? createdAt;
  final String? updatedAt;

  DuaModel({
    required this.id,
    required this.title,
    required this.verified,
    this.arabicText,
    this.transliteration,
    required this.translation,
    this.description,
    this.whenToRecite,
    this.occasion,
    this.repetitionCount,
    required this.category,
    this.categoryId,
    required this.tags,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.views,
    required this.reportCount,
    this.activeReportCount = 0,
    this.bookmarkCount = 0,
    required this.likeCount,
    this.isLiked = false,
    this.isFavorited = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DuaModel.fromApiJson(Map<String, dynamic> json) {
    final firstName = json['createdByFirstName'] as String? ?? '';
    final lastName = json['createdByLastName'] as String? ?? '';
    final userName = firstName.isNotEmpty
        ? '$firstName $lastName'
        : '';
    return DuaModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      verified: json['isVerified'] ?? false,
      arabicText: json['arabicText'],
      transliteration: json['transliteration'],
      translation: json['translation'] ?? '',
      description: json['description'],
      whenToRecite: json['whenToRecite'],
      occasion: json['occasion'],
      repetitionCount: json['repetitionCount'],
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

  DuaModel copyWith({
    String? title,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? userName,
    String? userAvatar,
    int? views,
    int? bookmarkCount,
    int? likeCount,
    bool? isLiked,
    bool? isFavorited,
    String? description,
    String? whenToRecite,
    String? occasion,
    int? repetitionCount,
    int? reportCount,
    int? activeReportCount,
    String? updatedAt,
  }) {
    return DuaModel(
      id: id,
      title: title ?? this.title,
      verified: verified,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      description: description ?? this.description,
      whenToRecite: whenToRecite ?? this.whenToRecite,
      occasion: occasion ?? this.occasion,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      category: category,
      categoryId: categoryId,
      tags: tags,
      userId: userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
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
