import '../../core/errors/error_helper.dart';
import '../../core/network/api_result.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';

class LeaderboardRepository {
  final LeaderboardService _service;

  LeaderboardRepository(this._service);

  Future<ApiResult<Map<String, List<LeaderboardEntry>>>> getTopLiked({int count = 10}) async {
    try {
      final data = await _service.getTopLiked(count: count);
      final duas = (data['topDuas'] as List)
          .map((e) => LeaderboardEntry.fromDuaJson(e as Map<String, dynamic>))
          .toList();
      final poems = (data['topPoems'] as List)
          .map((e) => LeaderboardEntry.fromPoemJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success({'duas': duas, 'poems': poems});
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }
}
