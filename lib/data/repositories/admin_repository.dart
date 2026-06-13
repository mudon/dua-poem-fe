import '../../core/enums/content_type.dart';
import '../../core/errors/error_helper.dart';
import '../../core/network/api_result.dart';
import '../models/admin/pending_revision_model.dart';
import '../services/admin_service.dart';

class AdminRepository {
  final AdminService _adminService;

  AdminRepository(this._adminService);

  Future<ApiResult<List<PendingRevisionModel>>> getPendingRevisions() async {
    try {
      final data = await _adminService.getPendingRevisions();
      final list = data
          .map((e) => PendingRevisionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResult.success(list);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getRevisionDetail(String revisionId, ContentType contentType) async {
    try {
      final data = contentType == ContentType.dua
          ? await _adminService.getDuaRevisionDetail(revisionId)
          : await _adminService.getPoemRevisionDetail(revisionId);
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<void>> reviewRevision(String revisionId, ContentType contentType, Map<String, String> actions) async {
    try {
      if (contentType == ContentType.dua) {
        await _adminService.reviewDuaRevision(revisionId, actions);
      } else {
        await _adminService.reviewPoemRevision(revisionId, actions);
      }
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }
}
