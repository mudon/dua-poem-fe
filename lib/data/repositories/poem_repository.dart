import '../../core/network/api_result.dart';
import '../models/paged_response.dart';
import '../models/poem_model.dart';
import '../models/report_model.dart';
import '../services/poem_service.dart';

class PoemRepository {
  final PoemService _poemService;

  PoemRepository(this._poemService);

  Future<ApiResult<PagedResponse<PoemModel>>> getLatestPoems({int limit = 20, String? cursor}) async {
    try {
      final result = await _poemService.getLatestPoems(limit: limit, cursor: cursor);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<PagedResponse<PoemModel>>> getUserPoems(String userId, {int limit = 20, String? cursor}) async {
    try {
      final result = await _poemService.getUserPoems(userId, limit: limit, cursor: cursor);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<PoemModel>> getPoemDetail(String id) async {
    try {
      final poem = await _poemService.getPoemDetail(id);
      return ApiResult.success(poem);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> toggleBookmark(String poemId, bool currentlyFavorited) async {
    try {
      await _poemService.toggleBookmark(poemId, currentlyFavorited);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> toggleLike(String poemId, bool currentlyLiked) async {
    try {
      await _poemService.toggleLike(poemId, currentlyLiked);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<PagedResponse<PoemModel>>> getPoemFavorites({int limit = 20, String? cursor}) async {
    try {
      final result = await _poemService.getPoemFavorites(limit: limit, cursor: cursor);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<PoemModel>>> getByCategory(int categoryId) async {
    try {
      final results = await _poemService.getByCategory(categoryId);
      return ApiResult.success(results);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<PoemModel>>> getByTag(int tagId) async {
    try {
      final results = await _poemService.getByTag(tagId);
      return ApiResult.success(results);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<PagedResponse<PoemModel>>> search(String query, {int limit = 20, String? cursor}) async {
    try {
      final result = await _poemService.search(query, limit: limit, cursor: cursor);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> recordView(String poemId) async {
    try {
      await _poemService.recordView(poemId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<PoemModel>> updatePoem(String id, Map<String, dynamic> data) async {
    try {
      final poem = await _poemService.updatePoem(id, data);
      return ApiResult.success(poem);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> deletePoem(String id) async {
    try {
      await _poemService.deletePoem(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> reportPoem(String poemId, String reason, String description) async {
    try {
      await _poemService.reportPoem(poemId, reason, description);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<Map<String, dynamic>>> createRevision(String poemId, Map<String, dynamic> data) async {
    try {
      final result = await _poemService.createRevision(poemId, data);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<PagedResponse<ReportModel>>> getReports(String poemId, {int limit = 50, String? cursor}) async {
    try {
      final result = await _poemService.getPoemReports(poemId, limit: limit, cursor: cursor);
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
