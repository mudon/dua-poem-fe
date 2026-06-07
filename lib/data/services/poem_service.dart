import '../../core/network/dio_client.dart';
import '../models/paged_response.dart';
import '../models/poem_model.dart';
import '../models/report_model.dart';

class PoemService {
  final DioClient _dioClient;

  PoemService(this._dioClient);

  Future<PagedResponse<PoemModel>> getLatestPoems({int limit = 20, String? cursor}) async {
    final queryParams = <String, dynamic>{};
    queryParams['limit'] = limit;
    if (cursor != null) queryParams['cursor'] = cursor;
    final response = await _dioClient.dio.get('/poems', queryParameters: queryParams);
    return PagedResponse.fromJson(response.data as Map<String, dynamic>, PoemModel.fromApiJson);
  }

  Future<PagedResponse<PoemModel>> getUserPoems(String userId, {int limit = 20, String? cursor}) async {
    final queryParams = <String, dynamic>{};
    queryParams['limit'] = limit;
    if (cursor != null) queryParams['cursor'] = cursor;
    final response = await _dioClient.dio.get('/poems/user/$userId', queryParameters: queryParams);
    return PagedResponse.fromJson(response.data as Map<String, dynamic>, PoemModel.fromApiJson);
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

  Future<PagedResponse<PoemModel>> getPoemFavorites({int limit = 20, String? cursor}) async {
    final queryParams = <String, dynamic>{};
    queryParams['limit'] = limit;
    if (cursor != null) queryParams['cursor'] = cursor;
    final response = await _dioClient.dio.get('/poems/favorites', queryParameters: queryParams);
    return PagedResponse.fromJson(response.data as Map<String, dynamic>, PoemModel.fromApiJson);
  }

  Future<List<PoemModel>> getByCategory(int categoryId) async {
    final response = await _dioClient.dio.get('/poems/by-category/$categoryId');
    return (response.data as List)
        .map((e) => PoemModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PoemModel>> getByTag(int tagId) async {
    final response = await _dioClient.dio.get('/poems/by-tag/$tagId');
    return (response.data as List)
        .map((e) => PoemModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PagedResponse<PoemModel>> search(String query, {int limit = 20, String? cursor}) async {
    final params = <String, dynamic>{'q': query, 'limit': limit};
    if (cursor != null) params['cursor'] = cursor;
    final response = await _dioClient.dio.get('/poems/search', queryParameters: params);
    return PagedResponse.fromJson(response.data as Map<String, dynamic>, PoemModel.fromApiJson);
  }

  Future<void> recordView(String poemId) async {
    await _dioClient.dio.post('/poems/$poemId/view');
  }

  Future<PoemModel> createPoem(Map<String, dynamic> data) async {
    final response = await _dioClient.dio.post('/poems', data: data);
    return PoemModel.fromApiJson(response.data as Map<String, dynamic>);
  }

  Future<PoemModel> updatePoem(String id, Map<String, dynamic> data) async {
    final response = await _dioClient.dio.put('/poems/$id', data: data);
    return PoemModel.fromApiJson(response.data as Map<String, dynamic>);
  }

  Future<void> deletePoem(String id) async {
    await _dioClient.dio.delete('/poems/$id');
  }

  Future<void> reportPoem(String poemId, String reason, String description) async {
    await _dioClient.dio.post('/poems/$poemId/reports', data: {
      'reason': reason,
      'description': description,
    });
  }

  Future<Map<String, dynamic>> createRevision(String poemId, Map<String, dynamic> data) async {
    final response = await _dioClient.dio.post('/poems/$poemId/revisions', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<PagedResponse<ReportModel>> getPoemReports(String poemId, {int limit = 50, String? cursor}) async {
    final queryParams = <String, dynamic>{};
    queryParams['limit'] = limit;
    if (cursor != null) queryParams['cursor'] = cursor;
    final response = await _dioClient.dio.get('/poems/$poemId/reports', queryParameters: queryParams);
    return PagedResponse.fromJson(response.data as Map<String, dynamic>, ReportModel.fromJson);
  }

  Future<Map<String, dynamic>> getPoemRevisionDetail(String revisionId) async {
    final response = await _dioClient.dio.get('/poem-revisions/$revisionId');
    return response.data as Map<String, dynamic>;
  }
}
