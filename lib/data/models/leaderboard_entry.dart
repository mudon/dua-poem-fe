import '../../core/enums/content_type.dart';

class LeaderboardEntry {
  final String id;
  final String title;
  final int likesCount;
  final ContentType type;

  LeaderboardEntry({
    required this.id,
    required this.title,
    required this.likesCount,
    required this.type,
  });

  factory LeaderboardEntry.fromDuaJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      type: ContentType.dua,
    );
  }

  factory LeaderboardEntry.fromPoemJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      type: ContentType.poem,
    );
  }

  LeaderboardEntry copyWith({int? likesCount}) {
    return LeaderboardEntry(
      id: id,
      title: title,
      likesCount: likesCount ?? this.likesCount,
      type: type,
    );
  }
}
