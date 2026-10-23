// core/utils/navigation_service.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class _AppModalObserver extends NavigatorObserver {
  int _modalCount = 0;

  /// Sheets and full-screen modals hide the bottom bar, but *alerts* are
  /// centered dialogs — the nav bar should stay visible behind them.
  bool _hidesNavBar(Route<dynamic>? route) {
    if (route is! PopupRoute) return false;
    // Material `showDialog` and Cupertino `showCupertinoDialog` are alerts.
    // Note: glass/modal sheets are plain `RawDialogRoute`s, so they still
    // hide the bar.
    return route is! DialogRoute && route is! CupertinoDialogRoute;
  }

  void _increment() {
    _modalCount++;
    NavigationService.isModalOpenNotifier.value = true;
  }

  void _decrement() {
    if (_modalCount > 0) _modalCount--;
    if (_modalCount == 0) {
      NavigationService.isModalOpenNotifier.value = false;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (_hidesNavBar(route)) {
      _increment();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (_hidesNavBar(route) && route is PopupRoute) {
      final anim = route.animation;
      if (anim != null && !anim.isDismissed) {
        void listener(AnimationStatus status) {
          if (status == AnimationStatus.dismissed) {
            anim.removeStatusListener(listener);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _decrement();
            });
          }
        }
        anim.addStatusListener(listener);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _decrement();
        });
      }
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (_hidesNavBar(route)) {
      _decrement();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (_hidesNavBar(oldRoute)) {
      _decrement();
    }
    if (_hidesNavBar(newRoute)) {
      _increment();
    }
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = 
      GlobalKey<NavigatorState>();
  
  static final ValueNotifier<bool> isModalOpenNotifier = ValueNotifier<bool>(false);
  static final NavigatorObserver modalObserver = _AppModalObserver();

  static BuildContext? get context => navigatorKey.currentContext;
  
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }
  
  static Future<dynamic> navigateReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }
  
  static Future<dynamic> navigateAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  static void goBack([dynamic result]) {
    return navigatorKey.currentState!.pop(result);
  }
}