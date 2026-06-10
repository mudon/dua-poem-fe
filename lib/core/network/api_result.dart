class ApiResult<T> {
  final T? data;
  final String? error;
  final String? code;
  final bool isSuccess;

  ApiResult.success(this.data)
      : isSuccess = true,
        error = null,
        code = null;

  ApiResult.failure(this.error, {this.code})
      : isSuccess = false,
        data = null;
}
