import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A few soft monochrome blobs drifting and melting into each other.
///
/// Three large radial gradients — white smoke on black, black smoke on
/// white — moving on different slow orbits. Shared by the Ask hub and the
/// chat screen so both surfaces feel like one place.
class AskBackground extends StatefulWidget {
  final bool isDark;

  const AskBackground({super.key, required this.isDark});

  @override
  State<AskBackground> createState() => _AskBackgroundState();
}

class _AskBackgroundState extends State<AskBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;
    final color = dark ? Colors.white : Colors.black;

    final a1 = dark ? 0.20 : 0.17;
    final a2 = dark ? 0.16 : 0.14;
    final a3 = dark ? 0.13 : 0.11;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value * 2 * math.pi;

              Widget blob(double fx, double fy, double sizeFactor, double a) {
                final size = w * sizeFactor;
                return Positioned(
                  left: fx * w - size / 2,
                  top: fy * h - size / 2,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withValues(alpha: a),
                          color.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  blob(
                    0.26 + 0.12 * math.sin(t),
                    0.20 + 0.09 * math.cos(t * 0.8),
                    1.05,
                    a1,
                  ),
                  blob(
                    0.82 + 0.09 * math.cos(t * 0.9),
                    0.46 + 0.11 * math.sin(t * 1.1),
                    0.95,
                    a2,
                  ),
                  blob(
                    0.44 + 0.14 * math.sin(t * 0.7 + 1.0),
                    0.86 + 0.07 * math.cos(t * 0.9),
                    1.15,
                    a3,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
