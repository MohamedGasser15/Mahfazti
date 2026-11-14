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
import 'package:my_wallet/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:my_wallet/features/auth/presentation/widgets/auth_mode_toggle.dart';
import 'package:my_wallet/features/auth/presentation/widgets/auth_wallet_artwork.dart';
import 'package:my_wallet/features/auth/presentation/widgets/social_login_section.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onSwitchToRegister;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onBack;
  final bool isEmbedded;
  final bool initialShowEmailForm;
  final ValueChanged<bool>? onEmailFormToggle;
  final AuthRepository? authRepository;
  final SocialAuthService? socialAuthService;

  const LoginScreen({
    super.key,
    this.onSwitchToRegister,
    this.onLoginSuccess,
    this.onBack,
    this.isEmbedded = false,
    this.initialShowEmailForm = false,
    this.onEmailFormToggle,
    this.authRepository,
    this.socialAuthService,
  });

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AuthRepository _authRepository;
  late final SocialAuthService _socialAuthService;

  late final PageController _loginPageController;
  final ScrollController _loginScrollController = ScrollController();
  final GlobalKey _loginButtonKey = GlobalKey();
  Timer? _keyboardRevealTimer;

  late AnimationController _fadeController;
  late AnimationController _artworkFloatController;
  late Animation<double> _fadeAnimation;

  bool _showEmailLoginForm = false;
  bool _obscureLoginPassword = true;
  bool _isLoggingIn = false;
  bool _isSocialLoading = false;
  bool _keyboardWasVisible = false;
  bool _keyboardExpected = false;
  bool _actualKeyboardSeen = false;
  bool _keyboardClosing = false;

  // Remembers where the reset sheet was left (email / OTP / new password).
  int _forgotStep = 0;
  String _forgotEmail = '';

  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  bool get showEmailLoginForm => _showEmailLoginForm;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? AuthRepository();
    _socialAuthService = widget.socialAuthService ?? SocialAuthService();
    _showEmailLoginForm = widget.initialShowEmailForm;

    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_onFocusChanged);

    _loginPageController = PageController(
      initialPage: widget.initialShowEmailForm ? 1 : 0,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _artworkFloatController = AnimationController(
      duration: const Duration(milliseconds: 3200),
      vsync: this,
    );

    _fadeController.forward();
  }

  @override
  void didChangeMetrics() => _scheduleKeyboardReveal();

  void _onFocusChanged() => _scheduleKeyboardReveal();

  void _onInputTap() {
    _keyboardClosing = false;
    if (!_keyboardExpected) setState(() => _keyboardExpected = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _revealLoginButton(force: true);
    });
  }

  void _scheduleKeyboardReveal() {
    _keyboardRevealTimer?.cancel();
    _keyboardRevealTimer = Timer(
      const Duration(milliseconds: 60),
      _revealLoginButton,
    );
  }

  void _revealLoginButton({bool force = false}) {
    if (!mounted ||
        !_showEmailLoginForm ||
        !_loginScrollController.hasClients) {
      return;
    }
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

    final buttonBox = _loginButtonKey.currentContext?.findRenderObject();
    if (buttonBox is! RenderBox || !buttonBox.attached) return;
    final buttonBottom = buttonBox
        .localToGlobal(Offset(0, buttonBox.size.height))
        .dy;
    final keyboardTop = MediaQuery.sizeOf(context).height - keyboardHeight;
    final neededScroll = math.max(
      _keyboardWasVisible ? 0.0 : 54.0,
      buttonBottom - keyboardTop + 4,
    );
    _keyboardWasVisible = true;
    if (neededScroll <= 1) return;

    final position = _loginScrollController.position;
    final target = math.min(
      position.maxScrollExtent,
      position.pixels + neededScroll,
    );
    if (target - position.pixels <= 1) return;
    if (!force && position.isScrollingNotifier.value) return;
    _loginScrollController
        .animateTo(
          target,
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeInOutCubic,
        )
        .then((_) {
          if (mounted && _loginScrollController.hasClients) {
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
    if (_loginScrollController.hasClients) {
      _loginScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _artworkFloatController.stop();
      _artworkFloatController.value = 0;
    } else if (!_artworkFloatController.isAnimating) {
      _artworkFloatController.repeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(_onFocusChanged);
    _keyboardRevealTimer?.cancel();
    _fadeController.dispose();
    _artworkFloatController.dispose();
    _loginPageController.dispose();
    _loginScrollController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  void goToEmailLogin(bool showEmail) {
    if (_showEmailLoginForm == showEmail) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (!showEmail) {
      _keyboardWasVisible = false;
      _keyboardExpected = false;
      _actualKeyboardSeen = false;
    }
    setState(() => _showEmailLoginForm = showEmail);
    widget.onEmailFormToggle?.call(showEmail);
    if (_loginPageController.hasClients) {
      _loginPageController.animateToPage(
        showEmail ? 1 : 0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void resetToSocialPage() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_loginPageController.hasClients) {
      _loginPageController.jumpToPage(0);
    }
    setState(() => _showEmailLoginForm = false);
    widget.onEmailFormToggle?.call(false);
  }

  bool handleBack() {
    if (_showEmailLoginForm) {
      goToEmailLogin(false);
      return true;
    }
    return false;
  }

  void _onNavigateAfterAuth() {
    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
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

  Future<void> _openForgotPasswordPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pageContext) => ForgotPasswordScreen(
          authRepository: _authRepository,
          initialStep: _forgotStep,
          initialEmail: _forgotEmail,
          onProgress: (step, email) {
            _forgotStep = step;
            _forgotEmail = email;
          },
          onSuccess: () {
            _forgotStep = 0;
            _forgotEmail = '';
            Navigator.pop(pageContext);
            MessageService.showSuccess(
              context: context,
              message: context.l10n.passwordResetSuccess,
            );
          },
        ),
      ),
    );
  }

  void _onSwitchToRegister() {
    if (widget.onSwitchToRegister != null) {
      widget.onSwitchToRegister!();
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = PageView(
      controller: _loginPageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildLoginPage(theme, isDark, email: false),
        _buildLoginPage(theme, isDark, email: true),
      ],
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
          if (_showEmailLoginForm ||
              (Navigator.of(context).canPop() || widget.onBack != null))
            PositionedDirectional(
              start: 12,
              top: MediaQuery.paddingOf(context).top + 4,
              child: AppGlassBackButton(
                onPressed: () {
                  if (_showEmailLoginForm) {
                    goToEmailLogin(false);
                  } else if (widget.onBack != null) {
                    widget.onBack!();
                  } else if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginPage(ThemeData theme, bool isDark, {required bool email}) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return SingleChildScrollView(
      controller: email ? _loginScrollController : null,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.paddingOf(context).top + (email ? 56 : 8),
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: email
                ? [
                    _buildEditorialEmailHero(theme, isDark),
                    const SizedBox(height: 20),
                    Text(
                      isArabic
                          ? 'الدخول بالبريد الإلكتروني'
                          : 'Sign in with email',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isArabic
                          ? 'أدخل بياناتك للمتابعة.'
                          : 'Enter your details to continue.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLoginForm(theme, isDark),
                    const SizedBox(height: 12),
                    _buildBackToSocialLogin(theme),
                    const SizedBox(height: 4),
                    AuthModeToggle(
                      onLoginPage: true,
                      onPressed: _onSwitchToRegister,
                    ),
                  ]
                : [
                    _buildEditorialSocialHero(theme, isDark),
                    const SizedBox(height: 8),
                    Text(
                      isArabic ? 'يلا نبدأ.' : 'Let’s get you in.',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isArabic
                          ? 'اختار طريقة الدخول المناسبة ليك.'
                          : 'Choose how you’d like to continue.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SocialLoginSection(
                      isLoading: _isSocialLoading,
                      socialFirst: true,
                      onProviderSelected: _handleSocialLogin,
                    ),
                    const SizedBox(height: 8),
                    _buildEmailLoginLink(theme),
                    AuthModeToggle(
                      onLoginPage: true,
                      onPressed: _onSwitchToRegister,
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorialSocialHero(ThemeData theme, bool isDark) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final ink = isDark ? const Color(0xFFF4F4F5) : const Color(0xFF18181B);
    final muted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final artworkHeight = (MediaQuery.sizeOf(context).height * 0.26).clamp(
      180.0,
      228.0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                isDark
                    ? 'assets/icons/mahfazti-logo-light.png'
                    : 'assets/icons/mahfazti-logo-dark.png',
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.l10n.appTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
        ),
        const SizedBox(height: 28),
        Text(
          isArabic ? 'فلوسك في صورة أوضح' : 'A BETTER VIEW OF YOUR MONEY',
          style: TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: isArabic ? 0 : 1.7,
          ),
        ),
        const SizedBox(height: 13),
        Text(
          isArabic ? 'ركّز على اللي\nيهمك.' : 'Make room for\nwhat matters.',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: ink,
            fontSize: 38,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isArabic
              ? 'اعرف فلوسك بتروح فين، وخطط بثقة.'
              : 'Know where your money goes. Move with confidence.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: muted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: artworkHeight,
          child: AuthWalletArtwork(
            isDark: isDark,
            height: artworkHeight,
            entranceAnimation: _fadeController,
            floatAnimation: _artworkFloatController,
          ),
        ),
      ],
    );
  }

  Widget _buildEditorialEmailHero(ThemeData theme, bool isDark) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final ink = isDark ? const Color(0xFFF4F4F5) : const Color(0xFF18181B);
    final muted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'أهلاً بعودتك' : 'WELCOME BACK',
          style: TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: isArabic ? 0 : 2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    isArabic
                        ? 'كمّل من مكان\nما وقفت.'
                        : 'Right where\nyou left off.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: ink,
                      fontSize: constraints.maxWidth < 300 ? 29 : 35,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                            padding: const EdgeInsets.all(13),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 30,
                                  height: 3,
                                  color: const Color(0xFF71717A),
                                ),
                                const SizedBox(height: 7),
                                Container(
                                  width: 18,
                                  height: 3,
                                  color: const Color(0xFF71717A),
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
              ? 'محفظتك مستنياك وقت ما تحتاجها.'
              : 'Your money is right here when you need it.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: muted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 26),
        Divider(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
        ),
      ],
    );
  }

  Widget _buildBackToSocialLogin(ThemeData theme) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Center(
      child: TextButton(
        onPressed: () => goToEmailLogin(false),
        child: Text(
          isArabic
              ? 'الرجوع إلى Google وFacebook'
              : 'Back to Google or Facebook',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmailLoginLink(ThemeData theme) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Center(
      child: TextButton(
        onPressed: () => goToEmailLogin(true),
        child: Text(
          isArabic ? 'الدخول بالبريد الإلكتروني ←' : 'Sign in with email  →',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, bool isDark) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLoginFieldLabel(
            isArabic ? 'البريد الإلكتروني' : 'EMAIL ADDRESS',
            theme,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _loginEmailController,
            onTap: _onInputTap,
            onTapOutside: (_) => _dismissKeyboard(),
            keyboardType: TextInputType.emailAddress,
            keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
            textInputAction: TextInputAction.next,
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
              hint: context.l10n.email,
              icon: null,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return context.l10n.emailRequired;
              }
              if (!EmailValidator.isValid(val)) {
                return context.l10n.validEmailRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          _buildLoginFieldLabel(isArabic ? 'كلمة المرور' : 'PASSWORD', theme),
          const SizedBox(height: 8),
          TextFormField(
            controller: _loginPasswordController,
            onTap: _onInputTap,
            onTapOutside: (_) => _dismissKeyboard(),
            obscureText: _obscureLoginPassword,
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
              letterSpacing: _obscureLoginPassword ? 2.4 : 0,
              fontWeight: FontWeight.w500,
            ),
            keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
            textInputAction: TextInputAction.done,
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
              icon: null,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onPressed: () => setState(
                  () => _obscureLoginPassword = !_obscureLoginPassword,
                ),
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
              onPressed: _openForgotPasswordPage,
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
            key: _loginButtonKey,
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
                ? const AppProgressIndicator.small(color: Colors.white)
                : Text(
                    context.l10n.login,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFieldLabel(String label, ThemeData theme) {
    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
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
