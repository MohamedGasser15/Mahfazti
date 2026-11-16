import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Soft, drifting color glows shared by the Ask hub, chat, and history screens.
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
    final colors = dark
        ? const [Color(0xFF087F68), Color(0xFF4338A8), Color(0xFF145D78)]
        : const [Colors.black, Colors.black, Colors.black];
    final alphas = dark ? const [0.27, 0.22, 0.18] : const [0.17, 0.14, 0.11];

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value * 2 * math.pi;

              Widget blob(
                double fx,
                double fy,
                double sizeFactor,
                Color color,
                double alpha,
              ) {
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
                          color.withValues(alpha: alpha),
                          color.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  if (dark)
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0D1114),
                              Color(0xFF09090B),
                              Color(0xFF0A0D12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  blob(
                    0.26 + 0.12 * math.sin(t),
                    0.20 + 0.09 * math.cos(t * 0.8),
                    1.05,
                    colors[0],
                    alphas[0],
                  ),
                  blob(
                    0.82 + 0.09 * math.cos(t * 0.9),
                    0.46 + 0.11 * math.sin(t * 1.1),
                    0.95,
                    colors[1],
                    alphas[1],
                  ),
                  blob(
                    0.44 + 0.14 * math.sin(t * 0.7 + 1.0),
                    0.86 + 0.07 * math.cos(t * 0.9),
                    1.15,
                    colors[2],
                    alphas[2],
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
