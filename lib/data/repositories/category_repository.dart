import '../../core/network/api_result.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryRepository {
  final CategoryService _categoryService;

  CategoryRepository(this._categoryService);

  Future<ApiResult<List<CategoryModel>>> getAll() async {
    try {
      final categories = await _categoryService.getAll();
      return ApiResult.success(categories);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<CategoryModel>> getById(int id) async {
    try {
      final category = await _categoryService.getById(id);
      return ApiResult.success(category);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<CategoryModel>> create(String name, String? description) async {
    try {
      final category = await _categoryService.create(name, description);
      return ApiResult.success(category);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<CategoryModel>> update(int id, String name, String? description) async {
    try {
      final category = await _categoryService.update(id, name, description);
      return ApiResult.success(category);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> delete(int id) async {
    try {
      await _categoryService.delete(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
