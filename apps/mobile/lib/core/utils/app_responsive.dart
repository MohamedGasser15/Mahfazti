import 'package:flutter/material.dart';

class AppResponsive {
  static const double maxContentWidth = 650.0;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;

  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 390;

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
          ? MediaQuery.sizeOf(context).width * 0.65
          : MediaQuery.sizeOf(context).width * 0.92;

  static double dialogWidth(BuildContext context) =>
      isTablet(context) ? 500 : MediaQuery.sizeOf(context).width * 0.92;

  static double gridColumnCount(BuildContext context) =>
      isTablet(context) ? 3 : 2;
}

/// A responsive container widget that centers content and limits maximum width
/// on larger screens (tablets/desktops) while filling full width on phones.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = AppResponsive.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );

    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    return content;
  }
}
