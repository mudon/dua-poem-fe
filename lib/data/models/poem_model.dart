class PoemModel {
  final int id;
  final String title;
  final bool verified;
  final String? content;
  final String translation;
  final String category;
  final List<String> tags;
  final int userId;
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
        id: json['id'],
        title: json['title'],
        verified: json['verified'],
        content: json['content'],
        translation: json['translation'],
        category: json['category'],
        tags: List<String>.from(json['tags']),
        userId: json['userId'],
        userName: json['userName'],
        userAvatar: json['userAvatar'],
        views: json['views'],
        bookmarkCount: json['bookmarkCount'],
        likeCount: json['likeCount'],
        reportCount: json['reportCount'] ?? 0,
      );
}
