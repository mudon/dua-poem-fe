import '../../core/network/api_result.dart';
import '../models/dua_model.dart';
import '../services/dua_service.dart';

class DuaRepository {
  final DuaService _duaService;

  DuaRepository(this._duaService);

  Future<ApiResult<List<DuaModel>>> getLatestDuas() async {
    try {
      final duas = await _duaService.getLatestDuas();
      return ApiResult.success(duas);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<DuaModel>>> getUserDuas(int userId) async {
    try {
      final duas = await _duaService.getUserDuas(userId);
      return ApiResult.success(duas);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<DuaModel>> getDuaDetail(int id) async {
    try {
      final dua = await _duaService.getDuaDetail(id);
      return ApiResult.success(dua);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> toggleBookmark(int duaId) async {
    try {
      await _duaService.toggleBookmark(duaId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> toggleLike(int duaId) async {
    try {
      await _duaService.toggleLike(duaId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> reportDua(int duaId, String reason, String description) async {
    try {
      await _duaService.reportDua(duaId, reason, description);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
