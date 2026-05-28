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
  final String views;
  final int bookmarkCount;
  final int likeCount;
  final int reportCount;
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
    required this.bookmarkCount,
    required this.likeCount,
    this.reportCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) => DuaModel(
        id: json['id'].toString(),
        title: json['title'],
        verified: json['verified'],
        arabicText: json['arabicText'],
        transliteration: json['transliteration'],
        translation: json['translation'],
        description: json['description'],
        whenToRecite: json['whenToRecite'],
        occasion: json['occasion'],
        repetitionCount: json['repetitionCount'],
        category: json['category'],
        categoryId: json['categoryId'],
        tags: List<String>.from(json['tags']),
        userId: json['userId'].toString(),
        userName: json['userName'],
        userAvatar: json['userAvatar'],
        views: json['views'],
        bookmarkCount: json['bookmarkCount'],
        likeCount: json['likeCount'],
        reportCount: json['reportCount'] ?? 0,
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );

  factory DuaModel.fromApiJson(Map<String, dynamic> json) => DuaModel(
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
        userName: '',
        userAvatar: '',
        views: (json['viewsCount'] ?? 0).toString(),
        bookmarkCount: 0,
        likeCount: json['likesCount'] ?? 0,
        reportCount: 0,
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );

  DuaModel copyWith({
    String? userName,
    String? userAvatar,
    String? views,
    int? bookmarkCount,
    int? likeCount,
    String? description,
    String? whenToRecite,
    String? occasion,
    int? repetitionCount,
  }) {
    return DuaModel(
      id: id,
      title: title,
      verified: verified,
      arabicText: arabicText,
      transliteration: transliteration,
      translation: translation,
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
      reportCount: reportCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
