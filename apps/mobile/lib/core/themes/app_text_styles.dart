import 'package:flutter/material.dart';
import 'package:my_wallet/core/themes/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) => TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle heading({
    double size = 18,
    Color color = AppColors.primaryBlack,
    FontWeight weight = FontWeight.bold,
  }) => TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle label({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) => TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle button({
    double size = 15,
    Color color = Colors.white,
    FontWeight weight = FontWeight.bold,
  }) => TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle fieldLabel({
    Color color = AppColors.primaryBlack,
    double size = 14,
  }) => TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle fieldHint({
    Color color = AppColors.error,
    double size = 13,
  }) => TextStyle(
        fontFamily: 'Inter',
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w500,
      );
}
