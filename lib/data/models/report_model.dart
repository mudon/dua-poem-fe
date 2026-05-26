class ReportModel {
  final int id;
  final String contentType;
  final int contentId;
  final String title;
  final String reason;
  final String description;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.contentType,
    required this.contentId,
    required this.title,
    required this.reason,
    required this.description,
    required this.createdAt,
  });
}
