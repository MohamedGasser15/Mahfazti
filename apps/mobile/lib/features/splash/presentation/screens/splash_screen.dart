import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_wallet/core/constants/app_routes.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';

class SplashScreen extends StatefulWidget {
  final Function(Locale) onLocaleChanged;

  const SplashScreen({super.key, required this.onLocaleChanged});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Generous, calm timer (2400ms) without fading animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthStatus();
      }
    });
    _controller.forward();
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;
    final destination = await _resolveDestination();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(destination);
  }

  Future<String> _resolveDestination() async {
    try {
      final token = SharedPrefs.authToken;

      if (token == null || token.isEmpty) {
        return AppRoutes.email;
      }

      // Resolve currency & user data in background
      var currency = SharedPrefs.currency;
      if (currency == null || currency.isEmpty) {
        final userDataStr = SharedPrefs.userData;
        if (userDataStr != null && userDataStr.isNotEmpty) {
          try {
            final userMap = jsonDecode(userDataStr) as Map<String, dynamic>;
            final c = userMap['currency'] as String?;
            if (c != null && c.isNotEmpty) {
              await SharedPrefs.setCurrency(c);
              currency = c;
            }
          } catch (_) {}
        }
      }

      if (currency == null || currency.isEmpty) {
        return AppRoutes.currencySelection;
      }

      // Pre-warm cache in the background during splash so HomeTab loads instantaneously
      try {
        final cachedHome = await WalletCacheService.getHome();
        if (cachedHome == null) {
          final walletRepo = WalletRepository();
          final homeData = await walletRepo.getHomeData();
          await WalletCacheService.saveHome(homeData.toJson());
          try {
            final budget = await walletRepo.getBudget();
            await WalletCacheService.saveBudget(budget.toJson());
          } catch (_) {}
        }
      } catch (_) {
        // Pre-caching is purely opportunistic; ignore any network/offline issues
      }

      return AppRoutes.home;
    } catch (_) {
      return AppRoutes.email;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    isDark
                        ? 'assets/icons/mahfazti-logo-light.png'
                        : 'assets/icons/mahfazti-logo-dark.png',
                    width: 84,
                    height: 84,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(width: 18),
                Text(
                  'Mahfazti',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.3,
                    height: 1,
                  ).copyWith(color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
