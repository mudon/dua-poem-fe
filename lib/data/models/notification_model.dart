import '../../core/enums/notification_type.dart';

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String? body;
  final String? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: NotificationType.fromValue(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String?,
      data: json['data'] as String?,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.value,
    'title': title,
    'body': body,
    'data': data,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
