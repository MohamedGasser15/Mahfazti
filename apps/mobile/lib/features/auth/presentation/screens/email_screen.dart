import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wallet/core/constants/app_routes.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/social_auth_service.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen>
    with TickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  final SocialAuthService _socialAuthService = SocialAuthService();

  bool _isLoginTab = true;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;

  bool _isLoggingIn = false;
  bool _isRegistering = false;
  bool _isSendingCode = false;
  bool _isVerifying = false;
  bool _isSocialLoading = false;

  // Login Form
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register Form
  final _registerFormKey = GlobalKey<FormState>();
  final _registerEmailController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  int _registerStep = 0; // 0: Email, 1: OTP, 2: Name & Password
  String? _registeredEmail;
  int _resendSeconds = 90;
  Timer? _resendTimer;

  static const int _codeLength = 6;
  late final List<TextEditingController> _codeControllers;
  late final List<FocusNode> _codeFocusNodes;

  late AnimationController _fadeController;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _codeControllers = List.generate(_codeLength, (_) => TextEditingController());
    _codeFocusNodes = List.generate(_codeLength, (_) => FocusNode());

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _resendTimer?.cancel();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerNameController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final n in _codeFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onNavigateAfterAuth() {
    if (!mounted) return;
    final currency = SharedPrefs.currency;
    if (currency == null || currency.isEmpty) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.currencySelection,
        (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  // =================== LOGIN ===================
  Future<void> _handleLogin() async {
    if (!(_loginFormKey.currentState?.validate() ?? false)) return;
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    setState(() => _isLoggingIn = true);
    try {
      await _authRepository.login(email: email, password: password);
      if (!mounted) return;
      MessageService.showSuccess(
        context: context,
        message: context.l10n.loginSuccess,
      );
      _onNavigateAfterAuth();
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  // =================== REGISTER STEP 0: SEND CODE ===================
  Future<void> _handleSendCode() async {
    final email = _registerEmailController.text.trim();
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      MessageService.showError(
        context: context,
        message: context.l10n.enterYourEmailDescription,
      );
      return;
    }

    setState(() => _isSendingCode = true);
    try {
      await _authRepository.sendCode(email: email);
      if (!mounted) return;
      _registeredEmail = email;
      for (final c in _codeControllers) {
        c.clear();
      }
      setState(() => _registerStep = 1);
      _startCountdown();
      MessageService.showSuccess(
        context: context,
        message: context.l10n.verificationCodeSent(email),
      );
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  // =================== REGISTER STEP 1: VERIFY CODE ===================
  Future<void> _handleVerifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length != _codeLength) {
      MessageService.showError(
        context: context,
        message: context.l10n.invalidVerificationCode,
      );
      return;
    }

    setState(() => _isVerifying = true);
    try {
      await _authRepository.verifyEmail(
        email: _registeredEmail!,
        code: code,
      );
      if (!mounted) return;
      _resendTimer?.cancel();
      setState(() => _registerStep = 2);
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // =================== REGISTER STEP 2: COMPLETE REGISTRATION ===================
  Future<void> _handleRegister() async {
    if (!(_registerFormKey.currentState?.validate() ?? false)) return;
    final fullName = _registerNameController.text.trim();
    final password = _registerPasswordController.text;
    final confirmPassword = _registerConfirmPasswordController.text;

    setState(() => _isRegistering = true);
    try {
      await _authRepository.register(
        fullName: fullName,
        email: _registeredEmail!,
        password: password,
        confirmPassword: confirmPassword,
      );
      if (!mounted) return;

      // Auto-login user after registration
      await _authRepository.login(
        email: _registeredEmail!,
        password: password,
      );
      if (!mounted) return;

      MessageService.showSuccess(
        context: context,
        message: context.l10n.accountCreatedSuccess,
      );
      _onNavigateAfterAuth();
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  void _startCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 90);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendSeconds--);
      if (_resendSeconds <= 0) timer.cancel();
    });
  }

  // =================== SOCIAL LOGIN ===================
  Future<void> _handleSocialLogin(String provider) async {
    if (_isSocialLoading || _isLoggingIn) return;
    setState(() => _isSocialLoading = true);

    try {
      Map<String, String?> tokenData;
      if (provider.toLowerCase() == 'google') {
        tokenData = await _socialAuthService.signInWithGoogle();
      } else {
        tokenData = await _socialAuthService.signInWithFacebook();
      }

      if (tokenData.containsKey('error')) {
        if (!mounted) return;
        if (tokenData['error'] != 'User cancelled Google sign in') {
          MessageService.showError(
            context: context,
            message: tokenData['error'] ?? context.l10n.somethingWentWrong,
          );
        }
        return;
      }

      final result = await _authRepository.socialLogin(
        provider: provider,
        tokenData: tokenData,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        MessageService.showSuccess(
          context: context,
          message: context.l10n.loginSuccess,
        );
        _onNavigateAfterAuth();
      } else {
        MessageService.showError(
          context: context,
          message: result['message'] ?? context.l10n.somethingWentWrong,
        );
      }
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  // =================== FORGOT PASSWORD MODAL ===================
  void _showForgotPasswordBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ForgotPasswordSheet(
        authRepository: _authRepository,
        onSuccess: () {
          Navigator.pop(ctx);
          MessageService.showSuccess(
            context: context,
            message: 'Password reset successfully. Please login.',
          );
        },
      ),
    );
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
          onPressed: () {
            if (_registerStep > 0 && !_isLoginTab) {
              setState(() => _registerStep--);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.onboarding,
                (route) => false,
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SlideTransition(
                  position: _logoSlide,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
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
                                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            size: 38,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.appTitle,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.manageYourMoneyEasily,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tab Switcher
                SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isLoginTab = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _isLoginTab
                                          ? (isDark ? Colors.grey[800] : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: _isLoginTab
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        context.l10n.login,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _isLoginTab
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isLoginTab = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_isLoginTab
                                          ? (isDark ? Colors.grey[800] : Colors.white)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: !_isLoginTab
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        context.l10n.register,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: !_isLoginTab
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Content
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isLoginTab
                              ? _buildLoginForm(theme, isDark)
                              : _buildRegisterWizard(theme, isDark),
                        ),

                        const SizedBox(height: 20),
                        _buildSocialSection(theme, isDark),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =================== LOGIN FORM ===================
  Widget _buildLoginForm(ThemeData theme, bool isDark) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              theme: theme,
              isDark: isDark,
              hint: context.l10n.email,
              icon: Icons.email_outlined,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(val.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              theme: theme,
              isDark: isDark,
              hint: context.l10n.password,
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _showForgotPasswordBottomSheet,
              child: Text(
                context.l10n.forgotPassword,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoggingIn ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
            ),
            child: _isLoggingIn
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    context.l10n.login,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }

  // =================== REGISTER 3-STEP WIZARD ===================
  Widget _buildRegisterWizard(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Steps indicator
        Row(
          children: List.generate(3, (index) {
            final done = index < _registerStep;
            final active = index == _registerStep;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: (done || active)
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.grey[800] : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < 2) const SizedBox(width: 6),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        if (_registerStep == 0) ...[
          // Step 1: Email
          Text(
            context.l10n.whatIsYourEmail,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.enterYourEmailDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              theme: theme,
              isDark: isDark,
              hint: context.l10n.email,
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSendingCode ? null : _handleSendCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSendingCode
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(context.l10n.continueText, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ] else if (_registerStep == 1) ...[
          // Step 2: OTP Verification
          Text(
            context.l10n.enterVerificationCode,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.verificationCodeSent(_registeredEmail ?? ''),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_codeLength, (index) {
              return SizedBox(
                width: 46,
                height: 54,
                child: TextField(
                  controller: _codeControllers[index],
                  focusNode: _codeFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && index < _codeLength - 1) {
                      _codeFocusNodes[index + 1].requestFocus();
                    } else if (val.isEmpty && index > 0) {
                      _codeFocusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _resendSeconds > 0
                    ? 'Resend code in ${_resendSeconds}s'
                    : "Didn't receive code?",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              if (_resendSeconds <= 0)
                TextButton(
                  onPressed: _handleSendCode,
                  child: Text(
                    context.l10n.resendCode,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isVerifying ? null : _handleVerifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isVerifying
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(context.l10n.verify, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ] else ...[
          // Step 3: Name & Password
          Form(
            key: _registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _registerNameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    theme: theme,
                    isDark: isDark,
                    hint: context.l10n.fullName,
                    icon: Icons.person_outline,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Full name is required';
                    if (val.trim().length < 3) return 'Name must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _registerPasswordController,
                  obscureText: _obscureRegisterPassword,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    theme: theme,
                    isDark: isDark,
                    hint: context.l10n.password,
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureRegisterPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: () => setState(() => _obscureRegisterPassword = !_obscureRegisterPassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Password is required';
                    if (val.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _registerConfirmPasswordController,
                  obscureText: _obscureRegisterConfirmPassword,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration(
                    theme: theme,
                    isDark: isDark,
                    hint: context.l10n.confirmPassword,
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureRegisterConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: () => setState(() => _obscureRegisterConfirmPassword = !_obscureRegisterConfirmPassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please confirm your password';
                    if (val != _registerPasswordController.text) return 'Passwords do not match';
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isRegistering ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isRegistering
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(context.l10n.register, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // =================== SOCIAL SECTION ===================
  Widget _buildSocialSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.l10n.orContinueWith,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            Expanded(child: Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSocialLoading ? null : () => _handleSocialLogin('Google'),
                icon: const FaIcon(FontAwesomeIcons.google, color: Color(0xFFEA4335), size: 18),
                label: const Text('Google', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSocialLoading ? null : () => _handleSocialLogin('Facebook'),
                icon: const FaIcon(FontAwesomeIcons.facebook, color: Color(0xFF1877F2), size: 18),
                label: const Text('Facebook', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required ThemeData theme,
    required bool isDark,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      filled: true,
      fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
      prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }
}

// =================== FORGOT PASSWORD BOTTOM SHEET ===================
class _ForgotPasswordSheet extends StatefulWidget {
  final AuthRepository authRepository;
  final VoidCallback onSuccess;

  const _ForgotPasswordSheet({
    required this.authRepository,
    required this.onSuccess,
  });

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  int _step = 0; // 0: Email, 1: Code, 2: New Password
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendForgotCode() async {
    final email = _emailController.text.trim();
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      MessageService.showError(context: context, message: 'Please enter a valid email');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await widget.authRepository.forgotPassword(email: email);
      if (!mounted) return;
      setState(() => _step = 1);
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(context: context, message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyResetCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      MessageService.showError(context: context, message: 'Please enter the 6-digit code');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await widget.authRepository.verifyResetCode(
        email: _emailController.text.trim(),
        code: code,
      );
      if (!mounted) return;
      setState(() => _step = 2);
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(context: context, message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    if (newPass.length < 8) {
      MessageService.showError(context: context, message: 'Password must be at least 8 characters');
      return;
    }
    if (newPass != confirmPass) {
      MessageService.showError(context: context, message: 'Passwords do not match');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await widget.authRepository.resetPassword(
        email: _emailController.text.trim(),
        newPassword: newPass,
        confirmPassword: confirmPass,
      );
      if (!mounted) return;
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(context: context, message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.forgotPassword,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (_step == 0) ...[
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: context.l10n.email,
                filled: true,
                fillColor: isDark ? Colors.black : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendForgotCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(context.l10n.sendCode),
            ),
          ] else if (_step == 1) ...[
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '6-digit Reset Code',
                filled: true,
                fillColor: isDark ? Colors.black : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyResetCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(context.l10n.verify),
            ),
          ] else ...[
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'New Password',
                filled: true,
                fillColor: isDark ? Colors.black : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: context.l10n.confirmPassword,
                filled: true,
                fillColor: isDark ? Colors.black : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Reset Password'),
            ),
          ],
        ],
      ),
    );
  }
}
