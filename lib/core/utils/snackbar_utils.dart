import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SnackBarUtils {
  // Private constructor to prevent instantiation
  SnackBarUtils._();

  // Show success snackbar
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  // Show error snackbar
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  // Show warning snackbar
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_outlined,
      duration: duration,
    );
  }

  // Show info snackbar
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  // Generic snackbar
  static void showCustom({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  // Private method to show snackbar
  static void _showSnackBar({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    // Remove any existing snackbars
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      elevation: 6,
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Show loading snackbar (dismissible)
  static void showLoading({
    required BuildContext context,
    String message = 'Yükleniyor...',
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
      duration: const Duration(minutes: 5), // Long duration for loading
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      elevation: 6,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Hide current snackbar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  // Show snackbar with retry action
  static void showErrorWithRetry({
    required BuildContext context,
    required String message,
    required VoidCallback onRetry,
    String retryLabel = 'Tekrar Dene',
  }) {
    showCustom(
      context: context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
      actionLabel: retryLabel,
      onActionPressed: onRetry,
      duration: const Duration(seconds: 6),
    );
  }

  // Show connection error
  static void showConnectionError({
    required BuildContext context,
    VoidCallback? onRetry,
  }) {
    showErrorWithRetry(
      context: context,
      message: 'İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin.',
      onRetry: onRetry ?? () {},
    );
  }

  // Show validation error
  static void showValidationError({
    required BuildContext context,
    required String field,
  }) {
    showError(
      context: context,
      message: '$field alanı geçerli değil. Lütfen kontrol edin.',
    );
  }

  // Show operation success
  static void showOperationSuccess({
    required BuildContext context,
    required String operation,
  }) {
    showSuccess(
      context: context,
      message: '$operation başarıyla tamamlandı.',
    );
  }

  // Show operation failed
  static void showOperationFailed({
    required BuildContext context,
    required String operation,
    VoidCallback? onRetry,
  }) {
    if (onRetry != null) {
      showErrorWithRetry(
        context: context,
        message: '$operation işlemi başarısız oldu.',
        onRetry: onRetry,
      );
    } else {
      showError(
        context: context,
        message: '$operation işlemi başarısız oldu.',
      );
    }
  }
}
