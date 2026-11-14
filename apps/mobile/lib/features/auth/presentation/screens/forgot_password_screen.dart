import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/utils/email_validator.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/core/widgets/app_progress_indicator.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:my_wallet/features/auth/presentation/widgets/otp_input_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final VoidCallback onSuccess;

  /// Reopens on the step the user left it at (e.g. the OTP step).
  final int initialStep;
  final String initialEmail;

  /// Keeps the caller in sync so the sheet can resume where it stopped.
  final void Function(int step, String email)? onProgress;

  const ForgotPasswordScreen({
    super.key,
    required this.authRepository,
    required this.onSuccess,
    this.initialStep = 0,
    this.initialEmail = '',
    this.onProgress,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with WidgetsBindingObserver {
  int _step = 0; // 0: Email, 1: OTP, 2: New Password
  String? _resetToken;
  final FocusNode _emailFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _primaryButtonKey = GlobalKey();
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _keyboardWasVisible = false;
  bool _keyboardExpected = false;
  bool _actualKeyboardSeen = false;
  bool _keyboardClosing = false;
  Timer? _keyboardRevealTimer;

  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const int _codeLength = 6;
  late final List<TextEditingController> _codeControllers;
  late final List<FocusNode> _codeFocusNodes;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  int _resendSeconds = 90;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_onFocusChanged);
    _codeControllers = List.generate(
      _codeLength,
      (_) => TextEditingController(),
    );
    _codeFocusNodes = List.generate(_codeLength, (_) => FocusNode());

    _step = widget.initialStep.clamp(0, 2);
    if (widget.initialEmail.isNotEmpty) {
      _emailController.text = widget.initialEmail;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_step == 1) {
        _codeFocusNodes.first.requestFocus();
      }
      _notifyProgress();
    });
    if (_step == 1) _startCountdown();
  }

  @override
  void didChangeMetrics() => _scheduleKeyboardReveal();

  void _onFocusChanged() => _scheduleKeyboardReveal();

  void _onInputTap() {
    _keyboardClosing = false;
    if (!_keyboardExpected) setState(() => _keyboardExpected = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _revealPrimaryButton(force: true);
    });
  }

  void _scheduleKeyboardReveal() {
    _keyboardRevealTimer?.cancel();
    _keyboardRevealTimer = Timer(
      const Duration(milliseconds: 60),
      _revealPrimaryButton,
    );
  }

  void _revealPrimaryButton({bool force = false}) {
    if (!mounted || !_scrollController.hasClients) return;
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
      return;
    }

    final buttonBox = _primaryButtonKey.currentContext?.findRenderObject();
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

    final position = _scrollController.position;
    final target = math.min(
      position.maxScrollExtent,
      position.pixels + neededScroll,
    );
    if (target - position.pixels <= 1) return;
    if (!force && position.isScrollingNotifier.value) return;
    _scrollController
        .animateTo(
          target,
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeInOutCubic,
        )
        .then((_) {
          if (mounted && _scrollController.hasClients) {
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
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _notifyProgress() {
    widget.onProgress?.call(_step, _emailController.text.trim());
  }

  void _handleBack() {
    _dismissKeyboard();
    if (_step > 0) {
      setState(() => _step--);
      _notifyProgress();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(_onFocusChanged);
    _keyboardRevealTimer?.cancel();
    _scrollController.dispose();
    _resendTimer?.cancel();
    _emailFocusNode.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final n in _codeFocusNodes) {
      n.dispose();
    }
    super.dispose();
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

  Future<void> _sendForgotCode() async {
    final email = _emailController.text.trim();
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;
    if (email.isEmpty) {
      MessageService.showError(
        context: context,
        message: context.l10n.validEmailRequired,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.authRepository.forgotPassword(email: email);
      if (!mounted) return;
      for (final c in _codeControllers) {
        c.clear();
      }
      setState(() => _step = 1);
      _notifyProgress();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyResetCode() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length != _codeLength) {
      MessageService.showError(
        context: context,
        message: context.l10n.digitCodeRequired,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await widget.authRepository.verifyResetCode(
        email: _emailController.text.trim(),
        code: code,
      );
      if (!mounted) return;
      final payload = response['data'];
      if (payload is Map<String, dynamic>) {
        _resetToken = payload['resetToken'] as String?;
      } else {
        _resetToken = response['resetToken'] as String?;
      }
      _resendTimer?.cancel();
      setState(() => _step = 2);
      _notifyProgress();
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.length < 8) {
      MessageService.showError(
        context: context,
        message: context.l10n.passwordMinLength,
      );
      return;
    }
    if (newPass != confirmPass) {
      MessageService.showError(
        context: context,
        message: context.l10n.passcodesDoNotMatch,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.authRepository.resetPassword(
        email: _emailController.text.trim(),
        newPassword: newPass,
        confirmPassword: confirmPass,
        resetToken: _resetToken,
      );
      if (!mounted) return;
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildRecoveryCards(bool isDark) {
    return SizedBox(
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
                      Icons.refresh_rounded,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final ink = isDark ? const Color(0xFFF4F4F5) : const Color(0xFF18181B);
    final muted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final line = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: AppGlassBackButton(onPressed: _handleBack),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: line),
        const SizedBox(height: 34),
        Text(
          isArabic ? 'استعادة الحساب' : 'ACCOUNT RECOVERY',
          style: TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: isArabic ? 0 : 2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 86,
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                Expanded(
                  child: Text(
                    isArabic
                        ? 'خلّينا نرجعك\nلحسابك.'
                        : 'Let’s get you\nback in.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: ink,
                      fontSize: constraints.maxWidth < 300 ? 29 : 34,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildRecoveryCards(isDark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isArabic
              ? 'هنساعدك تغيّر كلمة المرور في خطوات بسيطة.'
              : 'We’ll help you reset your password in a few steps.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: muted,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 26),
        Divider(color: line),
        const SizedBox(height: 24),
        Text(
          _step == 0
              ? (isArabic
                    ? context.l10n.resetPasswordTitle
                    : 'Reset your password')
              : _step == 1
              ? context.l10n.enterVerificationCode
              : context.l10n.enterNewPassword,
          style: theme.textTheme.titleMedium?.copyWith(
            color: ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _step == 0
              ? (isArabic
                    ? 'أولاً، أكّد البريد المرتبط بحسابك.'
                    : 'First, confirm the email linked to your account.')
              : _step == 1
              ? context.l10n.verificationCodeSent(_emailController.text.trim())
              : context.l10n.setNewPasswordDescription,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        const SizedBox(height: 24),

        // Steps Progress Bar
        Row(
          children: List.generate(3, (index) {
            final done = index < _step;
            final active = index == _step;
            return Expanded(
              child: Container(
                margin: EdgeInsetsDirectional.only(end: index < 2 ? 6 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: (done || active) ? ink : line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (index) {
            final labels = isArabic
                ? ['البريد', 'التحقق', 'كلمة المرور']
                : ['01  EMAIL', '02  VERIFY', '03  NEW PASSWORD'];
            return Expanded(
              child: Text(
                labels[index],
                textAlign: index == 0
                    ? TextAlign.start
                    : index == 1
                    ? TextAlign.center
                    : TextAlign.end,
                style: TextStyle(
                  color: index == _step ? ink : muted.withValues(alpha: .65),
                  fontSize: 9,
                  fontWeight: index == _step
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 20),

        // Step 0: Enter Email
        if (_step == 0) ...[
          Text(
            isArabic ? 'البريد الإلكتروني' : 'EMAIL ADDRESS',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 10),
          Form(
            key: _emailFormKey,
            child: TextFormField(
              controller: _emailController,
              onTap: _onInputTap,
              onTapOutside: (_) => _dismissKeyboard(),
              focusNode: _emailFocusNode,
              autofocus: false,
              keyboardType: TextInputType.emailAddress,
              keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
              textInputAction: TextInputAction.done,
              textDirection: TextDirection.ltr,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              decoration: InputDecoration(
                hintText: context.l10n.email,
                prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                filled: true,
                fillColor: isDark ? const Color(0xFF141418) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF3F3F46)
                        : const Color(0xFFD4D4D8),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return null;
                return EmailValidator.isValid(email)
                    ? null
                    : context.l10n.validEmailRequired;
              },
              onFieldSubmitted: (_) => _sendForgotCode(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            key: _primaryButtonKey,
            onPressed: _isLoading ? null : _sendForgotCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const AppProgressIndicator.small(color: Colors.white)
                : Text(
                    isArabic
                        ? context.l10n.sendVerificationCode
                        : 'Send reset code',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
          const SizedBox(height: 28),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isArabic
                    ? 'افتكرت كلمة المرور؟ ارجع لتسجيل الدخول'
                    : 'Remembered it? Back to sign in',
                style: TextStyle(
                  color: ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ]
        // Step 1: Verify Code
        else if (_step == 1) ...[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () {
                setState(() => _step = 0);
                _notifyProgress();
              },
              child: Text(
                context.l10n.changeEmail,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OtpInputField(
            controllers: _codeControllers,
            focusNodes: _codeFocusNodes,
            onCompleted: (_) => _verifyResetCode(),
          ),
          const SizedBox(height: 16),
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
                  onPressed: _isLoading ? null : _sendForgotCode,
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
            key: _primaryButtonKey,
            onPressed: _isLoading ? null : _verifyResetCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const AppProgressIndicator.small(color: Colors.white)
                : Text(
                    context.l10n.verify,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ]
        // Step 2: New Password
        else ...[
          const SizedBox(height: 16),
          TextField(
            controller: _newPasswordController,
            onTap: _onInputTap,
            onTapOutside: (_) => _dismissKeyboard(),
            obscureText: _obscureNewPassword,
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
            decoration: InputDecoration(
              hintText: context.l10n.newPasscode,
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureNewPassword = !_obscureNewPassword),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF141418) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _confirmPasswordController,
            onTap: _onInputTap,
            onTapOutside: (_) => _dismissKeyboard(),
            obscureText: _obscureConfirmPassword,
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
            decoration: InputDecoration(
              hintText: context.l10n.confirmPassword,
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF141418) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => _resetPassword(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            key: _primaryButtonKey,
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const AppProgressIndicator.small(color: Colors.white)
                : Text(
                    context.l10n.resetPasscode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ],
    );

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF09090B)
          : const Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: !Platform.isIOS,
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.paddingOf(context).top + 8,
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
