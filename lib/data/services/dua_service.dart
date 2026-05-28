import '../../core/network/dio_client.dart';
import '../models/dua_model.dart';

class DuaService {
  final DioClient _dioClient;

  DuaService(this._dioClient);

  Future<List<DuaModel>> getLatestDuas() async {
    final response = await _dioClient.dio.get('/duas');
    return (response.data as List)
        .map((e) => DuaModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DuaModel>> getUserDuas(String userId) async {
    final response = await _dioClient.dio.get('/duas');
    final all = (response.data as List)
        .map((e) => DuaModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
    return all.where((d) => d.userId == userId).toList();
  }

  Future<DuaModel> getDuaDetail(String id) async {
    final response = await _dioClient.dio.get('/duas/$id');
    return DuaModel.fromApiJson(response.data as Map<String, dynamic>);
  }

  Future<void> toggleBookmark(String duaId, bool currentlyFavorited) async {
    if (currentlyFavorited) {
      await _dioClient.dio.delete('/duas/$duaId/favorite');
    } else {
      await _dioClient.dio.post('/duas/$duaId/favorite');
    }
  }

  Future<void> toggleLike(String duaId, bool currentlyLiked) async {
    if (currentlyLiked) {
      await _dioClient.dio.delete('/duas/$duaId/like');
    } else {
      await _dioClient.dio.post('/duas/$duaId/like');
    }
  }

  Future<List<DuaModel>> getFavorites() async {
    final response = await _dioClient.dio.get('/favorites');
    return (response.data as List).map((e) {
      final json = Map<String, dynamic>.from(e);
      json['id'] = json['duaId'];
      return DuaModel.fromApiJson(json);
    }).toList();
  }

  Future<DuaModel> createDua(Map<String, dynamic> data) async {
    final response = await _dioClient.dio.post('/duas', data: data);
    return DuaModel.fromApiJson(response.data as Map<String, dynamic>);
  }

  Future<void> reportDua(String duaId, String reason, String description) async {
    await _dioClient.dio.post('/duas/$duaId/reports', data: {
      'reason': reason,
      'description': description,
    });
  }
}
