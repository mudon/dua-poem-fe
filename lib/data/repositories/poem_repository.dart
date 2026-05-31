import '../../core/network/api_result.dart';
import '../models/poem_model.dart';
import '../services/poem_service.dart';

class PoemRepository {
  final PoemService _poemService;

  PoemRepository(this._poemService);

  Future<ApiResult<List<PoemModel>>> getLatestPoems({int? limit, int? offset}) async {
    try {
      final poems = await _poemService.getLatestPoems(limit: limit, offset: offset);
      return ApiResult.success(poems);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<PoemModel>>> getUserPoems(String userId) async {
    try {
      final poems = await _poemService.getUserPoems(userId);
      return ApiResult.success(poems);
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

  Future<ApiResult<List<PoemModel>>> getPoemFavorites() async {
    try {
      final poems = await _poemService.getPoemFavorites();
      return ApiResult.success(poems);
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

  Future<ApiResult<List<PoemModel>>> search(String query, {int limit = 20, int offset = 0}) async {
    try {
      final results = await _poemService.search(query, limit: limit, offset: offset);
      return ApiResult.success(results);
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

  Future<ApiResult<List<dynamic>>> getReports(String poemId) async {
    try {
      final reports = await _poemService.getPoemReports(poemId);
      return ApiResult.success(reports);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
