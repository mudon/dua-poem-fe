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

  Future<ApiResult<List<PoemModel>>> getUserPoems(int userId) async {
    try {
      final poems = await _poemService.getUserPoems(userId);
      return ApiResult.success(poems);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<PoemModel>> getPoemDetail(int id) async {
    try {
      final poem = await _poemService.getPoemDetail(id);
      return ApiResult.success(poem);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> toggleBookmark(int poemId) async {
    try {
      await _poemService.toggleBookmark(poemId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> toggleLike(int poemId) async {
    try {
      await _poemService.toggleLike(poemId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
