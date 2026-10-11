import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Interactive Slidable Action Button that zooms in smoothly from depth
/// with squircle shape, subtle glass border, and secondary label beneath.
class SlidableScaleActionButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String label;
  final List<Color> gradientColors;
  final bool isDarkMode;

  const SlidableScaleActionButton({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.label,
    required this.gradientColors,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final slidable = Slidable.of(context);
    final pane = ActionPane.of(context);

    if (slidable == null || pane == null) {
      return _buildContent(1.0, 1.0);
    }

    return AnimatedBuilder(
      animation: slidable.animation,
      builder: (context, child) {
        final extent = pane.extentRatio > 0 ? pane.extentRatio : 0.22;
        final rawRatio = slidable.animation.value / extent;

        // 1. Initial deadzone: completely hidden at rest and very first touch
        if (rawRatio <= 0.08) {
          return const SizedBox.shrink();
        }

        // 2. Normalized progress mapped from [0.08 -> 1.0]
        final normalized = ((rawRatio - 0.08) / 0.92).clamp(0.0, 1.25);

        // 3. Scale: starts from deep background (0.35) and zooms forward to 1.0
        final double effectiveScale;
        if (normalized <= 1.0) {
          final curved = Curves.easeOutQuart.transform(normalized);
          effectiveScale = 0.35 + (0.65 * curved);
        } else {
          final overDrag = (normalized - 1.0).clamp(0.0, 0.25);
          effectiveScale = 1.0 + (0.08 * math.sin(overDrag * 4 * math.pi));
        }

        // 4. Opacity: gentle atmospheric fade-in from distance
        final opacity = Curves.easeInCubic.transform(normalized.clamp(0.0, 1.0));

        // 5. Subtle depth shift along Y axis (floats up slightly into place)
        final translateY = (1.0 - normalized.clamp(0.0, 1.0)) * 6.0;

        return Center(
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.scale(
              scale: effectiveScale,
              child: Opacity(
                opacity: opacity,
                child: _buildContent(effectiveScale, opacity),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(double scale, double opacity) {
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.25);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: borderColor,
              width: 0.8,
            ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: isDarkMode
                ? const Color(0xFFA1A1AA)
                : const Color(0xFF71717A),
          ),
        ),
      ],
    );
  }
}
