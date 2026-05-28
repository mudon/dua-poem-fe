import '../../core/network/api_result.dart';
import '../models/poem_model.dart';
import '../services/poem_service.dart';

class PoemRepository {
  final PoemService _poemService;

  PoemRepository(this._poemService);

  Future<ApiResult<List<PoemModel>>> getLatestPoems() async {
    try {
      final poems = await _poemService.getLatestPoems();
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

  Future<ApiResult<void>> reportPoem(String poemId, String reason, String description) async {
    try {
      await _poemService.reportPoem(poemId, reason, description);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
