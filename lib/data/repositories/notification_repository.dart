import '../../core/errors/error_helper.dart';
import '../../core/network/api_result.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository(this._notificationService);

  Future<ApiResult<List<NotificationModel>>> getNotifications({int page = 1, int pageSize = 20}) async {
    try {
      final data = await _notificationService.getNotifications(page: page, pageSize: pageSize);
      final list = (data['notifications'] as List)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<int>> getUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      return ApiResult.success(count);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<void>> markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<void>> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }
}
