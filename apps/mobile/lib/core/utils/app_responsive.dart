import 'package:flutter/material.dart';

class AppResponsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 390;

  static double fontScale(BuildContext context) =>
      isTablet(context) ? 1.15 : 1.0;

  static EdgeInsets screenPadding(BuildContext context) =>
      isTablet(context)
          ? const EdgeInsets.symmetric(horizontal: 60, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 16);

  static EdgeInsets horizontalPadding(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: isTablet(context) ? 60 : 20,
      );

  static double bottomNavHeight(BuildContext context) =>
      isTablet(context) ? 100 : 80;

  static double cardWidth(BuildContext context) =>
      isTablet(context)
          ? MediaQuery.of(context).size.width * 0.65
          : MediaQuery.of(context).size.width * 0.92;

  static double dialogWidth(BuildContext context) =>
      isTablet(context) ? 500 : MediaQuery.of(context).size.width * 0.92;

  static double gridColumnCount(BuildContext context) =>
      isTablet(context) ? 3 : 2;
}
