import 'package:flutter/material.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/themes/app_colors.dart';
import 'package:my_wallet/core/themes/app_text_styles.dart';

class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 44,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                size: 16,
                weight: FontWeight.w500,
                color: AppColors.gray500,
                height: 1.6,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel ?? context.l10n.retry),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlack,
                  side: BorderSide(
                    color: AppColors.primaryBlack.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppLoadingMore extends StatelessWidget {
  const AppLoadingMore({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            context.l10n.loading,
            style: const TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ErrorType { network, server, generic }

_ErrorType _classifyError(String message) {
  final s = message.toLowerCase();
  if (s.contains('socketexception') ||
      s.contains('network is unreachable') ||
      s.contains('failed host lookup') ||
      s.contains('clientexception') ||
      s.contains('connection closed') ||
      s.contains('connection failed') ||
      s.contains('connection timed out') ||
      s.contains('handshakeexception') ||
      s.contains('no address associated with hostname')) {
    return _ErrorType.network;
  }
  if (s.contains('servererror') || s.contains('server error') || s.contains('500')) {
    return _ErrorType.server;
  }
  return _ErrorType.generic;
}

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final errorType = _classifyError(message);

    final IconData icon;
    final String title;
    final String subtitle;
    final Color accentColor;

    switch (errorType) {
      case _ErrorType.network:
        icon = Icons.wifi_off_rounded;
        title = l10n.noInternet;
        subtitle = l10n.checkInternet;
        accentColor = AppColors.primaryBlack;
      case _ErrorType.server:
        icon = Icons.cloud_off_rounded;
        title = l10n.serverError;
        subtitle = l10n.serverErrorDesc;
        accentColor = AppColors.warning;
      case _ErrorType.generic:
        icon = Icons.error_outline_rounded;
        title = l10n.errorOccurred;
        subtitle = message;
        accentColor = AppColors.error;
    }

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.gray200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor,
                            accentColor.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 26, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading(
                    size: 18,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(
                    size: 14,
                    color: AppColors.gray500,
                    height: 1.5,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        retryLabel ?? l10n.retry,
                        style: AppTextStyles.button(size: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlack,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
