import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/errors/error_helper.dart';
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
      if (e is DioException) {
        final respData = e.response?.data;
        if (respData is Map && respData['code'] == 'EMAIL_NOT_VERIFIED') {
          return ApiResult.failure(e.userMessage, code: 'EMAIL_NOT_VERIFIED');
        }
      }
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<String>> signup(String firstName, String lastName, String email, String password) async {
    try {
      final data = await _authService.signup(firstName, lastName, email, password);
      return ApiResult.success(data['email'] as String);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<UserModel>> verifyEmail(String email, String code) async {
    try {
      final data = await _authService.verifyEmail(email, code);
      await _secureStorage.write(key: DioClient.accessTokenKey, value: data['accessToken']);
      await _secureStorage.write(key: DioClient.refreshTokenKey, value: data['refreshToken']);
      final user = UserModel.fromJson(data['user']);
      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<String>> resendOtp(String email) async {
    try {
      await _authService.resendOtp(email);
      return ApiResult.success(email);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<String>> forgotPassword(String email) async {
    try {
      await _authService.forgotPassword(email);
      return ApiResult.success(email);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }

  Future<ApiResult<String>> resetPassword(String email, String code, String newPassword) async {
    try {
      await _authService.resetPassword(email, code, newPassword);
      return ApiResult.success(email);
    } catch (e) {
      return ApiResult.failure(e.userMessage);
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
