class PendingRevisionModel {
  final String id;
  final String contentType;
  final String contentId;
  final String contentTitle;
  final String? submittedBy;
  final String? submitterName;
  final String createdAt;
  final List<PendingReportItemModel> reports;

  PendingRevisionModel({
    required this.id,
    required this.contentType,
    required this.contentId,
    required this.contentTitle,
    this.submittedBy,
    this.submitterName,
    required this.createdAt,
    required this.reports,
  });

  factory PendingRevisionModel.fromJson(Map<String, dynamic> json) {
    return PendingRevisionModel(
      id: json['id'].toString(),
      contentType: json['contentType'] ?? '',
      contentId: json['contentId'].toString(),
      contentTitle: json['contentTitle'] ?? '',
      submittedBy: json['submittedBy']?.toString(),
      submitterName: json['submitterName']?.toString(),
      createdAt: json['createdAt'] ?? '',
      reports: (json['reports'] as List?)
              ?.map((e) => PendingReportItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PendingReportItemModel {
  final String reportId;
  final String reason;
  final String? description;

  PendingReportItemModel({
    required this.reportId,
    required this.reason,
    this.description,
  });

  factory PendingReportItemModel.fromJson(Map<String, dynamic> json) {
    return PendingReportItemModel(
      reportId: json['reportId'].toString(),
      reason: json['reason'] ?? '',
      description: json['description'],
    );
  }
}
