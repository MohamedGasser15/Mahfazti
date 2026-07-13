import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';

class SetPasscodeScreen extends StatefulWidget {
  const SetPasscodeScreen({super.key});

  @override
  State<SetPasscodeScreen> createState() => _SetPasscodeScreenState();
}

class _SetPasscodeScreenState extends State<SetPasscodeScreen>
    with TickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  final List<String> _passcode = [];
  final int _passcodeLength = 6;

  bool _isLoading = false;
  bool _showError = false;
  String? _errorMessage;
  Timer? _resetTimer;

  late AnimationController _fadeController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _keyboardFade;
  late Animation<Offset> _keyboardSlide;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _resetTimer?.cancel();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (_passcode.length < _passcodeLength && !_isLoading) {
      setState(() {
        _passcode.add(digit);
        _errorMessage = null;
      });
      HapticFeedback.lightImpact();
      if (_passcode.length == _passcodeLength) {
        _createPasscode();
      }
    }
  }

  void _removeDigit() {
    if (_passcode.isNotEmpty && !_isLoading) {
      setState(() => _passcode.removeLast());
      HapticFeedback.selectionClick();
    }
  }

  void _clearPasscode() {
    if (!_isLoading) {
      setState(() => _passcode.clear());
    }
  }

  Future<void> _createPasscode() async {
    setState(() {
      _isLoading = true;
      _showError = false;
      _errorMessage = null;
    });

    String passcode = _passcode.join();

    try {
      final result = await _authRepository.createPasscode(passcode);
      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        _showErrorState(result['message'] ?? context.l10n.somethingWentWrong);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorState(context.l10n.somethingWentWrong);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorState(String message) {
    setState(() {
      _showError = true;
      _errorMessage = message;
    });
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

  void _signOut() async {
    await SharedPrefs.removeAuthToken();
    await SharedPrefs.removeUserData();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

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
          onPressed: _signOut,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                context.l10n.setPasscodeTitle,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                context.l10n.setPasscodeDescription,
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
                    SlideTransition(
                      position: _formSlide,
                      child: FadeTransition(
                        opacity: _formFade,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: TextDirection.ltr,
                              children: List.generate(_passcodeLength, (index) {
                                final isFilled = index < _passcode.length;
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _showError
                                        ? Colors.red
                                        : isFilled
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                    border: !isFilled
                                        ? Border.all(
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                );
                              }),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ],
                            if (_isLoading) ...[
                              const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SlideTransition(
              position: _keyboardSlide,
              child: FadeTransition(
                opacity: _keyboardFade,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildRow(['1', '2', '3']),
                      const SizedBox(height: 12),
                      _buildRow(['4', '5', '6']),
                      const SizedBox(height: 12),
                      _buildRow(['7', '8', '9']),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        textDirection: TextDirection.ltr,
                        children: [
                          const SizedBox(width: 80),
                          _buildNumberButton('0'),
                          _buildDeleteButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      textDirection: TextDirection.ltr,
      children: digits.map((d) => _buildNumberButton(d)).toList(),
    );
  }

  Widget _buildNumberButton(String digit) {
    return GestureDetector(
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
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _removeDigit,
      onLongPress: _clearPasscode,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(shape: BoxShape.circle),
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
}
