import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/constants/app_routes.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';

enum _ResetStep { enterNew, confirm }

class ResetPasscodeScreen extends StatefulWidget {
  final String otpCode;
  final String email;
  const ResetPasscodeScreen({
    super.key,
    required this.otpCode,
    required this.email,
  });

  @override
  State<ResetPasscodeScreen> createState() => _ResetPasscodeScreenState();
}

class _ResetPasscodeScreenState extends State<ResetPasscodeScreen>
    with TickerProviderStateMixin {
  final _authRepository = AuthRepository();
  final int _passcodeLength = 6;

  _ResetStep _step = _ResetStep.enterNew;
  List<String> _passcode = [];
  String _firstPasscode = '';

  bool _isLoading = false;
  bool _showError = false;

  late AnimationController _fadeController;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _keyboardFade;
  late Animation<Offset> _keyboardSlide;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

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

    _keyboardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _keyboardSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    _fadeController.forward();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
        parent: _shakeController, curve: Curves.easeInOut));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _slideController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (_passcode.length < _passcodeLength && !_isLoading && !_showError) {
      setState(() => _passcode.add(digit));
      HapticFeedback.lightImpact();
      if (_passcode.length == _passcodeLength) _onComplete();
    }
  }

  void _removeDigit() {
    if (_passcode.isNotEmpty && !_isLoading && !_showError) {
      setState(() => _passcode.removeLast());
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _onComplete() async {
    final entered = _passcode.join();

    if (_step == _ResetStep.enterNew) {
      _firstPasscode = entered;
      setState(() {
        _passcode = [];
        _step = _ResetStep.confirm;
      });
      _slideController.forward(from: 0.0);
      return;
    }

    if (entered != _firstPasscode) {
      _triggerError();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authRepository.resetPasscode(
        email: widget.email,
        otpCode: widget.otpCode,
        newPasscode: entered,
      );

      if (result['success'] == true) {
        await SharedPrefs.setSecureString('user_password', entered);

        if (mounted) {
          _showSuccessAndPop();
        }
      } else {
        if (mounted) {
         MessageService.showError(context: context, message: result['message'] ?? context.l10n.failedToResetPasscode);
          setState(() {
            _passcode = [];
            _firstPasscode = '';
            _step = _ResetStep.enterNew;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(context: context, message: context.l10n.somethingWentWrong);
        setState(() {
          _passcode = [];
          _firstPasscode = '';
          _step = _ResetStep.enterNew;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _triggerError() {
    setState(() => _showError = true);
    _shakeController.forward(from: 0.0);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _passcode = [];
          _showError = false;
        });
      }
    });
  }

void _showSuccessAndPop() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.passcodeUpdated,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.passcodeChangedSuccessfully,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);

                await SharedPrefs.removeAuthToken();

                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.email,
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(context.l10n.done),
            ),
          ),
        ],
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final isConfirm = _step == _ResetStep.confirm;

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
            if (isConfirm) {
              setState(() {
                _passcode = [];
                _firstPasscode = '';
                _step = _ResetStep.enterNew;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Column(
            children: [
              Expanded(
                child: SlideTransition(
                  position: isConfirm ? _slideAnimation : const AlwaysStoppedAnimation(Offset.zero),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
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

                        const SizedBox(height: 32),

                        // Title
                        SlideTransition(
                          position: _titleSlide,
                          child: FadeTransition(
                            opacity: _titleFade,
                            child: Column(
                              children: [
                                Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      key: ValueKey(_step),
                                      isConfirm ? context.l10n.confirmNewPasscode : context.l10n.enterNewPasscode,
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      key: ValueKey(_step),
                                    isConfirm 
                                      ? context.l10n.confirmNewPasscodeDescription
                                      : context.l10n.chooseNewPasscodeDescription,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Passcode dots
                        SlideTransition(
                          position: _formSlide,
                          child: FadeTransition(
                            opacity: _formFade,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildStepDot(active: _step == _ResetStep.enterNew, done: isConfirm, theme: theme),
                                    const SizedBox(width: 8),
                                    _buildStepDot(active: isConfirm, done: false, theme: theme),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                AnimatedBuilder(
                                  animation: _shakeAnimation,
                                  builder: (context, child) => Transform.translate(
                                    offset:
                                        Offset(_showError ? _shakeAnimation.value : 0, 0),
                                    child: child,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    textDirection: TextDirection.ltr,
                                    children: List.generate(_passcodeLength, (index) {
                                      final filled = index < _passcode.length;
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin:
                                            const EdgeInsets.symmetric(horizontal: 8),
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _showError
                                              ? Colors.red
                                              : filled
                                                  ? (isConfirm
                                                      ? Colors.green
                                                      : theme.colorScheme.primary)
                                                  : theme.colorScheme.onSurface
                                                      .withValues(alpha: 0.15),
                                          border: !filled
                                              ? Border.all(
                                                  color: theme.colorScheme.onSurface
                                                      .withValues(alpha: 0.3),
                                                  width: 1.5,
                                                )
                                              : null,
                                          boxShadow: filled && !_showError
                                              ? [
                                                  BoxShadow(
                                                    color: (isConfirm
                                                            ? Colors.green
                                                            : theme.colorScheme.primary)
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  )
                                                ]
                                              : null,
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                AnimatedOpacity(
                                  opacity: _showError ? 1 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      context.l10n.passcodesDoNotMatch,
                                      style: const TextStyle(color: Colors.red, fontSize: 14),
                                    ),
                                  ),
                                ),

                                if (_isLoading)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: CircularProgressIndicator(),
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

              // Keyboard
              SlideTransition(
                position: _keyboardSlide,
                child: FadeTransition(
                  opacity: _keyboardFade,
                  child: _buildKeyboard(theme),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepDot({
    required bool active,
    required bool done,
    required ThemeData theme,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: done
            ? Colors.green
            : active
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

Widget _buildKeyboard(ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Column(
      children: [
        _buildRow(['1', '2', '3'], theme),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6'], theme),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9'], theme),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          textDirection: TextDirection.ltr,
          children: [
            const SizedBox(width: 70),
            _buildKey('0', theme),
            _buildDeleteKey(theme),
          ],
        ),
      ],
    ),
  );
}

Widget _buildRow(List<String> digits, ThemeData theme) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    textDirection: TextDirection.ltr,
    children: digits.map((d) => _buildKey(d, theme)).toList(),
  );
}

  Widget _buildKey(String digit, ThemeData theme) {
    return GestureDetector(
      onTap: () => _addDigit(digit),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(ThemeData theme) {
    return GestureDetector(
      onTap: _removeDigit,
      onLongPress: () => setState(() => _passcode.clear()),
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: _passcode.isNotEmpty
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
