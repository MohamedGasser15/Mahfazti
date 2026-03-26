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

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _hiddenController = TextEditingController();
    _hiddenFocusNode = FocusNode();

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
        MessageService.showSuccess(context.l10n.codeResentTo(widget.newEmail));
      } else {
        MessageService.showError(result['message'] ?? context.l10n.failedToResend);
      }
    } catch (e) {
      MessageService.showError(context.l10n.somethingWentWrong);
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = ((screenWidth - 40 - 60) / 6).clamp(40.0, 56.0);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
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

                const SizedBox(height: 24),

                Text(
                  context.l10n.verifyNewEmail,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  context.l10n.verifyNewEmailDescription,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 32),

                // Hidden input
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

                // OTP boxes
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final digit =
                          _code.length > index ? _code[index] : '';
                      final filled = digit.isNotEmpty;
                      final hasError = _errorMessage != null;

                      return GestureDetector(
                        onTap: () => _hiddenFocusNode.requestFocus(),
                        child: Container(
                          width: fieldWidth,
                          height: 72,
                          margin: EdgeInsets.only(left: index > 0 ? 10 : 0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: hasError
                                  ? theme.colorScheme.error
                                  : filled
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline
                                          .withOpacity(0.3),
                              width: hasError || filled ? 2 : 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              digit,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: filled
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Error
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.error.withOpacity(0.5),
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

                const Spacer(),

                // Resend / Timer
                Center(
                  child: _countdown > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color:
                                  theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer,
                                  size: 18,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6)),
                              const SizedBox(width: 8),
                              Text(
                                context.l10n.resendIn(_formatCountdown(_countdown)),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}