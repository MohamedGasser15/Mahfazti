import 'package:flutter/material.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}

extension ResponsiveExtension on BuildContext {
  bool get isTablet => AppResponsive.isTablet(this);
  bool get isSmallPhone => AppResponsive.isSmallPhone(this);
  double get fontScale => AppResponsive.fontScale(this);
  EdgeInsets get screenPadding => AppResponsive.screenPadding(this);
  EdgeInsets get horizontalPadding => AppResponsive.horizontalPadding(this);
  double get bottomNavHeight => AppResponsive.bottomNavHeight(this);
  double get cardWidth => AppResponsive.cardWidth(this);
  double get dialogWidth => AppResponsive.dialogWidth(this);
  int get gridColumnCount => AppResponsive.gridColumnCount(this).toInt();
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
}