class PoemModel {
  final String id;
  final String title;
  final bool verified;
  final String? content;
  final String translation;
  final String category;
  final List<String> tags;
  final String userId;
  final String userName;
  final String userAvatar;
  final String views;
  final int bookmarkCount;
  final int likeCount;
  final int reportCount;

  PoemModel({
    required this.id,
    required this.title,
    required this.verified,
    this.content,
    required this.translation,
    required this.category,
    required this.tags,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.views,
    required this.bookmarkCount,
    required this.likeCount,
    this.reportCount = 0,
  });

  factory PoemModel.fromJson(Map<String, dynamic> json) => PoemModel(
        id: json['id'].toString(),
        title: json['title'],
        verified: json['verified'],
        content: json['content'],
        translation: json['translation'],
        category: json['category'],
        tags: List<String>.from(json['tags']),
        userId: json['userId'].toString(),
        userName: json['userName'],
        userAvatar: json['userAvatar'],
        views: json['views'],
        bookmarkCount: json['bookmarkCount'],
        likeCount: json['likeCount'],
        reportCount: json['reportCount'] ?? 0,
      );

  factory PoemModel.fromApiJson(Map<String, dynamic> json) => PoemModel(
        id: json['id'].toString(),
        title: json['title'] ?? '',
        verified: json['isVerified'] ?? false,
        content: json['content'],
        translation: json['translation'] ?? '',
        category: json['categoryName'] ?? '',
        tags: (json['tags'] as List<dynamic>?)
                ?.map((t) => t['name']?.toString() ?? '')
                .where((n) => n.isNotEmpty)
                .toList() ??
            [],
        userId: json['createdBy']?.toString() ?? '',
        userName: '',
        userAvatar: '',
        views: '0',
        bookmarkCount: 0,
        likeCount: 0,
        reportCount: 0,
      );

  PoemModel copyWith({
    String? userName,
    String? userAvatar,
    String? views,
    int? bookmarkCount,
    int? likeCount,
  }) {
    return PoemModel(
      id: id,
      title: title,
      verified: verified,
      content: content,
      translation: translation,
      category: category,
      tags: tags,
      userId: userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      views: views ?? this.views,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      likeCount: likeCount ?? this.likeCount,
      reportCount: reportCount,
    );
  }
}
