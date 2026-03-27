import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/biometric_service.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/auth/presentation/screens/ForgotPasscodeOtpScreen.dart';
import 'package:my_wallet/features/auth/presentation/widgets/biometric_bottom_sheet.dart';
import 'package:my_wallet/features/wallet/presentation/screens/HomeScreen.dart';

class PinScreen extends StatefulWidget {
  final bool isFirstTime;
  final bool showBiometricFirst;

  const PinScreen({
    super.key,
    this.isFirstTime = false,
    this.showBiometricFirst = true,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  final List<int> _pinDigits = [];
  bool _isLoading = false;
  bool _showError = false;
  String? _errorMessage;
  Timer? _errorTimer;

  // Biometric data
  bool _biometricEnabled = false;
  bool _hasBiometricSupport = false;
  String _biometricName = 'Biometric';
  bool _biometricFailed = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadBiometricData();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadBiometricData() async {
    final name = await BiometricService.getBiometricName();
    final enabled = await BiometricService.isBiometricEnabled();
    final supported = await BiometricService.hasBiometricSupport();

    setState(() {
      _biometricName = name;
      _biometricEnabled = enabled;
      _hasBiometricSupport = supported;
    });

    if (_biometricEnabled &&
        _hasBiometricSupport &&
        !widget.isFirstTime &&
        widget.showBiometricFirst &&
        !_biometricFailed) {
      await Future.delayed(const Duration(milliseconds: 300));
      _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final success = await BiometricService.authenticate();
    if (success) {
      _navigateToHome();
    } else {
      setState(() => _biometricFailed = true);
      // استخدام MessageService بدلاً من SnackBar
      MessageService.showWarning('${_biometricName} ${context.l10n.failed}');
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _addDigit(int digit) {
    if (_pinDigits.length < 6 && !_isLoading) {
      setState(() {
        _pinDigits.add(digit);
        _showError = false;
        _errorMessage = null;
      });
      if (_pinDigits.length == 6) _verifyPin();
    }
  }

  void _removeDigit() {
    if (_pinDigits.isNotEmpty && !_isLoading) {
      setState(() => _pinDigits.removeLast());
    }
  }

  void _clearPin() {
    if (!_isLoading) setState(() => _pinDigits.clear());
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    // محاكاة تحقق (يتم استبدالها بالتحقق الفعلي)
    await Future.delayed(const Duration(milliseconds: 600));
    final stored = await SharedPrefs.getStringValue('user_password');
    final entered = _pinDigits.join();

    if (stored == entered) {
      setState(() => _isLoading = false);
      _handleSuccess();
    } else {
      setState(() {
        _isLoading = false;
        _showError = true;
        _errorMessage = context.l10n.incorrectPin;
      });
      _errorTimer?.cancel();
      _errorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _pinDigits.clear();
            _showError = false;
            _errorMessage = null;
          });
        }
      });
    }
  }

  void _handleSuccess() {
    if (_hasBiometricSupport && !_biometricEnabled && !widget.isFirstTime) {
      _showBiometricBottomSheet();
    } else {
      _navigateToHome();
    }
  }

void _showBiometricBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BiometricBottomSheet(biometricName: _biometricName),
  ).then((_) {
    _navigateToHome();
  });
}
String _getUserEmail() {
  // جرب user_email الأول
  final directEmail = SharedPrefs.getStringValue('user_email');
  if (directEmail != null && directEmail.isNotEmpty) return directEmail;

  // لو مش موجود، جيبه من userData
  final userData = SharedPrefs.userData;
  if (userData != null) {
    try {
      final decoded = jsonDecode(userData) as Map<String, dynamic>;
      return decoded['email'] as String? ?? '';
    } catch (_) {}
  }
  return '';
}
void _onForgotPin() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final theme = Theme.of(context);
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          24, 16, 24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 28),

            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              context.l10n.forgotPin,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              context.l10n.forgotPinDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Reset button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForgotPasscodeOtpScreen(
                        email: _getUserEmail(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                ),
                child: Text(
                  context.l10n.reset,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  context.l10n.cancel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الشعار مع نبض خفيف
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 45,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.enterPin,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.enterPinDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // نقاط PIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.ltr,
                    children: List.generate(6, (index) {
                      final isFilled = index < _pinDigits.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _showError
                              ? Colors.red
                              : isFilled
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.15),
                          border: !isFilled
                              ? Border.all(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.3),
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
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),

            // لوحة المفاتيح
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildKeyRow(['1', '2', '3']),
                  const SizedBox(height: 12),
                  _buildKeyRow(['4', '5', '6']),
                  const SizedBox(height: 12),
                  _buildKeyRow(['7', '8', '9']),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Forget
                      _buildFunctionButton(
                        icon: Icons.help_outline,
                        onTap: _onForgotPin,
                        label: context.l10n.forgot,
                      ),
                      // 0
                      _buildNumberButton('0'),
                      // Delete / Biometric
                      _pinDigits.isEmpty && !_biometricFailed && _biometricEnabled
                          ? _buildBiometricButton()
                          : _buildFunctionButton(
                              icon: _pinDigits.isEmpty
                                  ? Icons.backspace_outlined
                                  : Icons.backspace,
                              onTap: _removeDigit,
                              onLongPress: _clearPin,
                              isActive: _pinDigits.isNotEmpty,
                            ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

Widget _buildKeyRow(List<String> digits) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    textDirection: TextDirection.ltr,
    children: digits.map((d) => _buildNumberButton(d)).toList(),
  );
}

Widget _buildNumberButton(String digit) {
  return GestureDetector(
    onTap: () => _addDigit(int.parse(digit)),
    child: Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
          textDirection: TextDirection.ltr, // 👈 Force LTR direction
        ),
      ),
    ),
  );
}

  Widget _buildFunctionButton({
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool isActive = true,
    String? label,
  }) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      onLongPress: onLongPress,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isActive
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            if (label != null)
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Colors.blue : Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    IconData icon;
    if (_biometricName.toLowerCase().contains('face')) {
      icon = Icons.face;
    } else if (_biometricName.toLowerCase().contains('finger')) {
      icon = Icons.fingerprint;
    } else {
      icon = Icons.security;
    }

    return GestureDetector(
      onTap: _authenticateWithBiometric,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}