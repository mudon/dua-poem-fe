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
  final String views;
  final int bookmarkCount;
  final int likeCount;
  final int reportCount;
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
    required this.views,
    required this.bookmarkCount,
    required this.likeCount,
    this.reportCount = 0,
    this.isLiked = false,
    this.isFavorited = false,
    this.createdAt,
    this.updatedAt,
  });

  factory PoemModel.fromJson(Map<String, dynamic> json) => PoemModel(
        id: json['id'].toString(),
        title: json['title'],
        verified: json['verified'],
        content: json['content'],
        transliteration: json['transliteration'],
        translation: json['translation'],
        description: json['description'],
        author: json['author'],
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

  factory PoemModel.fromApiJson(Map<String, dynamic> json) => PoemModel(
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
        userName: json['createdByName'] ?? '',
        userAvatar: _firstLetter(json['createdByName']),
        views: (json['viewsCount'] ?? 0).toString(),
        bookmarkCount: json['bookmarkCount'] ?? json['favoritesCount'] ?? 0,
        likeCount: json['likesCount'] ?? 0,
        isLiked: json['isLiked'] ?? false,
        isFavorited: json['isFavorited'] ?? false,
        reportCount: 0,
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );

  static String _firstLetter(dynamic name) {
    if (name is String && name.isNotEmpty) return name[0].toUpperCase();
    return '';
  }

  PoemModel copyWith({
    String? userName,
    String? userAvatar,
    String? views,
    int? bookmarkCount,
    int? likeCount,
    bool? isLiked,
    bool? isFavorited,
    String? description,
    String? author,
    String? transliteration,
  }) {
    return PoemModel(
      id: id,
      title: title,
      verified: verified,
      content: content,
      transliteration: transliteration ?? this.transliteration,
      translation: translation,
      description: description ?? this.description,
      author: author ?? this.author,
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
      reportCount: reportCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
