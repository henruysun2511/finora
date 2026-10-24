import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';

enum ToastType {
  success,
  error,
  info,
  warning,
}

/// Widget & Helper hiển thị thông báo Toast / SnackBar chuẩn Solarn FinTech
class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
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

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
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

  void showErrorToast(String message, {Duration? duration}) =>
      AppToast.error(this, message, duration: duration ?? const Duration(seconds: 3));

  void showInfoToast(String message, {Duration? duration}) =>
      AppToast.info(this, message, duration: duration ?? const Duration(seconds: 3));

  void showWarningToast(String message, {Duration? duration}) =>
      AppToast.warning(this, message, duration: duration ?? const Duration(seconds: 3));
}
