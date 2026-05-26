import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final AuthService _authService;
  final SharedPreferences _prefs;

  AuthRepository(this._authService, this._prefs);

  Future<ApiResult<UserModel>> login(String email, String password) async {
    try {
      final data = await _authService.login(email, password);
      await _prefs.setString(DioClient.accessTokenKey, data['accessToken']);
      await _prefs.setString(DioClient.refreshTokenKey, data['refreshToken']);
      final user = UserModel.fromJson(data['user']);
      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<UserModel>> signup(String name, String email, String password) async {
    try {
      final data = await _authService.signup(name, email, password);
      await _prefs.setString(DioClient.accessTokenKey, data['accessToken']);
      await _prefs.setString(DioClient.refreshTokenKey, data['refreshToken']);
      final user = UserModel.fromJson(data['user']);
      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _prefs.remove(DioClient.accessTokenKey);
    await _prefs.remove(DioClient.refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    return _prefs.containsKey(DioClient.accessTokenKey);
  }
}
