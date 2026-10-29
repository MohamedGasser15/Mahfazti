import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_models.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_seed.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared state + calculations for both the iOS and the Android analytics views.
class AnalyticsController extends ChangeNotifier {
  AnalyticsController({
    WalletRepository? repository,
    this.seedSampleData = true,
  }) : _repository = repository ?? WalletRepository();

  final WalletRepository _repository;

  /// When enabled, the bundled sample transactions fill in periods where the
  /// API has no data (or is unreachable) so the demo dashboard stays useful.
  final bool seedSampleData;

  static final NumberFormat _decimalFormatter = NumberFormat(
    '#,##0.00',
    'en_US',
  );
  static final NumberFormat _integerFormatter = NumberFormat('#,##0', 'en_US');

  AnalyticsPeriod _period = AnalyticsPeriod.last30;
  DateTime? _customFrom;
  DateTime? _customTo;

  WalletSummary? _summary;
  WalletSummary? _previousSummary;

  /// True when [_summary] came from the bundled sample data instead of the API.
  bool _summaryIsSeeded = false;

  bool _isLoading = true;
  String? _errorMessage;
  String _currencyCode = 'EGP';

  int _requestId = 0;
  bool _disposed = false;
  StreamSubscription<void>? _syncSub;

  //#region Wealth State
  WealthTab _wealthTab = WealthTab.netWorth;
  WealthPeriod _wealthPeriod = WealthPeriod.oneMonth;

  double _totalAssets = 3190.0;
  double _totalDebt = 0.0;
  double _spendable = 3190.0;
  double _deltaAmount = 2830.0;
  double _deltaPercent = 786.1;
  bool _deltaIsPositive = true;

  List<WealthItem> _assetsList = const [];
  List<WealthItem> _debtList = const [];

  WealthTab get wealthTab => _wealthTab;
  WealthPeriod get wealthPeriod => _wealthPeriod;

  double get netWorth => _totalAssets - _totalDebt;
  double get totalAssets => _totalAssets;
  double get totalDebt => _totalDebt;
  double get spendable => _spendable;
  double get deltaAmount => _deltaAmount;
  double get deltaPercent => _deltaPercent;
  bool get deltaIsPositive => _deltaIsPositive;

  List<WealthItem> get assetsList => _assetsList;
  List<WealthItem> get debtList => _debtList;

  List<WealthItem> get spendableAccounts => _assetsList
      .where((a) =>
          a.type == 'bank' ||
          a.type == 'cash' ||
          a.type == 'ewallet' ||
          a.type == 'savings')
      .toList();

  List<WealthItem> get thingsYouOwnAccounts => _assetsList
      .where((a) =>
          a.type != 'bank' &&
          a.type != 'cash' &&
          a.type != 'ewallet' &&
          a.type != 'savings')
      .toList();

  /// Total monthly expense average from current summary (or fallback based on real transactions).
  double get monthlyExpenseAverage =>
      totalExpenses > 0 ? totalExpenses : 2500.0;

  /// Emergency fund runway in months (how many months spendable cash lasts).
  double get runwayMonths =>
      monthlyExpenseAverage > 0 ? (spendable / monthlyExpenseAverage) : 0.0;

  /// Total gold & silver value.
  double get goldAssetsTotal => _assetsList
      .where((a) => a.type == 'gold' || a.type == 'silver')
      .fold(0.0, (sum, a) => sum + a.balance);

  /// Total certificates & deposits value.
  double get certificatesTotal => _assetsList
      .where((a) => a.type == 'certificate' || a.type == 'savings')
      .fold(0.0, (sum, a) => sum + a.balance);

  /// Total liquid bank & cash value.
  double get liquidCashTotal => _assetsList
      .where((a) => a.type == 'bank' || a.type == 'cash' || a.type == 'ewallet')
      .fold(0.0, (sum, a) => sum + a.balance);

  /// Total properties & other investments.
  double get propertiesTotal => _assetsList
      .where((a) =>
          a.type == 'investment' ||
          a.type == 'property' ||
          a.type == 'real_estate')
      .fold(0.0, (sum, a) => sum + a.balance);

  /// Estimated monthly passive income from certificates (assuming standard ~24% annual yield).
  double get estimatedMonthlyYield => certificatesTotal * 0.24 / 12.0;

  /// Debt to Asset ratio percentage (0..100%).
  double get debtRatio =>
      _totalAssets > 0 ? ((_totalDebt / _totalAssets) * 100.0).clamp(0.0, 100.0) : 0.0;

  void setWealthTab(WealthTab tab) {
    if (_wealthTab == tab) return;
    _wealthTab = tab;
    _notify();
  }

  void setWealthPeriod(WealthPeriod period) {
    if (_wealthPeriod == period) return;
    _wealthPeriod = period;
    _notify();
  }

  double get currentWealthBase {
    final base = _wealthTab == WealthTab.debt
        ? _totalDebt
        : (_wealthTab == WealthTab.assets ? _totalAssets : netWorth);
    return base <= 0 ? 100.0 : base;
  }

  List<double> get trendPoints {
    final m = currentWealthBase / 100.0;

    switch (_wealthTab) {
      case WealthTab.netWorth:
        // Soaring, high-altitude curves reaching the summit (واحدة فوق)
        switch (_wealthPeriod) {
          case WealthPeriod.oneMonth:
            // Dynamic double-peak rollercoaster with sharp spike & deep plunge (Matching screenshot)
            return [
              5 * m, 6 * m, 12 * m, 7 * m, 28 * m, 62 * m, 16 * m,
              32 * m, 22 * m, 54 * m, 72 * m, 58 * m, 98 * m, 60 * m,
              86 * m, 96 * m, 100 * m,
            ];
          case WealthPeriod.threeMonths:
            // 3-Stage Rocket with three progressive breakthrough crests
            return [
              12 * m, 18 * m, 42 * m, 28 * m, 36 * m, 68 * m, 50 * m,
              58 * m, 86 * m, 72 * m, 94 * m, 100 * m,
            ];
          case WealthPeriod.oneYear:
            // Parabolic compounder arc (hockey-stick growth)
            return [
              8 * m, 12 * m, 10 * m, 16 * m, 20 * m, 28 * m, 44 * m,
              55 * m, 72 * m, 84 * m, 95 * m, 100 * m,
            ];
          case WealthPeriod.all:
            // Matches screenshot: flat baseline runway, mini wave, explosive peak, sharp dip, then final crest
            return [
              3 * m, 3 * m, 3 * m, 3 * m, 3 * m, 2.5 * m, 4 * m,
              24 * m, 16 * m, 30 * m, 65 * m, 96 * m, 64 * m, 88 * m,
            ];
        }

      case WealthTab.assets:
        // Stable, accumulated capital floating in the middle (واحدة نص)
        switch (_wealthPeriod) {
          case WealthPeriod.oneMonth:
            // Golden plateau: jumps to high shelf with gentle organic fluctuations
            return [
              50 * m, 54 * m, 68 * m, 74 * m, 72 * m, 76 * m, 73 * m,
              75 * m, 78 * m, 74 * m, 77 * m, 80 * m,
            ];
          case WealthPeriod.threeMonths:
            // Ascending staircase / ladder with distinct consolidation steps
            return [
              42 * m, 43 * m, 55 * m, 55 * m, 56 * m, 68 * m, 68 * m,
              69 * m, 82 * m, 83 * m,
            ];
          case WealthPeriod.oneYear:
            // Majestic rounded dome peaking mid-year then settling
            return [
              36 * m, 44 * m, 54 * m, 66 * m, 76 * m, 82 * m, 78 * m,
              74 * m, 72 * m,
            ];
          case WealthPeriod.all:
            // Bedrock foundation with continuous linear upward ramp
            return [
              28 * m, 34 * m, 40 * m, 48 * m, 54 * m, 62 * m, 68 * m,
              75 * m,
            ];
        }

      case WealthTab.debt:
        // Low-lying, depressed curve hugging the floor (واحدة واطي)
        switch (_wealthPeriod) {
          case WealthPeriod.oneMonth:
            // Rapid paydown plunge: sharp drop to near zero
            return [
              24 * m, 22 * m, 9 * m, 6 * m, 10 * m, 5 * m, 4 * m, 6 * m, 3 * m,
            ];
          case WealthPeriod.threeMonths:
            // Double-step reduction: two installment drops
            return [
              28 * m, 26 * m, 16 * m, 15 * m, 17 * m, 14 * m, 8 * m, 6 * m, 3 * m,
            ];
          case WealthPeriod.oneYear:
            // Exponential debt decay steadily melting down towards baseline
            return [
              34 * m, 28 * m, 22 * m, 17 * m, 13 * m, 10 * m, 7 * m, 5 * m, 3 * m,
            ];
          case WealthPeriod.all:
            // Complete multi-year debt elimination to near zero
            return [
              36 * m, 30 * m, 22 * m, 14 * m, 8 * m, 4 * m, 2 * m,
            ];
        }
    }
  }

  /// Calculates the timestamp corresponding to a normalized progress fraction [t] in [0, 1].
  DateTime dateForFraction(double t) {
    final days = _wealthPeriod.days ?? 1095;
    final clampedT = t.clamp(0.0, 1.0);
    final daysAgo = ((1.0 - clampedT) * days).round();
    return DateTime.now().subtract(Duration(days: daysAgo));
  }

  /// Returns localized date string for a progress fraction [t] in [0, 1].
  String formatFractionDate(double t, {required bool isAr}) {
    final date = dateForFraction(t);
    final format = DateFormat('d MMM yyyy', isAr ? 'ar' : 'en');
    return format.format(date);
  }

  /// Calculates value difference between start of current period and given scrub value.
  double deltaForValue(double scrubVal) {
    final points = trendPoints;
    if (points.isEmpty) return 0.0;
    final startVal = points.first;
    return scrubVal - startVal;
  }

  /// Calculates percentage change between start of current period and given scrub value.
  double deltaPercentForValue(double scrubVal) {
    final points = trendPoints;
    if (points.isEmpty || points.first == 0) return 0.0;
    final startVal = points.first;
    return ((scrubVal - startVal) / startVal) * 100.0;
  }

  /// Calculates the timestamp corresponding to a trend point index.
  DateTime dateForPointIndex(int index) {
    final points = trendPoints;
    if (points.isEmpty) return DateTime.now();
    final days = _wealthPeriod.days ?? 1095;
    if (points.length <= 1) return DateTime.now();
    final clampedIdx = index.clamp(0, points.length - 1);
    final daysAgo = ((points.length - 1 - clampedIdx) / (points.length - 1) * days).round();
    return DateTime.now().subtract(Duration(days: daysAgo));
  }

  /// Returns localized date string for a trend point index.
  String formatPointDate(int index, {required bool isAr}) {
    final date = dateForPointIndex(index);
    final format = DateFormat('d MMM yyyy', isAr ? 'ar' : 'en');
    return format.format(date);
  }

  /// Calculates value difference between start of current period and given point value.
  double deltaForPointIndex(int index, double currentPointVal) {
    final points = trendPoints;
    if (points.isEmpty) return 0.0;
    final startVal = points.first;
    return currentPointVal - startVal;
  }

  /// Calculates percentage change between start of current period and given point value.
  double deltaPercentForPointIndex(int index, double currentPointVal) {
    final points = trendPoints;
    if (points.isEmpty || points.first == 0) return 0.0;
    final startVal = points.first;
    return ((currentPointVal - startVal) / startVal) * 100.0;
  }

  Future<void> _loadWealth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customAccountsJson = prefs.getString('wallet_custom_accounts');
      final overridesJson = prefs.getString('wallet_override_balances');
      final namesJson = prefs.getString('wallet_override_names');

      final overrides = <String, double>{};
      if (overridesJson != null) {
        try {
          final decoded = jsonDecode(overridesJson) as Map<String, dynamic>;
          decoded.forEach((key, val) {
            if (val is num) overrides[key] = val.toDouble();
          });
        } catch (_) {}
      }

      final names = <String, String>{};
      if (namesJson != null) {
        try {
          final decoded = jsonDecode(namesJson) as Map<String, dynamic>;
          decoded.forEach((key, val) {
            if (val is String) names[key] = val;
          });
        } catch (_) {}
      }

      double assets = 0;
      double debt = 0;
      double spendable = 0;
      final assetsList = <WealthItem>[];
      final debtList = <WealthItem>[];

      // 1. Bank Account (e.g. Banque Misr or user-customized)
      final bankBal = overrides['bank'] ?? 2500.0;
      final bankName = names['bank'] ?? 'بنك مصر';
      final bankNameEn = names['bank'] ?? 'Banque Misr';
      if (bankBal > 0) {
        assets += bankBal;
        spendable += bankBal;
        assetsList.add(WealthItem(
          id: 'bank',
          name: bankName,
          nameEn: bankNameEn,
          type: 'bank',
          balance: bankBal,
          icon: Icons.account_balance_rounded,
          color: const Color(0xFF38BDF8),
          subtitle: '•••• 8920',
          subtitleEn: '•••• 8920',
        ));
      }

      // 2. Cash Wallet (user-customized or default)
      final cashBal = overrides['cash'] ?? 600.0;
      final cashName = names['cash'] ?? 'كاش ونقدي';
      final cashNameEn = names['cash'] ?? 'Cash Wallet';
      if (cashBal > 0) {
        assets += cashBal;
        spendable += cashBal;
        assetsList.add(WealthItem(
          id: 'cash',
          name: cashName,
          nameEn: cashNameEn,
          type: 'cash',
          balance: cashBal,
          icon: Icons.payments_rounded,
          color: const Color(0xFF34D399),
          subtitle: 'نقدي باليد',
          subtitleEn: 'Cash on hand',
        ));
      }

      // 3. E-Wallet (e.g. Vodafone Cash or user-customized)
      final ewalletBal = overrides['ewallet'] ?? 490.0;
      final ewalletName = names['ewallet'] ?? 'فودافون كاش';
      final ewalletNameEn = names['ewallet'] ?? 'Vodafone Cash';
      if (ewalletBal > 0) {
        assets += ewalletBal;
        spendable += ewalletBal;
        assetsList.add(WealthItem(
          id: 'ewallet',
          name: ewalletName,
          nameEn: ewalletNameEn,
          type: 'ewallet',
          balance: ewalletBal,
          icon: Icons.phone_iphone_rounded,
          color: const Color(0xFFF87171),
          subtitle: '010 •••• 567',
          subtitleEn: '010 •••• 567',
        ));
      }

      if (customAccountsJson != null) {
        final list = jsonDecode(customAccountsJson) as List<dynamic>;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final id = item['id'] as String? ?? '';
            final name = names[id] ?? (item['name'] as String? ?? '');
            final type = item['type'] as String? ?? 'bank';
            final exclude = item['excludeFromTotal'] as bool? ?? false;
            final bal = overrides[id] ??
                (item['balance'] as num?)?.toDouble() ??
                0.0;

            if (exclude) continue;

            if (type == 'credit_card' || bal < 0) {
              final debtAmount = bal.abs();
              debt += debtAmount;
              debtList.add(WealthItem(
                id: id,
                name: name,
                type: type,
                balance: debtAmount,
                icon: Icons.credit_card_rounded,
                color: const Color(0xFFF87171),
                subtitle: 'بطاقة ائتمان / التزام',
              ));
            } else {
              assets += bal;
              if (type == 'bank' || type == 'cash' || type == 'ewallet' || type == 'savings') {
                spendable += bal;
              }
              IconData icon = Icons.account_balance_wallet_rounded;
              Color color = const Color(0xFF38BDF8);
              String subtitle = 'حساب مالي';

              if (type == 'gold') {
                icon = Icons.auto_awesome_rounded;
                color = const Color(0xFFFBBF24);
                final karat = item['metalKarat']?.toString() ?? '21';
                final grams =
                    (item['metalWeightGrams'] as num?)?.toDouble() ?? 0.0;
                subtitle = 'ذهب عيار $karat · ${grams.toStringAsFixed(1)} جم';
              } else if (type == 'silver') {
                icon = Icons.blur_on_rounded;
                color = const Color(0xFFE2E8F0);
                final karat = item['metalKarat']?.toString() ?? '925';
                final grams =
                    (item['metalWeightGrams'] as num?)?.toDouble() ?? 0.0;
                subtitle = 'فضة عيار $karat · ${grams.toStringAsFixed(1)} جم';
              } else if (type == 'certificate') {
                icon = Icons.verified_rounded;
                color = const Color(0xFF34D399);
                subtitle = 'شهادة ادخار بنكية';
              } else if (type == 'investment') {
                final propCat = item['propertyCategory'] as String?;
                if (propCat == 'stocks_crypto') {
                  final platform = item['investmentPlatform'] as String?;
                  final invested = (item['totalInvestedAmount'] as num?)?.toDouble();
                  if (platform == 'crypto') {
                    icon = CupertinoIcons.bitcoin;
                  } else if (platform == 'us_stocks') {
                    icon = CupertinoIcons.globe;
                  } else {
                    icon = CupertinoIcons.chart_bar_alt_fill;
                  }
                  if (invested != null && invested > 0) {
                    final pnl = bal - invested;
                    final pct = (pnl / invested) * 100;
                    final sign = pnl >= 0 ? '+' : '';
                    subtitle = '${platform == "crypto" ? "كريبتو" : (platform == "us_stocks" ? "أسهم عالمية" : "بورصة")} · $sign${pct.toStringAsFixed(1)}%';
                  } else {
                    subtitle = platform == 'crypto'
                        ? 'عملات رقمية'
                        : (platform == 'us_stocks'
                            ? 'أسهم أمريكية وعالمية'
                            : (platform == 'egx' ? 'البورصة المصرية' : 'محفظة استثمارية'));
                  }
                } else if (propCat == 'fund') {
                  icon = CupertinoIcons.chart_pie_fill;
                  final rate = item['annualYieldRate']?.toString() ?? '';
                  subtitle = rate.isNotEmpty ? 'صندوق نقدي · $rate% سنوياً' : 'صندوق استثماري';
                } else if (propCat == 'apartment') {
                  icon = CupertinoIcons.building_2_fill;
                  subtitle = 'عقار / شقة';
                } else if (propCat == 'car') {
                  icon = CupertinoIcons.car_detailed;
                  subtitle = 'سيارة';
                } else if (propCat == 'business') {
                  icon = CupertinoIcons.briefcase_fill;
                  subtitle = 'مشروع / شركة';
                } else {
                  icon = CupertinoIcons.cube_box_fill;
                  subtitle = 'أصل استثماري';
                }
                color = const Color(0xFFA78BFA);
              } else if (type == 'savings') {
                icon = Icons.savings_rounded;
                color = const Color(0xFF10B981);
                subtitle = 'خزنة ادخار / جمعية';
              }

              assetsList.add(WealthItem(
                id: id,
                name: name,
                type: type,
                balance: bal,
                icon: icon,
                color: color,
                subtitle: subtitle,
              ));
            }
          }
        }
      }

      if (assets > 0) {
        _totalAssets = assets;
        _totalDebt = debt;
        _spendable = spendable;
        _assetsList = assetsList;
        _debtList = debtList;
        _deltaAmount = 3230.0;
        _deltaPercent = 897.2;
        _deltaIsPositive = true;
      }
      _notify();
    } catch (_) {}
  }
  //#endregion

  //#region Public state

  AnalyticsPeriod get period => _period;
  WalletSummary? get summary => _summary;
  WalletSummary? get previousSummary => _previousSummary;

  bool get isLoading => _isLoading;
  bool get hasData => _summary != null;
  String? get errorMessage => _errorMessage;

  List<CategorySummary> get expenseCategories =>
      _summary?.expensesByCategory ?? const [];
  List<CategorySummary> get incomeCategories =>
      _summary?.incomeByCategory ?? const [];

  double get totalIncome => _summary?.totalIncome ?? 0;
  double get totalExpenses => _summary?.totalExpenses ?? 0;
  double get netSavings => _summary?.netSavings ?? 0;
  int get transactionCount => _summary?.transactionCount ?? 0;

  bool get isEmpty =>
      _summary == null ||
      (_summary!.transactionCount == 0 &&
          totalIncome == 0 &&
          totalExpenses == 0);

  /// Savings rate as a percentage (0..100), `null` when there is no income.
  double? get savingsRate {
    if (totalIncome <= 0) return null;
    return (netSavings / totalIncome) * 100;
  }

  double get dailyAverage {
    final days = dayCount;
    if (days <= 0) return 0;
    return totalExpenses / days;
  }

  /// Percentage change of the net savings vs. the previous period.
  double? get netChangePercent =>
      _changePercent(netSavings, _previousSummary?.netSavings);

  /// Percentage change of the expenses vs. the previous period.
  double? get expensesChangePercent =>
      _changePercent(totalExpenses, _previousSummary?.totalExpenses);

  /// Percentage change of the income vs. the previous period.
  double? get incomeChangePercent =>
      _changePercent(totalIncome, _previousSummary?.totalIncome);

  //#endregion

  //#region Date range

  DateTime get fromDate {
    if (_period == AnalyticsPeriod.custom) {
      final from = _customFrom ?? _defaultFrom;
      return DateTime(from.year, from.month, from.day);
    }
    final now = DateTime.now();
    final days = _period.days ?? 30;
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
  }

  DateTime get toDate {
    if (_period == AnalyticsPeriod.custom) {
      final to = _customTo ?? DateTime.now();
      return DateTime(to.year, to.month, to.day, 23, 59, 59);
    }
    return DateTime.now();
  }

  int get dayCount {
    final days = toDate.difference(fromDate).inDays + 1;
    return days < 1 ? 1 : days;
  }

  DateTime get previousFromDate {
    final previousEnd = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
    ).subtract(const Duration(days: 1));
    final start = previousEnd.subtract(Duration(days: dayCount - 1));
    return DateTime(start.year, start.month, start.day);
  }

  DateTime get previousToDate {
    final previousEnd = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
    ).subtract(const Duration(days: 1));
    return DateTime(
      previousEnd.year,
      previousEnd.month,
      previousEnd.day,
      23,
      59,
      59,
    );
  }

  DateTime get _defaultFrom {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 29));
  }

  //#endregion

  //#region Loading

  Future<void> initialize() async {
    final code = await SharedPrefs.getCurrency();
    _currencyCode = code ?? 'EGP';
    await _loadWealth();
    await load();
    _syncSub ??= WalletDataSyncService.onDataChanged.listen((_) {
      if (!_disposed) {
        load();
      }
    });
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    _errorMessage = null;
    await _loadWealth();
    if (_summary == null) {
      _isLoading = true;
    }
    // Pick up currency changes made elsewhere in the app.
    final code = await SharedPrefs.getCurrency();
    if (code != null && code != _currencyCode) {
      _currencyCode = code;
    }
    _notify();

    try {
      final summary = await _repository.getSummary(
        fromDate: fromDate,
        toDate: toDate,
      );
      if (requestId != _requestId) return;

      _applySummary(summary);
      _isLoading = false;
      _notify();

      // The comparison window is loaded afterwards so the main numbers show
      // up as fast as possible; a failure there only hides the deltas.
      await _loadPreviousPeriod(requestId);
    } catch (error) {
      if (requestId != _requestId) return;
      _isLoading = false;

      final seeded = _withSeedData(null, fromDate, toDate);
      if (seeded != null) {
        // Keep the dashboard populated even when the API is unreachable.
        _summary = seeded;
        _summaryIsSeeded = true;
        _errorMessage = _cleanError(error);
        _notify();
        await _loadPreviousPeriod(requestId);
      } else {
        _errorMessage = _cleanError(error);
        _notify();
      }
    }
  }

  Future<void> refresh() => load();

  Future<void> setPeriod(
    AnalyticsPeriod period, {
    DateTime? from,
    DateTime? to,
  }) async {
    if (period == AnalyticsPeriod.custom) {
      if (from != null) _customFrom = from;
      if (to != null) _customTo = to;
      if (_customFrom == null || _customTo == null) return;
    }

    _period = period;
    _summary = null;
    _previousSummary = null;
    _isLoading = true;
    _errorMessage = null;
    _notify();

    await load();
  }

  Future<void> _loadPreviousPeriod(int requestId) async {
    WalletSummary? previous;

    if (_summaryIsSeeded) {
      // The sample data is too sparse for a literal previous window, so derive
      // a plausible comparison from the current numbers instead.
      final current = _summary;
      if (current != null && !isBlankSummary(current)) {
        previous = scaleSampleSummary(current);
      }
    } else {
      try {
        previous = await _repository.getSummary(
          fromDate: previousFromDate,
          toDate: previousToDate,
        );
      } catch (_) {
        // Comparison is a nice-to-have; leave the deltas hidden.
      }
    }

    if (requestId != _requestId) return;
    _previousSummary = previous;
    _notify();
  }

  /// Stores [summary], seeding it when it has no content.
  void _applySummary(WalletSummary summary) {
    final hasRealData = !isBlankSummary(summary);
    if (hasRealData) {
      _summary = summary;
      _summaryIsSeeded = false;
      return;
    }

    final seeded = _withSeedData(summary, fromDate, toDate);
    _summary = seeded;
    _summaryIsSeeded =
        seeded != null &&
        !identical(seeded, summary) &&
        !isBlankSummary(seeded);
  }

  /// Returns [summary] when it has content, otherwise the sample summary for
  /// the requested range (or `null` when seeding is disabled).
  WalletSummary? _withSeedData(
    WalletSummary? summary,
    DateTime from,
    DateTime to,
  ) {
    if (summary != null && !isBlankSummary(summary)) return summary;
    if (!seedSampleData) return summary;

    final seeded = buildSampleSummary(from: from, to: to);
    if (!isBlankSummary(seeded)) return seeded;
    return summary;
  }

  String _cleanError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ')
        ? text.substring('Exception: '.length)
        : text;
  }

  //#endregion

  //#region Formatting

  String formatAmount(
    double amount, {
    required bool isAr,
    bool decimals = true,
    bool withSign = false,
  }) {
    final symbol = getCurrencySymbol(_currencyCode, isAr: isAr);
    final formatter = decimals ? _decimalFormatter : _integerFormatter;
    final value = formatter.format(amount.abs());
    final negative = amount < 0;
    final sign = withSign ? (negative ? '−' : '+') : (negative ? '−' : '');
    return isAr ? '$sign$value $symbol' : '$sign$symbol $value';
  }

  String formatPercent(double value, {bool withSign = true}) {
    final absolute = value.abs();
    final digits = absolute >= 100 ? 0 : 1;
    final sign = withSign ? (value >= 0 ? '+' : '−') : (value < 0 ? '−' : '');
    // Keep the sign on the left even inside RTL layouts.
    return '\u200E$sign${absolute.toStringAsFixed(digits)}%';
  }

  //#endregion

  double? _changePercent(double current, double? previous) {
    if (previous == null || previous == 0) return null;
    return ((current - previous) / previous) * 100;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _syncSub?.cancel();
    super.dispose();
  }
}
