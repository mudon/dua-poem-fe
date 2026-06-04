import '../../core/network/dio_client.dart';

class NotificationService {
  final DioClient _dioClient;

  NotificationService(this._dioClient);

  Future<Map<String, dynamic>> getNotifications({int page = 1, int pageSize = 20}) async {
    final response = await _dioClient.dio.get('/notifications', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<int> getUnreadCount() async {
    final response = await _dioClient.dio.get('/notifications/unread-count');
    return (response.data as Map<String, dynamic>)['unreadCount'] as int;
  }

  Future<void> markAsRead(String id) async {
    await _dioClient.dio.put('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dioClient.dio.put('/notifications/read-all');
  }
}
