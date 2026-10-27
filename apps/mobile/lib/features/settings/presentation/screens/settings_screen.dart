// features/settings/presentation/screens/settings_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/settings/presentation/widgets/settings_content.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) onLocaleChanged;

  const SettingsScreen({
    super.key,
    required this.onLocaleChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 52,
        leadingWidth: 58,
        leading: const AppGlassBackButton(),
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final offset =
                _scrollController.hasClients ? _scrollController.offset : 0.0;
            final isAr = Localizations.localeOf(context).languageCode == 'ar';
            final progress = ((offset - 16.0) / 38.0).clamp(0.0, 1.0);
            if (progress <= 0.0) return const SizedBox.shrink();
            final curve = Curves.easeOutCubic.transform(progress);

            // Travels in along the continuous diagonal trajectory
            final incomingX =
                isAr ? (1.0 - curve) * 60.0 : -(1.0 - curve) * 60.0;
            final incomingY = (1.0 - curve) * 12.0;
            final incomingScale = 0.85 + 0.15 * curve;

            return Transform.translate(
              offset: Offset(incomingX, incomingY),
              child: Transform.scale(
                scale: incomingScale,
                child: Opacity(
                  opacity: progress,
                  child: Text(
                    context.l10n.settings,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF09090B),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        flexibleSpace: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final offset =
                _scrollController.hasClients ? _scrollController.offset : 0.0;
            final progress = ((offset - 10.0) / 35.0).clamp(0.0, 1.0);
            if (progress <= 0.0) return const SizedBox.shrink();
            return ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 20.0 * progress,
                  sigmaY: 20.0 * progress,
                ),
                child: Container(
                  color: (isDarkMode
                          ? const Color(0xFF09090B)
                          : const Color(0xFFF8F8FA))
                      .withValues(alpha: 0.82 * progress),
                ),
              ),
            );
          },
        ),
      ),
      body: SettingsContent(
        onLocaleChanged: widget.onLocaleChanged,
        scrollController: _scrollController,
      ),
    );
  }
}
