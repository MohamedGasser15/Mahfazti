import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/features/wallet/presentation/screens/add_account_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_controller.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_models.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/wealth_spline_chart.dart';
import 'package:my_wallet/l10n/app_localizations.dart';

/// Android-styled Wealth & Analytics view matching the executive personal wealth design
/// with obsidian dark / monochrome theme, smooth spline curves, and direct asset management.
class AnalyticsAndroidView extends StatefulWidget {
  const AnalyticsAndroidView({super.key, this.controller});

  @visibleForTesting
  final AnalyticsController? controller;

  @override
  State<AnalyticsAndroidView> createState() => _AnalyticsAndroidViewState();
}

class _AnalyticsAndroidViewState extends State<AnalyticsAndroidView> {
  static const Color _green = Color(0xFF10B981);
  static const Color _red = Color(0xFFF87171);

  Color get _accent => _isDark ? Colors.white : Colors.black;

  late final AnalyticsController _controller =
      widget.controller ?? AnalyticsController();
  late final bool _ownsController = widget.controller == null;
  final ScrollController _scrollController = ScrollController();

  bool _isSpendableExpanded = false;
  int? _scrubbedIndex;
  double? _scrubbedValue;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.initialize();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _background =>
      _isDark ? const Color(0xFF09090C) : const Color(0xFFF8F8FA);

  Color get _cardBg =>
      _isDark ? const Color(0xFF131317) : Colors.white;

  Color get _textPrimary =>
      _isDark ? const Color(0xFFEDEDF0) : const Color(0xFF141416);

  Color get _textSecondary =>
      _isDark ? const Color(0xFF8A8A96) : const Color(0xFF71717A);

  Color get _border =>
      _isDark ? const Color(0xFF22222A) : const Color(0xFFE5E5EB);

  Color get _pillContainer =>
      _isDark ? const Color(0xFF15151B) : const Color(0xFFEBEBF0);

  double get _hPadding => AppResponsive.isTablet(context) ? 48 : 20;

  bool get _canPop => Navigator.of(context).canPop();

  String _formatDateRangeStart(bool isAr) {
    final now = DateTime.now();
    final days = _controller.wealthPeriod.days ?? 30;
    final start = now.subtract(Duration(days: days));
    final format = DateFormat('d MMM yyyy', isAr ? 'ar' : 'en');
    return format.format(start);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = context.isArabic;
    final bottomPadding = _canPop
        ? 28.0
        : MediaQuery.paddingOf(context).bottom + 104;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildHeader(isAr: isAr),
                const SizedBox(height: 18),
                _buildTopTabSwitcher(isAr: isAr),
                const SizedBox(height: 22),
                _buildHeroMetrics(isAr: isAr, l10n: l10n),
                const SizedBox(height: 14),
                _buildChartSection(isAr: isAr),
                const SizedBox(height: 18),
                _buildPeriodPills(isAr: isAr),
                const SizedBox(height: 22),
                _buildDynamicContentCard(isAr: isAr),
                const SizedBox(height: 18),
                _buildSpendableRow(isAr: isAr),
                SizedBox(height: bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //#region Header
  Widget _buildHeader({required bool isAr}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_canPop) ...[
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).maybePop();
                },
                icon: Icon(
                  isAr ? Icons.arrow_forward : Icons.arrow_back,
                  color: _textPrimary,
                  size: 22,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              isAr ? 'الثروة' : 'Wealth',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        // Plus Action Button
        GestureDetector(
          onTap: () async {
            HapticFeedback.selectionClick();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddAccountScreen(thingsYouOwnFirst: true),
              ),
            );
            _controller.refresh();
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _isDark ? const Color(0xFF181820) : const Color(0xFFF0F0F4),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isDark ? const Color(0xFF2A2A36) : const Color(0xFFE2E2E8),
                width: 0.8,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 22,
              color: _accent,
            ),
          ),
        ),
      ],
    );
  }
  //#endregion

  //#region Top 3-Way Segmented Control
  Widget _buildTopTabSwitcher({required bool isAr}) {
    const tabs = WealthTab.values;
    final selectedIdx = _controller.wealthTab.index;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: _pillContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                start: selectedIdx * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDark ? Colors.white : Colors.white,
                    borderRadius: BorderRadius.circular(10.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: _isDark ? 0.35 : 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: tabs.map((tab) {
                  final isSelected = _controller.wealthTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _controller.setWealthTab(tab);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.black : _textSecondary,
                            fontFamily: isAr ? 'Cairo' : null,
                          ),
                          child: Text(
                            tab.label(isAr: isAr),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
  //#endregion

  //#region Hero Balance Display
  Widget _buildHeroMetrics({required bool isAr, required AppLocalizations l10n}) {
    final isScrubbing = _scrubbedIndex != null && _scrubbedValue != null;
    final currentAmount = _scrubbedValue ??
        (_controller.wealthTab == WealthTab.debt
            ? _controller.totalDebt
            : (_controller.wealthTab == WealthTab.assets
                ? _controller.totalAssets
                : _controller.netWorth));

    final subtitleText = isScrubbing
        ? (isAr ? 'نقطة بيانية محددة من السجل' : 'Historical chart point')
        : (_controller.wealthTab == WealthTab.netWorth
            ? '${_controller.formatAmount(_controller.spendable, isAr: isAr, decimals: false)} ${isAr ? "متاح الآن" : "available now"}'
            : (_controller.wealthTab == WealthTab.assets
                ? (isAr ? 'إجمالي الأصول المملوكة' : 'Total owned assets')
                : (isAr ? 'إجمالي الالتزامات والديون' : 'Total outstanding debt')));

    final double deltaVal;
    final double deltaPct;
    final bool isPositive;
    if (isScrubbing) {
      deltaVal = _controller.deltaForPointIndex(_scrubbedIndex!, _scrubbedValue!);
      deltaPct = _controller.deltaPercentForPointIndex(_scrubbedIndex!, _scrubbedValue!);
      isPositive = deltaVal >= 0;
    } else {
      deltaVal = _controller.deltaAmount;
      deltaPct = _controller.deltaPercent;
      isPositive = _controller.deltaIsPositive;
    }

    final deltaColor = isPositive ? _green : _red;
    final deltaSign = isPositive ? '+' : '';
    final deltaFormatted = '$deltaSign${_controller.formatAmount(deltaVal, isAr: isAr, decimals: false)} (${deltaPct.abs().toStringAsFixed(1)}%)';
    final periodOrDateLabel = isScrubbing
        ? _controller.formatPointDate(_scrubbedIndex!, isAr: isAr)
        : (isAr ? 'هذا الشهر' : 'this month');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Amount
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            _controller.formatAmount(
              currentAmount,
              isAr: isAr,
              decimals: false,
            ),
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: _textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Growth Delta Badge & Period/Date
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
              decoration: BoxDecoration(
                color: deltaColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: deltaColor.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: deltaColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    deltaFormatted,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: deltaColor,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isScrubbing ? _textPrimary : _textSecondary,
              ),
              child: Text(periodOrDateLabel),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Subtitle (available now or historical note)
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
          child: Text(subtitleText),
        ),
      ],
    );
  }
  //#endregion

  //#region Spline Chart Section
  Widget _buildChartSection({required bool isAr}) {
    final points = _controller.trendPoints;
    final isScrubbing = _scrubbedIndex != null && _scrubbedValue != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WealthSplineChart(
          points: points,
          isDark: _isDark,
          lineColor: _accent,
          glowColor: _accent,
          height: 200.0,
          minY: 0.0,
          maxY: _controller.currentWealthBase,
          onScrubContinuous: (fraction, value) {
            if (_scrubbedValue != value) {
              setState(() {
                _scrubbedValue = value;
                _scrubbedIndex = (fraction * (points.length - 1)).round();
              });
            }
          },
          onScrubEnd: () {
            if (_scrubbedIndex != null || _scrubbedValue != null) {
              setState(() {
                _scrubbedIndex = null;
                _scrubbedValue = null;
              });
            }
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: isScrubbing ? 0.35 : 1.0,
              child: Text(
                _formatDateRangeStart(isAr),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: isScrubbing ? 0.35 : 1.0,
              child: Text(
                isAr ? 'اليوم' : 'Today',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  //#endregion

  //#region Period Selector Pills
  Widget _buildPeriodPills({required bool isAr}) {
    const periods = WealthPeriod.values;
    final selectedIdx = _controller.wealthPeriod.index;

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _pillContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / periods.length;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                start: selectedIdx * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDark ? Colors.white : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: _isDark ? 0.35 : 0.08),
                        blurRadius: 5,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: periods.map((p) {
                  final isSelected = _controller.wealthPeriod == p;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _controller.setWealthPeriod(p);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.black : _textSecondary,
                            fontFamily: isAr ? 'Cairo' : null,
                          ),
                          child: Text(p.label(isAr: isAr)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
  //#endregion

  //#region Dynamic Content Card (Onboarding or Breakdown)
  Widget _buildDynamicContentCard({required bool isAr}) {
    final isNetWorth = _controller.wealthTab == WealthTab.netWorth;
    final isAssets = _controller.wealthTab == WealthTab.assets;
    final isDebt = _controller.wealthTab == WealthTab.debt;

    if (isDebt) {
      return _buildDebtSection(isAr: isAr);
    }

    if (isAssets || (isNetWorth && _controller.assetsList.length > 1)) {
      return _buildAssetsBreakdown(isAr: isAr);
    }

    // Default screenshot card: Nothing you own is here yet
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.45 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isDark
                          ? Colors.white.withValues(alpha: 0.16)
                          : Colors.black.withValues(alpha: 0.10),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    size: 20,
                    color: _accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAr ? 'لا توجد أصول مضافة بعد' : 'Nothing you own is here yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isAr
                  ? 'شقة، سيارة، صندوق استثماري، ذهب أو شهادة بنكية. أضفها مرة واحدة لتُحسب ضمن صافي ثروتك، بجانب حساباتك البنكية.'
                  : 'An apartment, a car, a fund, gold or a certificate. Add it once and it counts toward your net worth, with your bank accounts.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAccountScreen(thingsYouOwnFirst: true),
                    ),
                  );
                  _controller.refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDark ? Colors.white : Colors.black,
                  foregroundColor: _isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isAr ? 'أضف ما تملكه' : 'Add something you own',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsBreakdown({required bool isAr}) {
    final assets = _controller.assetsList;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.45 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isAr ? 'الأصول المندرجة' : 'Included Assets',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAccountScreen(thingsYouOwnFirst: true),
                      ),
                    );
                    _controller.refresh();
                  },
                  child: Text(
                    isAr ? '+ إضافة' : '+ Add',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...assets.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 18, color: item.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          if (item.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _controller.formatAmount(
                        item.balance,
                        isAr: isAr,
                        decimals: false,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtSection({required bool isAr}) {
    final debts = _controller.debtList;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: debts.isEmpty
            ? Column(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 40,
                    color: _green,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isAr
                        ? 'لا توجد ديون أو التزامات مسجلة'
                        : 'No debt or liabilities recorded',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr
                        ? 'أنت حر من الالتزامات المالية والديون حالياً.'
                        : 'You are currently debt-free.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _textSecondary,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: debts.map((d) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.credit_card_rounded,
                            size: 18,
                            color: _red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            d.name,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _controller.formatAmount(
                            d.balance,
                            isAr: isAr,
                            decimals: false,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
  //#endregion

  //#region Spendable Row
  Widget _buildSpendableRow({required bool isAr}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 0.8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isSpendableExpanded = !_isSpendableExpanded);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isAr ? 'المتاح للصرف' : 'SPENDABLE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _controller.formatAmount(
                      _controller.spendable,
                      isAr: isAr,
                      decimals: false,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _isSpendableExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSpendableExpanded) ...[
            Divider(height: 1, thickness: 0.8, color: _border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  ..._controller.spendableAccounts.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _isDark
                                  ? const Color(0xFF191922)
                                  : const Color(0xFFF3F3F6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isDark
                                    ? const Color(0xFF282834)
                                    : const Color(0xFFE5E5EB),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              item.icon,
                              size: 16,
                              color: item.color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.displayName(isAr: isAr),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                                if (item.displaySubtitle(isAr: isAr) != null) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    item.displaySubtitle(isAr: isAr)!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            _controller.formatAmount(
                              item.balance,
                              isAr: isAr,
                              decimals: false,
                            ),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAccountScreen(),
                        ),
                      );
                      _controller.refresh();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 16,
                            color: _accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isAr ? 'إضافة حساب أو محفظة' : 'Add account or wallet',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  //#endregion
}
