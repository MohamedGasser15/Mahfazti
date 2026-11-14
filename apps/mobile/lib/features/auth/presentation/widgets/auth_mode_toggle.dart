import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';

class AuthModeToggle extends StatelessWidget {
  final bool onLoginPage;
  final VoidCallback onPressed;

  const AuthModeToggle({
    super.key,
    required this.onLoginPage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          onLoginPage
              ? context.l10n.dontHaveAccount
              : context.l10n.alreadyHaveAccount,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          child: Text(
            onLoginPage ? context.l10n.register : context.l10n.login,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
