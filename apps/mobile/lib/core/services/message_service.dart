import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/themes/app_colors.dart';
import 'package:my_wallet/core/themes/app_text_styles.dart';

class MessageService {
  static OverlayEntry? _currentEntry;

  static void showSuccess({
    required BuildContext context,
    required String message,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline_rounded,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
  }) {
    _show(
      context: context,
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    _dismiss();

    final overlay = Overlay.of(context);
    final isArabic = context.isArabic;
    final localizedMsg = localizeMessage(context: context, rawMessage: message);

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (overlayContext) => _MessageSnackBarWidget(
        message: localizedMsg,
        backgroundColor: backgroundColor,
        icon: icon,
        isRtl: isArabic,
        onDismiss: _dismiss,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void _dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }

  /// Automatically localizes any raw API, Dio, or backend message to current app language
  static String localizeMessage({
    required BuildContext context,
    required String rawMessage,
  }) {
    if (rawMessage.trim().isEmpty) return '';

    // 1. Clean technical prefixes like 'Exception: ', 'DioException: ', 'FormatException: '
    String cleaned = rawMessage
        .replaceAll(RegExp(r'^(Exception|DioException|FormatException|SocketException):\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[\s*\d+\s*\]'), '')
        .trim();

    final isArabic = context.isArabic;
    final lower = cleaned.toLowerCase();

    if (isArabic) {
      // Mapping English/API/Technical messages to Arabic
      if (lower.contains('invalid email or password') ||
          lower.contains('invalid username or password') ||
          lower.contains('invalid credentials') ||
          lower.contains('wrong password') ||
          lower.contains('bad credentials')) {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      if (lower.contains('user not found') || lower.contains('user does not exist')) {
        return 'المستخدم غير موجود';
      }
      if (lower.contains('duplicate email') ||
          lower.contains('email already exists') ||
          lower.contains('user with this email already exists') ||
          lower.contains('email is already taken')) {
        return 'هذا البريد الإلكتروني مستخدم مسبقاً';
      }
      if (lower.contains('duplicate full name') || lower.contains('duplicate username')) {
        return 'اسم المستخدم مستخدم مسبقاً';
      }
      if (lower.contains('email not confirmed')) {
        return 'البريد الإلكتروني غير مؤكد بعد';
      }
      if (lower.contains('invalid verification code') ||
          lower.contains('invalid reset code') ||
          lower.contains('invalid code')) {
        return 'رمز التحقق غير صحيح، يرجى التأكد وإعادة المحاولة';
      }
      if (lower.contains('failed to send verification code') ||
          lower.contains('failed to send code')) {
        return 'فشل في إرسال رمز التحقق، يرجى المحاولة لاحقاً';
      }
      if (lower.contains('failed to process forgot password') ||
          lower.contains('failed to reset password')) {
        return 'فشل في إعادة تعيين كلمة المرور، يرجى المحاولة لاحقاً';
      }
      if (lower.contains('registration failed') ||
          lower.contains('failed to create user')) {
        return 'فشل في إنشاء الحساب، يرجى المحاولة لاحقاً';
      }
      if (lower.contains('login failed')) {
        return 'فشل تسجيل الدخول، يرجى التحقق من بياناتك';
      }
      if (lower.contains('failed to set currency') ||
          lower.contains('failed to save currency')) {
        return 'فشل في حفظ العملة، يرجى المحاولة لاحقاً';
      }
      if (lower.contains('failed to update profile')) {
        return 'فشل في تحديث الملف الشخصي';
      }
      if (lower.contains('failed to load categories')) {
        return 'فشل في تحميل الفئات';
      }
      if (lower.contains('failed to load transactions')) {
        return 'فشل في تحميل المعاملات';
      }
      if (lower.contains('failed to add transaction')) {
        return 'فشل في إضافة المعاملة';
      }
      if (lower.contains('failed to update transaction')) {
        return 'فشل في تحديث المعاملة';
      }
      if (lower.contains('failed to delete transaction')) {
        return 'فشل في حذف المعاملة';
      }
      if (lower.contains('failed to load insights')) {
        return 'فشل في تحميل الرؤى والإحصائيات';
      }
      if (lower.contains('failed to load analytics')) {
        return 'فشل في تحميل التحليلات';
      }
      if (lower.contains('failed to load more')) {
        return 'فشل في تحميل المزيد';
      }
      if (lower.contains('no internet') ||
          lower.contains('connection timeout') ||
          lower.contains('connection error') ||
          lower.contains('network is unreachable') ||
          lower.contains('timed out') ||
          lower.contains('socketexception')) {
        return 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة';
      }
      if (lower.contains('server error') ||
          lower.contains('internal server error') ||
          lower.contains('an unexpected error occurred')) {
        return 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً';
      }
      if (lower.contains('user cancelled')) {
        return 'تم إلغاء العملية';
      }
      if (lower.contains('session expired') ||
          lower.contains('unauthorized') ||
          lower.contains('forbidden')) {
        return 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً';
      }
      if (lower.contains('password must be at least 8 characters')) {
        return 'يجب ألا تقل كلمة المرور عن 8 أحرف';
      }
      if (lower.contains('passwords do not match') ||
          lower.contains('passcodes do not match')) {
        return 'كلمتا المرور غير متطابقتين';
      }
      if (lower.contains('please enter a valid email')) {
        return 'يرجى إدخال بريد إلكتروني صالح';
      }
      if (lower.contains('please enter the 6-digit code')) {
        return 'يرجى إدخال الرمز المكون من 6 أرقام';
      }
      if (lower.contains('password reset successfully')) {
        return 'تمت إعادة تعيين كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول';
      }
      if (lower.contains('cannot open url') || lower.contains('could not launch')) {
        return 'تعذر فتح الرابط';
      }
      if (lower.contains('feature coming soon')) {
        return 'الميزة قريباً!';
      }

      return cleaned;
    } else {
      // Mapping Arabic backend error messages to English
      if (cleaned.contains('هذا البريد الإلكتروني مستخدم مسبقاً')) {
        return 'An account with this email already exists';
      }
      if (cleaned.contains('هذا الاسم مستخدم مسبقاً')) {
        return 'This name is already taken';
      }
      if (cleaned.contains('المستخدم غير موجود')) {
        return 'User not found';
      }
      if (cleaned.contains('البريد الإلكتروني غير مؤكد')) {
        return 'Email is not confirmed';
      }
      if (cleaned.contains('فشل إنشاء المستخدم') || cleaned.contains('فشل التسجيل')) {
        return 'Failed to create user. Please try again.';
      }
      if (cleaned.contains('فشل تسجيل الدخول')) {
        return 'Login failed. Please check your credentials.';
      }
      if (cleaned.contains('رمز التحقق غير صحيح') || cleaned.contains('رمز غير صحيح')) {
        return 'Invalid verification code';
      }
      if (cleaned.contains('رمز إعادة التعيين غير صالح')) {
        return 'Invalid reset code';
      }
      if (cleaned.contains('فشل إرسال رمز التحقق') || cleaned.contains('فشل إرسال الرمز')) {
        return 'Failed to send verification code';
      }
      if (cleaned.contains('فشل إعادة تعيين رمز المرور') ||
          cleaned.contains('فشل إعادة تعيين كلمة المرور')) {
        return 'Failed to reset password';
      }
      if (cleaned.contains('فشل حفظ العملة')) {
        return 'Failed to save currency';
      }
      if (cleaned.contains('فشل تحديث الملف الشخصي')) {
        return 'Failed to update profile';
      }
      if (cleaned.contains('فشل تحميل الملف الشخصي')) {
        return 'Failed to load profile';
      }
      if (cleaned.contains('فشل تحميل الفئات')) {
        return 'Failed to load categories';
      }
      if (cleaned.contains('فشل تحميل المعاملات')) {
        return 'Failed to load transactions';
      }
      if (cleaned.contains('فشل إضافة المعاملة')) {
        return 'Failed to add transaction';
      }
      if (cleaned.contains('فشل تحديث المعاملة')) {
        return 'Failed to update transaction';
      }
      if (cleaned.contains('فشل حذف المعاملة')) {
        return 'Failed to delete transaction';
      }
      if (cleaned.contains('فشل تحميل الرؤى')) {
        return 'Failed to load insights';
      }
      if (cleaned.contains('فشل تحميل التحليلات')) {
        return 'Failed to load analytics';
      }
      if (cleaned.contains('حدث خطأ غير متوقع أثناء التسجيل') ||
          cleaned.contains('حدث خطأ غير متوقع')) {
        return 'An unexpected error occurred. Please try again.';
      }
      if (cleaned.contains('لا يوجد اتصال بالإنترنت')) {
        return 'No internet connection. Please check your network.';
      }
      if (cleaned.contains('خطأ في الخادم')) {
        return 'Server error. Please try again later.';
      }
      if (cleaned.contains('تم تسجيل الدخول بنجاح')) {
        return 'Logged in successfully!';
      }
      if (cleaned.contains('تم إنشاء الحساب بنجاح')) {
        return 'Account created successfully!';
      }
      if (cleaned.contains('تمت إعادة تعيين كلمة المرور بنجاح')) {
        return 'Password reset successfully. Please sign in.';
      }
      if (cleaned.contains('تم تحديث الملف الشخصي بنجاح')) {
        return 'Profile updated successfully!';
      }
      if (cleaned.contains('تم حذف المعاملة بنجاح')) {
        return 'Transaction deleted successfully!';
      }
      if (cleaned.contains('تم تحديث المعاملة بنجاح')) {
        return 'Transaction updated successfully!';
      }
      if (cleaned.contains('تم إضافة المعاملة بنجاح') ||
          cleaned.contains('تم إضافة السحب بنجاح')) {
        return 'Transaction added successfully!';
      }
      if (cleaned.contains('تم حفظ العملة بنجاح')) {
        return 'Currency saved successfully!';
      }
      if (cleaned.contains('تعذر فتح الرابط')) {
        return 'Cannot open URL';
      }
      if (cleaned.contains('تعذر فتح متجر التطبيقات')) {
        return 'Cannot open app store';
      }

      return cleaned;
    }
  }
}

class _MessageSnackBarWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final bool isRtl;
  final VoidCallback onDismiss;

  const _MessageSnackBarWidget({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.isRtl,
    required this.onDismiss,
  });

  @override
  State<_MessageSnackBarWidget> createState() => _MessageSnackBarWidgetState();
}

class _MessageSnackBarWidgetState extends State<_MessageSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    _autoDismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) _handleDismiss();
    });
  }

  Future<void> _handleDismiss() async {
    _autoDismissTimer?.cancel();
    if (mounted) {
      await _controller.reverse();
    }
    widget.onDismiss();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).viewPadding.top + 12;

    return Positioned(
      top: topPadding,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Directionality(
              textDirection:
                  widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: GestureDetector(
                onTap: _handleDismiss,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: widget.backgroundColor.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: AppTextStyles.body(
                            color: Colors.white,
                            size: 15,
                            weight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleDismiss,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
