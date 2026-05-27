import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_config.dart';

class DioClient {
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient(this._dio, this._secureStorage) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(_AuthInterceptor(_secureStorage, _dio));
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _failedRequests = [];

  _AuthInterceptor(this._secureStorage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: DioClient.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;
      _failedRequests.add(requestOptions);
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshToken = await _secureStorage.read(key: DioClient.refreshTokenKey);
          if (refreshToken != null) {
            final response = await _dio.post('/auth/refresh',
                data: {'refreshToken': refreshToken});
            if (response.statusCode == 200) {
              final newAccessToken = response.data['accessToken'] as String;
              final newRefreshToken = response.data['refreshToken'] as String;
              await _secureStorage.write(key: DioClient.accessTokenKey, value: newAccessToken);
              await _secureStorage.write(key: DioClient.refreshTokenKey, value: newRefreshToken);
              for (var req in _failedRequests) {
                req.headers['Authorization'] = 'Bearer $newAccessToken';
                await _dio.fetch(req);
              }
              _failedRequests.clear();
              _isRefreshing = false;
              handler.resolve(await _dio.fetch(requestOptions));
              return;
            }
          }
          await _secureStorage.delete(key: DioClient.accessTokenKey);
          await _secureStorage.delete(key: DioClient.refreshTokenKey);
        } catch (e) {
          // ignore
        } finally {
          _isRefreshing = false;
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
        final newToken = await _secureStorage.read(key: DioClient.accessTokenKey);
        if (newToken != null) {
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          handler.resolve(await _dio.fetch(requestOptions));
          return;
        }
      }
    }
    handler.next(err);
  }
}
