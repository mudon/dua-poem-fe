import '../../../core/enums/notification_type.dart';

class NotificationUpdateModel {
  final String id;
  final NotificationType type;
  final String title;
  final String? body;
  final String? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationUpdateModel({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationUpdateModel.fromJson(Map<String, dynamic> json) {
    return NotificationUpdateModel(
      id: json['id'] as String,
      type: NotificationType.fromValue(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String?,
      data: json['data'] as String?,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
