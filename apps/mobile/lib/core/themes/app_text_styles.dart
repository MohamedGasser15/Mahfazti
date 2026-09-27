import 'package:flutter/material.dart';
import 'package:my_wallet/core/themes/app_colors.dart';
import 'package:my_wallet/core/utils/language_service.dart';

class AppTextStyles {
  AppTextStyles._();

  static String get fontFamily =>
      LanguageService.localeNotifier.value.languageCode == 'ar'
          ? 'Cairo'
          : 'Inter';

  static List<String> get fontFamilyFallback =>
      LanguageService.localeNotifier.value.languageCode == 'ar'
          ? const ['Inter']
          : const ['Cairo'];

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    String? customFontFamily,
  }) => TextStyle(
        fontFamily: customFontFamily ?? fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle heading({
    double size = 18,
    Color color = AppColors.primaryBlack,
    FontWeight weight = FontWeight.bold,
    String? customFontFamily,
  }) => TextStyle(
        fontFamily: customFontFamily ?? fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle label({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    Color? color,
    String? customFontFamily,
  }) => TextStyle(
        fontFamily: customFontFamily ?? fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle button({
    double size = 15,
    Color color = Colors.white,
    FontWeight weight = FontWeight.bold,
    String? customFontFamily,
  }) => TextStyle(
        fontFamily: customFontFamily ?? fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle fieldLabel({
    Color color = AppColors.primaryBlack,
    double size = 14,
    String? customFontFamily,
  }) => TextStyle(
        fontFamily: customFontFamily ?? fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle fieldHint({
    Color color = AppColors.error,
    double size = 13,
    String? customFontFamily,
  }) => TextStyle(
        fontFamily: customFontFamily ?? fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w500,
      );
}
