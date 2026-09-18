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
import 'package:my_wallet/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_wallet/features/auth/presentation/widgets/forgot_password_sheet.dart';
import 'package:my_wallet/features/auth/presentation/widgets/otp_input_field.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen>
    with SingleTickerProviderStateMixin {
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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _codeControllers =
        List.generate(_codeLength, (_) => TextEditingController());
    _codeFocusNodes = List.generate(_codeLength, (_) => FocusNode());

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

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
    if (email.isEmpty ||
        !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(email)) {
      MessageService.showError(
        context: context,
        message: context.l10n.validEmailRequired,
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
        message: context.l10n.digitCodeRequired,
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
      builder: (ctx) => ForgotPasswordSheet(
        authRepository: _authRepository,
        onSuccess: () {
          Navigator.pop(ctx);
          MessageService.showSuccess(
            context: context,
            message: context.l10n.passwordResetSuccess,
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
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
              child: Icon(
                isRTL ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurface,
              ),
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
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dynamic Header
                    AuthHeader(
                      title: context.l10n.appTitle,
                      subtitle: _isLoginTab
                          ? context.l10n.signInSubtitle
                          : context.l10n.signUpSubtitle,
                      icon: _isLoginTab
                          ? Icons.account_balance_wallet_rounded
                          : Icons.person_add_alt_1_rounded,
                    ),

                    const SizedBox(height: 28),

                    // Modern Pill Segmented Switcher
                    _buildTabSwitcher(theme, isDark),

                    const SizedBox(height: 24),

                    // Active Form with animated transitions
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.03),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _isLoginTab
                          ? _buildLoginForm(theme, isDark)
                          : _buildRegisterWizard(theme, isDark),
                    ),

                    // Social logins (shown on login or register step 0)
                    if (_isLoginTab || _registerStep == 0) ...[
                      const SizedBox(height: 24),
                      _buildSocialSection(theme, isDark),
                    ],

                    const SizedBox(height: 24),

                    // Bottom Toggle Link
                    _buildBottomToggle(theme),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =================== TAB SWITCHER ===================
  Widget _buildTabSwitcher(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isLoginTab) setState(() => _isLoginTab = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isLoginTab
                      ? (isDark ? const Color(0xFF2C2C2C) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isLoginTab
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    context.l10n.login,
                    style: TextStyle(
                      fontWeight: _isLoginTab ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                      color: _isLoginTab
                          ? (isDark ? Colors.white : theme.colorScheme.primary)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isLoginTab) setState(() => _isLoginTab = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isLoginTab
                      ? (isDark ? const Color(0xFF2C2C2C) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: !_isLoginTab
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    context.l10n.register,
                    style: TextStyle(
                      fontWeight: !_isLoginTab ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                      color: !_isLoginTab
                          ? (isDark ? Colors.white : theme.colorScheme.primary)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
            textDirection: TextDirection.ltr,
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'),
              ),
            ],
            decoration: _inputDecoration(
              theme: theme,
              isDark: isDark,
              hint: context.l10n.email,
              icon: Icons.mail_outline_rounded,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return context.l10n.emailRequired;
              }
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(val.trim())) {
                return context.l10n.validEmailRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            textInputAction: TextInputAction.done,
            textDirection: TextDirection.ltr,
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'),
              ),
            ],
            decoration: _inputDecoration(
              theme: theme,
              isDark: isDark,
              hint: context.l10n.password,
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onPressed: () =>
                    setState(() => _obscureLoginPassword = !_obscureLoginPassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return context.l10n.passwordRequired;
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _showForgotPasswordBottomSheet,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
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
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoggingIn ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isDark ? 0 : 2,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
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
        // Stepper Progress Header
        _buildWizardStepperHeader(theme, isDark),
        const SizedBox(height: 24),

        // Step 0: Email
        if (_registerStep == 0) ...[
          Text(
            context.l10n.whatIsYourEmail,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.enterYourEmailDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            textDirection: TextDirection.ltr,
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'),
              ),
            ],
            decoration: _inputDecoration(
              theme: theme,
              isDark: isDark,
              hint: context.l10n.email,
              icon: Icons.mail_outline_rounded,
            ),
            onSubmitted: (_) => _handleSendCode(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSendingCode ? null : _handleSendCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: isDark ? 0 : 2,
            ),
            child: _isSendingCode
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    context.l10n.continueText,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ]
        // Step 1: OTP Verification
        else if (_registerStep == 1) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _registerStep = 0),
                child: Text(
                  context.l10n.changeEmail,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          OtpInputField(
            controllers: _codeControllers,
            focusNodes: _codeFocusNodes,
            onCompleted: (_) => _handleVerifyCode(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _resendSeconds > 0
                    ? '${context.l10n.resendCodeIn} $_resendSeconds ${context.l10n.seconds}'
                    : context.l10n.resendCode,
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
          const SizedBox(height: 18),
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
                : Text(
                    context.l10n.verify,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ]
        // Step 2: Name & Password
        else ...[
          Form(
            key: _registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _registerNameController,
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'),
                    ),
                  ],
                  decoration: _inputDecoration(
                    theme: theme,
                    isDark: isDark,
                    hint: context.l10n.fullName,
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return context.l10n.fullNameRequired;
                    }
                    if (val.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _registerPasswordController,
                  obscureText: _obscureRegisterPassword,
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'),
                    ),
                  ],
                  decoration: _inputDecoration(
                    theme: theme,
                    isDark: isDark,
                    hint: context.l10n.password,
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureRegisterPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: () => setState(() =>
                          _obscureRegisterPassword = !_obscureRegisterPassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return context.l10n.passwordRequired;
                    }
                    if (val.length < 8) {
                      return context.l10n.passwordMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _registerConfirmPasswordController,
                  obscureText: _obscureRegisterConfirmPassword,
                  textInputAction: TextInputAction.done,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]'),
                    ),
                  ],
                  decoration: _inputDecoration(
                    theme: theme,
                    isDark: isDark,
                    hint: context.l10n.confirmPassword,
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureRegisterConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: () => setState(() =>
                          _obscureRegisterConfirmPassword =
                              !_obscureRegisterConfirmPassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return context.l10n.confirmPassword;
                    }
                    if (val != _registerPasswordController.text) {
                      return context.l10n.passcodesDoNotMatch;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 22),
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
                      : Text(
                          context.l10n.register,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // =================== STEPPER HEADER ===================
  Widget _buildWizardStepperHeader(ThemeData theme, bool isDark) {
    final stepTitles = [
      context.l10n.stepEmail,
      context.l10n.stepOtp,
      context.l10n.stepProfile,
    ];

    return Row(
      children: List.generate(3, (index) {
        final isDone = index < _registerStep;
        final isActive = index == _registerStep;

        return Expanded(
          child: Column(
            children: [
              Container(
                margin: EdgeInsetsDirectional.only(end: index < 2 ? 8 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: (isDone || isActive)
                      ? theme.colorScheme.primary
                      : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stepTitles[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: (isDone || isActive) ? FontWeight.w700 : FontWeight.w500,
                  color: (isDone || isActive)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // =================== SOCIAL LOGIN SECTION ===================
  Widget _buildSocialSection(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.l10n.orContinueWith,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSocialLoading ? null : () => _handleSocialLogin('Google'),
                icon: const FaIcon(
                  FontAwesomeIcons.google,
                  color: Color(0xFFEA4335),
                  size: 18,
                ),
                label: const Text('Google', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSocialLoading ? null : () => _handleSocialLogin('Facebook'),
                icon: const FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Color(0xFF1877F2),
                  size: 18,
                ),
                label: const Text('Facebook', style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =================== BOTTOM TOGGLE ===================
  Widget _buildBottomToggle(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLoginTab ? context.l10n.dontHaveAccount : context.l10n.alreadyHaveAccount,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isLoginTab = !_isLoginTab;
              if (!_isLoginTab) _registerStep = 0;
            });
          },
          child: Text(
            _isLoginTab ? context.l10n.register : context.l10n.login,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // =================== INPUT DECORATION ===================
  InputDecoration _inputDecoration({
    required ThemeData theme,
    required bool isDark,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        fontSize: 14,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF141414) : Colors.white,
      prefixIcon: Icon(
        icon,
        size: 20,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        ),
      ),
    );
  }
}
