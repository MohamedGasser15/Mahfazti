import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neo_cupertino/neo_cupertino.dart';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/presentation/utils/category_icon_helper.dart';

//#region Models
class CategoryTransactionItem {
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;

  const CategoryTransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
  });
}

class SpendingCategoryItem {
  final String id;
  final int? categoryId;
  final String nameAr;
  final String nameEn;
  final String emoji;
  final IconData icon;
  final Color color;
  final double amount;
  final int transactionCount;
  final double percentage;
  final List<CategoryTransactionItem> transactions;

  const SpendingCategoryItem({
    required this.id,
    this.categoryId,
    required this.nameAr,
    required this.nameEn,
    this.emoji = '',
    required this.icon,
    required this.color,
    required this.amount,
    required this.transactionCount,
    required this.percentage,
    this.transactions = const [],
  });

  SpendingCategoryItem copyWith({
    String? id,
    int? categoryId,
    String? nameAr,
    String? nameEn,
    String? emoji,
    IconData? icon,
    Color? color,
    double? amount,
    int? transactionCount,
    double? percentage,
    List<CategoryTransactionItem>? transactions,
  }) {
    return SpendingCategoryItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      emoji: emoji ?? this.emoji,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      amount: amount ?? this.amount,
      transactionCount: transactionCount ?? this.transactionCount,
      percentage: percentage ?? this.percentage,
      transactions: transactions ?? this.transactions,
    );
  }

  String localizedName(bool isAr) => isAr ? nameAr : nameEn;
}
//#endregion

//#region Seed Data
class SpendingBreakdownSeed {
  static List<SpendingCategoryItem> getCategories(String currency) {
    return [
      SpendingCategoryItem(
        id: 'shopping',
        nameAr: 'تسوق ومستلزمات',
        nameEn: 'Shopping',
        emoji: '🛒',
        icon: Icons.shopping_bag_rounded,
        color: const Color(0xFFF59E0B), // Warm Amber
        amount: 6395.0,
        transactionCount: 21,
        percentage: 34.0,
        transactions: [
          CategoryTransactionItem(
            title: 'Untitled',
            subtitle: 'Oct 27 · Microbus',
            amount: 50.0,
            date: DateTime(2026, 10, 27),
          ),
          CategoryTransactionItem(
            title: 'برجر',
            subtitle: 'Oct 25 · Microbus',
            amount: 200.0,
            date: DateTime(2026, 10, 25),
          ),
          CategoryTransactionItem(
            title: 'مخبز',
            subtitle: 'Oct 23 · Microbus',
            amount: 100.0,
            date: DateTime(2026, 10, 23),
          ),
          CategoryTransactionItem(
            title: 'حاجات افريكانو لجيسي',
            subtitle: 'Oct 20 · Microbus',
            amount: 110.0,
            date: DateTime(2026, 10, 20),
          ),
          CategoryTransactionItem(
            title: 'حاجه حلوه',
            subtitle: 'Oct 18 · Microbus',
            amount: 200.0,
            date: DateTime(2026, 10, 18),
          ),
          CategoryTransactionItem(
            title: 'عيش و جبن',
            subtitle: 'Oct 17 · Microbus',
            amount: 300.0,
            date: DateTime(2026, 10, 17),
          ),
          CategoryTransactionItem(
            title: 'حاجه حلوه',
            subtitle: 'Oct 17 · Microbus',
            amount: 50.0,
            date: DateTime(2026, 10, 17),
          ),
          CategoryTransactionItem(
            title: 'لبن',
            subtitle: 'Oct 16 · Microbus',
            amount: 55.0,
            date: DateTime(2026, 10, 16),
          ),
          CategoryTransactionItem(
            title: 'Untitled',
            subtitle: 'Oct 13 · Microbus',
            amount: 800.0,
            date: DateTime(2026, 10, 13),
          ),
          CategoryTransactionItem(
            title: 'مشتريات كارفور',
            subtitle: 'Oct 10 · Microbus',
            amount: 1250.0,
            date: DateTime(2026, 10, 10),
          ),
          CategoryTransactionItem(
            title: 'ملابس شتوية',
            subtitle: 'Oct 08 · Microbus',
            amount: 1850.0,
            date: DateTime(2026, 10, 8),
          ),
          CategoryTransactionItem(
            title: 'مستلزمات منزلية',
            subtitle: 'Oct 05 · Microbus',
            amount: 430.0,
            date: DateTime(2026, 10, 5),
          ),
          CategoryTransactionItem(
            title: 'صيدلية العزبي',
            subtitle: 'Oct 03 · Microbus',
            amount: 250.0,
            date: DateTime(2026, 10, 3),
          ),
          CategoryTransactionItem(
            title: 'مشتريات سوبرماركت',
            subtitle: 'Oct 02 · Microbus',
            amount: 380.0,
            date: DateTime(2026, 10, 2),
          ),
          CategoryTransactionItem(
            title: 'إكسسوارات موبايل',
            subtitle: 'Oct 01 · Microbus',
            amount: 320.0,
            date: DateTime(2026, 10, 1),
          ),
        ],
      ),
      SpendingCategoryItem(
        id: 'food',
        nameAr: 'طعام ومطاعم',
        nameEn: 'Food',
        emoji: '🍔',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFEA580C), // Deep Coral / Red-Orange
        amount: 3140.0,
        transactionCount: 13,
        percentage: 17.0,
        transactions: [
          CategoryTransactionItem(
            title: 'وجبة غداء عمل',
            subtitle: 'Oct 26 · Microbus',
            amount: 420.0,
            date: DateTime(2026, 10, 26),
          ),
          CategoryTransactionItem(
            title: 'مطعم كرم الشام',
            subtitle: 'Oct 22 · Microbus',
            amount: 650.0,
            date: DateTime(2026, 10, 22),
          ),
          CategoryTransactionItem(
            title: 'قهوة ستاربكس',
            subtitle: 'Oct 19 · Microbus',
            amount: 180.0,
            date: DateTime(2026, 10, 19),
          ),
          CategoryTransactionItem(
            title: 'بيتزا هت',
            subtitle: 'Oct 15 · Microbus',
            amount: 540.0,
            date: DateTime(2026, 10, 15),
          ),
          CategoryTransactionItem(
            title: 'مشروبات وعصائر',
            subtitle: 'Oct 12 · Microbus',
            amount: 150.0,
            date: DateTime(2026, 10, 12),
          ),
          CategoryTransactionItem(
            title: 'إفطار صباحي',
            subtitle: 'Oct 09 · Microbus',
            amount: 220.0,
            date: DateTime(2026, 10, 9),
          ),
        ],
      ),
      SpendingCategoryItem(
        id: 'education',
        nameAr: 'تعليم وتطوير',
        nameEn: 'Education',
        emoji: '🎓',
        icon: Icons.school_rounded,
        color: const Color(0xFF00B074), // Emerald Green
        amount: 3100.0,
        transactionCount: 11,
        percentage: 16.0,
        transactions: [
          CategoryTransactionItem(
            title: 'دورة برمجة متقدمة',
            subtitle: 'Oct 24 · Banque Misr',
            amount: 1500.0,
            date: DateTime(2026, 10, 24),
          ),
          CategoryTransactionItem(
            title: 'اشتراك منصة تعليمية',
            subtitle: 'Oct 18 · Banque Misr',
            amount: 600.0,
            date: DateTime(2026, 10, 18),
          ),
          CategoryTransactionItem(
            title: 'كتب ومراجع هندسية',
            subtitle: 'Oct 11 · Banque Misr',
            amount: 700.0,
            date: DateTime(2026, 10, 11),
          ),
          CategoryTransactionItem(
            title: 'أدوات دراسية',
            subtitle: 'Oct 04 · Banque Misr',
            amount: 300.0,
            date: DateTime(2026, 10, 4),
          ),
        ],
      ),
      SpendingCategoryItem(
        id: 'car',
        nameAr: 'مصاريف سيارة',
        nameEn: 'Car Things',
        emoji: '🚗',
        icon: Icons.directions_car_rounded,
        color: const Color(0xFF00C5C8), // Turquoise Cyan
        amount: 2000.0,
        transactionCount: 3,
        percentage: 11.0,
        transactions: [
          CategoryTransactionItem(
            title: 'صيانة وتغيير زيت',
            subtitle: 'Oct 21 · Cash Wallet',
            amount: 1400.0,
            date: DateTime(2026, 10, 21),
          ),
          CategoryTransactionItem(
            title: 'غسيل وتلميع سيارة',
            subtitle: 'Oct 14 · Cash Wallet',
            amount: 250.0,
            date: DateTime(2026, 10, 14),
          ),
          CategoryTransactionItem(
            title: 'مستلزمات سيارة',
            subtitle: 'Oct 07 · Cash Wallet',
            amount: 350.0,
            date: DateTime(2026, 10, 7),
          ),
        ],
      ),
      SpendingCategoryItem(
        id: 'electricity',
        nameAr: 'كهرباء وفواتير',
        nameEn: 'Electricity',
        emoji: '⚡',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFFB923C), // Bright Amber
        amount: 1050.0,
        transactionCount: 2,
        percentage: 6.0,
        transactions: [
          CategoryTransactionItem(
            title: 'فاتورة كهرباء شهر أكتوبر',
            subtitle: 'Oct 20 · Banque Misr',
            amount: 850.0,
            date: DateTime(2026, 10, 20),
          ),
          CategoryTransactionItem(
            title: 'شحن كارت مسبق الدفع',
            subtitle: 'Oct 05 · Banque Misr',
            amount: 200.0,
            date: DateTime(2026, 10, 5),
          ),
        ],
      ),
      SpendingCategoryItem(
        id: 'transport',
        nameAr: 'مواصلات',
        nameEn: 'Transportation',
        emoji: '🚙',
        icon: Icons.commute_rounded,
        color: const Color(0xFF3B82F6), // Royal Blue
        amount: 720.0,
        transactionCount: 8,
        percentage: 4.0,
        transactions: [
          CategoryTransactionItem(
            title: 'مشوار أوبر',
            subtitle: 'Oct 26 · Microbus',
            amount: 140.0,
            date: DateTime(2026, 10, 26),
          ),
          CategoryTransactionItem(
            title: 'تذكرة قطار',
            subtitle: 'Oct 22 · Microbus',
            amount: 180.0,
            date: DateTime(2026, 10, 22),
          ),
          CategoryTransactionItem(
            title: 'مشوار تاكسي',
            subtitle: 'Oct 16 · Microbus',
            amount: 90.0,
            date: DateTime(2026, 10, 16),
          ),
        ],
      ),
      SpendingCategoryItem(
        id: 'fuel',
        nameAr: 'بنزين ووقود',
        nameEn: 'Fuel',
        emoji: '⛽',
        icon: Icons.local_gas_station_rounded,
        color: const Color(0xFF8B4513), // Saddle Brown
        amount: 650.0,
        transactionCount: 1,
        percentage: 3.0,
        transactions: [
          CategoryTransactionItem(
            title: 'تفويلة بنزين 95',
            subtitle: 'Oct 19 · Cash Wallet',
            amount: 650.0,
            date: DateTime(2026, 10, 19),
          ),
        ],
      ),
      SpendingCategoryItem(
        id: 'entertainment',
        nameAr: 'ترفيه واشتراكات',
        nameEn: 'Entertainment',
        emoji: '🎬',
        icon: Icons.sports_esports_rounded,
        color: const Color(0xFF8B5CF6), // Purple
        amount: 545.0,
        transactionCount: 3,
        percentage: 3.0,
        transactions: [
          CategoryTransactionItem(
            title: 'تذاكر سينما',
            subtitle: 'Oct 24 · Microbus',
            amount: 280.0,
            date: DateTime(2026, 10, 24),
          ),
          CategoryTransactionItem(
            title: 'اشتراك منصة ترفيهية',
            subtitle: 'Oct 15 · Microbus',
            amount: 265.0,
            date: DateTime(2026, 10, 15),
          ),
        ],
      ),
      SpendingCategoryItem(
        id: 'health',
        nameAr: 'صحة وعناية',
        nameEn: 'Health & Medical',
        emoji: '🏥',
        icon: Icons.medical_services_rounded,
        color: const Color(0xFFEC4899), // Pink
        amount: 350.0,
        transactionCount: 2,
        percentage: 2.0,
        transactions: [
          CategoryTransactionItem(
            title: 'أدوية وفيتامينات',
            subtitle: 'Oct 17 · Microbus',
            amount: 220.0,
            date: DateTime(2026, 10, 17),
          ),
          CategoryTransactionItem(
            title: 'فحص دوري',
            subtitle: 'Oct 06 · Microbus',
            amount: 130.0,
            date: DateTime(2026, 10, 6),
          ),
        ],
      ),
      SpendingCategoryItem(
        id: 'others',
        nameAr: 'أخرى ومتنوعات',
        nameEn: 'Other',
        emoji: '📦',
        icon: Icons.category_rounded,
        color: const Color(0xFF6B7280), // Neutral Grey
        amount: 500.0,
        transactionCount: 2,
        percentage: 2.0,
        transactions: [
          CategoryTransactionItem(
            title: 'مشتريات متنوعة',
            subtitle: 'Oct 12 · Cash Wallet',
            amount: 300.0,
            date: DateTime(2026, 10, 12),
          ),
          CategoryTransactionItem(
            title: 'مستلزمات مكتبية',
            subtitle: 'Oct 08 · Cash Wallet',
            amount: 200.0,
            date: DateTime(2026, 10, 8),
          ),
        ],
      ),
      SpendingCategoryItem(
        id: 'tech',
        nameAr: 'خدمات إلكترونية',
        nameEn: 'Digital Services',
        emoji: '💻',
        icon: Icons.devices_rounded,
        color: const Color(0xFF0EA5E9), // Sky Blue
        amount: 400.0,
        transactionCount: 2,
        percentage: 2.0,
        transactions: [
          CategoryTransactionItem(
            title: 'خدمات سحابية',
            subtitle: 'Oct 16 · Banque Misr',
            amount: 250.0,
            date: DateTime(2026, 10, 16),
          ),
          CategoryTransactionItem(
            title: 'تطبيقات وبرامج',
            subtitle: 'Oct 03 · Banque Misr',
            amount: 150.0,
            date: DateTime(2026, 10, 3),
          ),
        ],
      ),
    ];
  }
}
//#endregion

//#region Main Screen
class SpendingBreakdownScreen extends StatefulWidget {
  final String currency;
  static ScrollController? debugScrollController;

  const SpendingBreakdownScreen({
    super.key,
    this.currency = 'EGP',
  });

  /// Opens the Glass Modal Sheet on iOS matching the edit category logic
  /// (starts half-expanded, draggable to full screen).
  static void openCategorySheet({
    required BuildContext context,
    required SpendingCategoryItem category,
    required DateTime date,
    String currency = 'EGP',
  }) {
    final sheetController = GlassModalSheetController();
    GlassModalSheet.present(
      context: context,
      controller: sheetController,
      halfSize: 0.62,
      fullSize: 0.88,
      initialState: GlassSheetState.half,
      showDragIndicator: true,
      builder: (sheetContext) => Material(
        type: MaterialType.transparency,
        child: _CategoryTransactionsContent(
          category: category,
          currency: currency,
          date: date,
          isModal: true,
        ),
      ),
    );
  }

  @override
  State<SpendingBreakdownScreen> createState() => _SpendingBreakdownScreenState();
}

class _SpendingBreakdownScreenState extends State<SpendingBreakdownScreen> {
  final WalletRepository _walletRepository = WalletRepository();
  StreamSubscription<void>? _syncSubscription;
  DateTime _selectedDate = DateTime(2026, 10, 1);
  List<SpendingCategoryItem> _categories = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SpendingBreakdownScreen.debugScrollController = _scrollController;
    // Initial optimistic population so test and UI start with instant data
    _categories = SpendingBreakdownSeed.getCategories(widget.currency);
    _loadData();
    _syncSubscription = WalletDataSyncService.onDataChanged.listen((_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    final fromDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final toDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

    try {
      final summary = await _walletRepository.getSummary(fromDate: fromDate, toDate: toDate);
      final total = summary.totalExpenses;

      final items = <SpendingCategoryItem>[];
      for (final cat in summary.expensesByCategory) {
        final meta = CategoryIconHelper.getMeta(cat.categoryId, cat.categoryNameEn);
        final pct = total > 0 ? (cat.total / total) * 100 : 0.0;

        items.add(SpendingCategoryItem(
          id: cat.categoryId.toString(),
          categoryId: cat.categoryId,
          nameAr: cat.categoryNameAr,
          nameEn: cat.categoryNameEn,
          emoji: '',
          icon: meta.icon,
          color: meta.color,
          amount: cat.total,
          transactionCount: cat.count,
          percentage: pct,
        ));
      }

      if (mounted) {
        setState(() {
          _categories = items;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    SpendingBreakdownScreen.debugScrollController = null;
    _scrollController.dispose();
    super.dispose();
  }

  double get _totalSpent => _categories.fold(0.0, (s, c) => s + c.amount);

  bool get _canGoNext {
    final maxDate = DateTime(2026, 10, 1);
    return _selectedDate.isBefore(maxDate);
  }

  bool get _canGoPrevious {
    final minDate = DateTime(2025, 1, 1);
    return _selectedDate.isAfter(minDate);
  }

  void _previousMonth() {
    if (!_canGoPrevious) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
    _loadData();
  }

  void _nextMonth() {
    if (!_canGoNext) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
    _loadData();
  }

  Future<void> _openCategoryDetail(SpendingCategoryItem category) async {
    HapticFeedback.selectionClick();
    final fromDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final toDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

    List<CategoryTransactionItem> mappedTx = category.transactions;

    // Fetch dynamic transactions from WalletRepository if category has an ID
    if (category.categoryId != null) {
      try {
        final res = await _walletRepository.getTransactions(
          categoryId: category.categoryId,
          fromDate: fromDate,
          toDate: toDate,
          pageSize: 50,
        );
        if (res.transactions.isNotEmpty) {
          mappedTx = res.transactions.map((t) {
            final dateStr = DateFormat('MMM dd').format(t.transactionDate);
            final desc = (t.description != null && t.description!.isNotEmpty) ? ' · ${t.description}' : '';
            return CategoryTransactionItem(
              title: t.title,
              subtitle: '$dateStr$desc',
              amount: t.amount,
              date: t.transactionDate,
            );
          }).toList();
        }
      } catch (_) {}
    }

    final itemWithTx = category.copyWith(transactions: mappedTx);

    if (!mounted) return;

    if (Platform.isAndroid) {
      // Android: full page route without modal sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryTransactionsScreen(
            category: itemWithTx,
            currency: widget.currency,
            date: _selectedDate,
          ),
        ),
      );
    } else {
      // iOS: GlassModalSheet matching edit category logic (opens half first, draggable to full)
      SpendingBreakdownScreen.openCategorySheet(
        context: context,
        category: itemWithTx,
        date: _selectedDate,
        currency: widget.currency,
      );
    }
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${widget.currency} ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isIOS = Platform.isIOS;
    final monthFormat = DateFormat('MMMM yyyy', isAr ? 'ar' : 'en_US');
    final monthStr = monthFormat.format(_selectedDate);

    // Warm Apple System Grouped Background in Light Mode (#F2F2F7), True Obsidian in Dark Mode
    final bgScaffold = isDarkMode ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgScaffold,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Unified Full-Page Scroll View (Whole page scrolls together with the Pie Chart)
            CustomScrollView(
              controller: _scrollController,
              physics: isIOS
                  ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
                  : const ClampingScrollPhysics(),
              slivers: [
                // 1. Pinned Sliver App Bar (Header stays cleanly pinned so back button is always accessible)
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: bgScaffold,
                  leadingWidth: 70,
                  leading: Center(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 16),
                      child: _buildCircleGlassButton(
                        context: context,
                        icon: appBackIcon(isIOS: isIOS, isRtl: isAr),
                        onPressed: () => Navigator.maybePop(context),
                        isDarkMode: isDarkMode,
                        isIOS: isIOS,
                      ),
                    ),
                  ),
                  title: Text(
                    isAr ? 'توزيع المصروفات' : 'Spending Breakdown',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: textPrimary,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 16),
                        child: _buildCircleGlassButton(
                          context: context,
                          icon: isIOS ? CupertinoIcons.line_horizontal_3 : Icons.menu_rounded,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                          },
                          isDarkMode: isDarkMode,
                          isIOS: isIOS,
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Account Selector Subheader
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 10),
                      child: Text(
                        isAr ? 'جميع الحسابات' : 'All accounts',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Main Donut Chart (Scrolls naturally with the rest of the page!)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(220, 220),
                              painter: _SpendingDonutChartPainter(
                                categories: _categories,
                                strokeWidth: 32,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cardBg,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatAmount(_totalSpent),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isAr ? 'إجمالي المصروف' : 'Total spent',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),

                // 4. Inset White / Obsidian Category Breakdown Card (Not full-width, matches reference layout)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                          itemCount: _categories.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.06),
                          ),
                          itemBuilder: (context, index) {
                            final item = _categories[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _openCategoryDetail(item),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
                                  child: Row(
                                    children: [
                                      // Colored Dot indicator
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: item.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Category Icon (Our Mahfazti Icon)
                                      Icon(
                                        item.icon,
                                        size: 20,
                                        color: isDarkMode
                                            ? const Color(0xFFD4D4D8)
                                            : const Color(0xFF3F3F46),
                                      ),
                                      const SizedBox(width: 12),

                                      // Category Name & Transactions
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.localizedName(isAr),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              isAr
                                                  ? '${item.transactionCount} معاملة · ${item.percentage.toInt()}%'
                                                  : '${item.transactionCount} transactions · ${item.percentage.toInt()}%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Amount
                                      Text(
                                        _formatAmount(item.amount),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Space for floating month selector when scrolled to bottom
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: (MediaQuery.of(context).padding.bottom > 0
                            ? MediaQuery.of(context).padding.bottom + 16
                            : 32) + 64,
                  ),
                ),
              ],
            ),

            // 5. Floating Bottom Month Selector (Buttons spaced out across width: [<] [October 2026] [>])
            Positioned(
              left: 29,
              right: 29,
              bottom: (MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 24) -
                  4,
              child: _buildMonthSelector(
                context: context,
                isDarkMode: isDarkMode,
                isAr: isAr,
                isIOS: isIOS,
                monthStr: monthStr,
                textPrimary: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Liquid Glass Button Builder for Circular Controls
  Widget _buildCircleGlassButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDarkMode,
    required bool isIOS,
  }) {
    if (isIOS) {
      final glassSettings = isDarkMode
          ? LiquidGlassSettings.ios27Dark.copyWith(
              glassColor: const Color(0x18FFFFFF),
              frostOpacity: 0.65,
            )
          : LiquidGlassSettings.ios27Light.copyWith(
              glassColor: const Color(0x80F8F8F8),
              frostOpacity: 0.65,
            );

      return GlassButton(
        width: 44,
        height: 44,
        shape: const LiquidOval(),
        useOwnLayer: true,
        quality: GlassQuality.premium,
        settings: glassSettings,
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        icon: Icon(
          icon,
          size: 20,
          color: isDarkMode ? Colors.white : const Color(0xFF18181B),
        ),
      );
    }

    // Android Material 3 Button
    return Material(
      color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 22,
            color: isDarkMode ? Colors.white : const Color(0xFF18181B),
          ),
        ),
      ),
    );
  }

  // Floating Month Selector with 3 Spaced Elements: [<] at left, [October 2026] in center, [>] at right
  // Uses authentic neo_cupertino iOS 26 AdaptiveLiquidGlassLayer (Glass Union)
  Widget _buildMonthSelector({
    required BuildContext context,
    required bool isDarkMode,
    required bool isAr,
    required bool isIOS,
    required String monthStr,
    required Color textPrimary,
  }) {
    final canPrev = _canGoPrevious;
    final canNext = _canGoNext;

    final leftIcon = appStepperIcon(isIOS: isIOS, isRtl: isAr, forward: false);
    final rightIcon = appStepperIcon(isIOS: isIOS, isRtl: isAr, forward: true);

    final activeColor = isDarkMode ? Colors.white : const Color(0xFF000000);
    final disabledColor = isDarkMode
        ? const Color(0xFF636366)
        : const Color(0xFF8E8E93);

    final leftColor = canPrev ? activeColor : disabledColor;
    final rightColor = canNext ? activeColor : disabledColor;

    if (isIOS) {
      final glassSettings = isDarkMode
          ? LiquidGlassSettings.ios27Dark.copyWith(
              glassColor: const Color(0x18FFFFFF),
              frostOpacity: 0.65,
            )
          : LiquidGlassSettings.ios27Light.copyWith(
              glassColor: const Color(0x80F8F8F8),
              frostOpacity: 0.65,
            );

      // Authentic neo_cupertino iOS 26 Glass Union via AdaptiveLiquidGlassLayer
      return AdaptiveLiquidGlassLayer(
        clipExpansion: const EdgeInsets.all(12),
        settings: glassSettings,
        quality: GlassQuality.premium,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Circle Glass Button (<) - 52x52 with large bold iOS chevron
            GlassButton(
              width: 52,
              height: 52,
              shape: const LiquidOval(),
              enabled: canPrev,
              onTap: canPrev ? _previousMonth : () {},
              iconSize: 26,
              iconColor: leftColor,
              icon: Icon(leftIcon, size: 26, color: leftColor),
            ),

            // Center Capsule Glass Button for Dates (October 2026) - Wider comfortable capsule
            Flexible(
              child: GlassButton.custom(
                height: 52,
                shape: const LiquidRoundedRectangle(borderRadius: 26),
                onTap: () {
                  HapticFeedback.selectionClick();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 42),
                  child: Text(
                    monthStr,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: activeColor,
                    ),
                  ),
                ),
              ),
            ),

            // Right Circle Glass Button (>) - 52x52 with large bold iOS chevron
            GlassButton(
              width: 52,
              height: 52,
              shape: const LiquidOval(),
              enabled: canNext,
              onTap: canNext ? _nextMonth : () {},
              iconSize: 26,
              iconColor: rightColor,
              icon: Icon(rightIcon, size: 26, color: rightColor),
            ),
          ],
        ),
      );
    }

    // Android Material 3 Surface Pill Row
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: isDarkMode ? const Color(0xFF222228) : Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          child: SizedBox(
            width: 52,
            height: 52,
            child: IconButton(
              icon: Icon(leftIcon, size: 26, color: leftColor),
              onPressed: canPrev ? _previousMonth : null,
              splashRadius: 26,
            ),
          ),
        ),
        Flexible(
          child: Material(
            color: isDarkMode ? const Color(0xFF222228) : Colors.white,
            borderRadius: BorderRadius.circular(26),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: Text(
                monthStr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: activeColor,
                ),
              ),
            ),
          ),
        ),
        Material(
          color: isDarkMode ? const Color(0xFF222228) : Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          child: SizedBox(
            width: 52,
            height: 52,
            child: IconButton(
              icon: Icon(rightIcon, size: 26, color: rightColor),
              onPressed: canNext ? _nextMonth : null,
              splashRadius: 26,
            ),
          ),
        ),
      ],
    );
  }
}
//#endregion

//#region Custom Donut Chart Painter
class _SpendingDonutChartPainter extends CustomPainter {
  final List<SpendingCategoryItem> categories;
  final double strokeWidth;
  final bool isDarkMode;

  _SpendingDonutChartPainter({
    required this.categories,
    required this.strokeWidth,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final total = categories.fold<double>(0.0, (s, c) => s + c.amount);

    if (total <= 0 || categories.isEmpty) {
      final trackPaint = Paint()
        ..color = (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE2E8F0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, trackPaint);
      return;
    }

    const startAngleBase = -math.pi / 2;
    double currentAngle = startAngleBase;
    const gapAngle = 0.035; // clean gap between slices

    for (int i = 0; i < categories.length; i++) {
      final item = categories[i];
      if (item.amount <= 0) continue;
      final sweepAngle = (item.amount / total) * 2 * math.pi;
      final actualSweep = math.max(0.04, sweepAngle - gapAngle);
      final actualStart = currentAngle + (gapAngle / 2);

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        actualStart,
        actualSweep,
        false,
        paint,
      );

      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _SpendingDonutChartPainter oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
//#endregion

//#region Category Transactions Screen (Android Full Page Route)
class CategoryTransactionsScreen extends StatelessWidget {
  final SpendingCategoryItem category;
  final String currency;
  final DateTime date;

  const CategoryTransactionsScreen({
    super.key,
    required this.category,
    this.currency = 'EGP',
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgScaffold = isDarkMode ? const Color(0xFF0F0F12) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AppGlassBackButton(
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: _CategoryTransactionsContent(
          category: category,
          currency: currency,
          date: date,
          isModal: false,
        ),
      ),
    );
  }
}
//#endregion

//#region Reusable Category Transactions Content
class _CategoryTransactionsContent extends StatelessWidget {
  final SpendingCategoryItem category;
  final String currency;
  final DateTime date;
  final bool isModal;

  const _CategoryTransactionsContent({
    required this.category,
    required this.currency,
    required this.date,
    required this.isModal,
  });

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '$currency ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isIOS = Platform.isIOS;
    final monthFormat = DateFormat('MMMM yyyy', isAr ? 'ar' : 'en_US');
    final monthStr = monthFormat.format(date);

    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280);

    return CustomScrollView(
      physics: isIOS
          ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
          : const ClampingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Subheader: 🕒 October 2026
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    monthStr,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Icon Badge (tinted rounded container with authentic category icon)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: isDarkMode ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: category.color.withValues(alpha: isDarkMode ? 0.4 : 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: category.color.withValues(alpha: isDarkMode ? 0.25 : 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    category.icon,
                    size: 28,
                    color: category.color,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Category Name
              Text(
                category.localizedName(isAr),
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                ),
              ),

              const SizedBox(height: 6),

              // Large Bold Amount
              Text(
                _formatAmount(category.amount),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              // Transaction Count Subtitle
              Text(
                isAr ? '${category.transactionCount} معاملة' : '${category.transactionCount} transactions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),

        // Rounded Transaction List Inset Card
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: category.transactions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.06),
                  ),
                  itemBuilder: (context, index) {
                    final tx = category.transactions[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tx.subtitle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatAmount(tx.amount),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    appForwardIcon(isIOS: isIOS, isRtl: isAr),
                                    size: 16,
                                    color: textSecondary?.withValues(alpha: 0.7),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }
}
//#endregion
