import '../../core/network/dio_client.dart';
import '../models/tag_model.dart';

class TagService {
  final DioClient _dioClient;

  TagService(this._dioClient);

  Future<List<TagModel>> getAll() async {
    final response = await _dioClient.dio.get('/tags');
    return (response.data as List).map((e) => TagModel.fromJson(e)).toList();
  }

  Future<TagModel> getById(int id) async {
    final response = await _dioClient.dio.get('/tags/$id');
    return TagModel.fromJson(response.data);
  }

  Future<TagModel> create(String name) async {
    final response = await _dioClient.dio.post('/tags', data: {
      'name': name,
    });
    return TagModel.fromJson(response.data);
  }

  Future<TagModel> update(int id, String name) async {
    final response = await _dioClient.dio.put('/tags/$id', data: {
      'name': name,
    });
    return TagModel.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    await _dioClient.dio.delete('/tags/$id');
  }
}
