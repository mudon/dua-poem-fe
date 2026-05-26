import '../../../core/network/api_result.dart';
import '../../models/user_model.dart';

abstract class IAuthRepository {
  Future<ApiResult<UserModel>> login(String email, String password);
  Future<ApiResult<UserModel>> signup(String name, String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
}
