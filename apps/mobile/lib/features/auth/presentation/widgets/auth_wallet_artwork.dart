import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuthWalletArtwork extends StatelessWidget {
  final bool isDark;
  final double height;
  final Animation<double> entranceAnimation;
  final Animation<double> floatAnimation;

  const AuthWalletArtwork({
    super.key,
    required this.isDark,
    required this.height,
    required this.entranceAnimation,
    required this.floatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([entranceAnimation, floatAnimation]),
      builder: (context, child) {
        final entrance = Curves.easeOutCubic.transform(entranceAnimation.value);
        final float = math.sin(floatAnimation.value * math.pi * 2) * 4;
        return Transform.translate(
          offset: Offset(0, (1 - entrance) * 16 + float),
          child: Transform.scale(scale: 0.94 + entrance * 0.06, child: child),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              Positioned(
                left: width * .12,
                top: 14,
                child: Transform.rotate(
                  angle: -.13,
                  child: Container(
                    width: width * .73,
                    height: height - 31,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF3F3F46)
                          : const Color(0xFFE4E4E7),
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: width * .05,
                top: 20,
                child: Transform.rotate(
                  angle: .1,
                  child: Container(
                    width: width * .88,
                    height: height - 26,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF28282D), Color(0xFF0D0D0F)],
                      ),
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.white.withValues(alpha: .12)
                              : Colors.black.withValues(alpha: .16),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MY WALLET',
                          style: TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '••  •••  •••',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Divider(color: Color(0xFF3F3F46), height: 1),
                        Text(
                          'ALL YOUR MONEY. ONE PLACE.',
                          style: TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
