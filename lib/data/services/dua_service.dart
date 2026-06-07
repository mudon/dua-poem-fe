import '../../core/network/dio_client.dart';
import '../models/dua_model.dart';
import '../models/paged_response.dart';
import '../models/report_model.dart';

class DuaService {
  final DioClient _dioClient;

  DuaService(this._dioClient);

  Future<PagedResponse<DuaModel>> getLatestDuas({int limit = 20, String? cursor}) async {
    final queryParams = <String, dynamic>{};
    queryParams['limit'] = limit;
    if (cursor != null) queryParams['cursor'] = cursor;
    final response = await _dioClient.dio.get('/duas', queryParameters: queryParams);
    return PagedResponse.fromJson(response.data as Map<String, dynamic>, DuaModel.fromApiJson);
  }

  Future<List<DuaModel>> getUserDuas(String userId) async {
    final response = await _dioClient.dio.get('/duas/user/$userId');
    return (response.data as List)
        .map((e) => DuaModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
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

  Future<PagedResponse<DuaModel>> getFavorites({int limit = 20, String? cursor}) async {
    final queryParams = <String, dynamic>{};
    queryParams['limit'] = limit;
    if (cursor != null) queryParams['cursor'] = cursor;
    final response = await _dioClient.dio.get('/favorites', queryParameters: queryParams);
    return PagedResponse.fromJson(response.data as Map<String, dynamic>, DuaModel.fromApiJson);
  }

  Future<List<DuaModel>> getByCategory(int categoryId) async {
    final response = await _dioClient.dio.get('/duas/by-category/$categoryId');
    return (response.data as List)
        .map((e) => DuaModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DuaModel>> getByTag(int tagId) async {
    final response = await _dioClient.dio.get('/duas/by-tag/$tagId');
    return (response.data as List)
        .map((e) => DuaModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PagedResponse<DuaModel>> search(String query, {int limit = 20, String? cursor}) async {
    final params = <String, dynamic>{'q': query, 'limit': limit};
    if (cursor != null) params['cursor'] = cursor;
    final response = await _dioClient.dio.get('/duas/search', queryParameters: params);
    return PagedResponse.fromJson(response.data as Map<String, dynamic>, DuaModel.fromApiJson);
  }

  Future<void> recordView(String duaId) async {
    await _dioClient.dio.post('/duas/$duaId/view');
  }

  Future<DuaModel> createDua(Map<String, dynamic> data) async {
    final response = await _dioClient.dio.post('/duas', data: data);
    return DuaModel.fromApiJson(response.data as Map<String, dynamic>);
  }

  Future<DuaModel> updateDua(String id, Map<String, dynamic> data) async {
    final response = await _dioClient.dio.put('/duas/$id', data: data);
    return DuaModel.fromApiJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteDua(String id) async {
    await _dioClient.dio.delete('/duas/$id');
  }

  Future<void> reportDua(String duaId, String reason, String description) async {
    await _dioClient.dio.post('/duas/$duaId/reports', data: {
      'reason': reason,
      'description': description,
    });
  }

  Future<Map<String, dynamic>> createRevision(String duaId, Map<String, dynamic> data) async {
    final response = await _dioClient.dio.post('/duas/$duaId/revisions', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<PagedResponse<ReportModel>> getDuaReports(String duaId, {int limit = 50, String? cursor}) async {
    final queryParams = <String, dynamic>{};
    queryParams['limit'] = limit;
    if (cursor != null) queryParams['cursor'] = cursor;
    final response = await _dioClient.dio.get('/duas/$duaId/reports', queryParameters: queryParams);
    return PagedResponse.fromJson(response.data as Map<String, dynamic>, ReportModel.fromJson);
  }

  Future<Map<String, dynamic>> getDuaRevisionDetail(String revisionId) async {
    final response = await _dioClient.dio.get('/dua-revisions/$revisionId');
    return response.data as Map<String, dynamic>;
  }
}
