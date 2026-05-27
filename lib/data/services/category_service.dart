import '../../core/network/dio_client.dart';
import '../models/category_model.dart';

class CategoryService {
  final DioClient _dioClient;

  CategoryService(this._dioClient);

  Future<List<CategoryModel>> getAll() async {
    final response = await _dioClient.dio.get('/categories');
    return (response.data as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<CategoryModel> getById(int id) async {
    final response = await _dioClient.dio.get('/categories/$id');
    return CategoryModel.fromJson(response.data);
  }

  Future<CategoryModel> create(String name, String? description) async {
    final response = await _dioClient.dio.post('/categories', data: {
      'name': name,
      'description': description,
    });
    return CategoryModel.fromJson(response.data);
  }

  Future<CategoryModel> update(int id, String name, String? description) async {
    final response = await _dioClient.dio.put('/categories/$id', data: {
      'name': name,
      'description': description,
    });
    return CategoryModel.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    await _dioClient.dio.delete('/categories/$id');
  }
}
