import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_liquid_glass/real_liquid_glass.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/budgets_tab.dart';
import 'package:my_wallet/features/wallet/presentation/screens/home_tab.dart';
import 'package:my_wallet/features/wallet/presentation/screens/subscriptions_tab.dart';

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

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Platform.isIOS;
    final l10n = context.l10n;

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final baseTabItems = [
      LiquidGlassBarItem(
        icon: CupertinoIcons.creditcard,
        selectedIcon: CupertinoIcons.creditcard_fill,
        sfSymbol: 'wallet.pass',
        selectedSfSymbol: 'wallet.pass.fill',
        label: l10n.wallet,
      ),
      LiquidGlassBarItem(
        icon: CupertinoIcons.chart_pie,
        selectedIcon: CupertinoIcons.chart_pie_fill,
        sfSymbol: 'chart.pie',
        selectedSfSymbol: 'chart.pie.fill',
        label: l10n.analytics,
      ),
      LiquidGlassBarItem(
        icon: CupertinoIcons.chart_bar_alt_fill,
        selectedIcon: CupertinoIcons.chart_bar_fill,
        sfSymbol: 'chart.bar.xaxis',
        selectedSfSymbol: 'chart.bar.xaxis',
        label: l10n.budgets,
      ),
      LiquidGlassBarItem(
        icon: CupertinoIcons.arrow_2_squarepath,
        selectedIcon: CupertinoIcons.arrow_2_squarepath,
        sfSymbol: 'arrow.2.squarepath',
        selectedSfSymbol: 'arrow.2.squarepath',
        label: l10n.subscriptions,
      ),
    ];
    final displayItems = isRtl ? baseTabItems.reversed.toList() : baseTabItems;
    final activeIndex = isRtl ? (baseTabItems.length - 1 - _currentIndex) : _currentIndex;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: isIOS,
      bottomNavigationBar: isIOS ? null : _buildAndroidNavigationBar(context, isDarkMode),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              RepaintBoundary(child: HomeTab(onNavigateToTab: _navigateToTab)),
              const RepaintBoundary(child: AnalyticsScreen()),
              const RepaintBoundary(child: BudgetsTab()),
              const RepaintBoundary(child: SubscriptionsTab()),
            ],
          ),
          if (isIOS)
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: LiquidGlassBottomBar(
                key: ValueKey('tab_bar_${isRtl}_$isDarkMode'),
                height: 85,
                tint: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                style: LiquidGlassStyle.regular,
                items: displayItems,
                currentIndex: activeIndex,
                onTap: (index) {
                  HapticFeedback.selectionClick();
                  final targetIndex = isRtl ? (displayItems.length - 1 - index) : index;
                  _navigateToTab(targetIndex);
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
            _navigateToTab(index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
              label: l10n.wallet,
            ),
            NavigationDestination(
              icon: const Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: const Icon(Icons.pie_chart_rounded),
              label: l10n.analytics,
            ),
            NavigationDestination(
              icon: const Icon(Icons.savings_outlined),
              selectedIcon: const Icon(Icons.savings_rounded),
              label: l10n.budgets,
            ),
            NavigationDestination(
              icon: const Icon(Icons.autorenew_outlined),
              selectedIcon: const Icon(Icons.autorenew_rounded),
              label: l10n.subscriptions,
            ),
          ],
        ),
      ),
    );
  }
}