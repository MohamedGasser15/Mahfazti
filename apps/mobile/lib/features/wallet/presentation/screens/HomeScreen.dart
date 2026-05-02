import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/features/wallet/presentation/screens/Insights_tab.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/TransactionsPage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'home_tab.dart';
import 'package:cupertino_native/cupertino_native.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Platform.isIOS;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      extendBody: isIOS,
      bottomNavigationBar: isIOS ? null : _buildAndroidBottomNav(context, isDarkMode),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              HomeTab(),           // Wallet
              InsightsPage(),      // Insights
              AnalyticsScreen(),   // Analytics
              TransactionsTab(),   // Transactions
            ],
          ),
          if (isIOS)
            Positioned(
              left: 20,
              right: 20,
              bottom: 15,
              child: CNTabBar(
                items: [
                  CNTabBarItem(
                    label: l10n.wallet ?? 'Wallet',
                    icon: const CNSymbol('creditcard.fill'),
                  ),
                  CNTabBarItem(
                    label: l10n.insights ?? 'Insights',
                    icon: const CNSymbol('lightbulb.fill'),
                  ),
                  CNTabBarItem(
                    label: l10n.analytics ?? 'Analytics',
                    icon: const CNSymbol('chart.bar.fill'),
                  ),
                  CNTabBarItem(
                    label: l10n.transactions ?? 'Transactions',
                    icon: const CNSymbol('list.bullet.rectangle.fill'),
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

Widget _buildAndroidBottomNav(BuildContext context, bool isDarkMode) {
  final l10n = context.l10n;

  return Container(
    decoration: BoxDecoration(
      color: isDarkMode ? Colors.black : Colors.white,
      border: Border(
        top: BorderSide(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: GNav(
          selectedIndex: _currentIndex,
          onTabChange: (index) {
            setState(() => _currentIndex = index);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          gap: 8,
          tabBorderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          duration: const Duration(milliseconds: 300),
          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          activeColor: isDarkMode ? Colors.white : Colors.black,
          tabBackgroundColor: isDarkMode
              ? Colors.grey[900]!
              : Colors.grey[100]!,
          tabs: [
GButton(
  icon: Icons.account_balance_wallet_outlined,
  text: l10n.wallet ?? 'Wallet',
),
GButton(
  icon: Icons.lightbulb_outline,
  text: l10n.insights ?? 'Insights',
),
GButton(
  icon: Icons.bar_chart_rounded,
  text: l10n.analytics ?? 'Analytics',
),
GButton(
  icon: Icons.receipt_long_outlined,
  text: l10n.transactions ?? 'Transactions',
),
          ],
        ),
      ),
    ),
  );
}

}