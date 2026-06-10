import '../../core/network/dio_client.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dioClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> signup(String firstName, String lastName, String email, String password) async {
    final response = await _dioClient.dio.post('/auth/register', data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    final response = await _dioClient.dio.post('/auth/verify-email', data: {
      'email': email,
      'code': code,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> resendOtp(String email) async {
    await _dioClient.dio.post('/auth/resend-otp', data: {
      'email': email,
    });
  }

  Future<void> forgotPassword(String email) async {
    await _dioClient.dio.post('/auth/forgot-password', data: {
      'email': email,
    });
  }

  Future<void> resetPassword(String email, String code, String newPassword) async {
    await _dioClient.dio.post('/auth/reset-password', data: {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
  }

  Future<void> logout() async {}
}
