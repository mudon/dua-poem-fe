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

  Future<void> toggleBookmark(String poemId, bool currentlyFavorited) async {
    if (currentlyFavorited) {
      await _dioClient.dio.delete('/poems/$poemId/favorite');
    } else {
      await _dioClient.dio.post('/poems/$poemId/favorite');
    }
  }

  Future<void> toggleLike(String poemId, bool currentlyLiked) async {
    if (currentlyLiked) {
      await _dioClient.dio.delete('/poems/$poemId/like');
    } else {
      await _dioClient.dio.post('/poems/$poemId/like');
    }
  }

  Future<List<PoemModel>> getPoemFavorites() async {
    final response = await _dioClient.dio.get('/poems/favorites');
    return (response.data as List).map((e) {
      final json = Map<String, dynamic>.from(e);
      json['id'] = json['poemId'];
      return PoemModel.fromApiJson(json);
    }).toList();
  }

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
