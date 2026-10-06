// features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/settings/presentation/widgets/settings_content.dart';

class SettingsScreen extends StatelessWidget {
  final Function(Locale) onLocaleChanged;
  
  const SettingsScreen({
    super.key,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          context.l10n.settings,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: isDarkMode ? Colors.white : const Color(0xFF09090B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const AppGlassBackButton(),
      ),
      body: SettingsContent(onLocaleChanged: onLocaleChanged),
    );
  }
}