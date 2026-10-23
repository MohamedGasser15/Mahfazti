import 'package:flutter/material.dart';

/// Shared surfaces for the app so every list/card matches the same palette.
///
/// Light → white card on the white page, hairline zinc border + very soft
/// shadow (the "Obsidian" bento cards).
/// Dark → `#141418` card on the near-black page with a `#27272A` border.
class AppSurfaces {
  const AppSurfaces._();

  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF141418);

  static const Color borderLight = Color(0xFFE4E4E7);
  static const Color borderDark = Color(0xFF27272A);

  static Color card(bool isDarkMode) => isDarkMode ? cardDark : cardLight;

  static Color border(bool isDarkMode) => isDarkMode ? borderDark : borderLight;

  /// Card container used by wallet cards, grouped lists, and transaction rows.
  static BoxDecoration cardDecoration({
    required bool isDarkMode,
    double radius = 22,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: card(isDarkMode),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border(isDarkMode), width: 1),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: isDarkMode ? 0.25 : 0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}
