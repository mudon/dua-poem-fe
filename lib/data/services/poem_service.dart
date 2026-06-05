import '../../core/network/dio_client.dart';
import '../models/poem_model.dart';

class PoemService {
  final DioClient _dioClient;

  PoemService(this._dioClient);

  Future<List<PoemModel>> getLatestPoems({int? limit, int? offset}) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;
    final response = await _dioClient.dio.get('/poems', queryParameters: queryParams.isNotEmpty ? queryParams : null);
    return (response.data as List)
        .map((e) => PoemModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PoemModel>> getUserPoems(String userId) async {
    final response = await _dioClient.dio.get('/poems/user/$userId');
    return (response.data as List)
        .map((e) => PoemModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
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
    return (response.data as List)
        .map((e) => PoemModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
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

  Future<List<PoemModel>> search(String query, {int limit = 20, int offset = 0}) async {
    final response = await _dioClient.dio.get('/poems/search', queryParameters: {'q': query, 'limit': limit, 'offset': offset});
    return (response.data as List)
        .map((e) => PoemModel.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> recordView(String poemId) async {
    await _dioClient.dio.post('/poems/$poemId/view');
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

  Future<Map<String, dynamic>> createRevision(String poemId, Map<String, dynamic> data) async {
    final response = await _dioClient.dio.post('/poems/$poemId/revisions', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPoemReports(String poemId) async {
    final response = await _dioClient.dio.get('/poems/$poemId/reports');
    return response.data as List;
  }

  Future<Map<String, dynamic>> getPoemRevisionDetail(String revisionId) async {
    final response = await _dioClient.dio.get('/poem-revisions/$revisionId');
    return response.data as Map<String, dynamic>;
  }
}
