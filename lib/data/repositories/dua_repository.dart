import '../../core/errors/error_helper.dart';
import '../../core/network/api_result.dart';
import '../models/dua_model.dart';
import '../models/paged_response.dart';
import '../models/report_model.dart';
import '../services/dua_service.dart';

class DuaRepository {
  final DuaService _duaService;

  DuaRepository(this._duaService);

  Future<ApiResult<PagedResponse<DuaModel>>> getLatestDuas({int limit = 20, String? cursor}) async {
    try {
      final result = await _duaService.getLatestDuas(limit: limit, cursor: cursor);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<PagedResponse<DuaModel>>> getUserDuas(String userId, {int limit = 20, String? cursor}) async {
    try {
      final result = await _duaService.getUserDuas(userId, limit: limit, cursor: cursor);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<DuaModel>> getDuaDetail(String id) async {
    try {
      final dua = await _duaService.getDuaDetail(id);
      return ApiResult.success(dua);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<void>> toggleBookmark(String duaId, bool currentlyFavorited) async {
    try {
      await _duaService.toggleBookmark(duaId, currentlyFavorited);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<void>> toggleLike(String duaId, bool currentlyLiked) async {
    try {
      await _duaService.toggleLike(duaId, currentlyLiked);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<PagedResponse<DuaModel>>> getFavorites({int limit = 20, String? cursor}) async {
    try {
      final result = await _duaService.getFavorites(limit: limit, cursor: cursor);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<List<DuaModel>>> getByCategory(int categoryId) async {
    try {
      final results = await _duaService.getByCategory(categoryId);
      return ApiResult.success(results);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<List<DuaModel>>> getByTag(int tagId) async {
    try {
      final results = await _duaService.getByTag(tagId);
      return ApiResult.success(results);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<PagedResponse<DuaModel>>> search(String query, {int limit = 20, String? cursor}) async {
    try {
      final result = await _duaService.search(query, limit: limit, cursor: cursor);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<void>> recordView(String duaId) async {
    try {
      await _duaService.recordView(duaId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<DuaModel>> updateDua(String id, Map<String, dynamic> data) async {
    try {
      final dua = await _duaService.updateDua(id, data);
      return ApiResult.success(dua);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<void>> deleteDua(String id) async {
    try {
      await _duaService.deleteDua(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<void>> reportDua(String duaId, String reason, String description) async {
    try {
      await _duaService.reportDua(duaId, reason, description);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> createRevision(String duaId, Map<String, dynamic> data) async {
    try {
      final result = await _duaService.createRevision(duaId, data);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<PagedResponse<ReportModel>>> getReports(String duaId, {int limit = 50, String? cursor}) async {
    try {
      final result = await _duaService.getDuaReports(duaId, limit: limit, cursor: cursor);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }
}
