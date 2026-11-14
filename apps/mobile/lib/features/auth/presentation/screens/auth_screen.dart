import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_wallet/core/constants/app_routes.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/auth/presentation/controllers/register_controller.dart';
import 'package:my_wallet/features/auth/presentation/screens/login_screen.dart';
import 'package:my_wallet/features/auth/presentation/screens/register_screen.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  final AuthMode initialMode;

  const AuthScreen({super.key, this.initialMode = AuthMode.login});

  static void navigateAfterAuth(BuildContext context) {
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

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final PageController _authPageController;
  late final RegisterController _registerController;
  final GlobalKey<LoginScreenState> _loginKey = GlobalKey<LoginScreenState>();

  bool _isLoginTab = true;
  bool _showEmailLoginForm = false;

  @override
  void initState() {
    super.initState();
    _isLoginTab = widget.initialMode != AuthMode.register;
    _registerController = RegisterController();
    _authPageController = PageController(initialPage: _isLoginTab ? 0 : 1);
  }

  @override
  void dispose() {
    _authPageController.dispose();
    _registerController.dispose();
    super.dispose();
  }

  void _goToRegister(bool register) {
    if (_isLoginTab == !register) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoginTab = !register;
      if (register) _registerController.resetToEmailStep();
    });
    _authPageController
        .animateToPage(
          register ? 1 : 0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
        )
        .then((_) {
          if (register && mounted) {
            _loginKey.currentState?.resetToSocialPage();
            setState(() => _showEmailLoginForm = false);
          }
        });
  }

  void _handleBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_isLoginTab) {
      if (_showEmailLoginForm) {
        _loginKey.currentState?.goToEmailLogin(false);
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    final handledInRegister = _registerController.handleBack();
    if (!handledInRegister) {
      _goToRegister(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF09090B)
          : const Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: !Platform.isIOS,
      body: Stack(
        children: [
          ResponsiveWrapper(
            child: PageView(
              controller: _authPageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                LoginScreen(
                  key: _loginKey,
                  isEmbedded: true,
                  onSwitchToRegister: () => _goToRegister(true),
                  onEmailFormToggle: (showEmail) =>
                      setState(() => _showEmailLoginForm = showEmail),
                ),
                RegisterScreen(
                  isEmbedded: true,
                  controller: _registerController,
                  onSwitchToLogin: () => _goToRegister(false),
                ),
              ],
            ),
          ),
          if ((_isLoginTab && _showEmailLoginForm) || !_isLoginTab)
            PositionedDirectional(
              start: 12,
              top: MediaQuery.paddingOf(context).top + 4,
              child: AppGlassBackButton(onPressed: _handleBack),
            ),
        ],
      ),
    );
  }
}
