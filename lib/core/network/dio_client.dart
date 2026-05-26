import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  final Dio _dio;
  final SharedPreferences _prefs;

  DioClient(this._dio, this._prefs) {
    _dio.options.baseUrl = 'https://your-api.com/api';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(_AuthInterceptor(_prefs, _dio));
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _failedRequests = [];

  _AuthInterceptor(this._prefs, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(DioClient.accessTokenKey);
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
          final refreshToken = _prefs.getString(DioClient.refreshTokenKey);
          if (refreshToken != null) {
            final response = await _dio.post('/auth/refresh',
                data: {'refreshToken': refreshToken});
            if (response.statusCode == 200) {
              final newAccessToken = response.data['accessToken'];
              final newRefreshToken = response.data['refreshToken'];
              await _prefs.setString(DioClient.accessTokenKey, newAccessToken);
              await _prefs.setString(DioClient.refreshTokenKey, newRefreshToken);
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
          await _prefs.remove(DioClient.accessTokenKey);
          await _prefs.remove(DioClient.refreshTokenKey);
        } catch (e) {
          // ignore
        } finally {
          _isRefreshing = false;
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
        final newToken = _prefs.getString(DioClient.accessTokenKey);
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
