import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:my_wallet/features/onboarding/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final Function(Locale) onLocaleChanged;

  const SplashScreen({super.key, required this.onLocaleChanged});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AuthRepository _authRepository = AuthRepository();

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthStatus();
      }
    });
  }

  void _initAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  String? _getCachedEmail() {
    final directEmail = SharedPrefs.getStringValue('user_email');
    if (directEmail != null && directEmail.isNotEmpty) return directEmail;

    final userData = SharedPrefs.userData;
    if (userData != null) {
      try {
        final decoded = jsonDecode(userData) as Map<String, dynamic>;
        return decoded['email'] as String?;
      } catch (_) {}
    }
    return null;
  }

// 1. دي الدالة المساعدة اللي بتحدد هيروح فين بالظبط بناءً على وجود الباسكود
void _navigateToSecurityScreen() {
  if (!mounted) return;
  
  final hasPasscode = SharedPrefs.getStringValue('user_password') != null;
  final route = hasPasscode ? '/pin' : '/set-passcode';
  
  Navigator.of(context).pushReplacementNamed(
    route,
    arguments: hasPasscode
        ? {
            'isFirstTime': false,
            'showBiometricFirst': true,
          }
        : null,
  );
}

// 2. دالة فحص حالة التسجيل بعد التعديل والدمج
Future<void> _checkAuthStatus() async {
  final token = SharedPrefs.authToken;

  // أولاً: لو مفيش توكن، روح لـ Onboarding واقفل الدالة فوراً
  if (token == null || token.isEmpty) {
    _navigateToOnboarding();
    return;
  }

  // ثانياً: لو مفيش إيميل كاش، روح لصفحة الأمان (PIN أو Set Passcode) واخرج
  final email = _getCachedEmail();
  if (email == null || email.isEmpty) {
    _navigateToSecurityScreen();
    return;
  }

  // ثالثاً: لو كل تمام، اتأكد من السيرفر إن الإيميل لسه فعال ومتحظرش
  try {
    final exists = await _authRepository.checkEmail(email);
    if (!exists) {
      await _forceLogout(); // لو مش موجود اعمل تسجيل خروج إجباري
      if (!mounted) return;
      _navigateToOnboarding();
      return;
    }
  } catch (_) {
    // لو السيرفر وقع أو مفيش نت، عدي الخطوة وخليه يدخل بالـ PIN عادي
  }

  // رابعاً: لو الإيميل فعال على السيرفر، وديه لصفحة الأمان
  _navigateToSecurityScreen();
}
  Future<void> _forceLogout() async {
    await SharedPrefs.removeAuthToken();
    await SharedPrefs.removeUserData();
    await SharedPrefs.removeKey('user_password');
    await SharedPrefs.removeKey('user_email');
    await SharedPrefs.removeSecureKey('user_email');
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: _logoRotation.value * 3.14159,
                  child: Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.account_balance_wallet,
                            size: 60,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: Text(
                      context.l10n.appTitle,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SlideTransition(
                  position: _subtitleSlide,
                  child: FadeTransition(
                    opacity: _subtitleFade,
                    child: Text(
                      context.l10n.manageYourMoneyEasily,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
