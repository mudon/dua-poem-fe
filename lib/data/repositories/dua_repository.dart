import '../../core/network/api_result.dart';
import '../models/dua_model.dart';
import '../services/dua_service.dart';

class DuaRepository {
  final DuaService _duaService;

  DuaRepository(this._duaService);

  Future<ApiResult<List<DuaModel>>> getLatestDuas({int? limit, int? offset}) async {
    try {
      final duas = await _duaService.getLatestDuas(limit: limit, offset: offset);
      return ApiResult.success(duas);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<DuaModel>>> getUserDuas(String userId) async {
    try {
      final duas = await _duaService.getUserDuas(userId);
      return ApiResult.success(duas);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<DuaModel>> getDuaDetail(String id) async {
    try {
      final dua = await _duaService.getDuaDetail(id);
      return ApiResult.success(dua);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> toggleBookmark(String duaId, bool currentlyFavorited) async {
    try {
      await _duaService.toggleBookmark(duaId, currentlyFavorited);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> toggleLike(String duaId, bool currentlyLiked) async {
    try {
      await _duaService.toggleLike(duaId, currentlyLiked);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<DuaModel>>> getFavorites() async {
    try {
      final duas = await _duaService.getFavorites();
      return ApiResult.success(duas);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<DuaModel>>> getByCategory(int categoryId) async {
    try {
      final results = await _duaService.getByCategory(categoryId);
      return ApiResult.success(results);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<DuaModel>>> getByTag(int tagId) async {
    try {
      final results = await _duaService.getByTag(tagId);
      return ApiResult.success(results);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<DuaModel>>> search(String query, {int limit = 20, int offset = 0}) async {
    try {
      final results = await _duaService.search(query, limit: limit, offset: offset);
      return ApiResult.success(results);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> recordView(String duaId) async {
    try {
      await _duaService.recordView(duaId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<DuaModel>> updateDua(String id, Map<String, dynamic> data) async {
    try {
      final dua = await _duaService.updateDua(id, data);
      return ApiResult.success(dua);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> deleteDua(String id) async {
    try {
      await _duaService.deleteDua(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> reportDua(String duaId, String reason, String description) async {
    try {
      await _duaService.reportDua(duaId, reason, description);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<Map<String, dynamic>>> createRevision(String duaId, Map<String, dynamic> data) async {
    try {
      final result = await _duaService.createRevision(duaId, data);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<dynamic>>> getReports(String duaId) async {
    try {
      final reports = await _duaService.getDuaReports(duaId);
      return ApiResult.success(reports);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
