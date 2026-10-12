import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_adaptive_context_menu/ios_adaptive_context_menu.dart';

/// A widget that triggers a native iOS context menu (UIMenu) strictly on HOLD / long press
/// on iOS, opening strictly above or below the card (never covering it), with strong haptic
/// vibration, and ensuring single taps select the wallet without sticking or re-opening.
class IosHoldContextMenu extends StatefulWidget {
  final Widget child;
  final List<IosContextMenuItem> actions;
  final ValueChanged<String>? onSelected;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const IosHoldContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.onSelected,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<IosHoldContextMenu> createState() => _IosHoldContextMenuState();
}

class _IosHoldContextMenuState extends State<IosHoldContextMenu> {
  static const MethodChannel _iosHostChannel =
      MethodChannel('ios_adaptive_context_menu/methods');

  late final String _instanceId;
  late final MethodChannel _iosInstanceChannel;

  bool get _isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _instanceId =
        '${identityHashCode(this)}_${DateTime.now().microsecondsSinceEpoch}';
    _iosInstanceChannel = MethodChannel(
      'ios_adaptive_context_menu/instance_$_instanceId',
    );
    _iosInstanceChannel.setMethodCallHandler(_handleCallback);
  }

  @override
  void dispose() {
    _disposeAnchorButton();
    _iosInstanceChannel.setMethodCallHandler(null);
    super.dispose();
  }

  void _disposeAnchorButton() {
    if (_isIos) {
      _iosHostChannel.invokeMethod<void>('disposeInstance', {
        'instanceId': _instanceId,
      });
    }
  }

  Future<void> _handleCallback(MethodCall call) async {
    if (call.method != 'onSelected' || widget.onSelected == null) {
      return;
    }
    final Object? args = call.arguments;
    if (args is! Map<Object?, Object?>) {
      return;
    }
    final Object? rawId = args['id'];
    if (rawId is String && rawId.isNotEmpty) {
      _disposeAnchorButton();
      HapticFeedback.selectionClick();
      widget.onSelected!.call(rawId);
    }
  }

  Future<void> _showIosMenu() async {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }

    final double screenHeight =
        MediaQuery.maybeOf(context)?.size.height ?? 800.0;
    final Rect anchorRect =
        renderObject.localToGlobal(Offset.zero) & renderObject.size;
    final params = await _buildCreationParams();

    // Check available vertical screen space to guarantee the menu
    // appears strictly UNDER the card (or above if near the bottom edge),
    // NEVER on top of the card itself!
    final bool hasSpaceBelow = (anchorRect.bottom + 220.0) <= screenHeight;
    final double targetY = hasSpaceBelow
        ? (anchorRect.bottom + 4.0)
        : (anchorRect.top - 4.0);

    params['instanceId'] = _instanceId;
    params['x'] = anchorRect.left;
    params['y'] = targetY;
    params['width'] = anchorRect.width;
    params['height'] = 1.0;

    await _iosHostChannel.invokeMethod<void>('showMenu', params);
  }

  Future<Map<String, Object?>> _buildCreationParams() async {
    final serialized = <Map<String, Object?>>[];
    for (final item in widget.actions) {
      if (item is IosContextMenuDivider) {
        serialized.add(const <String, Object?>{'type': 'divider'});
      } else if (item is IosContextMenuAction) {
        serialized.add(<String, Object?>{
          'type': 'action',
          'id': item.id,
          'title': item.title,
          'iconSystemName': item.iconSystemName,
          'showTrailingCheckmark': item.showTrailingCheckmark,
          'destructive': item.destructive,
          'enabled': item.enabled,
        });
      }
    }
    return <String, Object?>{'actions': serialized};
  }

  void _handleTap() {
    _disposeAnchorButton();
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  void _handleTapDown(TapDownDetails _) {
    _disposeAnchorButton();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isIos || widget.actions.isEmpty) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: _handleTapDown,
        onTap: _handleTap,
        onLongPress: () {
          // Deep, punchy iOS Taptic Engine vibration when hold triggers
          HapticFeedback.heavyImpact();
          _showIosMenu();
        },
        borderRadius: widget.borderRadius,
        child: widget.child,
      ),
    );
  }
}
