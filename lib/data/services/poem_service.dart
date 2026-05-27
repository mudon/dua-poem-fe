import '../../core/network/dio_client.dart';
import '../models/poem_model.dart';

class PoemService {
  final DioClient _dioClient;

  PoemService(this._dioClient);

  Future<List<PoemModel>> getLatestPoems() async {
    final response = await _dioClient.dio.get('/poems');
    return (response.data as List)
        .map((e) => PoemModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PoemModel>> getUserPoems(String userId) async {
    final response = await _dioClient.dio.get('/poems');
    final all = (response.data as List)
        .map((e) => PoemModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
    return all.where((p) => p.userId == userId).toList();
  }

  Future<PoemModel> getPoemDetail(String id) async {
    final response = await _dioClient.dio.get('/poems/$id');
    return PoemModel.fromApiJson(response.data as Map<String, dynamic>);
  }

  Future<void> toggleBookmark(String poemId) async {
    try {
      await _dioClient.dio.post('/poems/$poemId/favorite');
    } catch (_) {
      await _dioClient.dio.delete('/poems/$poemId/favorite');
    }
  }

  Future<void> toggleLike(String poemId) async {}

  Future<PoemModel> createPoem(Map<String, dynamic> data) async {
    final response = await _dioClient.dio.post('/poems', data: data);
    return PoemModel.fromApiJson(response.data as Map<String, dynamic>);
  }

  Future<void> reportPoem(String poemId, String reason, String description) async {
    await _dioClient.dio.post('/poems/$poemId/reports', data: {
      'reason': reason,
      'description': description,
    });
  }
}
