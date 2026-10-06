import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Adaptive back button that renders a circular liquid glass button on iOS
/// and a clean standard Material button on Android.
class AppGlassBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool? isDarkMode;
  final IconData icon;

  const AppGlassBackButton({
    super.key,
    this.onPressed,
    this.isDarkMode,
    this.icon = Icons.arrow_back_ios_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode ?? (Theme.of(context).brightness == Brightness.dark);
    final isIOS = Platform.isIOS;

    void handleTap() {
      HapticFeedback.selectionClick();
      if (onPressed != null) {
        onPressed!();
      } else {
        Navigator.maybePop(context);
      }
    }

    if (isIOS) {
      return Center(
        child: GlassButton(
          width: 38,
          height: 38,
          shape: const LiquidOval(),
          useOwnLayer: true,
          settings: LiquidGlassSettings(
            thickness: 14,
            blur: 10,
            glassColor: dark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.85),
          ),
          onTap: handleTap,
          icon: Icon(
            icon,
            size: 15,
            color: dark ? Colors.white : const Color(0xFF09090B),
          ),
        ),
      );
    }

    final borderColor = dark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final iconBgColor = dark ? const Color(0xFF141418) : Colors.white;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: handleTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 15,
                color: dark ? Colors.white : const Color(0xFF09090B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
