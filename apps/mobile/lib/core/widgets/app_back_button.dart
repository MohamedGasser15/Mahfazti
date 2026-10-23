import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

/// Canonical "go back" icon used everywhere in the app.
///
/// iOS renders Cupertino chevrons, Android (and everything else) plain
/// Material arrows. Direction is resolved from the active layout direction:
/// LTR → left-pointing, RTL → right-pointing.
IconData appBackIcon({required bool isIOS, required bool isRtl}) {
  if (isIOS) {
    return isRtl ? CupertinoIcons.chevron_right : CupertinoIcons.chevron_left;
  }
  return isRtl ? Icons.arrow_forward : Icons.arrow_back;
}

/// Canonical "go forward / next" chevron used for list rows, section links
/// ("View all ›") and any disclosure affordance.
IconData appForwardIcon({required bool isIOS, required bool isRtl}) {
  if (isIOS) {
    return isRtl ? CupertinoIcons.chevron_left : CupertinoIcons.chevron_right;
  }
  return isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;
}

/// Chevron for previous/next steppers (month switchers).
/// [forward] = true means "next".
IconData appStepperIcon({
  required bool isIOS,
  required bool isRtl,
  required bool forward,
}) {
  final pointRight = forward != isRtl;
  if (isIOS) {
    return pointRight ? CupertinoIcons.chevron_right : CupertinoIcons.chevron_left;
  }
  return pointRight
      ? Icons.chevron_right_rounded
      : Icons.chevron_left_rounded;
}

/// Context-aware convenience wrappers — they resolve both the platform and
/// the text direction, so call sites stay one-liners.
IconData appBackIconOf(BuildContext context) => appBackIcon(
      isIOS: Platform.isIOS,
      isRtl: Directionality.of(context) == TextDirection.rtl,
    );

IconData appForwardIconOf(BuildContext context) => appForwardIcon(
      isIOS: Platform.isIOS,
      isRtl: Directionality.of(context) == TextDirection.rtl,
    );

IconData appStepperIconOf(BuildContext context, {required bool forward}) =>
    appStepperIcon(
      isIOS: Platform.isIOS,
      isRtl: Directionality.of(context) == TextDirection.rtl,
      forward: forward,
    );

/// Adaptive back button that renders a circular liquid glass button on iOS
/// and a clean standard Material button on Android.
class AppGlassBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool? isDarkMode;
  final IconData? icon;

  const AppGlassBackButton({
    super.key,
    this.onPressed,
    this.isDarkMode,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode ?? (Theme.of(context).brightness == Brightness.dark);
    final isIOS = Platform.isIOS;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final effectiveIcon = icon ?? appBackIcon(isIOS: isIOS, isRtl: isRtl);

    void handleTap() {
      HapticFeedback.selectionClick();
      if (onPressed != null) {
        onPressed!();
      } else {
        Navigator.maybePop(context);
      }
    }

    final isIOS26 = isIOS;

    if (isIOS26) {
      return Center(
        child: GlassButton(
          width: 44,
          height: 44,
          shape: const LiquidOval(),
          useOwnLayer: true,
          quality: GlassQuality.premium,
          settings: dark
              ? LiquidGlassSettings.ios27Dark
              : LiquidGlassSettings.ios27Light,
          onTap: handleTap,
          icon: Transform.translate(
            // Micro-shift to optically center the chevron
            offset: Offset(isRtl ? 1.0 : -1.0, 0),
            child: Icon(
              effectiveIcon,
              size: 20,
              color: dark ? Colors.white : const Color(0xFF09090B),
            ),
          ),
        ),
      );
    }

    if (isIOS) {
      return Center(
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: handleTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: dark
                  ? CupertinoColors.systemGrey6.darkColor
                  : CupertinoColors.systemGrey6,
              shape: BoxShape.circle,
            ),
            child: Icon(
              effectiveIcon,
              size: 16,
              color: dark ? CupertinoColors.white : CupertinoColors.black,
            ),
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
                effectiveIcon,
                size: 18,
                color: dark ? Colors.white : const Color(0xFF09090B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
