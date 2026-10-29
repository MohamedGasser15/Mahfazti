import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neo_cupertino/neo_cupertino.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:my_wallet/core/themes/app_surfaces.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/wallet/data/models/budget_models.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/presentation/screens/spending_breakdown_screen.dart';
import 'package:my_wallet/features/wallet/presentation/utils/category_icon_helper.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/home_tab_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Detailed Financial Analytics & Money Flow Screen.
/// Provides Account filtering, Date range selection, Money Flow (Spent with Bar Graph,
/// Income, Net Cashflow, Saving Rate), and Monthly Budget overview / setup CTA.
class FinancialAnalyticsScreen extends StatefulWidget {
  const FinancialAnalyticsScreen({super.key});

  @override
  State<FinancialAnalyticsScreen> createState() => _FinancialAnalyticsScreenState();
}

class _FinancialAnalyticsScreenState extends State<FinancialAnalyticsScreen> {
  final WalletRepository _walletRepository = WalletRepository();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _dateButtonKey = GlobalKey();

  String _currencyCode = 'EGP';

  // Accounts
  List<AccountItem> _accounts = [];
  String _selectedAccountId = 'all';

  // Date Range (cannot exceed today)
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  // Budget
  BudgetDto? _budgetData;

  // Daily Spending distribution (Sat to Fri)
  final List<double> _baseDailySpending = [1420.0, 2150.0, 980.0, 3200.0, 1850.0, 4850.0, 2358.0];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final currency = SharedPrefs.currency ?? 'EGP';
    setState(() => _currencyCode = currency);

    try {
      // 1. Load accounts from home data & overrides
      final homeData = await _walletRepository.getHomeData();
      final prefs = await SharedPreferences.getInstance();

      final overridesRaw = prefs.getString('wallet_override_balances');
      final Map<String, double> balanceOverrides = {};
      if (overridesRaw != null) {
        final decoded = jsonDecode(overridesRaw) as Map<String, dynamic>;
        decoded.forEach((key, val) {
          if (val is num) balanceOverrides[key] = val.toDouble();
        });
      }

      final customStr = prefs.getString('wallet_custom_accounts');
      final List<AccountItem> customAccs = [];
      if (customStr != null) {
        final list = jsonDecode(customStr) as List<dynamic>;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            customAccs.add(AccountItem.fromJson(item));
          }
        }
      }

      final balance = homeData.balance.totalBalance;
      final income = homeData.balance.totalDeposits;
      final expense = homeData.balance.totalWithdrawals;

      final defaultBank = balance * 0.62;
      final defaultCash = balance * 0.18;
      final defaultEwallet = balance * 0.20;

      final bankBal = balanceOverrides['bank'] ?? defaultBank;
      final cashBal = balanceOverrides['cash'] ?? defaultCash;
      final ewalletBal = balanceOverrides['ewallet'] ?? defaultEwallet;
      final customTotal = customAccs.fold<double>(
        0.0,
        (sum, a) => sum + (a.excludeFromTotal ? 0.0 : (balanceOverrides[a.id] ?? a.balance)),
      );

      final totalEffBalance = balanceOverrides.isNotEmpty
          ? (bankBal + cashBal + ewalletBal + customTotal)
          : balance;

      final accountsList = <AccountItem>[
        AccountItem(
          id: 'all',
          name: 'All Accounts',
          type: 'all',
          balance: totalEffBalance,
          income: income,
          expense: expense,
          icon: Icons.account_balance_wallet_rounded,
          isAll: true,
          currency: currency,
        ),
        AccountItem(
          id: 'bank',
          name: 'Banque Misr',
          type: 'bank',
          balance: bankBal,
          income: income * 0.70,
          expense: expense * 0.60,
          icon: Icons.account_balance_rounded,
          currency: currency,
        ),
        AccountItem(
          id: 'cash',
          name: 'Cash Wallet',
          type: 'cash',
          balance: cashBal,
          income: income * 0.10,
          expense: expense * 0.18,
          icon: Icons.payments_rounded,
          currency: currency,
        ),
        AccountItem(
          id: 'ewallet',
          name: 'E-Wallet',
          type: 'ewallet',
          balance: ewalletBal,
          income: income * 0.20,
          expense: expense * 0.22,
          icon: Icons.phone_android_rounded,
          currency: currency,
        ),
        ...customAccs,
      ];

      // 2. Load Budget (Only if user explicitly created/set one)
      BudgetDto? budget;
      final hasSetBudget = prefs.getBool('user_has_set_monthly_budget') ?? false;
      if (hasSetBudget) {
        final cached = await WalletCacheService.getBudget();
        if (cached != null) {
          budget = BudgetDto.fromJson(cached);
        }
      }

      if (mounted) {
        setState(() {
          _accounts = accountsList;
          _budgetData = budget;
        });
      }
    } catch (e) {
      // Keep defaults
    }
  }

  // Active Account helper
  AccountItem get _selectedAccount {
    return _accounts.firstWhere(
      (a) => a.id == _selectedAccountId,
      orElse: () => _accounts.isNotEmpty
          ? _accounts.first
          : AccountItem(
              id: 'all',
              name: 'All Accounts',
              type: 'all',
              balance: 50561.0,
              income: 35000.0,
              expense: 18808.0,
              icon: Icons.account_balance_wallet_rounded,
              isAll: true,
              currency: _currencyCode,
            ),
    );
  }

  // Active Metrics filtered by account
  double get _currentSpent {
    if (_selectedAccountId == 'all') {
      return 18808.0;
    }
    return _selectedAccount.expense > 0 ? _selectedAccount.expense : 11284.0;
  }

  double get _currentIncome {
    if (_selectedAccountId == 'all') {
      return 35000.0;
    }
    return _selectedAccount.income > 0 ? _selectedAccount.income : 24500.0;
  }

  double get _currentNetCashflow => _currentIncome - _currentSpent;

  double get _currentSavingRate {
    if (_currentIncome <= 0) return 0.0;
    final rate = ((_currentIncome - _currentSpent) / _currentIncome) * 100;
    return rate.clamp(0.0, 100.0);
  }

  List<double> get _scaledBars {
    final scale = _currentSpent / 18808.0;
    return _baseDailySpending.map((v) => v * scale).toList();
  }

  String get _formattedDateRange {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (_startDate.year == _endDate.year && _startDate.month == _endDate.month) {
      if (_startDate.day == 1 && _endDate.day >= 28) {
        return DateFormat('MMM yyyy', isAr ? 'ar' : 'en').format(_startDate);
      }
    }
    final startStr = DateFormat('d MMM', isAr ? 'ar' : 'en').format(_startDate);
    final endStr = DateFormat('d MMM', isAr ? 'ar' : 'en').format(_endDate);
    return '$startStr - $endStr';
  }

  String _formatMoney(double amount, {bool showSign = false}) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final symbol = _currencyCode == 'EGP'
        ? (isAr ? 'ج.م' : 'EGP')
        : getCurrencySymbol(_currencyCode, isAr: isAr);
    final formattedNumber = NumberFormat('#,##0', isAr ? 'ar' : 'en').format(amount.abs());
    final sign = showSign ? (amount >= 0 ? '+' : '-') : '';
    return isAr ? '$sign$formattedNumber $symbol' : '$sign$symbol $formattedNumber';
  }

  BoxDecoration _glassCardDecoration(bool isDarkMode) {
    return AppSurfaces.cardDecoration(isDarkMode: isDarkMode, radius: 24);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 28;
    final isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF09090C) : const Color(0xFFF8F8FA),
      appBar: AppBar(
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 52,
        leadingWidth: 58,
        leading: const AppGlassBackButton(),
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final offset =
                _scrollController.hasClients ? _scrollController.offset : 0.0;
            final progress = ((offset - 16.0) / 38.0).clamp(0.0, 1.0);
            if (progress <= 0.0) return const SizedBox.shrink();
            final curve = Curves.easeOutCubic.transform(progress);

            // Travels in along continuous diagonal trajectory
            final incomingX =
                isAr ? (1.0 - curve) * 60.0 : -(1.0 - curve) * 60.0;
            final incomingY = (1.0 - curve) * 12.0;
            final incomingScale = 0.85 + 0.15 * curve;

            return Transform.translate(
              offset: Offset(incomingX, incomingY),
              child: Transform.scale(
                scale: incomingScale,
                child: Opacity(
                  opacity: progress,
                  child: Text(
                    isAr ? 'التحليلات' : 'Analytics',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF09090B),
                      fontFamily: isAr ? 'Cairo' : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        flexibleSpace: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final offset =
                _scrollController.hasClients ? _scrollController.offset : 0.0;
            final progress = ((offset - 10.0) / 35.0).clamp(0.0, 1.0);
            if (progress <= 0.0) return const SizedBox.shrink();
            return ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 20.0 * progress,
                  sigmaY: 20.0 * progress,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: (isDarkMode
                            ? const Color(0xFF09090C)
                            : const Color(0xFFF8F8FA))
                        .withValues(alpha: 0.82 * progress),
                    border: Border(
                      bottom: BorderSide(
                        color: (isDarkMode ? Colors.white : Colors.black)
                            .withValues(alpha: 0.06 * progress),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppResponsive.isTablet(context) ? 48 : 20,
          0,
          AppResponsive.isTablet(context) ? 48 : 20,
          bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Large Animated Hero Title (Settings style)
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final offset =
                    _scrollController.hasClients ? _scrollController.offset : 0.0;
                final progress = (offset / 48.0).clamp(0.0, 1.0);
                final curve = Curves.easeOutCubic.transform(progress);
                final deltaX = isAr ? -curve * 30.0 : curve * 30.0;
                final deltaY = -curve * 10.0;
                final scale = 1.0 - 0.12 * curve;
                final opacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);

                return Transform.translate(
                  offset: Offset(deltaX, deltaY),
                  child: Transform.scale(
                    scale: scale,
                    alignment:
                        isAr ? Alignment.centerRight : Alignment.centerLeft,
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 16),
                child: Text(
                  isAr ? 'التحليلات' : 'Analytics',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.15,
                    color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                    fontFamily: isAr ? 'Cairo' : null,
                  ),
                ),
              ),
            ),

            // 2. Control Row: [All Accounts Menu] + [Date Range Selector Pill]
            _buildControlFiltersRow(isDarkMode, isAr, isIOS),

            const SizedBox(height: 24),

            // 3. Money Flow Section Header (Clean Title as in reference image)
            Text(
              isAr ? 'تدفق الأموال' : 'Money Flow',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDarkMode ? const Color(0xFFEDEDF0) : const Color(0xFF0F172A),
                fontFamily: isAr ? 'Cairo' : null,
              ),
            ),

            const SizedBox(height: 14),

            // 4. Hero Spent Card with Interactive Bar Graph (ابراج graph)
            _buildSpentHeroBarCard(isDarkMode, isAr, isIOS),

            const SizedBox(height: 16),

            // 5. Two-Column Row: Income & Net Cashflow Cards
            _buildIncomeAndCashflowRow(isDarkMode, isAr),

            const SizedBox(height: 16),

            // 6. Saving Rate Card
            _buildSavingRateCard(isDarkMode, isAr, isIOS),

            const SizedBox(height: 28),

            // 7. Monthly Budget Section (Card or CTA Button Thil)
            _buildBudgetSection(isDarkMode, isAr, isIOS),
          ],
        ),
      ),
    );
  }

  //#region 2. Filter Controls: Account Menu + Date Selector Pill
  Widget _buildControlFiltersRow(bool isDarkMode, bool isAr, bool isIOS) {
    final pillBg = isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final pillBorder = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.06);
    final textPrimary = isDarkMode ? const Color(0xFFF4F4F5) : const Color(0xFF18181B);
    final iconColor = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final chevronColor = isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA);

    final selectedAcc = _selectedAccount;
    final accLabel = selectedAcc.isAll
        ? (isAr ? 'كل الحسابات' : 'All Accounts')
        : (isAr && selectedAcc.id == 'bank'
            ? 'بنك مصر'
            : (isAr && selectedAcc.id == 'cash'
                ? 'المحفظة النقدية'
                : (isAr && selectedAcc.id == 'ewallet'
                    ? 'المحفظة الإلكترونية'
                    : selectedAcc.name)));

    return Row(
      children: [
        // 1. Account Selector Pill (iOS Native UIMenu / Android Popup)
        Flexible(
          child: NeoSingleTapContextMenu(
            isDark: isDarkMode,
            actions: _buildAccountMenuItems(isAr),
            onSelected: (id) {
              HapticFeedback.selectionClick();
              setState(() => _selectedAccountId = id);
            },
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: pillBorder, width: 0.7),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selectedAcc.icon,
                    size: 14.5,
                    color: iconColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      accLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        letterSpacing: -0.2,
                        fontFamily: isAr ? 'Cairo' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 10,
                    color: chevronColor,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 2. Date Range Selector Pill (Cupertino Calendar Popover / Date Picker)
        InkWell(
          onTap: () => _pickDate(isDarkMode, isAr, isIOS),
          borderRadius: BorderRadius.circular(100),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            key: _dateButtonKey,
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: pillBorder, width: 0.7),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 14,
                  color: iconColor,
                ),
                const SizedBox(width: 6),
                Text(
                  _formattedDateRange,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    letterSpacing: -0.2,
                    fontFamily: isAr ? 'Cairo' : null,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  CupertinoIcons.chevron_down,
                  size: 10,
                  color: chevronColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  //#endregion



  //#region 4. Hero Card: Spent with Bar Graph (الأبراج)
  Widget _buildSpentHeroBarCard(bool isDarkMode, bool isAr, bool isIOS) {
    final textPrimary = isDarkMode ? const Color(0xFFEDEDF0) : const Color(0xFF0F172A);
    final textSecondary = isDarkMode ? const Color(0xFF8A8A96) : const Color(0xFF64748B);
    final bars = _scaledBars;
    final maxVal = bars.reduce((a, b) => a > b ? a : b);
    final activeSpent = _currentSpent;

    return Container(
      width: double.infinity,
      decoration: _glassCardDecoration(isDarkMode),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Spent" label
          Text(
            isAr ? 'المصروفات' : 'Spent',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textSecondary,
              fontFamily: isAr ? 'Cairo' : null,
            ),
          ),

          const SizedBox(height: 6),

          // Total Spent Amount Display (e.g. EGP 19,725)
          Text(
            _formatMoney(activeSpent),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: textPrimary,
              fontFamily: isAr ? 'Cairo' : null,
            ),
          ),

          const SizedBox(height: 22),

          // 7 Minimalist Rounded Bars as in reference
          SizedBox(
            height: 38,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final barVal = bars[index];
                final normalized = maxVal > 0 ? (barVal / maxVal).clamp(0.08, 1.0) : 0.08;
                final isLast = index == 6;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    height: 38 * normalized,
                    decoration: BoxDecoration(
                      color: isLast
                          ? (isDarkMode ? Colors.white : const Color(0xFF18181B))
                          : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  //#endregion

  //#region 5. Row: Income & Net Cashflow Cards
  Widget _buildIncomeAndCashflowRow(bool isDarkMode, bool isAr) {
    final income = _currentIncome;
    final cashflow = _currentNetCashflow;
    final spent = _currentSpent;
    final isSurplus = cashflow >= 0;
    final textPrimary = isDarkMode ? const Color(0xFFEDEDF0) : const Color(0xFF0F172A);
    final textSecondary = isDarkMode ? const Color(0xFF8A8A96) : const Color(0xFF64748B);

    return Row(
      children: [
        // 1. Income Card
        Expanded(
          child: Container(
            height: 152,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: _glassCardDecoration(isDarkMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'الدخل' : 'Income',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                    fontFamily: isAr ? 'Cairo' : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatMoney(income),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: textPrimary,
                    fontFamily: isAr ? 'Cairo' : null,
                  ),
                ),
                const Spacer(),
                // Single solid thick green bar
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B569),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 14),

        // 2. Net Cashflow Card
        Expanded(
          child: Container(
            height: 152,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: _glassCardDecoration(isDarkMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'صافي التدفق' : 'Net cashflow',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                    fontFamily: isAr ? 'Cairo' : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatMoney(cashflow),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: textPrimary,
                    fontFamily: isAr ? 'Cairo' : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSurplus ? (isAr ? 'إيجابي' : 'Positive') : (isAr ? 'سلبي' : 'Negative'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSurplus ? const Color(0xFF00B569) : const Color(0xFFF43F5E),
                    fontFamily: isAr ? 'Cairo' : null,
                  ),
                ),
                const Spacer(),
                // Dual comparison bars: Green (Income) over Red (Spent on gray track)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B569),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 5,
                        width: double.infinity,
                        color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        child: FractionallySizedBox(
                          alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                          widthFactor: income > 0 ? (spent / income).clamp(0.08, 1.0) : 0.82,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF43F5E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  //#endregion

  //#region 6. Saving Rate Card
  Widget _buildSavingRateCard(bool isDarkMode, bool isAr, bool isIOS) {
    final rate = _currentSavingRate;
    final income = _currentIncome;
    final spent = _currentSpent;
    final textPrimary = isDarkMode ? const Color(0xFFEDEDF0) : const Color(0xFF0F172A);
    final textSecondary = isDarkMode ? const Color(0xFF8A8A96) : const Color(0xFF64748B);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        _showSavingRateDetailsModal(isDarkMode, isAr, isIOS);
      },
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: _glassCardDecoration(isDarkMode),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'معدل الادخار' : 'Savings rate',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                    fontFamily: isAr ? 'Cairo' : null,
                  ),
                ),
                Icon(
                  isAr ? CupertinoIcons.chevron_left : CupertinoIcons.chevron_right,
                  size: 16,
                  color: textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // "17% of what you earned"
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${rate.toInt()}% ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      color: textPrimary,
                      fontFamily: isAr ? 'Cairo' : null,
                    ),
                  ),
                  TextSpan(
                    text: isAr ? 'مما كسبته' : 'of what you earned',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                      fontFamily: isAr ? 'Cairo' : null,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Horizontal Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 6,
                width: double.infinity,
                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                child: FractionallySizedBox(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                  widthFactor: (rate / 100).clamp(0.03, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B569),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // "Spent EGP 19,725 of EGP 23,880"
            Text(
              isAr
                  ? 'أنفقت ${_formatMoney(spent)} من أصل ${_formatMoney(income)}'
                  : 'Spent ${_formatMoney(spent)} of ${_formatMoney(income)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textSecondary,
                fontFamily: isAr ? 'Cairo' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavingRateDetailsModal(bool isDarkMode, bool isAr, bool isIOS) {
    if (isIOS) {
      final sheetController = GlassModalSheetController();
      GlassModalSheet.present(
        context: context,
        controller: sheetController,
        halfSize: 0.72,
        fullSize: 0.92,
        initialState: GlassSheetState.half,
        showDragIndicator: true,
        builder: (sheetContext) => Material(
          type: MaterialType.transparency,
          child: _buildSavingRateModalContent(
            sheetContext: sheetContext,
            isDarkMode: isDarkMode,
            isAr: isAr,
            isIOS: true,
          ),
        ),
      );
    } else {
      final sheetBg = isDarkMode ? const Color(0xFF0C0C0E) : const Color(0xFFF4F5F8);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              color: sheetBg,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.88,
              ),
              child: _buildSavingRateModalContent(
                sheetContext: sheetContext,
                isDarkMode: isDarkMode,
                isAr: isAr,
                isIOS: false,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildSavingRateModalContent({
    required BuildContext sheetContext,
    required bool isDarkMode,
    required bool isAr,
    required bool isIOS,
  }) {
    final rate = _currentSavingRate;
    final income = _currentIncome;
    final monthStr = DateFormat('MMMM yyyy', isAr ? 'ar' : 'en').format(_startDate);

    final cardBg = isDarkMode ? const Color(0xFF18181B) : Colors.white;
    final cardBorder = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final textPrimary = isDarkMode ? const Color(0xFFEDEDF0) : const Color(0xFF0F172A);
    final textSecondary = isDarkMode ? const Color(0xFF8A8A96) : const Color(0xFF64748B);
    final dragHandleColor = isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8);
    final trackColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF1F1F5);

    final categories = SpendingBreakdownSeed.getCategories(_currencyCode);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Android only drag handle (iOS GlassModalSheet renders its own native drag indicator)
          if (!isIOS) ...[
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: dragHandleColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ] else ...[
            const SizedBox(height: 6),
          ],

          // Date Tag: [Clock Icon] October 2026
          Row(
            children: [
              Icon(
                CupertinoIcons.clock,
                size: 14.5,
                color: textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                monthStr,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  fontFamily: isAr ? 'Cairo' : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Top Hero Card: "17% kept of the EGP 23,880 that came in"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cardBorder, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${rate.toInt()}% ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: textPrimary,
                      fontFamily: isAr ? 'Cairo' : null,
                    ),
                  ),
                  TextSpan(
                    text: isAr
                        ? 'تم توفيرها من أصل ${_formatMoney(income)} دخلت محفظتك'
                        : 'kept of the ${_formatMoney(income)} that came in',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontFamily: isAr ? 'Cairo' : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Section Title: "Where it goes"
          Text(
            isAr ? 'أين تذهب أموالك' : 'Where it goes',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: textPrimary,
              fontFamily: isAr ? 'Cairo' : null,
            ),
          ),

          const SizedBox(height: 14),

          // Categories Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cardBorder, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < categories.length; i++) ...[
                  _buildSpendingCategoryRow(
                    category: categories[i],
                    isDarkMode: isDarkMode,
                    isAr: isAr,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    trackColor: trackColor,
                  ),
                  if (i < categories.length - 1) const SizedBox(height: 18),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSpendingCategoryRow({
    required SpendingCategoryItem category,
    required bool isDarkMode,
    required bool isAr,
    required Color textPrimary,
    required Color textSecondary,
    required Color trackColor,
  }) {
    final meta = CategoryIconHelper.getMeta(category.categoryId, category.nameEn);
    final catColor = category.color;
    final catIcon = meta.icon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: isDarkMode ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Icon(
                  catIcon,
                  size: 16,
                  color: catColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category.localizedName(isAr),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.2,
                  fontFamily: isAr ? 'Cairo' : null,
                ),
              ),
            ),
            Text(
              '${category.percentage.toInt()}%',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: textSecondary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatMoney(category.amount),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.2,
                fontFamily: isAr ? 'Cairo' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 4.5,
            child: LinearProgressIndicator(
              value: (category.percentage / 100).clamp(0.01, 1.0),
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation<Color>(catColor),
            ),
          ),
        ),
      ],
    );
  }
  //#endregion

  //#region 7. Monthly Budget Section (Card or CTA Button Thil)
  Widget _buildBudgetSection(bool isDarkMode, bool isAr, bool isIOS) {
    final hasBudget = _budgetData != null && _budgetData!.monthlyBudget > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'الميزانية الشهرية' : 'Monthly Budget',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDarkMode ? const Color(0xFFEDEDF0) : const Color(0xFF0F172A),
            fontFamily: isAr ? 'Cairo' : null,
          ),
        ),
        const SizedBox(height: 14),
        hasBudget
            ? _buildActiveBudgetCard(isDarkMode, isAr, isIOS)
            : _buildSetBudgetCtaCard(isDarkMode, isAr, isIOS),
      ],
    );
  }

  // Active Budget Overview Card
  Widget _buildActiveBudgetCard(bool isDarkMode, bool isAr, bool isIOS) {
    final budget = _budgetData!.monthlyBudget;
    final spent = _budgetData!.currentSpending > 0 ? _budgetData!.currentSpending : _currentSpent;
    final remaining = budget - spent;
    final ratio = (spent / budget).clamp(0.0, 1.0);
    final percent = (ratio * 100).toInt();

    final cardDecoration = AppSurfaces.cardDecoration(isDarkMode: isDarkMode, radius: 24);
    final textPrimary = isDarkMode ? const Color(0xFFEDEDF0) : const Color(0xFF141416);
    final textSecondary = isDarkMode ? const Color(0xFF8A8A96) : const Color(0xFF71717A);

    final isExceeded = spent > budget;
    final progressColor = isExceeded
        ? const Color(0xFFF43F5E)
        : const Color(0xFF10B981);

    return Container(
      width: double.infinity,
      decoration: cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'الميزانية الشهرية' : 'Monthly Budget',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                      fontFamily: isAr ? 'Cairo' : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoney(budget),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 10,
              width: double.infinity,
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              child: FractionallySizedBox(
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                widthFactor: ratio.clamp(0.02, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr
                    ? (remaining >= 0
                        ? 'متبقي: ${_formatMoney(remaining)}'
                        : 'تجاوزت الميزانية بـ ${_formatMoney(remaining.abs())}')
                    : (remaining >= 0
                        ? 'Remaining: ${_formatMoney(remaining)}'
                        : 'Over budget by ${_formatMoney(remaining.abs())}'),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: remaining >= 0 ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                  fontFamily: isAr ? 'Cairo' : null,
                ),
              ),
              // Edit Budget Action Button
              InkWell(
                onTap: () => _showSetBudgetDialog(isDarkMode, isAr, isIOS),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAr ? 'تعديل' : 'Edit',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: isAr ? 'Cairo' : null,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        isAr ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                        size: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // No Budget Set -> Call-to-action Card with Prominent Button ("button thil")
  Widget _buildSetBudgetCtaCard(bool isDarkMode, bool isAr, bool isIOS) {
    final textPrimary = isDarkMode ? const Color(0xFFEDEDF0) : const Color(0xFF141416);
    final textSecondary = isDarkMode ? const Color(0xFF8A8A96) : const Color(0xFF71717A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: _glassCardDecoration(isDarkMode),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1C1C24) : const Color(0xFFF1F1F5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 24,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isAr ? 'لم تحدد ميزانية شهرية بعد' : 'No Monthly Budget Set',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              fontFamily: isAr ? 'Cairo' : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isAr
                ? 'حدد سقفاً شهرياً للإنفاق لتتبع مصاريفك وتحقيق أهدافك'
                : 'Set a monthly spending limit to control your cash flow',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: textSecondary,
              fontFamily: isAr ? 'Cairo' : null,
            ),
          ),
          const SizedBox(height: 20),
          // Prominent Button ("button تقيل")
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                _showSetBudgetDialog(isDarkMode, isAr, isIOS);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.white : const Color(0xFF09090C),
                foregroundColor: isDarkMode ? const Color(0xFF09090C) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'تحديد ميزانية شهرية' : 'Set Monthly Budget',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFamily: isAr ? 'Cairo' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  //#endregion

  //#region Account Menu Items & Native iOS Menu
  List<NeoContextMenuAction> _buildAccountMenuItems(bool isAr) {
    return _accounts.map((acc) {
      final isSelected = acc.id == _selectedAccountId;
      final accName = acc.isAll
          ? (isAr ? 'كل الحسابات' : 'All Accounts')
          : (isAr && acc.id == 'bank'
              ? 'بنك مصر'
              : (isAr && acc.id == 'cash'
                  ? 'المحفظة النقدية'
                  : (isAr && acc.id == 'ewallet'
                      ? 'المحفظة الإلكترونية'
                      : acc.name)));

      String? sfSymbol;
      if (acc.id == 'all') {
        sfSymbol = 'tray.full';
      } else if (acc.id == 'bank') {
        sfSymbol = 'building.columns';
      } else if (acc.id == 'cash') {
        sfSymbol = 'banknote';
      } else if (acc.id == 'ewallet') {
        sfSymbol = 'creditcard';
      }

      return NeoContextMenuAction(
        id: acc.id,
        title: accName,
        icon: acc.icon,
        iconSystemName: sfSymbol,
        showTrailingCheckmark: isSelected,
      );
    }).toList();
  }
  //#endregion

  //#region Month Picker (iOS Cupertino Month-Year Wheel Picker / Android DatePicker)
  Future<void> _pickDate(bool isDarkMode, bool isAr, bool isIOS) async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    if (isIOS) {
      int tempYear = _startDate.year > currentYear ? currentYear : _startDate.year;
      int tempMonth = _startDate.month;
      if (tempYear == currentYear && tempMonth > currentMonth) {
        tempMonth = currentMonth;
      }

      final months = isAr
          ? [
              'يناير',
              'فبراير',
              'مارس',
              'أبريل',
              'مايو',
              'يونيو',
              'يوليو',
              'أغسطس',
              'سبتمبر',
              'أكتوبر',
              'نوفمبر',
              'ديسمبر'
            ]
          : [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December'
            ];

      // Years only up to currentYear (no future years)
      final years = List.generate(6, (i) => (currentYear - 5) + i);

      int initialYearIdx = years.indexOf(tempYear);
      if (initialYearIdx < 0) initialYearIdx = years.indexOf(currentYear);
      if (initialYearIdx < 0) initialYearIdx = years.length - 1;

      final monthController = FixedExtentScrollController(initialItem: (tempMonth - 1).clamp(0, 11));
      final yearController = FixedExtentScrollController(initialItem: initialYearIdx);

      final picked = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (ctx) {
          final bg = isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
          final textPrimary = isDarkMode ? Colors.white : const Color(0xFF09090B);
          final textSecondary = isDarkMode ? const Color(0xFF8E8E93) : const Color(0xFF6C6C70);

          return StatefulBuilder(
            builder: (ctx, setModalState) {
              final isFutureSelected = (tempYear == currentYear && tempMonth > currentMonth) || (tempYear > currentYear);

              return Container(
                height: 310,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      // Header Bar
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : Colors.black.withValues(alpha: 0.08),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                isAr ? 'إلغاء' : 'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: isAr ? 'Cairo' : null,
                                ),
                              ),
                            ),
                            Text(
                              isAr ? 'تحديد الشهر' : 'Select Month',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                                letterSpacing: -0.3,
                                fontFamily: isAr ? 'Cairo' : null,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: isFutureSelected
                                  ? null
                                  : () {
                                      HapticFeedback.selectionClick();
                                      Navigator.pop(ctx, DateTime(tempYear, tempMonth, 1));
                                    },
                              child: Text(
                                isAr ? 'تم' : 'Done',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isFutureSelected
                                      ? (isDarkMode ? Colors.white24 : Colors.black26)
                                      : (isDarkMode ? Colors.white : Colors.black),
                                  fontFamily: isAr ? 'Cairo' : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Wheels Row
                      Expanded(
                        child: Row(
                          children: [
                            // Month Picker Wheel
                            Expanded(
                              flex: 3,
                              child: CupertinoPicker(
                                scrollController: monthController,
                                itemExtent: 40,
                                useMagnifier: true,
                                magnification: 1.15,
                                selectionOverlay: Container(
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.07)
                                        : Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onSelectedItemChanged: (idx) {
                                  final selectedM = idx + 1;
                                  if (tempYear == currentYear && selectedM > currentMonth) {
                                    HapticFeedback.lightImpact();
                                    setModalState(() {
                                      tempMonth = currentMonth;
                                    });
                                    Future.delayed(const Duration(milliseconds: 120), () {
                                      if (monthController.hasClients) {
                                        monthController.animateToItem(
                                          currentMonth - 1,
                                          duration: const Duration(milliseconds: 260),
                                          curve: Curves.easeOutBack,
                                        );
                                      }
                                    });
                                  } else {
                                    HapticFeedback.selectionClick();
                                    setModalState(() {
                                      tempMonth = selectedM;
                                    });
                                  }
                                },
                                children: List.generate(12, (idx) {
                                  final isItemFuture = tempYear == currentYear && (idx + 1) > currentMonth;

                                  return Center(
                                    child: Text(
                                      months[idx],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isItemFuture
                                            ? (isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8))
                                            : textPrimary,
                                        fontFamily: isAr ? 'Cairo' : null,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),

                            // Year Picker Wheel (Max currentYear)
                            Expanded(
                              flex: 2,
                              child: CupertinoPicker(
                                scrollController: yearController,
                                itemExtent: 40,
                                useMagnifier: true,
                                magnification: 1.15,
                                selectionOverlay: Container(
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.07)
                                        : Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onSelectedItemChanged: (idx) {
                                  final y = years[idx];
                                  HapticFeedback.selectionClick();
                                  setModalState(() {
                                    tempYear = y;
                                    if (tempYear == currentYear && tempMonth > currentMonth) {
                                      tempMonth = currentMonth;
                                      if (monthController.hasClients) {
                                        monthController.animateToItem(
                                          currentMonth - 1,
                                          duration: const Duration(milliseconds: 250),
                                          curve: Curves.easeOut,
                                        );
                                      }
                                    }
                                  });
                                },
                                children: List.generate(years.length, (idx) {
                                  return Center(
                                    child: Text(
                                      '${years[idx]}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                        fontFamily: isAr ? 'Cairo' : null,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

      if (picked != null) {
        HapticFeedback.selectionClick();
        final isCurrentMonth = picked.year == now.year && picked.month == now.month;
        final lastDayOfMonth = DateTime(picked.year, picked.month + 1, 0);
        setState(() {
          _startDate = DateTime(picked.year, picked.month, 1);
          _endDate = isCurrentMonth ? now : lastDayOfMonth;
        });
      }
    } else {
      // Android
      final picked = await showDatePicker(
        context: context,
        initialDate: _startDate.isAfter(now) ? now : _startDate,
        firstDate: DateTime(2020),
        lastDate: now,
      );
      if (picked != null) {
        HapticFeedback.selectionClick();
        final isCurrentMonth = picked.year == now.year && picked.month == now.month;
        final lastDayOfMonth = DateTime(picked.year, picked.month + 1, 0);
        setState(() {
          _startDate = DateTime(picked.year, picked.month, 1);
          _endDate = isCurrentMonth ? now : lastDayOfMonth;
        });
      }
    }
  }
  //#endregion

  //#region Set Monthly Budget Modal Dialog
  //#region Set Monthly Budget (iOS Input Alert vs Android Modal Sheet)
  void _showSetBudgetDialog(bool isDarkMode, bool isAr, bool isIOS) {
    if (isIOS) {
      _showIOSBudgetInputDialog(isDarkMode, isAr);
    } else {
      _showAndroidBudgetModalSheet(isDarkMode, isAr);
    }
  }

  // 1. iOS: Native Input Alert Dialog (from neo_cupertino)
  Future<void> _showIOSBudgetInputDialog(bool isDarkMode, bool isAr) async {
    HapticFeedback.selectionClick();
    final currentVal = (_budgetData != null && _budgetData!.monthlyBudget > 0)
        ? _budgetData!.monthlyBudget.toInt().toString()
        : '';
    final hasActiveBudget = _budgetData != null && _budgetData!.monthlyBudget > 0;

    final result = await NeoNativeAlert.inputShow(
      context: context,
      title: isAr ? 'الميزانية الشهرية' : 'Monthly Budget',
      message: isAr
          ? 'أدخل سقف الإنفاق المستهدف لهذا الشهر:'
          : 'Enter your target monthly spending limit:',
      input: NeoAlertDialogInput(
        placeholder: isAr ? 'المبلغ (مثال: 25000)' : 'Amount (e.g. 25000)',
        initialValue: currentVal,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      isDark: isDarkMode,
      tint: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1E),
      actions: [
        DialogAction(
          title: isAr ? 'إلغاء' : 'Cancel',
          role: DialogActionRole.cancel,
          onPressed: () {},
        ),
        if (hasActiveBudget)
          DialogAction(
            title: isAr ? 'حذف الميزانية' : 'Remove',
            role: DialogActionRole.destructive,
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('user_has_set_monthly_budget', false);
              await prefs.remove('cached_budget');
              setState(() {
                _budgetData = null;
              });
              await _walletRepository.updateMonthlyBudget(0.0);
              WalletDataSyncService.notifyDataChanged();
              if (mounted) {
                MessageService.showSuccess(
                  context: context,
                  message: isAr ? 'تم حذف الميزانية' : 'Budget removed',
                );
              }
            },
          ),
        DialogAction(
          title: isAr ? 'حفظ' : 'Save',
          role: DialogActionRole.standard,
          onPressed: () {},
        ),
      ],
    );

    if (result != null && result.trim().isNotEmpty) {
      final parsed = double.tryParse(result.replaceAll(',', '').trim());
      if (parsed != null && parsed > 0) {
        HapticFeedback.mediumImpact();
        final updated = _budgetData != null
            ? _budgetData!.copyWith(monthlyBudget: parsed)
            : BudgetDto(
                monthlyBudget: parsed,
                currentSpending: _currentSpent,
                categoryBudgets: BudgetDto.defaultSeed().categoryBudgets,
              );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_has_set_monthly_budget', true);
        setState(() => _budgetData = updated);
        await _walletRepository.updateMonthlyBudget(parsed);
        await WalletCacheService.saveBudget(updated.toJson());
        WalletDataSyncService.notifyDataChanged();

        if (mounted) {
          MessageService.showSuccess(
            context: context,
            message: isAr ? 'تم حفظ الميزانية الشهرية بنجاح' : 'Monthly budget updated successfully',
          );
        }
      }
    }
  }

  // 2. Android: Bottom Modal Sheet
  void _showAndroidBudgetModalSheet(bool isDarkMode, bool isAr) {
    HapticFeedback.selectionClick();
    final currentVal = (_budgetData != null && _budgetData!.monthlyBudget > 0)
        ? _budgetData!.monthlyBudget.toInt().toString()
        : '24000';
    final controller = TextEditingController(text: currentVal);
    final textPrimary = isDarkMode ? const Color(0xFFEDEDF0) : const Color(0xFF141416);
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isAr ? 'تعيين الميزانية الشهرية' : 'Set Monthly Budget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  fontFamily: isAr ? 'Cairo' : null,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isAr ? 'أدخل المبلغ الإجمالي المستهدف للإنفاق هذا الشهر:' : 'Enter your target monthly spending limit:',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDarkMode ? const Color(0xFF8A8A96) : const Color(0xFF71717A),
                  fontFamily: isAr ? 'Cairo' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Amount Input Field
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1C1C24) : const Color(0xFFF1F1F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixText: _currencyCode,
                    suffixStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Preset Quick Chips
              Wrap(
                spacing: 8,
                children: [10000, 20000, 24000, 35000].map((preset) {
                  return ActionChip(
                    label: Text(
                      _formatMoney(preset.toDouble()),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      controller.text = preset.toString();
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Save Button & Reset
              Row(
                children: [
                  if (_budgetData != null && _budgetData!.monthlyBudget > 0)
                    TextButton(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(ctx);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('user_has_set_monthly_budget', false);
                        await prefs.remove('cached_budget');
                        setState(() {
                          _budgetData = null;
                        });
                        await _walletRepository.updateMonthlyBudget(0.0);
                        WalletDataSyncService.notifyDataChanged();
                        if (mounted) {
                          MessageService.showSuccess(
                            context: context,
                            message: isAr ? 'تم حذف الميزانية' : 'Budget removed',
                          );
                        }
                      },
                      child: Text(
                        isAr ? 'إلغاء الميزانية' : 'Remove',
                        style: const TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.w700),
                      ),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final parsed = double.tryParse(controller.text.replaceAll(',', ''));
                      if (parsed == null || parsed <= 0) return;
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);

                      final updated = _budgetData != null
                          ? _budgetData!.copyWith(monthlyBudget: parsed)
                          : BudgetDto(
                              monthlyBudget: parsed,
                              currentSpending: _currentSpent,
                              categoryBudgets: BudgetDto.defaultSeed().categoryBudgets,
                            );

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('user_has_set_monthly_budget', true);
                      setState(() => _budgetData = updated);
                      await _walletRepository.updateMonthlyBudget(parsed);
                      await WalletCacheService.saveBudget(updated.toJson());
                      WalletDataSyncService.notifyDataChanged();

                      if (mounted) {
                        MessageService.showSuccess(
                          context: context,
                          message: isAr ? 'تم حفظ الميزانية الشهرية بنجاح' : 'Monthly budget updated successfully',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.white : Colors.black,
                      foregroundColor: isDarkMode ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      isAr ? 'حفظ الميزانية' : 'Save Budget',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        fontFamily: isAr ? 'Cairo' : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  //#endregion
}
