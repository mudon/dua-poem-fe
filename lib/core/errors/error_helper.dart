import 'package:dio/dio.dart';

extension ErrorMessageX on Object {
  String get userMessage {
    if (this is DioException) {
      return ErrorHelper.getUserFriendlyMessage(this as DioException);
    }
    return toString();
  }
}

class ErrorHelper {
  static String getUserFriendlyMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please check your connection and try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    }
    if (e.type == DioExceptionType.cancel) {
      return 'Request was cancelled.';
    }

    final response = e.response;
    if (response?.data is Map) {
      final data = response!.data as Map<String, dynamic>;
      if (data.containsKey('error') && data['error'] is String) {
        return data['error'] as String;
      }
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstField = errors.values.firstWhere(
          (v) => v is List && v.isNotEmpty,
          orElse: () => [],
        );
        if (firstField is List && firstField.isNotEmpty) {
          return firstField.first as String;
        }
      }
    }

    switch (response?.statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Invalid email or password.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'This resource already exists.';
      case 422:
        return 'Invalid data submitted. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Service temporarily unavailable. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
