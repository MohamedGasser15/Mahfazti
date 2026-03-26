import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';

class RecoveryPasswordScreen extends StatefulWidget {
  final String emailOrUsername;
  const RecoveryPasswordScreen({super.key, required this.emailOrUsername});

  @override
  State<RecoveryPasswordScreen> createState() => _RecoveryPasswordScreenState();
}

class _RecoveryPasswordScreenState extends State<RecoveryPasswordScreen>
    with TickerProviderStateMixin {
  final _authRepository = AuthRepository();
  final List<String> _passcode = [];
  final int _passcodeLength = 6;
  bool _isLoading = false;
  bool _showError = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
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
    _shakeController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (_passcode.length < _passcodeLength && !_isLoading && !_showError) {
      setState(() => _passcode.add(digit));
      HapticFeedback.lightImpact();
      if (_passcode.length == _passcodeLength) _verify();
    }
  }

  void _removeDigit() {
    if (_passcode.isNotEmpty && !_isLoading && !_showError) {
      setState(() => _passcode.removeLast());
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _verify() async {
    setState(() { _isLoading = true; _showError = false; });

    try {
      final result = await _authRepository.recoveryVerifyPassword(
        emailOrUsername: widget.emailOrUsername,
        password: _passcode.join(),
      );

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/recovery-new-email',
            arguments: {
              'emailOrUsername': widget.emailOrUsername,
              'password': _passcode.join(),
            },
          );
        }
      } else {
        _triggerError();
      }
    } catch (e) {
      _triggerError();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _triggerError() {
    setState(() => _showError = true);
    _shakeController.forward(from: 0.0);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() { _passcode.clear(); _showError = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_outline,
                        size: 36, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enter your passcode',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verify it\'s you before changing your email',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Dots
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(_showError ? _shakeAnimation.value : 0, 0),
                      child: child,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_passcodeLength, (index) {
                        final filled = index < _passcode.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _showError
                                ? Colors.red
                                : filled
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withOpacity(0.2),
                            border: !filled
                                ? Border.all(
                                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                                    width: 1.5,
                                  )
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
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Incorrect passcode',
                        style: TextStyle(color: Colors.red, fontSize: 14),
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

            // Keyboard
            _buildKeyboard(theme),
            const SizedBox(height: 12),
          ],
        ),
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
              color: Colors.black.withOpacity(0.05),
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
                : theme.colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}