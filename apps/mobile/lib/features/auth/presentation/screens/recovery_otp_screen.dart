import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';

class RecoveryOtpScreen extends StatefulWidget {
  final String emailOrUsername;
  final String newEmail;
  const RecoveryOtpScreen({
    super.key,
    required this.emailOrUsername,
    required this.newEmail,
  });

  @override
  State<RecoveryOtpScreen> createState() => _RecoveryOtpScreenState();
}

class _RecoveryOtpScreenState extends State<RecoveryOtpScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _hiddenController;
  late final FocusNode _hiddenFocusNode;
  final _authRepository = AuthRepository();

  String _code = '';
  bool _isLoading = false;
  String? _errorMessage;
  int _countdown = 60;
  Timer? _timer;

  late AnimationController _fadeController;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _socialFade;
  late Animation<Offset> _socialSlide;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _hiddenController = TextEditingController();
    _hiddenFocusNode = FocusNode();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );

    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );

    _socialFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _socialSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    _fadeController.forward();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _shakeController.reset();
      });

    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hiddenFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _hiddenController.dispose();
    _hiddenFocusNode.dispose();
    _fadeController.dispose();
    _shakeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  void _onTextChanged(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits != value) {
      _hiddenController.text = digits;
      _hiddenController.selection =
          TextSelection.fromPosition(TextPosition(offset: digits.length));
    }
    setState(() { _code = digits; _errorMessage = null; });
    if (digits.length == 6) _verify();
  }

  Future<void> _verify() async {
    _hiddenFocusNode.unfocus();
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final result = await _authRepository.recoveryConfirmEmailChange(
        emailOrUsername: widget.emailOrUsername,
        newEmail: widget.newEmail,
        otpCode: _code,
      );

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context, '/home', (route) => false,
          );
        }
      } else {
        setState(() => _errorMessage = result['message'] ?? context.l10n.invalidCode);
        _shakeController.forward(from: 0.0);
        _clearCode();
      }
    } catch (e) {
      setState(() => _errorMessage = context.l10n.somethingWentWrong);
      _shakeController.forward(from: 0.0);
      _clearCode();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearCode() {
    setState(() => _code = '');
    _hiddenController.clear();
    _hiddenFocusNode.requestFocus();
  }

  Future<void> _resend() async {
    if (_countdown > 0) return;
    setState(() => _isLoading = true);
    try {
      final result = await _authRepository.recoveryRequestEmailChange(
        emailOrUsername: widget.emailOrUsername,
        newEmail: widget.newEmail,
      );
      if (result['success'] == true) {
        _startTimer();
        _clearCode();
        if (mounted) {
          MessageService.showSuccess(context: context, message: context.l10n.codeResentTo(widget.newEmail));
        }
      } else if (mounted) {
        MessageService.showError(context: context, message: result['message'] ?? context.l10n.failedToResend);
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(context: context, message: context.l10n.somethingWentWrong);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCountdown(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = ((screenWidth - (28 * 2) - 60) / 6).clamp(40.0, 56.0);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
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
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
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

                const SizedBox(height: 20),

                // Email chip
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.email_outlined,
                                size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.newEmail,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Title & Subtitle
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            context.l10n.verifyNewEmail,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            context.l10n.verifyNewEmailDescription,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // OTP Form
                SlideTransition(
                  position: _formSlide,
                  child: FadeTransition(
                    opacity: _formFade,
                    child: Column(
                      children: [
                        Opacity(
                          opacity: 0,
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _hiddenController,
                              focusNode: _hiddenFocusNode,
                              keyboardType: const TextInputType.numberWithOptions(),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: _onTextChanged,
                              autofillHints: const [AutofillHints.oneTimeCode],
                            ),
                          ),
                        ),

                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            textDirection: TextDirection.ltr,
                            children: List.generate(6, (index) {
                              final digit =
                                  _code.length > index ? _code[index] : '';
                              final filled = digit.isNotEmpty;
                              final hasError = _errorMessage != null;

                              return GestureDetector(
                                onTap: () => _hiddenFocusNode.requestFocus(),
                                child: Container(
                                  width: fieldWidth,
                                  height: 80,
                                  margin: EdgeInsets.only(left: index > 0 ? 12 : 0),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: hasError
                                          ? theme.colorScheme.error
                                          : filled
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.outline
                                                  .withValues(alpha: 0.3),
                                      width: hasError || filled ? 2 : 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      digit,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: filled
                                            ? theme.colorScheme.onSurface
                                            : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.error.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: theme.colorScheme.error, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: theme.colorScheme.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Resend / Timer
                SlideTransition(
                  position: _socialSlide,
                  child: FadeTransition(
                    opacity: _socialFade,
                    child: Column(
                      children: [
                        Center(
                          child: _countdown > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[900] : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          theme.colorScheme.outline.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.timer,
                                          size: 18,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6)),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.l10n.resendIn(_formatCountdown(_countdown)),
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : TextButton(
                                  onPressed: _isLoading ? null : _resend,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.refresh, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                       context.l10n.resendCode,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: theme.colorScheme.primary,
                                        ),
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
      ),
    );
  }
}
