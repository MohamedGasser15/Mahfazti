import 'dart:io';
import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/home_tab.dart';
import 'package:my_wallet/features/wallet/presentation/screens/insights_tab.dart';
import 'package:my_wallet/features/wallet/presentation/screens/transactions_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Platform.isIOS;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: isIOS,
      bottomNavigationBar: isIOS ? null : _buildAndroidNavigationBar(context, isDarkMode),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              RepaintBoundary(child: HomeTab()),
              RepaintBoundary(child: InsightsPage()),
              RepaintBoundary(child: AnalyticsScreen()),
              RepaintBoundary(child: TransactionsTab()),
            ],
          ),
          if (isIOS)
            Positioned(
              left: 20,
              right: 20,
              bottom: 1,
              child: CNTabBar(
                iconSize: 20.0,
                autoHideOnPageTransition: false,
                items: [
                  CNTabBarItem(
                    label: l10n.wallet,
                    icon: const CNSymbol('wallet.pass', size: 20.0),
                  ),
                  CNTabBarItem(
                    label: l10n.insights,
                    icon: const CNSymbol('sparkles', size: 20.0),
                  ),
                  CNTabBarItem(
                    label: l10n.analytics,
                    icon: const CNSymbol('chart.pie', size: 20.0),
                  ),
                  CNTabBarItem(
                    label: l10n.transactions,
                    icon: const CNSymbol('arrow.left.arrow.right', size: 20.0),
                  ),
                ],
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAndroidNavigationBar(BuildContext context, bool isDarkMode) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF141418) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            width: 0.8,
          ),
        ),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 68,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: isDarkMode ? Colors.white : const Color(0xFFF4F4F5),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isDarkMode
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFE4E4E7), width: 0.8),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(
                color: isDarkMode ? Colors.black : const Color(0xFF18181B),
                size: 22,
              );
            }
            return IconThemeData(
              color: isDarkMode ? Colors.white54 : const Color(0xFF71717A),
              size: 22,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF18181B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              );
            }
            return TextStyle(
              color: isDarkMode ? Colors.white54 : const Color(0xFF71717A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
              label: l10n.wallet,
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: const Icon(Icons.auto_awesome_rounded),
              label: l10n.insights,
            ),
            NavigationDestination(
              icon: const Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: const Icon(Icons.pie_chart_rounded),
              label: l10n.analytics,
            ),
            NavigationDestination(
              icon: const Icon(Icons.swap_horiz_rounded),
              selectedIcon: const Icon(Icons.swap_horiz_rounded),
              label: l10n.transactions,
            ),
          ],
        ),
      ),
    );
  }
}