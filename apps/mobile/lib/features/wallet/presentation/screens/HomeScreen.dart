import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/features/wallet/presentation/screens/Insights_tab.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/TransactionsPage.dart';

import 'home_tab.dart';

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
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: _buildFloatingNav(context, isDarkMode),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAndroidBottomNav(BuildContext context, bool isDarkMode) {
    final l10n = context.l10n;
    
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAndroidNavItem(
            context,
            0,
            FontAwesomeIcons.wallet,
            FontAwesomeIcons.wallet,
            l10n.wallet ?? 'Wallet',
            isDarkMode,
          ),
          _buildAndroidNavItem(
            context,
            1,
            FontAwesomeIcons.solidLightbulb,
            FontAwesomeIcons.solidLightbulb,
            l10n.insights ?? 'Insights',
            isDarkMode,
          ),
          _buildAndroidNavItem(
            context,
            2,
            FontAwesomeIcons.chartSimple,
            FontAwesomeIcons.chartSimple,
            l10n.analytics ?? 'Analytics',
            isDarkMode,
          ),
          _buildAndroidNavItem(
            context,
            3,
            FontAwesomeIcons.receipt,
            FontAwesomeIcons.receipt,
            l10n.transactions ?? 'Transactions',
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidNavItem(
    BuildContext context,
    int index,
    FaIconData outlineIcon,
    FaIconData filledIcon,
    String label,
    bool isDarkMode,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.grey[900] : Colors.grey[100])
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              isSelected ? filledIcon : outlineIcon,
              size: 24,
              color: isSelected
                  ? (isDarkMode ? Colors.white : Colors.black)
                  : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : (isDarkMode ? Colors.grey[500] : Colors.grey[500]),
              ),
            ),
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white : Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNav(BuildContext context, bool isDarkMode) {
    final l10n = context.l10n;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 75,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black.withOpacity(0.5)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                0, 
                FontAwesomeIcons.wallet, 
                FontAwesomeIcons.wallet,
                l10n.wallet ?? 'Wallet',
                isDarkMode,
              ),
              _buildNavItem(
                context,
                1,
                FontAwesomeIcons.solidLightbulb,
                FontAwesomeIcons.solidLightbulb,
                l10n.insights ?? 'Insights',
                isDarkMode,
              ),
              _buildNavItem(
                context,
                2,
                FontAwesomeIcons.chartSimple,
                FontAwesomeIcons.chartSimple,
                l10n.analytics ?? 'Analytics',
                isDarkMode,
              ),
              _buildNavItem(
                context,
                3,
                FontAwesomeIcons.receipt,
                FontAwesomeIcons.receipt,
                l10n.transactions ?? 'Transactions',
                isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    FaIconData outlineIcon,
    FaIconData filledIcon,
    String label,
    bool isDarkMode,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: 70,
        height: 65,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 250),
              scale: isSelected ? 1.1 : 1.0,
              child: FaIcon(
                isSelected ? filledIcon : outlineIcon,
                size: 26,
                color: isSelected
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : (isDarkMode ? Colors.white60 : Colors.black45),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : (isDarkMode ? Colors.white60 : Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}