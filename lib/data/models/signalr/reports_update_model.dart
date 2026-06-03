class ReportsUpdateModel {
  final String id;
  final int reportsCount;

  ReportsUpdateModel({required this.id, required this.reportsCount});

  factory ReportsUpdateModel.fromJson(Map<String, dynamic> json) {
    return ReportsUpdateModel(
      id: json['duaId'] as String? ?? json['poemId'] as String,
      reportsCount: json['reportsCount'] as int,
    );
  }
}
