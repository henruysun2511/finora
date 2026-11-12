import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../errors/app_exception.dart';

enum ToastType {
  success,
  error,
  info,
  warning,
}

/// Widget & Helper hiển thị thông báo Toast / SnackBar chuẩn Solarn FinTech
class AppToast {
  AppToast._();

  /// Bóc tách thông điệp lỗi chuẩn xác từ Backend (NestJS / Dio / AppException)
  static String extractErrorMessage(
    dynamic error, [
    String defaultMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại.',
  ]) {
    if (error == null) return defaultMessage;

    // 1. Xử lý DioException
    if (error is DioException) {
      final res = error.response;
      if (res != null && res.data != null) {
        final data = res.data;
        if (data is Map) {
          // Validation errors: {"errors": ["property q should not exist"]}
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            return errors.map((e) => e.toString()).join('\n');
          } else if (errors is Map && errors.isNotEmpty) {
            return errors.values.map((e) => e.toString()).join('\n');
          } else if (errors is String && errors.isNotEmpty) {
            return errors;
          }

          // NestJS exception: {"message": "..."} hoặc {"message": ["..."]}
          final msg = data['message'];
          if (msg is List && msg.isNotEmpty) {
            return msg.map((e) => e.toString()).join(', ');
          } else if (msg is String && msg.isNotEmpty) {
            return msg;
          }

          // Field "error"
          final errField = data['error'];
          if (errField is String && errField.isNotEmpty) {
            return errField;
          }
        } else if (data is String && data.isNotEmpty) {
          return data;
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Kết nối mạng quá thời gian chờ. Vui lòng thử lại.';
        case DioExceptionType.connectionError:
          return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.';
        case DioExceptionType.cancel:
          return 'Yêu cầu đã bị hủy.';
        default:
          if (error.response?.statusCode != null) {
            final code = error.response!.statusCode;
            if (code == 401) return 'Phiên đăng nhập đã hết hạn.';
            if (code == 403) return 'Bạn không có quyền thực hiện thao tác này.';
            if (code == 404) return 'Không tìm thấy dữ liệu yêu cầu.';
            if (code == 500) return 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.';
          }
          break;
      }
    }

    // 2. Xử lý AppException
    if (error is AppException) {
      return error.message;
    }

    // 3. Xử lý chuỗi
    if (error is String) {
      if (error.trim().isEmpty) return defaultMessage;
      var str = error.trim();
      if (str.startsWith('Exception: ')) {
        str = str.substring(11).trim();
      }
      return str.isNotEmpty ? str : defaultMessage;
    }

    // 4. Các exception hoặc đối tượng khác
    var str = error.toString().trim();
    if (str.startsWith('Exception: ')) {
      str = str.substring(11).trim();
    }
    return str.isNotEmpty ? str : defaultMessage;
  }

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      final config = _getToastConfig(type);

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
        SnackBar(
          elevation: 6,
          behavior: SnackBarBehavior.floating,
          backgroundColor: config.backgroundColor,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          duration: duration,
          action: action,
          content: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context,
      message: message,
      type: ToastType.success,
      duration: duration,
      action: action,
    );
  }

  /// Hiển thị Toast lỗi tự động bóc tách thông điệp lỗi từ Backend hoặc Exception
  static void error(
    BuildContext context,
    dynamic errorOrMessage, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final message = extractErrorMessage(errorOrMessage);
    show(
      context,
      message: message,
      type: ToastType.error,
      duration: duration,
      action: action,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context,
      message: message,
      type: ToastType.info,
      duration: duration,
      action: action,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      duration: duration,
      action: action,
    );
  }

  static _ToastConfig _getToastConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const _ToastConfig(
          backgroundColor: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case ToastType.error:
        return const _ToastConfig(
          backgroundColor: AppColors.danger,
          icon: Icons.error_outline_rounded,
        );
      case ToastType.warning:
        return const _ToastConfig(
          backgroundColor: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case ToastType.info:
        return const _ToastConfig(
          backgroundColor: AppColors.primary,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _ToastConfig {
  final Color backgroundColor;
  final IconData icon;

  const _ToastConfig({
    required this.backgroundColor,
    required this.icon,
  });
}

/// Tiện ích mở rộng trên BuildContext
extension BuildContextToastX on BuildContext {
  void showSuccessToast(String message, {Duration? duration}) =>
      AppToast.success(this, message, duration: duration ?? const Duration(seconds: 3));

  void showErrorToast(dynamic errorOrMessage, {Duration? duration}) =>
      AppToast.error(this, errorOrMessage, duration: duration ?? const Duration(seconds: 3));

  void showInfoToast(String message, {Duration? duration}) =>
      AppToast.info(this, message, duration: duration ?? const Duration(seconds: 3));

  void showWarningToast(String message, {Duration? duration}) =>
      AppToast.warning(this, message, duration: duration ?? const Duration(seconds: 3));
}
