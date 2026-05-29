import '../../core/network/dio_client.dart';
import '../models/user_stats_model.dart';

class UserService {
  final DioClient _dioClient;

  UserService(this._dioClient);

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _dioClient.dio.get('/users/me');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    final response = await _dioClient.dio.get('/users/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<UserStatsModel> getStats(String userId) async {
    final response = await _dioClient.dio.get('/users/$userId/stats');
    return UserStatsModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updateProfile(String name) async {
    final response = await _dioClient.dio.put('/users/me', data: {'name': name});
    return response.data as Map<String, dynamic>;
  }
}
