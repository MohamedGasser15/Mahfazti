import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neo_cupertino/neo_cupertino.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/features/wallet/presentation/screens/add_account_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_controller.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/analytics_models.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics/wealth_spline_chart.dart';
import 'package:my_wallet/l10n/app_localizations.dart';

/// iOS-styled Wealth & Analytics view matching the executive personal wealth design
/// with obsidian dark / monochrome theme, smooth spline curves, and direct asset management.
class AnalyticsIosView extends StatefulWidget {
  const AnalyticsIosView({super.key, this.controller});

  @visibleForTesting
  final AnalyticsController? controller;

  @override
  State<AnalyticsIosView> createState() => _AnalyticsIosViewState();
}

class _AnalyticsIosViewState extends State<AnalyticsIosView> {
  Color get _accent => _isDark ? Colors.white : Colors.black;

  late final AnalyticsController _controller =
      widget.controller ?? AnalyticsController();
  late final bool _ownsController = widget.controller == null;
  final ScrollController _scrollController = ScrollController();

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
      _isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);

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
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = _canPop
        ? 28.0
        : MediaQuery.paddingOf(context).bottom + 104;

    return Scaffold(
      backgroundColor: _background,
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _hPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topPadding > 0 ? topPadding + 8 : 18),
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
              _buildWealthIntelligence(isAr: isAr),
              const SizedBox(height: 18),
              _buildDynamicContentCard(isAr: isAr),
              SizedBox(height: bottomPadding),
            ],
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
              GlassIconButton(
                size: 38,
                iconSize: 20,
                useOwnLayer: true,
                shape: GlassIconButtonShape.circle,
                icon: Icon(
                  isAr ? CupertinoIcons.chevron_right : CupertinoIcons.chevron_left,
                  size: 20,
                  color: _textPrimary,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).maybePop();
                },
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
        // Plus Action Button with Liquid Glass
        GlassIconButton(
          size: 38,
          iconSize: 20,
          useOwnLayer: true,
          shape: GlassIconButtonShape.circle,
          icon: Icon(
            CupertinoIcons.add,
            size: 20,
            color: _textPrimary,
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
        ),
      ],
    );
  }
  //#endregion

  //#region Top 3-Way Segmented Control
  Widget _buildTopTabSwitcher({required bool isAr}) {
    final selectedIdx = _controller.wealthTab == WealthTab.netWorth
        ? 0
        : (_controller.wealthTab == WealthTab.assets ? 1 : 2);
    final isGlass = PlatformInfo.isIOS26OrHigher();

    if (isGlass) {
      return GlassSegmentedControl(
        selectedIndex: selectedIdx,
        onSegmentSelected: (idx) {
          HapticFeedback.selectionClick();
          if (idx == 0) {
            _controller.setWealthTab(WealthTab.netWorth);
          } else if (idx == 1) {
            _controller.setWealthTab(WealthTab.assets);
          } else {
            _controller.setWealthTab(WealthTab.debt);
          }
        },
        segments: [
          GlassSegment(label: isAr ? 'صافي الثروة' : 'Net worth'),
          GlassSegment(label: isAr ? 'الأصول' : 'Assets'),
          GlassSegment(label: isAr ? 'الديون' : 'Debt'),
        ],
        height: 42,
        useOwnLayer: true,
        backgroundColor: _isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        indicatorColor: _isDark
            ? const Color(0xFF27272A)
            : Colors.white,
        selectedTextStyle: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: _isDark ? Colors.white : Colors.black,
          fontFamily: isAr ? 'Cairo' : null,
        ),
        unselectedTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _isDark
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.55),
          fontFamily: isAr ? 'Cairo' : null,
        ),
      );
    }

    const tabs = WealthTab.values;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: _pillContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 250),
                curve: Curves.fastOutSlowIn,
                start: selectedIdx * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDark ? const Color(0xFF27272A) : Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: _isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
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
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (_isDark ? Colors.white : Colors.black)
                                : (_isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.55)),
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
            ? (isAr ? 'إجمالي صافي الثروة' : 'Total Net Worth')
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

    final deltaColor = _textPrimary;
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
            if (_controller.wealthTab == WealthTab.debt &&
                _controller.totalDebt == 0 &&
                !isScrubbing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _border,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_shield_fill,
                      size: 11,
                      color: _textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAr ? 'خالي من الديون' : 'Debt-free',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _border,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? CupertinoIcons.arrowtriangle_up_fill
                          : CupertinoIcons.arrowtriangle_down_fill,
                      size: 9,
                      color: deltaColor,
                    ),
                    const SizedBox(width: 4),
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
    final isGlass = PlatformInfo.isIOS26OrHigher();

    if (isGlass) {
      return GlassSegmentedControl(
        selectedIndex: selectedIdx,
        onSegmentSelected: (idx) {
          HapticFeedback.selectionClick();
          _controller.setWealthPeriod(periods[idx]);
        },
        segments: periods
            .map((p) => GlassSegment(label: p.label(isAr: isAr)))
            .toList(),
        height: 38,
        useOwnLayer: true,
        backgroundColor: _isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        indicatorColor: _isDark
            ? const Color(0xFF27272A)
            : Colors.white,
        selectedTextStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _isDark ? Colors.white : Colors.black,
          fontFamily: isAr ? 'Cairo' : null,
        ),
        unselectedTextStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: _isDark
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.55),
          fontFamily: isAr ? 'Cairo' : null,
        ),
      );
    }

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _pillContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
          width: 0.8,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / periods.length;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 220),
                curve: Curves.fastOutSlowIn,
                start: selectedIdx * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDark ? const Color(0xFF27272A) : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: _isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
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
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (_isDark ? Colors.white : Colors.black)
                                : (_isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.55)),
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

  //#region Wealth Intelligence & Insights
  Widget _buildWealthIntelligence({required bool isAr}) {
    final tab = _controller.wealthTab;
    if (tab == WealthTab.netWorth) {
      return _buildNetWorthInsights(isAr: isAr);
    } else if (tab == WealthTab.assets) {
      return _buildAssetsInsights(isAr: isAr);
    } else {
      return _buildDebtInsights(isAr: isAr);
    }
  }

  Widget _buildNetWorthInsights({required bool isAr}) {
    final runway = _controller.runwayMonths;
    final isRunwaySafe = runway >= 3.0;
    final isRunwayModerate = runway >= 1.0;

    final statusText = isRunwaySafe
        ? (isAr ? 'أمان ممتاز' : 'Safe')
        : (isRunwayModerate ? (isAr ? 'مقبول' : 'Fair') : (isAr ? 'يحتاج دعم' : 'Low'));

    final totalAssets = _controller.totalAssets > 0 ? _controller.totalAssets : 1.0;
    final cashPct = ((_controller.liquidCashTotal / totalAssets) * 100).round();
    final goldPct = ((_controller.goldAssetsTotal / totalAssets) * 100).round();
    final certPct = ((_controller.certificatesTotal / totalAssets) * 100).round();
    final propPct = ((_controller.propertiesTotal / totalAssets) * 100).round();

    // Monochrome allocation palette (executive grayscale obsidian)
    final cashColor = _isDark ? Colors.white : const Color(0xFF18181B);
    final goldColor = _isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF52525B);
    final certColor = _isDark ? Colors.white.withValues(alpha: 0.40) : const Color(0xFF8E8E93);
    final propColor = _isDark ? Colors.white.withValues(alpha: 0.20) : const Color(0xFFC7C7CC);

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Emergency Runway
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.shield_lefthalf_fill,
                  size: 16,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'مؤشر الأمان المالي' : 'Financial Runway',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr
                          ? 'السيولة تكفي نفقاتك لمدة ${runway.toStringAsFixed(1)} شهر بدون دخل'
                          : 'Liquid cash covers ${runway.toStringAsFixed(1)} months of burn rate',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border, width: 0.8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Runway Progress Bar (Target 6 Months)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                value: (runway / 6.0).clamp(0.05, 1.0),
                backgroundColor: _isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(_accent),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: _border),
          const SizedBox(height: 14),

          // 2. Asset Allocation Breakdown Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'توزيع الأصول' : 'Asset Allocation',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              Text(
                '100%',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  if (cashPct > 0)
                    Flexible(
                      flex: cashPct,
                      child: Container(color: cashColor),
                    ),
                  if (goldPct > 0)
                    Flexible(
                      flex: goldPct,
                      child: Container(color: goldColor),
                    ),
                  if (certPct > 0)
                    Flexible(
                      flex: certPct,
                      child: Container(color: certColor),
                    ),
                  if (propPct > 0)
                    Flexible(
                      flex: propPct,
                      child: Container(color: propColor),
                    ),
                  if (cashPct == 0 && goldPct == 0 && certPct == 0 && propPct == 0)
                    Expanded(
                      child: Container(color: cashColor),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildAllocationPill(
                color: cashColor,
                label: isAr ? 'سيولة وبنوك' : 'Cash & Bank',
                pct: cashPct > 0 ? cashPct : 100,
              ),
              if (goldPct > 0)
                _buildAllocationPill(
                  color: goldColor,
                  label: isAr ? 'ذهب ومعادن' : 'Gold & Metals',
                  pct: goldPct,
                ),
              if (certPct > 0)
                _buildAllocationPill(
                  color: certColor,
                  label: isAr ? 'شهادات وودائع' : 'CDs & Yield',
                  pct: certPct,
                ),
              if (propPct > 0)
                _buildAllocationPill(
                  color: propColor,
                  label: isAr ? 'أصول واستثمار' : 'Properties',
                  pct: propPct,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationPill({
    required Color color,
    required String label,
    required int pct,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label $pct%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetsInsights({required bool isAr}) {
    final certTotal = _controller.certificatesTotal;
    final goldTotal = _controller.goldAssetsTotal;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  certTotal > 0 ? CupertinoIcons.sparkles : CupertinoIcons.chart_pie_fill,
                  size: 16,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certTotal > 0
                          ? (isAr ? 'الدخل السلبي المتوقع' : 'Estimated Passive Income')
                          : (isAr ? 'تنمية أصولك الاستثمارية' : 'Grow Your Asset Yield'),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      certTotal > 0
                          ? (isAr
                              ? 'عوائد شهرية تقديرية من شهاداتك وودائعك البنكية'
                              : 'Estimated monthly cash payout from bank certificates')
                          : (isAr
                              ? 'أضف شهادة بنكية أو صندوق استثماري لحساب عوائدك التلقائية'
                              : 'Add CDs, funds, or gold to track effortless monthly yield'),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (certTotal > 0)
                Text(
                  '+${_controller.formatAmount(_controller.estimatedMonthlyYield, isAr: isAr, decimals: false)}/${isAr ? "ش" : "mo"}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
            ],
          ),
          if (goldTotal > 0) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: _border),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(CupertinoIcons.shield_fill, size: 14, color: _textSecondary),
                const SizedBox(width: 6),
                Text(
                  isAr ? 'ملاذ التحوط من التضخم (ذهب): ' : 'Inflation hedge (Gold): ',
                  style: TextStyle(fontSize: 11.5, color: _textSecondary),
                ),
                Text(
                  _controller.formatAmount(goldTotal, isAr: isAr, decimals: false),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDebtInsights({required bool isAr}) {
    final debtRatio = _controller.debtRatio;
    final isZero = _controller.totalDebt == 0;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isZero ? CupertinoIcons.checkmark_shield_fill : CupertinoIcons.gauge_badge_plus,
              size: 16,
              color: _textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'مؤشر عبء المديونية (DTI)' : 'Debt-to-Asset Health',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isZero
                      ? (isAr
                          ? 'أنت حر مالياً 100% وبدون أي التزامات مسجلة'
                          : 'Zero outstanding liabilities — 100% debt-free')
                      : (isAr
                          ? 'الديون تمثل ${debtRatio.toStringAsFixed(1)}% من ثروتك (الأمان تحت 30%)'
                          : 'Debt represents ${debtRatio.toStringAsFixed(1)}% of assets (Keep under 30%)'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border, width: 0.8),
            ),
            child: Text(
              isZero ? '0%' : '${debtRatio.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
          ),
        ],
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
                    CupertinoIcons.house_fill,
                    size: 18,
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
                        color: _isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 18, color: _textPrimary),
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
        child: debts.isEmpty
            ? Column(
                children: [
                  Icon(
                    CupertinoIcons.checkmark_shield_fill,
                    size: 40,
                    color: _textPrimary,
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.selectionClick();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddAccountScreen(),
                          ),
                        );
                        _controller.refresh();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        foregroundColor: _textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _border,
                            width: 0.8,
                          ),
                        ),
                      ),
                      child: Text(
                        isAr ? 'تسجيل كارت مشتريات أو التزام' : 'Add credit card or liability',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isAr ? 'الديون والالتزامات' : 'Debt & Liabilities',
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
                              builder: (context) => const AddAccountScreen(),
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
                  ...debts.map((d) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              CupertinoIcons.creditcard_fill,
                              size: 18,
                              color: _textPrimary,
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
  //#endregion
}
