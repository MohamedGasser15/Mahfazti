import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/constants/app_routes.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/social_auth_service.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/email_validator.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/core/widgets/app_progress_indicator.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:my_wallet/features/auth/presentation/controllers/register_controller.dart';
import 'package:my_wallet/features/auth/presentation/models/registration_step.dart';
import 'package:my_wallet/features/auth/presentation/widgets/auth_header.dart';
import 'package:my_wallet/features/auth/presentation/widgets/auth_mode_toggle.dart';
import 'package:my_wallet/features/auth/presentation/widgets/otp_input_field.dart';
import 'package:my_wallet/features/auth/presentation/widgets/social_login_section.dart';

class RegisterScreen extends StatefulWidget {
  final RegisterController? controller;
  final VoidCallback? onSwitchToLogin;
  final VoidCallback? onRegistrationSuccess;
  final VoidCallback? onBack;
  final bool isEmbedded;
  final AuthRepository? authRepository;
  final SocialAuthService? socialAuthService;

  const RegisterScreen({
    super.key,
    this.controller,
    this.onSwitchToLogin,
    this.onRegistrationSuccess,
    this.onBack,
    this.isEmbedded = false,
    this.authRepository,
    this.socialAuthService,
  });

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen>
    with WidgetsBindingObserver {
  late final RegisterController _controller;
  bool _ownsController = false;

  late final AuthRepository _authRepository;
  late final SocialAuthService _socialAuthService;
  final ScrollController _registerScrollController = ScrollController();
  final GlobalKey _primaryButtonKey = GlobalKey();
  Timer? _keyboardRevealTimer;

  bool _isSocialLoading = false;
  bool _keyboardWasVisible = false;
  bool _keyboardExpected = false;
  bool _actualKeyboardSeen = false;
  bool _keyboardClosing = false;

  RegisterController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? AuthRepository();
    _socialAuthService = widget.socialAuthService ?? SocialAuthService();

    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = RegisterController(authRepository: _authRepository);
      _ownsController = true;
    }

    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_onFocusChanged);
  }

  @override
  void didChangeMetrics() => _scheduleKeyboardReveal();

  void _onFocusChanged() => _scheduleKeyboardReveal();

  void _onInputTap() {
    _keyboardClosing = false;
    if (!_keyboardExpected) setState(() => _keyboardExpected = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _revealRegisterButton(force: true);
    });
  }

  void _scheduleKeyboardReveal() {
    _keyboardRevealTimer?.cancel();
    _keyboardRevealTimer = Timer(
      const Duration(milliseconds: 60),
      _revealRegisterButton,
    );
  }

  void _revealRegisterButton({bool force = false}) {
    if (!mounted || !_registerScrollController.hasClients) return;
    final actualKeyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    if (_keyboardClosing) {
      if (actualKeyboardHeight <= 0) {
        _keyboardClosing = false;
        _actualKeyboardSeen = false;
      }
      return;
    }
    if (actualKeyboardHeight > 0) {
      _actualKeyboardSeen = true;
    } else if (_actualKeyboardSeen) {
      _actualKeyboardSeen = false;
      _dismissKeyboard();
      return;
    }
    final keyboardHeight = math.max(
      actualKeyboardHeight,
      _keyboardExpected ? 350.0 : 0.0,
    );
    if (keyboardHeight <= 0) {
      _keyboardWasVisible = false;
      if (_keyboardExpected) setState(() => _keyboardExpected = false);
      return;
    }

    final buttonBox = _primaryButtonKey.currentContext?.findRenderObject();
    if (buttonBox is! RenderBox || !buttonBox.attached) return;
    final buttonBottom = buttonBox
        .localToGlobal(Offset(0, buttonBox.size.height))
        .dy;
    final keyboardTop = MediaQuery.sizeOf(context).height - keyboardHeight;
    final neededScroll = math.max(
      _keyboardWasVisible ? 0.0 : 70.0,
      buttonBottom - keyboardTop + 16,
    );
    _keyboardWasVisible = true;
    if (neededScroll <= 1) return;

    final position = _registerScrollController.position;
    final target = math.min(
      position.maxScrollExtent,
      position.pixels + neededScroll,
    );
    if (target - position.pixels <= 1) return;
    if (!force && position.isScrollingNotifier.value) return;
    _registerScrollController
        .animateTo(
          target,
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeInOutCubic,
        )
        .then((_) {
          if (mounted && _registerScrollController.hasClients) {
            _scheduleKeyboardReveal();
          }
        });
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    _keyboardRevealTimer?.cancel();
    _keyboardClosing = true;
    _keyboardWasVisible = false;
    if (_keyboardExpected) setState(() => _keyboardExpected = false);
    if (_registerScrollController.hasClients) {
      _registerScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(_onFocusChanged);
    _keyboardRevealTimer?.cancel();
    _registerScrollController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onNavigateAfterAuth() {
    if (widget.onRegistrationSuccess != null) {
      widget.onRegistrationSuccess!();
      return;
    }
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

  Future<void> _handleSendCode() async {
    await _controller.sendCode(
      onError: (message) =>
          MessageService.showError(context: context, message: message),
      onSuccess: (message) =>
          MessageService.showSuccess(context: context, message: message),
      validEmailRequiredMessage: context.l10n.validEmailRequired,
      verificationCodeSentMessage: (email) =>
          context.l10n.verificationCodeSent(email),
    );
  }

  Future<void> _handleVerifyCode() async {
    await _controller.verifyCode(
      onError: (message) =>
          MessageService.showError(context: context, message: message),
      digitCodeRequiredMessage: context.l10n.digitCodeRequired,
    );
  }

  Future<void> _handleRegister() async {
    final success = await _controller.register(
      onError: (message) =>
          MessageService.showError(context: context, message: message),
      onSuccess: (message) =>
          MessageService.showSuccess(context: context, message: message),
      accountCreatedSuccessMessage: context.l10n.accountCreatedSuccess,
    );
    if (success && mounted) {
      _onNavigateAfterAuth();
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (_isSocialLoading || _controller.isRegistering) return;
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

  void _onSwitchToLogin() {
    if (widget.onSwitchToLogin != null) {
      widget.onSwitchToLogin!();
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void handleBackButtonPress() {
    FocusManager.instance.primaryFocus?.unfocus();
    final handled = _controller.handleBack();
    if (!handled) {
      if (widget.onBack != null) {
        widget.onBack!();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        _onSwitchToLogin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => _buildRegisterPage(theme, isDark),
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF09090B)
          : const Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: !Platform.isIOS,
      body: Stack(
        children: [
          ResponsiveWrapper(child: content),
          PositionedDirectional(
            start: 12,
            top: MediaQuery.paddingOf(context).top + 4,
            child: AppGlassBackButton(onPressed: handleBackButtonPress),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterPage(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      controller: _registerScrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.paddingOf(context).top + 56,
        24,
        24,
      ),
      child: AnimatedPadding(
        duration: Duration(milliseconds: _keyboardExpected ? 0 : 120),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: Platform.isIOS
              ? math.max(
                  MediaQuery.viewInsetsOf(context).bottom,
                  _keyboardExpected ? 350.0 : 0.0,
                )
              : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_controller.step == RegistrationStep.email) ...[
              _buildRegisterHero(theme, isDark),
              const SizedBox(height: 20),
            ] else ...[
              AuthHeader(
                title: context.l10n.appTitle,
                subtitle: context.l10n.signUpSubtitle,
              ),
              const SizedBox(height: 28),
            ],
            _buildRegisterWizard(theme, isDark),
            if (_controller.step == RegistrationStep.email) ...[
              const SizedBox(height: 24),
              SocialLoginSection(
                isLoading: _isSocialLoading,
                onProviderSelected: _handleSocialLogin,
              ),
            ],
            const SizedBox(height: 18),
            AuthModeToggle(onLoginPage: false, onPressed: _onSwitchToLogin),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterHero(ThemeData theme, bool isDark) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final ink = isDark ? const Color(0xFFF4F4F5) : const Color(0xFF18181B);
    final muted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final line = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: line),
        const SizedBox(height: 24),
        Text(
          isArabic ? 'أهلاً بيك في محفظتي' : 'WELCOME TO MAHFAZTI',
          style: TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: isArabic ? 0 : 2,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 86,
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                Expanded(
                  child: Text(
                    isArabic
                        ? 'ابدأ بصورة\nأوضح لفلوسك.'
                        : 'Start with a\nclearer picture.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: ink,
                      fontSize: constraints.maxWidth < 300 ? 27 : 32,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  height: 72,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        right: 4,
                        child: Transform.rotate(
                          angle: -.12,
                          child: Container(
                            width: 75,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3F3F46)
                                  : const Color(0xFFE4E4E7),
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 0,
                        child: Transform.rotate(
                          angle: .12,
                          child: Container(
                            width: 88,
                            height: 59,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF29292E), Color(0xFF101012)],
                              ),
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: .12)
                                      : Colors.black.withValues(alpha: .12),
                                  blurRadius: isDark ? 20 : 12,
                                  offset: const Offset(0, 9),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 27,
                                      height: 3,
                                      color: const Color(0xFFA1A1AA),
                                    ),
                                    const SizedBox(height: 7),
                                    Container(
                                      width: 17,
                                      height: 3,
                                      color: const Color(0xFFA1A1AA),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Color(0xFFA1A1AA),
                                  size: 17,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isArabic
              ? 'كل اللي يخص فلوسك في مكان واحد.'
              : 'Everything about your money, in one place.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: muted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        Divider(color: line),
        const SizedBox(height: 18),
        Text(
          isArabic ? 'اعمل حسابك' : 'Create your account',
          style: theme.textTheme.titleLarge?.copyWith(
            color: ink,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          isArabic
              ? '٣ خطوات بسيطة. أولاً، الإيميل.'
              : 'Three quick steps. First, your email.',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }

  Widget _buildRegisterWizard(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWizardStepperHeader(theme, isDark),
        const SizedBox(height: 24),

        // Step 0: Email
        if (_controller.step == RegistrationStep.email) ...[
          Text(
            context.l10n.whatIsYourEmail,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.enterYourEmailDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 18),
          Form(
            key: _controller.emailFormKey,
            child: TextFormField(
              controller: _controller.emailController,
              onTap: _onInputTap,
              onTapOutside: (_) => _dismissKeyboard(),
              keyboardType: TextInputType.emailAddress,
              keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
              textInputAction: TextInputAction.done,
              textDirection: TextDirection.ltr,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              decoration: _inputDecoration(
                theme: theme,
                isDark: isDark,
                hint: context.l10n.email,
                icon: Icons.mail_outline_rounded,
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return null;
                return EmailValidator.isValid(email)
                    ? null
                    : context.l10n.validEmailRequired;
              },
              onFieldSubmitted: (_) => _handleSendCode(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            key: _primaryButtonKey,
            onPressed: _controller.isSendingCode ? null : _handleSendCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isDark ? 0 : 2,
            ),
            child: _controller.isSendingCode
                ? const AppProgressIndicator.small(color: Colors.white)
                : Text(
                    context.l10n.continueText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ]
        // Step 1: OTP Verification
        else if (_controller.step == RegistrationStep.verification) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.enterVerificationCode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _controller.needsFreshCode
                          ? Localizations.localeOf(context).languageCode == 'ar'
                                ? 'الكود السابق اتستخدم. اطلب كود جديد عشان تكمل.'
                                : 'That code was used. Resend a new code to continue.'
                          : context.l10n.verificationCodeSent(
                              _controller.registeredEmail ?? '',
                            ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _controller.resetToEmailStep();
                },
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
          IgnorePointer(
            ignoring: _controller.needsFreshCode,
            child: Opacity(
              opacity: _controller.needsFreshCode ? 0.5 : 1,
              child: OtpInputField(
                controllers: _controller.codeControllers,
                focusNodes: _controller.codeFocusNodes,
                onCompleted: (_) => _handleVerifyCode(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_controller.resendSeconds > 0)
                Text(
                  '${context.l10n.resendCodeIn} ${_controller.resendSeconds} ${context.l10n.seconds}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                )
              else
                TextButton(
                  onPressed: _controller.isSendingCode ? null : _handleSendCode,
                  child: _controller.isSendingCode
                      ? const AppProgressIndicator.small()
                      : Text(
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
            key: _primaryButtonKey,
            onPressed: _controller.isVerifying || _controller.needsFreshCode
                ? null
                : _handleVerifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _controller.isVerifying
                ? const AppProgressIndicator.small(color: Colors.white)
                : Text(
                    context.l10n.verify,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ]
        // Step 2: Name & Password
        else ...[
          Form(
            key: _controller.detailsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _controller.nameController,
                  onTap: _onInputTap,
                  onTapOutside: (_) => _dismissKeyboard(),
                  textInputAction: TextInputAction.next,
                  keyboardAppearance: isDark
                      ? Brightness.dark
                      : Brightness.light,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp(
                        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
                      ),
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
                  controller: _controller.passwordController,
                  onTap: _onInputTap,
                  onTapOutside: (_) => _dismissKeyboard(),
                  obscureText: _controller.obscurePassword,
                  textAlignVertical: TextAlignVertical.center,
                  obscuringCharacter: '•',
                  strutStyle: const StrutStyle(
                    fontSize: 16,
                    height: 1.4,
                    forceStrutHeight: true,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    leadingDistribution: TextLeadingDistribution.even,
                    letterSpacing: _controller.obscurePassword ? 2.4 : 0,
                    fontWeight: FontWeight.w500,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardAppearance: isDark
                      ? Brightness.dark
                      : Brightness.light,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp(
                        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
                      ),
                    ),
                  ],
                  decoration: _inputDecoration(
                    theme: theme,
                    isDark: isDark,
                    hint: context.l10n.password,
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _controller.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      onPressed: _controller.toggleObscurePassword,
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
                  controller: _controller.confirmPasswordController,
                  onTap: _onInputTap,
                  onTapOutside: (_) => _dismissKeyboard(),
                  obscureText: _controller.obscureConfirmPassword,
                  textAlignVertical: TextAlignVertical.center,
                  obscuringCharacter: '•',
                  strutStyle: const StrutStyle(
                    fontSize: 16,
                    height: 1.4,
                    forceStrutHeight: true,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    leadingDistribution: TextLeadingDistribution.even,
                    letterSpacing: _controller.obscureConfirmPassword ? 2.4 : 0,
                    fontWeight: FontWeight.w500,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardAppearance: isDark
                      ? Brightness.dark
                      : Brightness.light,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp(
                        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
                      ),
                    ),
                  ],
                  decoration: _inputDecoration(
                    theme: theme,
                    isDark: isDark,
                    hint: context.l10n.confirmPassword,
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _controller.obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      onPressed: _controller.toggleObscureConfirmPassword,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return context.l10n.confirmPassword;
                    }
                    if (val != _controller.passwordController.text) {
                      return context.l10n.passcodesDoNotMatch;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  key: _primaryButtonKey,
                  onPressed: _controller.isRegistering ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _controller.isRegistering
                      ? const AppProgressIndicator.small(color: Colors.white)
                      : Text(
                          context.l10n.register,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWizardStepperHeader(ThemeData theme, bool isDark) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final stepTitles = [
      context.l10n.stepEmail,
      context.l10n.stepOtp,
      context.l10n.stepProfile,
    ];

    return Row(
      children: List.generate(3, (index) {
        final isDone = index < _controller.step.index;
        final isActive = index == _controller.step.index;

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsetsDirectional.only(end: index < 2 ? 8 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: (isDone || isActive)
                      ? theme.colorScheme.primary
                      : (isDark
                            ? const Color(0xFF2C2C2C)
                            : const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? stepTitles[index]
                    : '${(index + 1).toString().padLeft(2, '0')}  ${['EMAIL', 'VERIFY', 'DETAILS'][index]}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: (isDone || isActive)
                      ? FontWeight.w700
                      : FontWeight.w500,
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

  InputDecoration _inputDecoration({
    required ThemeData theme,
    required bool isDark,
    required String hint,
    IconData? icon,
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
      prefixIcon: icon == null
          ? null
          : Icon(
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
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
