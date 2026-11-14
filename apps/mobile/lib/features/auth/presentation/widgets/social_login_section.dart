import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';

class SocialLoginSection extends StatelessWidget {
  final bool isLoading;
  final bool socialFirst;
  final ValueChanged<String> onProviderSelected;

  const SocialLoginSection({
    super.key,
    required this.isLoading,
    required this.onProviderSelected,
    this.socialFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    Widget providerButton(String provider) {
      final isGoogle = provider == 'Google';
      return OutlinedButton.icon(
        onPressed: isLoading ? null : () => onProviderSelected(provider),
        icon: FaIcon(
          isGoogle ? FontAwesomeIcons.google : FontAwesomeIcons.facebook,
          color: isGoogle ? const Color(0xFFEA4335) : const Color(0xFF1877F2),
          size: 18,
        ),
        label: Text(
          socialFirst
              ? '${isArabic ? 'المتابعة باستخدام' : 'Continue with'} $provider'
              : provider,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          side: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
          ),
        ),
      );
    }

    if (socialFirst) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          providerButton('Google'),
          const SizedBox(height: 12),
          providerButton('Facebook'),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                context.l10n.orContinueWith,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: providerButton('Google')),
            const SizedBox(width: 12),
            Expanded(child: providerButton('Facebook')),
          ],
        ),
      ],
    );
  }
}
