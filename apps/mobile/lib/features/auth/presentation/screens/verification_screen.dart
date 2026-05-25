import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:my_wallet/features/onboarding/presentation/screens/onboarding_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final bool isLogin;
  final String? deviceName; 
  final String? ipAddress;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.isLogin,
    this.deviceName,
    this.ipAddress,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> with TickerProviderStateMixin {
  late final TextEditingController _hiddenController;
  late final FocusNode _hiddenFocusNode;

  final AuthRepository _authRepository = AuthRepository();

  int _countdown = 60;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;

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

  String _code = '';

  @override
  void initState() {
    super.initState();
    _hiddenController = TextEditingController();
    _hiddenFocusNode = FocusNode();
    _startTimer();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hiddenFocusNode.requestFocus();
    });
  }

  void _initAnimations() {
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

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reset();
        }
      });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _countdown = 60;
    });
    _startTimer();
  }

  void _onBackPressed() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen(onLocaleChanged: (locale) {})),
      (route) => false,
    );
  }

  void _onHiddenTextChanged(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits != value) {
      _hiddenController.text = digits;
      _hiddenController.selection = TextSelection.fromPosition(TextPosition(offset: digits.length));
    }

    setState(() {
      _code = digits;
    });

    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    if (digits.length == 6) {
      _verifyCode();
    }
  }

  Future<void> _verifyCode() async {
    if (_isLoading) return;

    _hiddenFocusNode.unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authRepository.verifyCode(
        email: widget.email,
        verificationCode: _code,
      );

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/passcode',
            arguments: {
              'email': widget.email,
              'verificationCode': _code,
              'isLogin': widget.isLogin,
            },
          );
        }
      } else {
        setState(() {
          _errorMessage = context.l10n.invalidVerificationCode;
        });
        _showErrorShake();
        _clearCode();
      }
    } catch (e) {
      setState(() {
        _errorMessage = context.l10n.verifyCodeFailed;
      });
      _showErrorShake();
      _clearCode();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearCode() {
    setState(() {
      _code = '';
    });
    _hiddenController.clear();
    _hiddenFocusNode.requestFocus();
  }

  void _showErrorShake() {
    _shakeController.forward(from: 0.0);
  }

 Future<void> _resendCode() async {
    if (_countdown > 0) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.resendCode(
        email: widget.email,
        isLogin: widget.isLogin,
        deviceName: widget.deviceName,
        ipAddress: widget.ipAddress,
      );
      _resetTimer();
      _clearCode();
      if (!mounted) return;
      MessageService.showSuccess(context: context, message: context.l10n.verificationCodeResentTo(widget.email));
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(context: context, message: context.l10n.failedToResend);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _hiddenController.dispose();
    _hiddenFocusNode.dispose();
    _timer?.cancel();
    _fadeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final screenWidth = MediaQuery.of(context).size.width;
    const spacing = 12.0;
    const totalSpacing = (6 - 1) * spacing;
    double fieldWidth = (screenWidth - (28 * 2) - totalSpacing) / 6;
    fieldWidth = fieldWidth.clamp(40.0, 56.0);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios, size: 20),
          onPressed: _onBackPressed,
        ),
        title: null,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.email_outlined, size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.email,
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
                            widget.isLogin ? context.l10n.enterVerificationCode : context.l10n.verifyYourEmail,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            widget.isLogin
                                ? context.l10n.enterCodeSentToEmailForLogin
                                : context.l10n.enterVerificationCodeSentToEmail,
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
                              keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: _onHiddenTextChanged,
                              textInputAction: TextInputAction.done,
                              enableInteractiveSelection: true,
                              autofillHints: const [AutofillHints.oneTimeCode],
                            ),
                          ),
                        ),

                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_shakeAnimation.value, 0),
                              child: child,
                            );
                          },
                          child: AutofillGroup(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: TextDirection.ltr,
                              children: List.generate(6, (index) => _buildDisplayBox(index, fieldWidth, theme)),
                            ),
                          ),
                        ),

                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Timer and resend
                SlideTransition(
                  position: _socialSlide,
                  child: FadeTransition(
                    opacity: _socialFade,
                    child: Column(
                      children: [
                        Center(
                          child: Column(
                            children: [
                              if (_countdown > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[900] : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.timer, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                      const SizedBox(width: 8),
                                      Text(
                                       context.l10n.resendIn(_formatCountdown(_countdown)),
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (_countdown == 0)
                                TextButton(
                                  onPressed: _isLoading ? null : _resendCode,
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!_isLoading) Icon(Icons.refresh, size: 18),
                                      if (!_isLoading) const SizedBox(width: 8),
                                      Text(
                                        _isLoading ? context.l10n.resending : context.l10n.resendCode,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (_isLoading)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 12),
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
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

  Widget _buildDisplayBox(int index, double width, ThemeData theme) {
    final String digit = _code.length > index ? _code[index] : '';
    final bool isFilled = digit.isNotEmpty;
    final bool hasError = _errorMessage != null;

    return GestureDetector(
      onTap: () {
        _hiddenFocusNode.requestFocus();
      },
      child: Container(
        width: width,
        height: 80,
        margin: EdgeInsets.only(left: index > 0 ? 12 : 0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError
                ? theme.colorScheme.error
                : (isFilled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3)),
            width: hasError ? 2 : (isFilled ? 2 : 1.5),
          ),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isFilled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}
