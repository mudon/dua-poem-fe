import '../../core/errors/error_helper.dart';
import '../../core/network/api_result.dart';
import '../models/tag_model.dart';
import '../services/tag_service.dart';

class TagRepository {
  final TagService _tagService;

  TagRepository(this._tagService);

  Future<ApiResult<List<TagModel>>> getAll() async {
    try {
      final tags = await _tagService.getAll();
      return ApiResult.success(tags);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<TagModel>> getById(int id) async {
    try {
      final tag = await _tagService.getById(id);
      return ApiResult.success(tag);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<TagModel>> create(String name) async {
    try {
      final tag = await _tagService.create(name);
      return ApiResult.success(tag);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<TagModel>> update(int id, String name) async {
    try {
      final tag = await _tagService.update(id, name);
      return ApiResult.success(tag);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<void>> delete(int id) async {
    try {
      await _tagService.delete(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }
}
