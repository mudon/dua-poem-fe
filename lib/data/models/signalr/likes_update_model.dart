class LikesUpdateModel {
  final String id;
  final int likesCount;

  LikesUpdateModel({required this.id, required this.likesCount});

  factory LikesUpdateModel.fromJson(Map<String, dynamic> json) {
    return LikesUpdateModel(
      id: json['duaId'] as String? ?? json['poemId'] as String,
      likesCount: json['likesCount'] as int,
    );
  }
}
