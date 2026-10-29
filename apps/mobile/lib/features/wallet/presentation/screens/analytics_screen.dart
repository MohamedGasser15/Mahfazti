import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_android_view.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_ios_view.dart';

/// Entry point for the analytics tab.
///
/// iOS and Android intentionally have two completely separate experiences:
/// iOS uses the Liquid Glass design system (`neo_cupertino`), Android uses
/// Material 3. They only share the data layer in `analytics_controller.dart`.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS =
        Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? const AnalyticsIosView() : const AnalyticsAndroidView();
  }
}
