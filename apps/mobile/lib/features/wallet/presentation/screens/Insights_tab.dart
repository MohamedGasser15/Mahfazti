import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:shimmer/shimmer.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  final WalletRepository _repository = WalletRepository();

  bool _isLoading = true;
  String? _errorMessage;
  String _currencyCode = 'USD';

  // بيانات الشهر الحالي
  double _totalExpenses = 0;
  double _totalIncome = 0;
  List<Map<String, dynamic>> _topCategories = [];
  double _highestTransaction = 0;
  String _highestTransactionCategory = '';

  // بيانات الشهر اللي فات للمقارنة
  double _lastMonthExpenses = 0;

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'EGP': 'E£',
    'SAR': '﷼',
    'AED': 'د.إ',
    'KWD': 'د.ك',
  };

  @override
  void initState() {
    super.initState();
    _init();
  }

Future<void> _init() async {
  final code = await SharedPrefs.getCurrency();
  if (mounted) {
    setState(() => _currencyCode = code ?? 'USD');
    await _loadData();
  }
}

Future<void> _loadData({bool forceRefresh = false}) async {
  // 1. جرب الـ cache الأول
  if (!forceRefresh) {
    final cachedCurrent = await WalletCacheService.getInsightsCurrent();
    final cachedLast = await WalletCacheService.getInsightsLast();

    if (cachedCurrent != null && cachedLast != null) {
      _applyData(cachedCurrent, cachedLast);
      setState(() => _isLoading = false);
      // refresh في الـ background
      _refreshInBackground();
      return;
    }
  }

  // 2. مفيش cache أو force refresh
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });
  await _fetchFromApi();
}

Future<void> _fetchFromApi({bool silent = false}) async {
  try {
    final now = DateTime.now();

    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 1)
        .subtract(const Duration(days: 1));
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 1)
        .subtract(const Duration(days: 1));

    final results = await Future.wait([
      _repository.getSummary(fromDate: thisMonthStart, toDate: thisMonthEnd),
      _repository.getSummary(fromDate: lastMonthStart, toDate: lastMonthEnd),
    ]);

    final current = results[0];
    final last = results[1];

    // تحويل للـ map عشان نحفظه في الـ cache
    final currentMap = {
      'totalIncome': current.totalIncome,
      'totalExpenses': current.totalExpenses,
      'netSavings': current.netSavings,
      'expensesByCategory': current.expensesByCategory
          .map((e) => {
                'nameAr': e.categoryNameAr,
                'nameEn': e.categoryNameEn,
                'total': e.total,
              })
          .toList(),
    };

    final lastMap = {
      'totalExpenses': last.totalExpenses,
    };

    // حفظ في الـ cache
    await WalletCacheService.saveInsightsCurrent(currentMap);
    await WalletCacheService.saveInsightsLast(lastMap);

    if (mounted) {
      _applyData(currentMap, lastMap);
      if (!silent) setState(() => _isLoading = false);
    }
  } catch (e) {
    if (mounted && !silent) {
      setState(() {
        _errorMessage = 'Failed to load insights: $e';
        _isLoading = false;
      });
    }
  }
}

Future<void> _refreshInBackground() async {
  try {
    await _fetchFromApi(silent: true);
  } catch (_) {}
}

void _applyData(
  Map<String, dynamic> currentMap,
  Map<String, dynamic> lastMap,
) {
  final expenses = (currentMap['expensesByCategory'] as List)
      .map((e) => e as Map<String, dynamic>)
      .toList()
    ..sort((a, b) =>
        (b['total'] as num).compareTo(a['total'] as num));

  double highest = 0;
  String highestCat = '';
  if (expenses.isNotEmpty) {
    highest = (expenses.first['total'] as num).toDouble();
    highestCat = expenses.first['nameEn'] as String;
  }

  setState(() {
    _totalExpenses = (currentMap['totalExpenses'] as num).toDouble();
    _totalIncome = (currentMap['totalIncome'] as num).toDouble();
    _topCategories = expenses.take(3).toList();
    _highestTransaction = highest;
    _highestTransactionCategory = highestCat;
    _lastMonthExpenses = (lastMap['totalExpenses'] as num).toDouble();
  });
}
  String _formatCurrency(double amount) {
    final symbol = currencySymbols[_currencyCode] ?? '\$';
    final formatter = NumberFormat('#,##0', 'en_US');
    return '$symbol ${formatter.format(amount)}';
  }

  double get _dailyAverage {
    final day = DateTime.now().day;
    return day > 0 ? _totalExpenses / day : 0;
  }

  double get _expenseVsLastMonth {
    if (_lastMonthExpenses == 0) return 0;
    return ((_totalExpenses - _lastMonthExpenses) / _lastMonthExpenses) * 100;
  }

  // ── Shimmer ──────────────────────────────────────────
  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: Platform.isIOS ? 110 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // month label
            Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 20),
            // 2 stat cards
            Row(children: [
              Expanded(child: _shimmerCard(isDark, height: 110)),
              const SizedBox(width: 12),
              Expanded(child: _shimmerCard(isDark, height: 110)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _shimmerCard(isDark, height: 110)),
              const SizedBox(width: 12),
              Expanded(child: _shimmerCard(isDark, height: 110)),
            ]),
            const SizedBox(height: 28),
            // section title
            Container(
                width: 160,
                height: 18,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 14),
            // 3 category rows
            ...List.generate(
                3, (_) => _shimmerCategoryRow(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCard(bool isDark, {double height = 110}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _shimmerCategoryRow(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Spending Insights',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
         IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black),
            onPressed: () => _loadData(forceRefresh: true),
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmer(isDark)
          : _errorMessage != null
              ? _buildError(isDark)
              : _buildContent(isDark),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64,
                color: isDark ? Colors.white54 : Colors.black38),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy').format(now);
    final diff = _expenseVsLastMonth;
    final isUp = diff >= 0;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: Platform.isIOS ? 110 : 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month label
          Text(
            monthLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),

          const SizedBox(height: 20),

          // ── 4 stat cards ──────────────────────────
          Row(children: [
            Expanded(
              child: _statCard(
                isDark: isDark,
                icon: Icons.trending_down_rounded,
                iconColor: Colors.red,
                label: 'This Month',
                value: _formatCurrency(_totalExpenses),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                isDark: isDark,
                icon: Icons.trending_up_rounded,
                iconColor: Colors.green,
                label: 'Income',
                value: _formatCurrency(_totalIncome),
              ),
            ),
          ]),

          const SizedBox(height: 12),

          Row(children: [
            Expanded(
              child: _statCard(
                isDark: isDark,
                icon: Icons.calendar_today_rounded,
                iconColor: Colors.blue,
                label: 'Daily Avg',
                value: _formatCurrency(_dailyAverage),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                isDark: isDark,
                icon: isUp
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                iconColor: isUp ? Colors.orange : Colors.green,
                label: 'vs Last Month',
                value: _lastMonthExpenses == 0
                    ? 'No data'
                    : '${isUp ? '+' : ''}${diff.toStringAsFixed(1)}%',
                valueColor: _lastMonthExpenses == 0
                    ? null
                    : (isUp ? Colors.orange : Colors.green),
              ),
            ),
          ]),

          const SizedBox(height: 28),

          // ── Top spending categories ───────────────
          Text(
            'Top Spending Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 14),

          if (_topCategories.isEmpty)
            _emptyState(isDark, 'No expenses this month')
          else
            ..._topCategories.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final cat = entry.value;
              final locale =
                  Localizations.localeOf(context).languageCode;
              final name = locale == 'ar'
                  ? cat['nameAr'] as String
                  : cat['nameEn'] as String;
              final total = cat['total'] as double;
              final percent = _totalExpenses > 0
                  ? (total / _totalExpenses * 100)
                  : 0.0;

              return _categoryRow(
                isDark: isDark,
                rank: rank,
                name: name,
                total: total,
                percent: percent,
              );
            }),

          const SizedBox(height: 28),

          // ── Quick facts ───────────────────────────
          Text(
            'Quick Facts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 14),

          _factCard(
            isDark: isDark,
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.deepOrange,
            title: 'Biggest spend',
            subtitle: _highestTransactionCategory.isEmpty
                ? 'No data'
                : '$_highestTransactionCategory — ${_formatCurrency(_highestTransaction)}',
          ),

          const SizedBox(height: 10),

          _factCard(
            isDark: isDark,
            icon: Icons.savings_rounded,
            iconColor: Colors.teal,
            title: 'Net savings',
            subtitle: _formatCurrency(_totalIncome - _totalExpenses),
            subtitleColor: (_totalIncome - _totalExpenses) >= 0
                ? Colors.green[700]
                : Colors.red[700],
          ),

          const SizedBox(height: 10),

          _factCard(
            isDark: isDark,
            icon: Icons.compare_arrows_rounded,
            iconColor: Colors.purple,
            title: 'Last month expenses',
            subtitle: _lastMonthExpenses == 0
                ? 'No data'
                : _formatCurrency(_lastMonthExpenses),
          ),
        ],
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────

  Widget _statCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valueColor ??
                  (isDark ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow({
    required bool isDark,
    required int rank,
    required String name,
    required double total,
    required double percent,
  }) {
    final colors = [Colors.red, Colors.orange, Colors.amber];
    final color = colors[(rank - 1).clamp(0, 2)];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rank badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(total),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    '${percent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              backgroundColor:
                  isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _factCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: subtitleColor ??
                        (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(bool isDark, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}