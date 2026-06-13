import '../../../core/enums/content_type.dart';

class LeaderboardUpdateModel {
  final String id;
  final String title;
  final int likesCount;
  final ContentType type;

  LeaderboardUpdateModel({
    required this.id,
    required this.title,
    required this.likesCount,
    required this.type,
  });

  factory LeaderboardUpdateModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUpdateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      likesCount: json['likesCount'] as int,
      type: ContentType.fromValue(json['type'] as String),
    );
  }
}
