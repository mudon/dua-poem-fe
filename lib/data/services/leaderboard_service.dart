import '../../core/network/dio_client.dart';

class LeaderboardService {
  final DioClient _dioClient;

  LeaderboardService(this._dioClient);

  Future<Map<String, dynamic>> getTopLiked({int count = 10}) async {
    final response = await _dioClient.dio.get('/leaderboard', queryParameters: {'count': count});
    return response.data as Map<String, dynamic>;
  }
}
