class AppException implements Exception {
  final String message;
  final int? statusCode;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.statusCode,
    this.stackTrace,
  });

  factory AppException.network() =>
      const AppException('Không có kết nối mạng. Vui lòng thử lại.');

  factory AppException.timeout() =>
      const AppException('Kết nối quá thời gian chờ. Vui lòng thử lại.');

  factory AppException.unauthorized() =>
      const AppException('Phiên đăng nhập đã hết hạn.', statusCode: 401);

  factory AppException.server([String? message]) => AppException(
        message ?? 'Hệ thống đang bận. Vui lòng thử lại sau.',
        statusCode: 500,
      );

  factory AppException.unknown([String? message]) =>
      AppException(message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.');

  @override
  String toString() => message;
}
