import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/device_info_service.dart';
import 'package:my_wallet/core/services/social_auth_service.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:my_wallet/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:my_wallet/core/services/message_service.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final AuthRepository _authRepository = AuthRepository();
  final SocialAuthService _socialAuthService = SocialAuthService();

  bool _isEmailValid = false;
  bool _isLoading = false;
  bool _emailExists = false;
  String? _deviceName;
  String? _ipAddress;

  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _socialFade;
  late Animation<Offset> _socialSlide;
  final List<double> _dotScales = [1.0, 1.0, 1.0];
  final List<double> _dotOpacities = [0.5, 0.5, 0.5];

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _loadDeviceInfo();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _socialFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _socialSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeController.forward();
  }

  Future<void> _loadDeviceInfo() async {
    final deviceName = await DeviceInfoService().getDeviceName();
    final ip = await DeviceInfoService().getPublicIp();
    if (mounted) {
      setState(() {
        _deviceName = deviceName;
        _ipAddress = ip;
      });
    }
  }

  void _startWaveAnimation() {
    _waveController.repeat(reverse: true);

    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted || !_isLoading) {
        timer.cancel();
        return;
      }

      setState(() {
        final time = DateTime.now().millisecondsSinceEpoch / 500;

        for (int i = 0; i < 3; i++) {
          double phase = i * 0.8;
          double waveValue = sin(time - phase);

          _dotOpacities[i] = 0.5 + ((waveValue + 1) / 2) * 0.5;
          _dotScales[i] = 0.8 + ((waveValue + 1) / 2) * 0.4;
        }
      });
    });
  }

  void _stopWaveAnimation() {
    _waveController.stop();
    setState(() {
      for (int i = 0; i < 3; i++) {
        _dotScales[i] = 1.0;
        _dotOpacities[i] = 0.5;
      }
    });
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }

  Future<void> _checkEmail() async {
    if (!_isEmailValid) return;

    setState(() {
      _isLoading = true;
    });

    _startWaveAnimation();

    try {
      final email = _emailController.text.trim();
      final exists = await _authRepository.checkEmail(email);

      setState(() {
        _emailExists = exists;
      });

      await _sendVerificationCode();

      if (!mounted) return;
      MessageService.showSuccess(
          context: context,
          message: context.l10n.verificationCodeSent(email));
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
          context: context, message: context.l10n.failedToSendCode);
    } finally {
      setState(() {
        _isLoading = false;
      });
      _stopWaveAnimation();
    }
  }

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();
    final isLogin = _emailExists;

    final deviceName =
        _deviceName ?? await DeviceInfoService().getDeviceName();

    try {
      await _authRepository.sendVerification(
        email: email,
        isLogin: isLogin,
        deviceName: deviceName,
        ipAddress: _ipAddress,
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/verification',
        arguments: {
          'email': email,
          'isLogin': isLogin,
          'deviceName': deviceName,
          'ipAddress': _ipAddress,
        },
      );
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
          context: context, message: context.l10n.failedToSendCode);
    }
  }

  void _onBackPressed() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OnboardingScreen(onLocaleChanged: (locale) {})),
      (route) => false,
    );
  }

  void _onLostAccess() {
    Navigator.pushNamed(context, '/recovery-check-user');
  }

  Future<void> _onSocialLogin(String provider) async {
    setState(() => _isLoading = true);

    try {
      Map<String, String?> tokenData;
      switch (provider.toLowerCase()) {
        case 'google':
          tokenData = await _socialAuthService.signInWithGoogle();
          break;
        case 'facebook':
          tokenData = await _socialAuthService.signInWithFacebook();
          break;
        default:
          if (!mounted) return;
          MessageService.showError(
            context: context,
            message: 'Unknown provider',
          );
          setState(() => _isLoading = false);
          return;
      }

      if (tokenData.containsKey('error')) {
        if (!mounted) return;
        if (tokenData['error'] != 'User cancelled Google sign in') {
          MessageService.showError(
            context: context,
            message: tokenData['error'] ?? context.l10n.somethingWentWrong,
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final result = await _authRepository.socialLogin(
        provider: provider,
        tokenData: tokenData,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final hasPassword = result['hasPassword'] == true;
        if (hasPassword) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/set-passcode',
            (route) => false,
          );
        }
      } else {
        final needsRegistration = result['needsRegistration'] == true;
        if (needsRegistration && result['email'] != null) {
          Navigator.pushNamed(
            context,
            '/register',
            arguments: {
              'email': result['email'],
              'isSocialLogin': true,
              'provider': provider,
            },
          );
        } else {
          MessageService.showError(
            context: context,
            message: result['message'] ?? context.l10n.somethingWentWrong,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            size: 20,
          ),
          onPressed: _onBackPressed,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Logo
              SlideTransition(
                position: _logoSlide,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              SlideTransition(
                position: _titleSlide,
                child: FadeTransition(
                  opacity: _titleFade,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          context.l10n.whatIsYourEmail,
                          style:
                              theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          context.l10n.enterYourEmailDescription,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Form
              SlideTransition(
                position: _formSlide,
                child: FadeTransition(
                  opacity: _formFade,
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: context.l10n.email,
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor:
                              isDark ? Colors.grey[900] : Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 12),
                            child: Icon(
                              Icons.email_outlined,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          suffixIcon:
                              _emailController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.cancel_outlined,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.3),
                                      ),
                                      onPressed: () {
                                        _emailController.clear();
                                        setState(() {
                                          _isEmailValid = false;
                                          _emailExists = false;
                                        });
                                      },
                                    )
                                  : null,
                        ),
                        style: theme.textTheme.bodyLarge,
                        onSubmitted: (_) {
                          if (_isEmailValid) _checkEmail();
                        },
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isEmailValid && !_isLoading
                              ? _checkEmail
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isEmailValid
                                    ? (isDark ? Colors.white : theme.colorScheme.primary)
                                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                            foregroundColor:
                                _isEmailValid
                                    ? (isDark ? Colors.black : theme.colorScheme.onPrimary)
                                    : (isDark ? Colors.white38 : Colors.black38),
                            disabledBackgroundColor:
                                isDark ? Colors.grey[800] : Colors.grey[200],
                            disabledForegroundColor:
                                isDark ? Colors.white38 : Colors.black38,
                            minimumSize:
                                const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            elevation: _isEmailValid ? 4 : 0,
                            shadowColor: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 60,
                                  height: 24,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: List.generate(
                                        3, (index) {
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(
                                                milliseconds: 200),
                                        margin:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal: 3),
                                        width: 8 *
                                            _dotScales[index],
                                        height: 8 *
                                            _dotScales[index],
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .onPrimary
                                              .withValues(
                                                alpha:
                                                    _dotOpacities[
                                                        index],
                                              ),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }),
                                  ),
                                )
                              : Text(
                                  context.l10n.continueText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: _isEmailValid && !_isLoading
                                        ? (isDark ? Colors.black : theme.colorScheme.onPrimary)
                                        : (isDark ? Colors.white38 : Colors.black38),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Social
              SlideTransition(
                position: _socialSlide,
                child: FadeTransition(
                  opacity: _socialFade,
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: theme
                                  .textTheme.bodySmall
                                  ?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _onSocialLogin('Google'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey.withValues(alpha: 0.05),
                            minimumSize:
                                const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                          ),
                          icon: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          label: Text(
                            'Continue with Google',
                            style: theme
                                .textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _onSocialLogin('Facebook'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                            backgroundColor: Colors.blue
                                .withValues(alpha: isDark ? 0.15 : 0.05),
                            minimumSize:
                                const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                          ),
                          icon: Icon(
                            Icons.facebook,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                          label: Text(
                            'Continue with Facebook',
                            style: theme
                                .textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: GestureDetector(
                          onTap: _onLostAccess,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.lostAccessToEmail,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isRTL
                                    ? Icons.arrow_back_ios
                                    : Icons.arrow_forward_ios,
                                size: 12,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
