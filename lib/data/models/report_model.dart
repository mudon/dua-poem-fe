class ReportModel {
  final String id;
  final String reason;
  final String? description;
  final String status;
  final String? createdAt;

  ReportModel({
    required this.id,
    required this.reason,
    this.description,
    required this.status,
    this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'].toString(),
      reason: json['reason'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'],
    );
  }
}
