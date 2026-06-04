import '../../../data/models/notification_model.dart';

abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {
  final bool refresh;
  LoadNotifications({this.refresh = false}) ;
}

class MarkAsRead extends NotificationEvent {
  final String id;
  MarkAsRead(this.id);
}

class MarkAllRead extends NotificationEvent {}

class NotificationReceived extends NotificationEvent {
  final NotificationModel notification;
  NotificationReceived(this.notification);
}

class RefreshUnreadCount extends NotificationEvent {}
