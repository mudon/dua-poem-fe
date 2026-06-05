import '../../core/network/dio_client.dart';

class AdminService {
  final DioClient _dioClient;

  AdminService(this._dioClient);

  Future<List<dynamic>> getPendingRevisions() async {
    final response = await _dioClient.dio.get('/admin/revisions/pending');
    return response.data as List;
  }

  Future<Map<String, dynamic>> getDuaRevisionDetail(String revisionId) async {
    final response = await _dioClient.dio.get('/dua-revisions/$revisionId');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPoemRevisionDetail(String revisionId) async {
    final response = await _dioClient.dio.get('/poem-revisions/$revisionId');
    return response.data as Map<String, dynamic>;
  }

  Future<void> reviewDuaRevision(String revisionId, Map<String, String> actions) async {
    await _dioClient.dio.put('/dua-revisions/$revisionId/review', data: actions);
  }

  Future<void> reviewPoemRevision(String revisionId, Map<String, String> actions) async {
    await _dioClient.dio.put('/poem-revisions/$revisionId/review', data: actions);
  }
}
