import '../../core/network/dio_client.dart';

class DeviceTokenService {
  final DioClient _dioClient;

  DeviceTokenService(this._dioClient);

  Future<void> registerToken(String token, String platform) async {
    await _dioClient.dio.post('/device-tokens', data: {
      'token': token,
      'platform': platform,
    });
  }

  Future<void> unregisterToken(String id) async {
    await _dioClient.dio.delete('/device-tokens/$id');
  }
}
