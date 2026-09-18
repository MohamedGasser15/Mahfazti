import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/constants/app_routes.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:my_wallet/features/auth/presentation/screens/forgot_passcode_otp_screen.dart';
import 'package:my_wallet/features/onboarding/presentation/screens/onboarding_screen.dart';

class PasscodeScreen extends StatefulWidget {
  final String email;
  final String verificationCode;
  final bool isLogin;
  final String? deviceName;
  final String? ipAddress;

  const PasscodeScreen({
    super.key,
    required this.email,
    required this.verificationCode,
    required this.isLogin,
    this.deviceName,
    this.ipAddress,
  });
  
  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> with TickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  final List<String> _passcode = [];
  final int _passcodeLength = 6;
  
  bool _isLoading = false;
  bool _showError = false;
  String? _errorMessage;
  Timer? _resetTimer;
  
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
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    _resetTimer?.cancel();
    super.dispose();
  }
  
  void _onBackPressed() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen(onLocaleChanged: (locale) {})),
      (route) => false,
    );
  }
  
  void _addDigit(String digit) {
    if (_passcode.length < _passcodeLength && !_isLoading && !_showError) {
      setState(() {
        _passcode.add(digit);
        _errorMessage = null;
      });
      
      HapticFeedback.lightImpact();
      
      if (_passcode.length == _passcodeLength) {
        _completeProcess();
      }
    }
  }
  
  void _removeDigit() {
    if (_passcode.isNotEmpty && !_isLoading && !_showError) {
      setState(() {
        _passcode.removeLast();
        _errorMessage = null;
      });
      HapticFeedback.selectionClick();
    }
  }
  
  void _clearPasscode() {
    if (!_isLoading && !_showError) {
      setState(() {
        _passcode.clear();
        _errorMessage = null;
      });
    }
  }
  
  Future<void> _completeProcess() async {
    setState(() {
      _isLoading = true;
      _showError = false;
      _errorMessage = null;
    });
    
    String passcode = _passcode.join();
    
    try {
      if (widget.isLogin) {
        final result = await _authRepository.completeLogin(
          email: widget.email,
          verificationCode: widget.verificationCode,
          password: passcode,
        );
        
        if (result['success'] == true) {
          await SharedPrefs.setString('user_password', passcode);
          _navigateToHome();
        } else {
         if (!mounted) return;
          _showErrorState(context.l10n.invalidPasscode);
        }
      } else {
        await SharedPrefs.setString(AppConstants.userPasswordKey, passcode);
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          AppRoutes.register,
          arguments: {
            'email': widget.email,
            'verificationCode': widget.verificationCode,
            'passcode': passcode,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorState(context.l10n.somethingWentWrong);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showErrorState(String message) {
    setState(() {
      _showError = true;
      _errorMessage = message;
    });
    
    _shakeController.forward(from: 0.0);
    
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _passcode.clear();
          _showError = false;
          _errorMessage = null;
        });
      }
    });
  }
  
  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }
  
void _onForgotPasscode() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _buildForgotPasscodeSheet(),
  );
}

Widget _buildForgotPasscodeSheet() {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  return Container(
    decoration: BoxDecoration(
      color: isDark ? Colors.black : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    ),
    padding: EdgeInsets.fromLTRB(
      24, 16, 24,
      24 + MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_reset_rounded, size: 36, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.resetPasscode,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.resetPasscodeDescription,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ForgotPasscodeOtpScreen(
                    email: widget.email,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
            ),
            child: Text(
              context.l10n.reset,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildKeyboard() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    child: Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          textDirection: TextDirection.ltr, 
          children: [
            widget.isLogin
                ? _buildTextButton(context.l10n.forgot, onTap: _onForgotPasscode)
                : const SizedBox(width: 80),
            _buildNumberButton('0'),
            _buildDeleteButton(),
          ],
        ),
      ],
    ),
  );
}
  
  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      textDirection: TextDirection.ltr,
      children: digits.map((digit) => _buildNumberButton(digit)).toList(),
    );
  }
  
  Widget _buildNumberButton(String digit) {
    return _KeyboardButton(
      onTap: () => _addDigit(digit),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDeleteButton() {
    return _KeyboardButton(
      onTap: _removeDigit,
      onLongPress: _clearPasscode,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: _passcode.isNotEmpty && !_isLoading
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextButton(String text, {required VoidCallback onTap}) {
    return _KeyboardButton(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
Widget _buildPasscodeIndicators() {
  return AnimatedBuilder(
    animation: _shakeAnimation,
    builder: (context, child) {
      return Transform.translate(
        offset: Offset(_showError ? _shakeAnimation.value : 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.ltr,
          children: List.generate(_passcodeLength, (index) {
            final isFilled = index < _passcode.length;
            final isError = _showError && isFilled;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isError
                    ? Colors.red
                    : isFilled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                border: !isFilled
                    ? Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        width: 1.5,
                      )
                    : null,
                boxShadow: isFilled && !isError
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            );
          }),
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
        child: ResponsiveWrapper(
          child: Column(
            children: [
              Expanded(
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
                      
                      // Title & Subtitle
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleFade,
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  widget.isLogin ? context.l10n.enterYourPasscode : context.l10n.setPasscodeTitle,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  widget.isLogin
                                      ? ''
                                      : context.l10n.setPasscodeDescription,
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
                      
                      const SizedBox(height: 48),
                      
                      // Passcode indicators
                      SlideTransition(
                        position: _formSlide,
                        child: FadeTransition(
                          opacity: _formFade,
                          child: Column(
                            children: [
                              _buildPasscodeIndicators(),
                              
                              const SizedBox(height: 24),
                              
                              if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
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
              
              // Custom Keyboard
              SlideTransition(
                position: _keyboardSlide,
                child: FadeTransition(
                  opacity: _keyboardFade,
                  child: _buildKeyboard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyboardButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  
  const _KeyboardButton({
    required this.onTap,
    this.onLongPress,
    required this.child,
  });
  
  @override
  State<_KeyboardButton> createState() => __KeyboardButtonState();
}

class __KeyboardButtonState extends State<_KeyboardButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _isPressed ? 0.9 : 1.0,
        child: widget.child,
      ),
    );
  }
}
