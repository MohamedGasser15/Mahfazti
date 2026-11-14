import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand mark
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            // Light mode shows the black tile (like the app icon), dark mode
            // shows the white one.
            isDark
                ? 'assets/icons/mahfazti-logo-light.png'
                : 'assets/icons/mahfazti-logo-dark.png',
            width: 76,
            height: 76,
            filterQuality: FilterQuality.high,
          ),
        ),

        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
