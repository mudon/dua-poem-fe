class FavoritesUpdateModel {
  final String id;
  final int favoritesCount;

  FavoritesUpdateModel({required this.id, required this.favoritesCount});

  factory FavoritesUpdateModel.fromJson(Map<String, dynamic> json) {
    return FavoritesUpdateModel(
      id: json['duaId'] as String? ?? json['poemId'] as String,
      favoritesCount: json['favoritesCount'] as int,
    );
  }
}
