import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A platform-adaptive loading indicator that renders:
/// - [CupertinoActivityIndicator] (iOS native radial spokes) on iOS.
/// - [CircularProgressIndicator] (Material indeterminate circle) on Android.
class AppProgressIndicator extends StatelessWidget {
  final double? size;
  final double? radius;
  final Color? color;
  final double strokeWidth;

  const AppProgressIndicator({
    super.key,
    this.size,
    this.radius,
    this.color,
    this.strokeWidth = 2.5,
  });

  /// Small indicator suitable for buttons, pills, and inline labels.
  const AppProgressIndicator.small({
    super.key,
    this.color,
    this.strokeWidth = 2.0,
  }) : size = 20,
       radius = 10;

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && Platform.isIOS;
    if (isIOS) {
      final effectiveRadius = radius ?? (size != null ? size! / 2 : 12.0);
      return CupertinoActivityIndicator(radius: effectiveRadius, color: color);
    }

    final effectiveSize = size ?? (radius != null ? radius! * 2 : null);
    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      valueColor: color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
      color: color,
    );

    if (effectiveSize != null) {
      return SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: indicator,
      );
    }
    return indicator;
  }
}
