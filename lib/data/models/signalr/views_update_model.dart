class ViewsUpdateModel {
  final String id;
  final int viewsCount;

  ViewsUpdateModel({required this.id, required this.viewsCount});

  factory ViewsUpdateModel.fromJson(Map<String, dynamic> json) {
    return ViewsUpdateModel(
      id: json['duaId'] as String? ?? json['poemId'] as String,
      viewsCount: json['viewsCount'] as int,
    );
  }
}
