import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;

  AuthRepository(this._authService, this._secureStorage);

  Future<ApiResult<UserModel>> login(String email, String password) async {
    try {
      final data = await _authService.login(email, password);
      await _secureStorage.write(key: DioClient.accessTokenKey, value: data['accessToken']);
      await _secureStorage.write(key: DioClient.refreshTokenKey, value: data['refreshToken']);
      final user = UserModel.fromJson(data['user']);
      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<UserModel>> signup(String name, String email, String password) async {
    try {
      final data = await _authService.signup(name, email, password);
      await _secureStorage.write(key: DioClient.accessTokenKey, value: data['accessToken']);
      await _secureStorage.write(key: DioClient.refreshTokenKey, value: data['refreshToken']);
      final user = UserModel.fromJson(data['user']);
      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _secureStorage.delete(key: DioClient.accessTokenKey);
    await _secureStorage.delete(key: DioClient.refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: DioClient.accessTokenKey);
    return token != null;
  }
}
