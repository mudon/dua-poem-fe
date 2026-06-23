import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/app_config.dart';
import '../services/secure_storage_service.dart';
import '../errors/error_helper.dart';
import '../themes/app_theme.dart';

class DioClient {
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static GlobalKey<NavigatorState>? navigatorKey;

  final Dio _dio;
  final SecureStorageService _secureStorage;

  DioClient(this._dio, this._secureStorage) {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(_AuthInterceptor(_secureStorage, _dio));
    _dio.interceptors.add(_ErrorInterceptor());
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
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

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 429) {
      final headers = err.response?.headers.map;
      final rawRetryAfter = err.response?.headers.value('retry-after');
      print('[RateLimit] 429 received. All response headers: $headers');
      print('[RateLimit] Raw Retry-After header value: "$rawRetryAfter"');
      print('[RateLimit] Response body: ${err.response?.data}');
      final context = DioClient.navigatorKey?.currentContext;
      if (context != null) {
        final retryAfter = rawRetryAfter;
        final message = retryAfter != null
            ? 'Too many requests. Try again in ~${retryAfter}s.'
            : 'Too many requests. Please wait.';
        ScaffoldMessenger.of(context).showSnackBar(
          AppTheme.errorSnackBar(message),
        );
      }
    }
    final cleanMessage = ErrorHelper.getUserFriendlyMessage(err);
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: err.error,
      message: cleanMessage,
      stackTrace: err.stackTrace,
    ));
  }
}
