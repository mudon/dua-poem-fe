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

  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    await _dioClient.dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    final response = await _dioClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {}
}
