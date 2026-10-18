part of '../screens/home_tab.dart';
// ignore_for_file: annotate_overrides

mixin _HomeTabWidgets on _HomeTabState {
  //#region Skeleton Loading (Say Style)
  Widget _buildSkeletonLoading(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFE4E4E7),
      highlightColor: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 140,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Card Skeleton
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions Skeleton (3 pills)
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    height: 52,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 6,
                      right: index == 2 ? 0 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Filter Bar Skeleton
            Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 20),
            // Transaction Rows Skeleton
            ...List.generate(
              4,
              (index) => Container(
                height: 72,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //#endregion

  //#region Atmospheric Hero Section (Say Style with Black Gradient Shadow in Light Mode)
  Widget _buildSayHeroSection(bool isDarkMode, HideBalanceService hideService) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? const [
                  Color(0xFF16161B), // Elegant deep graphite at status bar
                  Color(0xFF202026), // Soft natural lift into top bar
                  Color(0xFF2A2A33), // Rising luminous tone approaching spent label
                  Color(0xFF33333F), // Peak luminous aura centered across the price number
                  Color(0xFF2A2A34), // Soft glow continuing through account selector
                  Color(0xFF1F1F26), // Gentle decay above action buttons
                  Color(0xFF15151A), // Soft ambient depth at buttons
                  Color(0xFF0E0E12), // Deep shadow below buttons
                  Color(0xFF09090B), // Flawless blend into page background
                ]
              : [
                  const Color(0xFF141418),
                  const Color(0xFF141418).withValues(alpha: 0.99),
                  const Color(0xFF141418).withValues(alpha: 0.96),
                  const Color(0xFF141418).withValues(alpha: 0.91),
                  const Color(0xFF141418).withValues(alpha: 0.83),
                  const Color(0xFF141418).withValues(alpha: 0.72),
                  const Color(0xFF141418).withValues(alpha: 0.56),
                  const Color(0xFF141418).withValues(alpha: 0.36),
                  const Color(0xFF141418).withValues(alpha: 0.0),
                ],
          stops: isDarkMode
              ? const [
                  0.0,
                  0.16,
                  0.30,
                  0.44,
                  0.58,
                  0.70,
                  0.82,
                  0.92,
                  1.0,
                ]
              : const [
                  0.0,
                  0.15,
                  0.30,
                  0.45,
                  0.60,
                  0.72,
                  0.82,
                  0.91,
                  1.0,
                ],
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding > 0 ? topPadding : 12,
        bottom: isDarkMode ? 40 : 60,
      ),
      child: Column(
        children: [
          _buildSayTopBar(isDarkMode, hideService),
          const SizedBox(height: 6),
          _buildSayHeroHeader(isDarkMode, hideService),
          const SizedBox(height: 30),
          _buildSayActionRow(isDarkMode),
        ],
      ),
    );
  }
  //#endregion

  //#region Top App Bar (Say Style)
  Widget _buildSayTopBar(bool isDarkMode, HideBalanceService hideService) {
    final isIOS = Platform.isIOS;

    final topBarGlassSettings = LiquidGlassSettings(
      thickness: 14,
      blur: 10,
      glassColor: isDarkMode
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.20),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: User Profile Avatar
          isIOS
              ? GlassButton(
                  width: 38,
                  height: 38,
                  shape: const LiquidOval(),
                  useOwnLayer: true,
                  settings: topBarGlassSettings,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          onLocaleChanged: (locale) {},
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.person_rounded,
                    size: 19,
                    color: Colors.white,
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          onLocaleChanged: (locale) {},
                        ),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

          // Center: Date Range Selector Pill (Say Style / Native iOS Menu on iOS)
          isIOS
              ? IosSingleTapContextMenu(
                  actions: [
                    IosContextMenuAction(
                      id: 'this_month',
                      title: context.l10n.thisMonth,
                      iconSystemName: 'calendar',
                    ),
                    IosContextMenuAction(
                      id: 'last_month',
                      title: context.l10n.lastMonth,
                      iconSystemName: 'clock.arrow.circlepath',
                    ),
                    const IosContextMenuDivider(),
                    IosContextMenuAction(
                      id: 'by_month',
                      title: context.l10n.byMonth,
                      iconSystemName: 'calendar.day.timeline.left',
                    ),
                    IosContextMenuAction(
                      id: 'custom_range',
                      title: context.l10n.customRangeDots,
                      iconSystemName: 'calendar.badge.clock',
                    ),
                  ],
                  onSelected: (id) async {
                    final now = DateTime.now();
                    if (id == 'this_month') {
                      setState(() {
                        _startDate = DateTime(now.year, now.month, 1);
                        _endDate = DateTime(now.year, now.month + 1, 0);
                      });
                    } else if (id == 'last_month') {
                      setState(() {
                        _startDate = DateTime(now.year, now.month - 1, 1);
                        _endDate = DateTime(now.year, now.month, 0);
                      });
                    } else if (id == 'by_month') {
                      await _pickMonthPicker(context);
                    } else if (id == 'custom_range') {
                      await _pickCustomDateRange(context);
                    }
                  },
                  child: GlassContainer(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: const LiquidRoundedRectangle(borderRadius: 19),
                    useOwnLayer: true,
                    settings: topBarGlassSettings,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formattedDateRange,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 17,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showDateRangeModalSheetAndroid(isDarkMode),
                    borderRadius: BorderRadius.circular(19),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                          width: 1.1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formattedDateRange,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 17,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

          // Right: Analytics Chart Icon
          isIOS
              ? GlassButton(
                  width: 38,
                  height: 38,
                  shape: const LiquidOval(),
                  useOwnLayer: true,
                  settings: topBarGlassSettings,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.auto_graph_rounded,
                    size: 19,
                    color: Colors.white,
                  ),
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_graph_rounded,
                          size: 19,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showDateRangeModalSheetAndroid(bool isDarkMode) {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final isThisMonth = _startDate.year == now.year &&
        _startDate.month == now.month &&
        _startDate.day == 1 &&
        _endDate.day == DateTime(now.year, now.month + 1, 0).day;
    final prevMonthDate = DateTime(now.year, now.month - 1, 1);
    final isLastMonth = _startDate.year == prevMonthDate.year &&
        _startDate.month == prevMonthDate.month &&
        _startDate.day == 1 &&
        _endDate.day == DateTime(now.year, now.month, 0).day;
    final isByMonth = !isThisMonth && !isLastMonth && _startDate.day == 1 && _endDate.day == DateTime(_startDate.year, _startDate.month + 1, 0).day;
    final isCustom = !isThisMonth && !isLastMonth && !isByMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF18181B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 36,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.selectDateRange,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDateRangeSheetItem(
                ctx: ctx,
                title: context.l10n.thisMonth,
                icon: Icons.calendar_today_rounded,
                isSelected: isThisMonth,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _startDate = DateTime(now.year, now.month, 1);
                    _endDate = DateTime(now.year, now.month + 1, 0);
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildDateRangeSheetItem(
                ctx: ctx,
                title: context.l10n.lastMonth,
                icon: Icons.history_rounded,
                isSelected: isLastMonth,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _startDate = DateTime(now.year, now.month - 1, 1);
                    _endDate = DateTime(now.year, now.month, 0);
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildDateRangeSheetItem(
                ctx: ctx,
                title: context.l10n.byMonth,
                icon: Icons.calendar_month_rounded,
                isSelected: isByMonth,
                isDarkMode: isDarkMode,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickMonthPicker(context);
                },
              ),
              const SizedBox(height: 8),
              _buildDateRangeSheetItem(
                ctx: ctx,
                title: context.l10n.customRangeDots,
                icon: Icons.date_range_rounded,
                isSelected: isCustom,
                isDarkMode: isDarkMode,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickCustomDateRange(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateRangeSheetItem({
    required BuildContext ctx,
    required String title,
    required IconData icon,
    required bool isDarkMode,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06))
                : (isDarkMode ? const Color(0xFF27272A).withValues(alpha: 0.45) : const Color(0xFFF4F4F5)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDarkMode ? Colors.white : Colors.black)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
            ],
          ),
        ),
      ),
    );
  }
  //#endregion

  //#region Hero Header (Say Style - Spent & Balance)
  Widget _buildSayHeroHeader(bool isDarkMode, HideBalanceService hideService) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final isIOS = Platform.isIOS;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _heroDragDistance = 0,
      onHorizontalDragUpdate: (details) => _heroDragDistance += details.primaryDelta ?? 0,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        final isSwipeLeft = velocity < -120 || _heroDragDistance < -35;
        final isSwipeRight = velocity > 120 || _heroDragDistance > 35;

        if (isRtl) {
          // RTL (Arabic): Swiping right advances to next wallet, swiping left goes to previous
          if (isSwipeRight) {
            _switchToNextAccount(isRtl: true);
          } else if (isSwipeLeft) {
            _switchToPreviousAccount(isRtl: true);
          }
        } else {
          // LTR (English): Swiping left advances to next wallet, swiping right goes to previous
          if (isSwipeLeft) {
            _switchToNextAccount(isRtl: false);
          } else if (isSwipeRight) {
            _switchToPreviousAccount(isRtl: false);
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                hideService.toggle();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "Wallet Balance" Label
                  Text(
                    context.l10n.balance,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Big Balance Amount: e.g. $ 12,450.00 (Animated on swipe/switch)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      final offsetTween = Tween<Offset>(
                        begin: Offset(_heroSlideFromLeft ? -0.25 : 0.25, 0.0),
                        end: Offset.zero,
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetTween.animate(
                            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      key: ValueKey('balance_hero_$_selectedAccountId'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _buildBlurrableNumber(
                          _selectedAccount.balance,
                          const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            color: Colors.white,
                          ),
                          hideService.isHidden,
                          currencyCode: _selectedAccount.isAll ? null : _selectedAccount.currency,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Account Switcher (Clean text with chevron - animated on switch)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: KeyedSubtree(
                key: ValueKey('account_switcher_$_selectedAccountId'),
                child: isIOS
                    ? IosSingleTapContextMenu(
                        actions: [
                          ..._accounts.map((acc) {
                            final isSelected = acc.id == _selectedAccountId;
                            final label = acc.isMain ? '${acc.name} ⭐' : acc.name;
                            return IosContextMenuAction(
                              id: 'acc_${acc.id}',
                              title: label,
                              iconSystemName: isSelected ? 'checkmark.circle.fill' : 'circle',
                              showTrailingCheckmark: isSelected,
                            );
                          }),
                          const IosContextMenuDivider(),
                          IosContextMenuAction(
                            id: 'add_account',
                            title: context.l10n.addAccount,
                            iconSystemName: 'plus',
                          ),
                          IosContextMenuAction(
                            id: 'manage_accounts',
                            title: context.l10n.manageAccounts,
                            iconSystemName: 'slider.horizontal.3',
                          ),
                        ],
                        onSelected: (id) {
                          if (id.startsWith('acc_')) {
                            final accId = id.substring(4);
                            final targetAcc = _accounts.firstWhere((a) => a.id == accId, orElse: () => _accounts.first);
                            final curIdx = _accounts.indexWhere((a) => a.id == _selectedAccountId);
                            final targetIdx = _accounts.indexWhere((a) => a.id == accId);
                            final isMovingForward = targetIdx > curIdx;
                            setState(() {
                              _heroSlideFromLeft = isRtl ? isMovingForward : !isMovingForward;
                              _selectedAccountId = targetAcc.id;
                            });
                            _syncWalletsCarouselToSelected();
                          } else if (id == 'add_account') {
                            _showAddAccountModal();
                          } else if (id == 'manage_accounts') {
                            _showManageAccountsModal();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedAccount.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.90),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 15,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _showAccountSwitcherModal();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedAccount.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.90),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 15,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),

            // Carousel Dot Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _accounts.map((acc) {
                final isSelected = acc.id == _selectedAccountId;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    final accounts = _accounts;
                    final curIdx = accounts.indexWhere((a) => a.id == _selectedAccountId);
                    final targetIdx = accounts.indexWhere((a) => a.id == acc.id);
                    final isMovingForward = targetIdx > curIdx;
                    setState(() {
                      _heroSlideFromLeft = isRtl ? isMovingForward : !isMovingForward;
                      _selectedAccountId = acc.id;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    height: 4,
                    width: isSelected ? 18 : 5,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  //#endregion

  //#region 4 Circular Action Buttons (Say Style: Add, Voice, Receipt, More)
  Widget _buildSayActionRow(bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Add (+)
          _buildCircularActionItem(
            icon: Icons.add_rounded,
            label: context.l10n.add,
            isDarkMode: isDarkMode,
            onTap: () => _showUnifiedAddModal(),
          ),

          // 2. Voice (🎙️)
          VoiceExpenseButton(
            isDarkMode: isDarkMode,
            isCircular: true,
            isInHero: true,
            onResult: (result) {
              if (result.isSuccess) {
                _showUnifiedAddModal(prefillFromVoice: result);
              } else {
                MessageService.showError(
                  context: context,
                  message: result.errorMessage ?? context.l10n.voiceAnalysisFailed,
                );
              }
            },
          ),

          // 3. Receipt Scanner (🧾)
          _buildCircularActionItem(
            icon: Icons.document_scanner_rounded,
            label: context.l10n.receipt,
            isDarkMode: isDarkMode,
            onTap: () => _showReceiptScannerModal(isDarkMode, isAr),
          ),

          // 4. More (••• with Native iOS Popover Menu via CNPopupMenuButton)
          _buildMoreActionButton(isDarkMode),
        ],
      ),
    );
  }

  void _showReceiptScannerModal(bool isDarkMode, bool isAr) {
    HapticFeedback.selectionClick();

    _showAdaptiveBottomSheet(
      showDragHandle: true,
      builder: (ctx, isGlass, _) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, isGlass ? 8 : 16, 24, 28),
          decoration: isGlass
              ? const BoxDecoration(color: Colors.transparent)
              : BoxDecoration(
                  color: isDarkMode ? const Color(0xFF15151A) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                    color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                    width: 1.2,
                  ),
                ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isGlass)
                Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              if (isGlass) const SizedBox(height: 12),
              const SizedBox(height: 22),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.document_scanner_rounded,
                  size: 32,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.aiReceiptScanner,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? Colors.white : Colors.black,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.aiReceiptScannerDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showUnifiedAddModal();
                      },
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: Text(
                        context.l10n.manual,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: isDarkMode ? Colors.white : Colors.black,
                        side: BorderSide(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        MessageService.showSuccess(
                          context: context,
                          message: context.l10n.aiCameraComingSoon,
                        );
                      },
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: isDarkMode ? Colors.black : Colors.white,
                      ),
                      label: Text(
                        context.l10n.camera,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: isDarkMode ? Colors.white : Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreActionButton(bool isDarkMode) {
    final isIOS = Platform.isIOS;

    if (isIOS) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassContainer(
            width: 52,
            height: 52,
            shape: const LiquidOval(),
            useOwnLayer: true,
            platformViewBackdrop: true,
            settings: LiquidGlassSettings(
              thickness: 16,
              blur: 10,
              glassColor: isDarkMode
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.22),
            ),
            child: IosSingleTapContextMenu(
              actions: [
                IosContextMenuAction(
                  id: 'add_account',
                  title: context.l10n.addAccount,
                  iconSystemName: 'plus',
                ),
                IosContextMenuAction(
                  id: 'manage_accounts',
                  title: context.l10n.manageAccounts,
                  iconSystemName: 'slider.horizontal.3',
                ),
                const IosContextMenuDivider(),
                IosContextMenuAction(
                  id: 'switch_account',
                  title: context.l10n.switchAccount,
                  iconSystemName: 'arrow.left.arrow.right',
                ),
              ],
              onSelected: (id) {
                switch (id) {
                  case 'add_account':
                    _showAddAccountModal();
                    break;
                  case 'manage_accounts':
                    _showManageAccountsModal();
                    break;
                  case 'switch_account':
                    _showAccountSwitcherModal();
                    break;
                }
              },
              child: const SizedBox(
                width: 52,
                height: 52,
                child: Center(
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.more,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: isDarkMode
                  ? null
                  : [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.60),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassContainer(
          width: 52,
          height: 52,
          shape: const LiquidOval(),
          useOwnLayer: true,
          settings: LiquidGlassSettings(
            thickness: 16,
            blur: 10,
            glassColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.22),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showMoreActionsModalAndroid(isDarkMode),
              borderRadius: BorderRadius.circular(26),
              child: const Center(
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.more,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: isDarkMode
                ? null
                : [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.60),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  void _showMoreActionsModalAndroid(bool isDarkMode) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF18181B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 36,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.more,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDateRangeSheetItem(
                ctx: ctx,
                title: context.l10n.addAccount,
                icon: Icons.add_card_rounded,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddAccountModal();
                },
              ),
              const SizedBox(height: 8),
              _buildDateRangeSheetItem(
                ctx: ctx,
                title: context.l10n.manageAccounts,
                icon: Icons.tune_rounded,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(ctx);
                  _showManageAccountsModal();
                },
              ),
              const SizedBox(height: 8),
              _buildDateRangeSheetItem(
                ctx: ctx,
                title: context.l10n.switchAccount,
                icon: Icons.swap_horiz_rounded,
                isDarkMode: isDarkMode,
                onTap: () {
                  Navigator.pop(ctx);
                  _showAccountSwitcherModal();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickCustomDateRange(BuildContext context) async {
    final isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      return _pickCustomDateRangeIOS(context);
    } else {
      return _pickCustomDateRangeAndroid(context);
    }
  }

  Future<void> _pickMonthPicker(BuildContext context) async {
    final isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      return _pickMonthPickerIOS(context);
    } else {
      return _pickMonthPickerAndroid(context);
    }
  }

  //#region iOS Pickers (Concept 1: Cupertino Wheels & cupertino_calendar_picker)
  Future<void> _pickCustomDateRangeIOS(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final textSecondary = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime tempStart = _startDate.isAfter(today) ? today : _startDate;
    DateTime tempEnd = _endDate.isAfter(today) ? today : _endDate;

    final GlobalKey fromCardKey = GlobalKey();
    final GlobalKey toCardKey = GlobalKey();

    String formatDatePill(DateTime d) {
      return DateFormat('d MMM yyyy', isAr ? 'ar' : 'en').format(d);
    }

    await showGlassModalSheet<void>(
      context: context,
      halfSize: 0.52,
      fullSize: 0.70,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final dayCount = tempEnd.difference(tempStart).inDays + 1;

            void applyDaysPreset(int days) {
              HapticFeedback.selectionClick();
              setSheetState(() {
                tempEnd = today;
                tempStart = today.subtract(Duration(days: days - 1));
              });
            }

            void applyThisMonthPreset() {
              HapticFeedback.selectionClick();
              setSheetState(() {
                tempStart = DateTime(today.year, today.month, 1);
                tempEnd = today;
              });
            }

            Future<void> openCupertinoCalendar(bool isFrom) async {
              HapticFeedback.selectionClick();
              final key = isFrom ? fromCardKey : toCardKey;
              final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

              final picked = await showCupertinoCalendarPicker(
                ctx,
                widgetRenderBox: renderBox,
                minimumDate: isFrom ? DateTime(2020) : tempStart,
                maximumDate: today,
                initialDate: isFrom
                    ? tempStart
                    : (tempEnd.isBefore(tempStart) ? tempStart : tempEnd),
                currentDate: today,
                mainColor: isDarkMode ? Colors.white : const Color(0xFF09090B),
              );

              if (picked != null) {
                // Ensure picked date is never in the future
                final clampedPicked = picked.isAfter(today) ? today : picked;
                setSheetState(() {
                  if (isFrom) {
                    tempStart = clampedPicked;
                    if (tempEnd.isBefore(tempStart)) {
                      tempEnd = tempStart;
                    }
                  } else {
                    tempEnd = clampedPicked;
                  }
                });
              }
            }

            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.customRange,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Text(
                          context.l10n.daysCount(dayCount),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Presets Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPresetChip(
                          label: context.l10n.last7Days,
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => applyDaysPreset(7),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: context.l10n.last30Days,
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => applyDaysPreset(30),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: context.l10n.thisMonth,
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: applyThisMonthPreset,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dual From & To Cards
                  Row(
                    children: [
                      // "From" Card
                      Expanded(
                        child: Material(
                          key: fromCardKey,
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => openCupertinoCalendar(true),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E1E24) : const Color(0xFFF4F4F6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor, width: 0.9),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.l10n.from,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: textSecondary,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 15,
                                        color: textPrimary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    formatDatePill(tempStart),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // "To" Card
                      Expanded(
                        child: Material(
                          key: toCardKey,
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => openCupertinoCalendar(false),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E1E24) : const Color(0xFFF4F4F6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor, width: 0.9),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.l10n.to,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: textSecondary,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 15,
                                        color: textPrimary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    formatDatePill(tempEnd),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _startDate = tempStart;
                          _endDate = DateTime(tempEnd.year, tempEnd.month, tempEnd.day, 23, 59, 59);
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.white : const Color(0xFF09090B),
                        foregroundColor: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.confirm,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }

  Future<void> _pickMonthPickerIOS(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF09090B);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int selectedYear = _startDate.year > now.year ? now.year : _startDate.year;
    int selectedMonth = (selectedYear == now.year && _startDate.month > now.month)
        ? now.month
        : _startDate.month;

    final monthNamesAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final monthNamesEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthNames = isAr ? monthNamesAr : monthNamesEn;

    // Years only up to current year (cannot pick future year)
    final years = List.generate(now.year - 2020 + 1, (index) => 2020 + index);

    await showGlassModalSheet<void>(
      context: context,
      halfSize: 0.46,
      fullSize: 0.60,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                  // Header with selection pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.selectMonth,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Text(
                          '${monthNames[selectedMonth - 1]} $selectedYear',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dual CupertinoPicker Wheels for Month & Year
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1B1B20) : const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor, width: 0.8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        // Month Wheel
                        Expanded(
                          flex: 3,
                          child: Builder(
                            builder: (context) {
                              final availableMonthsCount = selectedYear == now.year ? now.month : 12;
                              final clampedIndex = (selectedMonth - 1).clamp(0, availableMonthsCount - 1);
                              return CupertinoPicker(
                                key: ValueKey('month-picker-$selectedYear-$availableMonthsCount'),
                                scrollController: FixedExtentScrollController(
                                  initialItem: clampedIndex,
                                ),
                                itemExtent: 42.0,
                                diameterRatio: 1.2,
                                selectionOverlay: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onSelectedItemChanged: (index) {
                                  HapticFeedback.selectionClick();
                                  setSheetState(() => selectedMonth = index + 1);
                                },
                                children: List.generate(availableMonthsCount, (index) {
                                  return Center(
                                    child: Text(
                                      monthNames[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        // Divider
                        Container(
                          width: 1,
                          height: 120,
                          color: borderColor,
                        ),
                        // Year Wheel
                        Expanded(
                          flex: 2,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: years.contains(selectedYear)
                                  ? years.indexOf(selectedYear)
                                  : 0,
                            ),
                            itemExtent: 42.0,
                            diameterRatio: 1.2,
                            selectionOverlay: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onSelectedItemChanged: (index) {
                              HapticFeedback.selectionClick();
                              final pickedYear = years[index];
                              setSheetState(() {
                                selectedYear = pickedYear;
                                if (selectedYear == now.year && selectedMonth > now.month) {
                                  selectedMonth = now.month;
                                }
                              });
                            },
                            children: years.map((y) {
                              return Center(
                                child: Text(
                                  '$y',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _startDate = DateTime(selectedYear, selectedMonth, 1);
                          final endDay = DateTime(selectedYear, selectedMonth + 1, 0);
                          _endDate = endDay.isAfter(today)
                              ? DateTime(today.year, today.month, today.day, 23, 59, 59)
                              : DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59);
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.white : const Color(0xFF09090B),
                        foregroundColor: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.confirm,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool isDarkMode,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E24) : const Color(0xFFF4F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
      ),
    );
  }
  //#endregion

  //#region Android Pickers (Concept 2: Bento Squircle & Connected Ribbon)
  Future<void> _pickCustomDateRangeAndroid(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final sheetBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final textSecondary = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime tempStart = _startDate.isAfter(today) ? today : _startDate;
    DateTime tempEnd = _endDate.isAfter(today) ? today : _endDate;
    DateTime viewingMonth = DateTime(tempStart.year, tempStart.month, 1);

    final monthNamesAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final monthNamesEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekDayNamesAr = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    final weekDayNamesEn = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final monthTitle = isAr
                ? '${monthNamesAr[viewingMonth.month - 1]} ${viewingMonth.year}'
                : '${monthNamesEn[viewingMonth.month - 1]} ${viewingMonth.year}';
            final weekDays = isAr ? weekDayNamesAr : weekDayNamesEn;

            final firstDayOfMonth = DateTime(viewingMonth.year, viewingMonth.month, 1);
            final daysInMonth = DateTime(viewingMonth.year, viewingMonth.month + 1, 0).day;
            final leadingEmptyDays = firstDayOfMonth.weekday % 7; // Sunday = 0

            String formatDatePill(DateTime d) {
              return DateFormat('d MMM yyyy', isAr ? 'ar' : 'en').format(d);
            }

            final dayCount = tempEnd.difference(tempStart).inDays + 1;
            final canGoNextMonth = viewingMonth.year < now.year ||
                (viewingMonth.year == now.year && viewingMonth.month < now.month);

            void applyDaysPreset(int days) {
              HapticFeedback.selectionClick();
              setSheetState(() {
                tempEnd = today;
                tempStart = today.subtract(Duration(days: days - 1));
                viewingMonth = DateTime(tempStart.year, tempStart.month, 1);
              });
            }

            void applyThisMonthPreset() {
              HapticFeedback.selectionClick();
              setSheetState(() {
                tempStart = DateTime(today.year, today.month, 1);
                tempEnd = today;
                viewingMonth = DateTime(today.year, today.month, 1);
              });
            }

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(ctx).padding.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Month Switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.customRange,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: textPrimary,
                        ),
                      ),
                      // Month Stepper Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: Icon(Icons.chevron_left_rounded, size: 20, color: textPrimary),
                              onPressed: () {
                                setSheetState(() {
                                  viewingMonth = DateTime(viewingMonth.year, viewingMonth.month - 1, 1);
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                monthTitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: canGoNextMonth
                                    ? textPrimary
                                    : textSecondary.withValues(alpha: 0.3),
                              ),
                              onPressed: canGoNextMonth
                                  ? () {
                                      setSheetState(() {
                                        viewingMonth = DateTime(viewingMonth.year, viewingMonth.month + 1, 1);
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Presets Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPresetChip(
                          label: context.l10n.last7Days,
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => applyDaysPreset(7),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: context.l10n.last30Days,
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => applyDaysPreset(30),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: context.l10n.thisMonth,
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: applyThisMonthPreset,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Selected Range Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E1E24) : const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          '${formatDatePill(tempStart)}  ←  ${formatDatePill(tempEnd)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: textPrimary,
                          ),
                        ),
                        if (dayCount > 1) ...[
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.daysCountInParens(dayCount),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weekday Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (final w in weekDays)
                        SizedBox(
                          width: 38,
                          child: Center(
                            child: Text(
                              w,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Calendar Days Grid with Connected Ribbon
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: leadingEmptyDays + daysInMonth,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 0,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (context, index) {
                      if (index < leadingEmptyDays) {
                        return const SizedBox.shrink();
                      }
                      final dayNum = index - leadingEmptyDays + 1;
                      final dayDate = DateTime(viewingMonth.year, viewingMonth.month, dayNum);
                      final isFuture = dayDate.isAfter(today);

                      final isStart = dayDate.year == tempStart.year &&
                          dayDate.month == tempStart.month &&
                          dayDate.day == tempStart.day;
                      final isEnd = dayDate.year == tempEnd.year &&
                          dayDate.month == tempEnd.month &&
                          dayDate.day == tempEnd.day;
                      final isSameDay = tempStart.year == tempEnd.year &&
                          tempStart.month == tempEnd.month &&
                          tempStart.day == tempEnd.day;
                      final isInBetween = dayDate.isAfter(tempStart) && dayDate.isBefore(tempEnd);

                      final ribbonBg = isDarkMode
                          ? Colors.white.withValues(alpha: 0.14)
                          : const Color(0xFFE4E4E7);
                      final endpointBg = isDarkMode ? Colors.white : const Color(0xFF09090B);
                      final endpointFg = isDarkMode ? const Color(0xFF09090B) : Colors.white;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isFuture
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  setSheetState(() {
                                    if (dayDate.isBefore(tempStart)) {
                                      tempStart = dayDate;
                                    } else if (isStart && !isEnd) {
                                      tempStart = dayDate;
                                    } else if (isSameDay) {
                                      tempEnd = dayDate;
                                    } else {
                                      tempStart = dayDate;
                                      tempEnd = dayDate;
                                    }
                                  });
                                },
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              // Ribbon connector background
                              if (!isFuture) ...[
                                if (isInBetween)
                                  Positioned.fill(
                                    top: 3,
                                    bottom: 3,
                                    child: Container(color: ribbonBg),
                                  )
                                else if (isStart && !isEnd)
                                  Positioned.fill(
                                    top: 3,
                                    bottom: 3,
                                    child: Row(
                                      children: [
                                        const Expanded(child: SizedBox.shrink()),
                                        Expanded(child: Container(color: ribbonBg)),
                                      ],
                                    ),
                                  )
                                else if (isEnd && !isStart)
                                  Positioned.fill(
                                    top: 3,
                                    bottom: 3,
                                    child: Row(
                                      children: [
                                        Expanded(child: Container(color: ribbonBg)),
                                        const Expanded(child: SizedBox.shrink()),
                                      ],
                                    ),
                                  ),
                              ],

                              // Day circle & text
                              Center(
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (!isFuture && (isStart || isEnd))
                                        ? endpointBg
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$dayNum',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: (!isFuture && (isStart || isEnd))
                                            ? FontWeight.w800
                                            : ((!isFuture && isInBetween)
                                                ? FontWeight.w700
                                                : FontWeight.w500),
                                        color: isFuture
                                            ? textSecondary.withValues(alpha: 0.25)
                                            : ((isStart || isEnd)
                                                ? endpointFg
                                                : (isInBetween ? textPrimary : textSecondary)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _startDate = tempStart;
                          _endDate = DateTime(tempEnd.year, tempEnd.month, tempEnd.day, 23, 59, 59);
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.white : const Color(0xFF09090B),
                        foregroundColor: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.confirm,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickMonthPickerAndroid(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final sheetBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final textSecondary = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int selectedYear = _startDate.year > now.year ? now.year : _startDate.year;
    int selectedMonth = (selectedYear == now.year && _startDate.month > now.month)
        ? now.month
        : _startDate.month;

    final monthNamesAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final monthNamesEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final monthNames = isAr ? monthNamesAr : monthNamesEn;
            final canGoNextYear = selectedYear < now.year;

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(ctx).padding.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Year Switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.selectMonth,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: textPrimary,
                        ),
                      ),
                      // Year stepper pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: Icon(Icons.chevron_left_rounded, size: 20, color: textPrimary),
                              onPressed: selectedYear > 2020
                                  ? () => setSheetState(() => selectedYear--)
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '$selectedYear',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: canGoNextYear
                                    ? textPrimary
                                    : textSecondary.withValues(alpha: 0.3),
                              ),
                              onPressed: canGoNextYear
                                  ? () {
                                      setSheetState(() {
                                        selectedYear++;
                                        if (selectedYear == now.year && selectedMonth > now.month) {
                                          selectedMonth = now.month;
                                        }
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Months Bento Squircle Cards Grid (Only shows months up to current month in current year)
                  Builder(
                    builder: (context) {
                      final displayedMonthsCount = selectedYear == now.year ? now.month : 12;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.55,
                        ),
                        itemCount: displayedMonthsCount,
                        itemBuilder: (context, idx) {
                          final monthNum = idx + 1;
                          final isSelected = selectedMonth == monthNum;
                          final numStr = monthNum < 10 ? '0$monthNum' : '$monthNum';

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setSheetState(() => selectedMonth = monthNum);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDarkMode ? Colors.white : const Color(0xFF09090B))
                                      : (isDarkMode ? const Color(0xFF1B1B20) : const Color(0xFFF4F4F6)),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDarkMode ? Colors.white : const Color(0xFF09090B))
                                        : borderColor,
                                    width: isSelected ? 1.4 : 0.8,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.12),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          numStr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            fontFamily: 'monospace',
                                            color: isSelected
                                                ? (isDarkMode ? const Color(0xFF09090B).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.7))
                                                : textSecondary,
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      monthNames[idx],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        letterSpacing: -0.2,
                                        color: isSelected
                                            ? (isDarkMode ? const Color(0xFF09090B) : Colors.white)
                                            : textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _startDate = DateTime(selectedYear, selectedMonth, 1);
                          final endDay = DateTime(selectedYear, selectedMonth + 1, 0);
                          _endDate = endDay.isAfter(today)
                              ? DateTime(today.year, today.month, today.day, 23, 59, 59)
                              : DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59);
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.white : const Color(0xFF09090B),
                        foregroundColor: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.confirm,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  //#endregion


  Widget _buildCircularActionItem({
    required IconData icon,
    required String label,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassButton(
          onTap: onTap,
          width: 52,
          height: 52,
          shape: const LiquidOval(),
          useOwnLayer: true,
          settings: LiquidGlassSettings(
            thickness: 16,
            blur: 10,
            glassColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.22),
          ),
          icon: Icon(
            icon,
            size: 22,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: isDarkMode
                ? null
                : [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.60),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
        ),
      ],
    );
  }
  //#endregion

  //#region Auto-Tracking & Get Started Carousel
  Future<void> _dismissGetStartedCard(String cardId, int cardIndex, int totalCards) async {
    if (_isDismissingCard) return;

    setState(() {
      _isDismissingCard = true;
      _animatingDismissCardId = cardId;
    });

    if (totalCards <= 1) {
      // Last remaining card: wait for scale & fade out
      await Future.delayed(const Duration(milliseconds: 240));
      if (!mounted) return;
      setState(() {
        _dismissedGetStartedCards.add(cardId);
        _showAutoTrackingBanner = false;
        _animatingDismissCardId = null;
        _isDismissingCard = false;
      });
      return;
    }

    if (cardIndex < totalCards - 1) {
      // Smoothly glide forward to next card while this one vanishes
      if (_getStartedPageController.hasClients) {
        await _getStartedPageController.animateToPage(
          cardIndex + 1,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 280));
      }
      if (!mounted) return;
      _getStartedPageController.dispose();
      _getStartedPageController = PageController(
        viewportFraction: 0.90,
        initialPage: cardIndex,
      );
      setState(() {
        _dismissedGetStartedCards.add(cardId);
        _getStartedCardIndex = cardIndex;
        _animatingDismissCardId = null;
        _isDismissingCard = false;
      });
    } else {
      // Last card in carousel: glide back to previous card
      if (_getStartedPageController.hasClients) {
        await _getStartedPageController.animateToPage(
          cardIndex - 1,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 280));
      }
      if (!mounted) return;
      _getStartedPageController.dispose();
      _getStartedPageController = PageController(
        viewportFraction: 0.90,
        initialPage: cardIndex - 1,
      );
      setState(() {
        _dismissedGetStartedCards.add(cardId);
        _getStartedCardIndex = cardIndex - 1;
        _animatingDismissCardId = null;
        _isDismissingCard = false;
      });
    }
  }

  //#region Compact Wallets Bar
  Widget _buildWalletsCarousel(bool isDarkMode, HideBalanceService hideService) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final isAr = isRtl || Localizations.localeOf(context).languageCode == 'ar';
    final wallets = _walletsCarouselList;

    if (wallets.isEmpty) return const SizedBox.shrink();




    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Matches Recent Transactions with "View all" / "عرض الكل"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.myWallets,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showManageAccountsModal,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          context.l10n.viewAll,
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Compact Clean Cards with Shadow on Active (no border on active, no clipping!)
        SizedBox(
          height: 104,
          child: ListView.separated(
            controller: _walletsScrollController,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: wallets.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == wallets.length) {
                // Sleek "+ Add" Card
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showAddAccountModal,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF131317) : const Color(0xFFF8F9FB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.add,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final acc = wallets[index];
              final isSelected = acc.id == _selectedAccountId;

              return IosHoldContextMenu(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _heroSlideFromLeft = false;
                    _selectedAccountId = acc.id;
                  });
                },
                actions: [
                  IosContextMenuAction(
                    id: 'transfer',
                    title: isAr ? 'تحويل' : 'Transfer',
                    iconSystemName: 'arrow.left.arrow.right',
                  ),
                  IosContextMenuAction(
                    id: 'adjust_balance',
                    title: isAr ? 'تعديل الرصيد' : 'Adjust Balance',
                    iconSystemName: 'slider.horizontal.3',
                  ),
                  IosContextMenuAction(
                    id: 'edit_account',
                    title: isAr ? 'تعديل الحساب' : 'Edit Account',
                    iconSystemName: 'pencil',
                  ),
                ],
                onSelected: (actionId) {
                  switch (actionId) {
                    case 'transfer':
                      _showUnifiedAddModal(
                        initialType: TransactionType.transfer,
                        initialAccountId: acc.id,
                      );
                      break;
                    case 'adjust_balance':
                      _showAdjustBalanceModal(acc, isDarkMode, isAr);
                      break;
                    case 'edit_account':
                      _showEditAccountModal(acc, isDarkMode, isAr);
                      break;
                  }
                },
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 156,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDarkMode ? const Color(0xFF1C1C24) : Colors.white)
                          : (isDarkMode ? const Color(0xFF131317) : const Color(0xFFF9FAFC)),
                      borderRadius: BorderRadius.circular(16),
                      // NO border when active, shadow only!
                      border: isSelected
                          ? null
                          : Border.all(
                              color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFEBECEF),
                              width: 1,
                            ),
                      boxShadow: isSelected
                          ? [
                              // Ambient 360-degree soft black shadow: clearly defines all 4 edges against bg
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDarkMode ? 0.45 : 0.09),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: Offset.zero,
                              ),
                              // Directional depth shadow
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDarkMode ? 0.60 : 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDarkMode ? 0.30 : 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top Row: Icon + Title next to it
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: isSelected ? 0.12 : 0.06),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Icon(
                                acc.icon,
                                color: isDarkMode ? Colors.white : Colors.black,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                acc.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isDarkMode
                                      ? (isSelected ? Colors.white : Colors.grey[300])
                                      : (isSelected ? Colors.black : Colors.grey[800]),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Bottom: Balance & Currency under the icon
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                          child: _buildBlurrableNumber(
                            acc.balance,
                            TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDarkMode ? Colors.white : Colors.black,
                              letterSpacing: -0.3,
                            ),
                            hideService.isHidden,
                            currencyCode: acc.currency,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
            },
          ),
        ),
      ],
    );
  }
  //#endregion

  Widget _buildAutoTrackingBanner(bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final allCards = [
      (
        id: 'auto_track',
        icon: Icons.bolt_rounded,
        title: context.l10n.autoTrackSpendingTitle,
        subtitle: context.l10n.autoTrackSpendingSubtitle,
        actionText: context.l10n.setUpNow,
        onTap: () {
          MessageService.showSuccess(
            context: context,
            message: context.l10n.autoSyncComingSoon,
          );
        },
      ),
      (
        id: 'salary',
        icon: Icons.payments_rounded,
        title: context.l10n.addSalaryIncomeTitle,
        subtitle: context.l10n.addSalaryIncomeSubtitle,
        actionText: context.l10n.addSalary,
        onTap: () => _showUnifiedAddModal(),
      ),
      (
        id: 'accounts',
        icon: Icons.account_balance_wallet_rounded,
        title: context.l10n.organizeAccountsTitle,
        subtitle: context.l10n.organizeAccountsSubtitle,
        actionText: context.l10n.addAccount,
        onTap: () => _showAddAccountModal(),
      ),
      (
        id: 'budget',
        icon: Icons.pie_chart_rounded,
        title: context.l10n.setMonthlyBudgetPromptTitle,
        subtitle: context.l10n.setMonthlyBudgetPromptSubtitle,
        actionText: context.l10n.createBudget,
        onTap: () {
          MessageService.showSuccess(
            context: context,
            message: context.l10n.budgetAlertsComingSoon,
          );
        },
      ),
    ];

    final cards = allCards.where((c) => !_dismissedGetStartedCards.contains(c.id)).toList();

    if (!_showAutoTrackingBanner || cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeIndex = _getStartedCardIndex.clamp(0, cards.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: "Get started" title + Dynamic Dots
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.getStarted,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.black,
                  letterSpacing: -0.3,
                ),
              ),
              if (cards.length > 1)
                Row(
                  children: List.generate(cards.length, (idx) {
                    final isActive = activeIndex == idx;
                    return GestureDetector(
                      onTap: () {
                        _getStartedPageController.animateToPage(
                          idx,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        height: 5,
                        width: isActive ? 14 : 5,
                        decoration: BoxDecoration(
                          color: isActive
                              ? (isDarkMode ? Colors.white : Colors.black)
                              : (isDarkMode ? Colors.grey[800] : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal Swipeable Cards
        SizedBox(
          height: 138,
          child: PageView.builder(
            key: ValueKey('get_started_${_dismissedGetStartedCards.length}'),
            controller: _getStartedPageController,
            itemCount: cards.length,
            onPageChanged: (idx) {
              if (_isDismissingCard) return;
              setState(() => _getStartedCardIndex = idx);
            },
            itemBuilder: (context, index) {
              final card = cards[index];
              final isDismissing = _animatingDismissCardId == card.id;

              return AnimatedScale(
                scale: isDismissing ? 0.85 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: isDismissing ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      key: ValueKey(card.id),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF16161B) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF26262E) : const Color(0xFFE8EAEE),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.40 : 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Subtle background watermark icon at the trailing bottom edge
                          PositionedDirectional(
                            end: -10,
                            bottom: -12,
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: isDarkMode ? 0.05 : 0.035,
                                child: Icon(
                                  card.icon,
                                  size: 100,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),

                          // Main Card Content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Top area: Header + Subtitle
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top Row: Icon badge + Title + Close button
                                    Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.07),
                                            borderRadius: BorderRadius.circular(9),
                                            border: Border.all(
                                              color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.07),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            card.icon,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                            card.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: isDarkMode ? Colors.white : Colors.black,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        InkWell(
                                          onTap: () => _dismissGetStartedCard(card.id, index, cards.length),
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 16,
                                              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    // Subtitle
                                    Text(
                                      card.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        height: 1.3,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),

                                // Bottom: Slightly larger Action Pill near the border
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: card.onTap,
                                      borderRadius: BorderRadius.circular(9),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isDarkMode ? Colors.white : Colors.black,
                                          borderRadius: BorderRadius.circular(9),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              card.actionText,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: isDarkMode ? Colors.black : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Icon(
                                              isAr ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                              size: 13,
                                              color: isDarkMode ? Colors.black : Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
              );
            },
          ),
        ),
      ],
    );
  }
  //#endregion

  //#region Recent Transactions Section (Say Style)
  Widget _buildRecentTransactionsSection(bool isDarkMode) {
    final transactions = _filteredTransactions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.recentTransactions,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final allTransactions = await _loadAllTransactions();
                    if (!mounted) return;
                    _showAllTransactionsModal(allTransactions);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          context.l10n.viewAll,
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey('tx_list_$_selectedAccountId'),
              child: transactions.isEmpty
                  ? _buildEmptyState(isDarkMode)
                  : SlidableAutoCloseBehavior(
                      closeWhenOpened: true,
                      closeWhenTapped: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: transactions
                            .take(4)
                            .map((t) => _buildTransactionCard(t, isDarkMode))
                            .toList(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  //#endregion


  //#region Financial Insights 2x2 Bento Grid (Realistic Data & App Theme)
  Widget _buildInsightsGridSection(bool isDarkMode, HideBalanceService hideService) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final isAr = isRtl || Localizations.localeOf(context).languageCode == 'ar';
    final balance = _homeData?.balance;
    final totalSpent = _budgetData?.currentSpending ?? (balance?.totalWithdrawals ?? 0.0);
    final monthlyBudget = _budgetData?.monthlyBudget ?? 0.0;
    final remaining = (monthlyBudget - totalSpent).clamp(0.0, double.infinity);
    final ratio = monthlyBudget > 0 ? (totalSpent / monthlyBudget).clamp(0.0, 1.0) : 0.0;
    final percentage = (ratio * 100).toInt();
    final isOverBudget = monthlyBudget > 0 && totalSpent > monthlyBudget;
    final hasBudget = monthlyBudget > 0;

    // Upcoming Bill
    final upcoming = _upcomingSubscription;
    final now = DateTime.now();
    int? daysUntil;
    if (upcoming != null) {
      int diff = upcoming.renewalDay - now.day;
      if (diff < 0) diff += 30;
      daysUntil = diff;
    }

    // Daily safe spend calculation
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (lastDayOfMonth - now.day + 1).clamp(1, 31);
    final dailySafeSpend = remaining / daysLeft;

    // Real Money Flow & Savings Rate
    final totalIncome = balance?.totalDeposits ?? 0.0;
    final totalExpense = balance?.totalWithdrawals ?? 0.0;
    final netCashFlow = totalIncome - totalExpense;
    final isPositiveFlow = netCashFlow >= 0;
    final savingsRate = totalIncome > 0
        ? ((netCashFlow / totalIncome) * 100).toInt().clamp(0, 100)
        : 0;

    // Real Top Spending Category calculation
    final expenseCats = (_budgetData?.categoryBudgets ?? [])
        .where((c) => c.spent > 0)
        .toList();
    expenseCats.sort((a, b) => b.spent.compareTo(a.spent));
    final topCat = expenseCats.isNotEmpty ? expenseCats.first : null;
    final topCatName = topCat != null
        ? (isAr ? topCat.categoryNameAr : topCat.categoryNameEn)
        : '';

    IconData getCatIcon(int catId, String name) {
      final lower = name.toLowerCase();
      if (catId == 1 || lower.contains('food') || lower.contains('طعام') || lower.contains('مطاعم')) {
        return Icons.restaurant_rounded;
      }
      if (catId == 2 || lower.contains('shop') || lower.contains('تسوق') || lower.contains('مستلزمات')) {
        return Icons.shopping_bag_rounded;
      }
      if (catId == 3 || lower.contains('bill') || lower.contains('فواتير') || lower.contains('خدمات')) {
        return Icons.receipt_long_rounded;
      }
      if (lower.contains('trans') || lower.contains('مواصلات') || lower.contains('سيارة')) {
        return Icons.directions_car_rounded;
      }
      if (lower.contains('health') || lower.contains('صحة') || lower.contains('طبي')) {
        return Icons.medical_services_rounded;
      }
      return Icons.category_rounded;
    }

    final topCatIcon = topCat != null
        ? getCatIcon(topCat.categoryId, topCatName)
        : Icons.pie_chart_outline_rounded;

    // Standard Cohesive Bento Card Decoration (Matches App Theme)
    final cardDecoration = BoxDecoration(
      color: isDarkMode ? const Color(0xFF141418) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );

    // 1. Monthly Budget Card
    Widget buildBudgetCard() {
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(2); // Budgets Tab
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 156,
              padding: const EdgeInsets.all(13),
              decoration: cardDecoration,
              child: hasBudget
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.budget,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isOverBudget
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                                    : (isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isOverBudget
                                      ? const Color(0xFFEF4444)
                                      : (isDarkMode ? Colors.white : Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                              child: Text(
                                hideService.isHidden ? '••••••' : _formatAmount(remaining),
                                textDirection: ui.TextDirection.ltr,
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                  color: isOverBudget
                                      ? const Color(0xFFEF4444)
                                      : (isDarkMode ? Colors.white : Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isOverBudget
                                  ? context.l10n.overLimit
                                  : context.l10n.remainingMonth,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: SizedBox(
                                height: 4.5,
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  backgroundColor:
                                      isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isOverBudget
                                        ? const Color(0xFFEF4444)
                                        : ratio > 0.85
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '~${hideService.isHidden ? '••••' : _formatAmount(dailySafeSpend)} ${context.l10n.perDay}',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.budget,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                context.l10n.notSet,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.l10n.tapToSetMonthlyBudget,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              size: 12,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.setBudget,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    // 2. Accounts Distribution Card (with Mini Donut / Pie Chart)
    Widget buildAccountsCard() {
      final accountsList = _accounts.where((a) => !a.isAll).toList();
      accountsList.sort((a, b) => b.balance.compareTo(a.balance));
      final activeCount = accountsList.length;
      final totalAccBalance = accountsList.fold<double>(0.0, (s, a) => s + (a.balance > 0 ? a.balance : 0.0));
      final topAcc = accountsList.isNotEmpty ? accountsList.first : null;

      final accColors = [
        const Color(0xFF10B981), // Emerald
        const Color(0xFF3B82F6), // Blue
        const Color(0xFFF59E0B), // Amber
        const Color(0xFF8B5CF6), // Purple
      ];

      final chartValues = accountsList.map((a) => a.balance > 0 ? a.balance : 0.0).toList();

      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              _showManageAccountsModal();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 156,
              padding: const EdgeInsets.all(13),
              decoration: cardDecoration,
              child: accountsList.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.accounts,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                context.l10n.walletsCount(activeCount),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _MiniDonutChart(
                              values: chartValues,
                              colors: accColors,
                              size: 46,
                              strokeWidth: 5.5,
                              centerChild: Icon(
                                topAcc?.icon ?? Icons.account_balance_wallet_rounded,
                                size: 13,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    topAcc?.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    hideService.isHidden
                                        ? '••••••'
                                        : _formatAmount(topAcc?.balance ?? 0.0, currencyCode: topAcc?.currency),
                                    textDirection: ui.TextDirection.ltr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ...List.generate(
                              math.min(3, accountsList.length),
                              (i) {
                                final acc = accountsList[i];
                                final pct = totalAccBalance > 0
                                    ? ((acc.balance / totalAccBalance) * 100).toInt()
                                    : 0;
                                final color = accColors[i % accColors.length];
                                return Padding(
                                  padding: const EdgeInsetsDirectional.only(end: 7),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '$pct%',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.accounts,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                context.l10n.walletsCount(0),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.l10n.tapToManageWallets,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.add_circle_outline_rounded, size: 12, color: isDarkMode ? Colors.white : Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.manageWallets,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    // 3. Top Spending Category Card (with Mini Donut / Pie Chart)
    Widget buildTopCategoryCard() {
      final expenseCats = (_budgetData?.categoryBudgets ?? [])
          .where((c) => c.spent > 0)
          .toList();
      expenseCats.sort((a, b) => b.spent.compareTo(a.spent));
      final hasTopCat = expenseCats.isNotEmpty;
      final topCat = hasTopCat ? expenseCats.first : null;
      final topCatName = topCat != null
          ? (isAr ? topCat.categoryNameAr : topCat.categoryNameEn)
          : '';
      final topCatSpent = topCat?.spent ?? 0.0;
      final effectiveTotalSpent = totalSpent > 0 ? totalSpent : 1.0;
      final topCatRatio = (topCatSpent / effectiveTotalSpent).clamp(0.0, 1.0);
      final topCatPct = (topCatRatio * 100).toInt();

      final catColors = [
        isDarkMode ? Colors.white : const Color(0xFF18181B), // Top category high contrast
        const Color(0xFF10B981), // Emerald
        const Color(0xFF3B82F6), // Blue
        const Color(0xFFF59E0B), // Amber
        const Color(0xFF8B5CF6), // Purple
      ];

      final catChartValues = <double>[];
      for (int i = 0; i < expenseCats.length && i < 3; i++) {
        catChartValues.add(expenseCats[i].spent);
      }
      final topCatsSum = catChartValues.fold<double>(0.0, (s, v) => s + v);
      if (totalSpent > topCatsSum) {
        catChartValues.add(totalSpent - topCatsSum);
      }

      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(2); // Budgets Tab
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 156,
              padding: const EdgeInsets.all(13),
              decoration: cardDecoration,
              child: hasTopCat
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.topCategories,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$topCatPct%',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _MiniDonutChart(
                              values: catChartValues,
                              colors: catColors,
                              size: 46,
                              strokeWidth: 5.5,
                              centerChild: Icon(
                                topCatIcon,
                                size: 13,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    topCatName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    hideService.isHidden ? '••••••' : _formatAmount(topCatSpent),
                                    textDirection: ui.TextDirection.ltr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ...List.generate(
                              math.min(2, expenseCats.length),
                              (i) {
                                final cat = expenseCats[i];
                                final pct = effectiveTotalSpent > 0
                                    ? ((cat.spent / effectiveTotalSpent) * 100).toInt()
                                    : 0;
                                final color = catColors[i % catColors.length];
                                return Padding(
                                  padding: const EdgeInsetsDirectional.only(end: 7),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '$pct%',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                context.l10n.topCategories,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                context.l10n.balanced,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.pie_chart_outline_rounded,
                                size: 16,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.l10n.balancedSpending,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.viewCategories,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    // 4. Cash Flow & Net Card
    Widget buildCashFlowCard() {
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(1); // Analytics Tab
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 156,
              padding: const EdgeInsets.all(13),
              decoration: cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.cashFlow,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isPositiveFlow ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPositiveFlow
                              ? context.l10n.savedPercent(savingsRate)
                              : context.l10n.deficit,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isPositiveFlow ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          hideService.isHidden
                              ? '••••••'
                              : _formatAmount(
                                  netCashFlow.abs(),
                                  prefix: isPositiveFlow ? '+ ' : '- ',
                                ),
                          textDirection: ui.TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: isPositiveFlow
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPositiveFlow
                            ? context.l10n.positiveFlowMonth
                            : context.l10n.negativeFlowMonth,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.incoming,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            hideService.isHidden ? '••••' : _formatAmount(totalIncome),
                            textDirection: ui.TextDirection.ltr,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey[500] : Colors.grey[700],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.outgoing,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            hideService.isHidden ? '••••' : _formatAmount(totalExpense),
                            textDirection: ui.TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 5. Upcoming Bill & Subscriptions Wide Card (Bento Row 3)
    Widget buildSubscriptionWideCard() {
      final hasUpcoming = upcoming != null;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            if (widget.onNavigateToTab != null) {
              widget.onNavigateToTab!(3); // Subscriptions Tab
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: cardDecoration,
            child: hasUpcoming
                ? Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          upcoming.icon,
                          size: 18,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    upcoming.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: (daysUntil == 0)
                                        ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                                        : (daysUntil == 1)
                                            ? const Color(0xFFF59E0B).withValues(alpha: 0.14)
                                            : (isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5)),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    daysUntil == 0
                                        ? context.l10n.dueToday
                                        : daysUntil == 1
                                            ? context.l10n.dueTomorrow
                                            : context.l10n.dueInDays(daysUntil ?? 0),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: (daysUntil == 0)
                                          ? const Color(0xFFEF4444)
                                          : (daysUntil == 1)
                                              ? const Color(0xFFF59E0B)
                                              : (isDarkMode ? Colors.white : Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.dueDayWithBillsCount(upcoming.renewalDay, _subscriptions.length),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hideService.isHidden ? '••••••' : _formatAmount(upcoming.amount),
                            textDirection: ui.TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.viewAll,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 8.5,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.event_available_rounded,
                          size: 18,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.l10n.billsAndSubscriptions,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.noUpcomingBills,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, size: 12, color: Color(0xFF10B981)),
                            const SizedBox(width: 2),
                            Text(
                              context.l10n.add,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.financialInsights,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (widget.onNavigateToTab != null) {
                      widget.onNavigateToTab!(1); // Analytics / Insights Tab
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.fullAnalytics,
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bento Row 1: Budget & Cash Flow
          Row(
            children: [
              buildBudgetCard(),
              const SizedBox(width: 12),
              buildCashFlowCard(),
            ],
          ),
          const SizedBox(height: 12),

          // Bento Row 2: Accounts & Spending Categories (Both with Mini Donut Charts!)
          Row(
            children: [
              buildAccountsCard(),
              const SizedBox(width: 12),
              buildTopCategoryCard(),
            ],
          ),
          const SizedBox(height: 12),

          // Bento Row 3: Upcoming Bills & Subscriptions
          buildSubscriptionWideCard(),
        ],
      ),
    );
  }
  //#endregion
  //#endregion

  //#region Say-Style Transaction Item Card
  @override
  Widget _buildTransactionCard(WalletTransaction transaction, bool isDarkMode) {
    final isIncome = transaction.isDeposit;
    final hideService = Provider.of<HideBalanceService>(context, listen: true);
    final locale = Localizations.localeOf(context).languageCode;
    final categoryName = locale == 'ar'
        ? (transaction.categoryNameAr ?? transaction.categoryNameEn ?? '')
        : (transaction.categoryNameEn ?? transaction.categoryNameAr ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: Key('transaction_${transaction.id}'),
        groupTag: 'home_transactions_list',
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.28,
          dismissible: Builder(
            builder: (paneContext) => DismissiblePane(
              motion: const _SlidableSeamlessStretchMotion(),
              dismissThreshold: 0.90,
              closeOnCancel: false,
              confirmDismiss: () async {
                HapticFeedback.lightImpact();
                Slidable.of(paneContext)?.openCurrentActionPane();
                return false;
              },
              onDismissed: () {},
            ),
          ),
          children: [
            CustomSlidableAction(
              onPressed: (_) {
                HapticFeedback.selectionClick();
                _showDeleteConfirmationDialog(transaction);
              },
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(18),
              padding: EdgeInsets.zero,
              child: const Icon(
                CupertinoIcons.trash_fill,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _showEditTransactionDialog(transaction);
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
          children: [
            // Category Mono Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                transaction.icon,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Title & Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title.isNotEmpty ? transaction.title : categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (categoryName.isNotEmpty) ...[
                        Flexible(
                          child: Text(
                            categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      Text(
                        _formatDate(transaction.transactionDate),
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Amount
            _buildBlurrableNumber(
              transaction.amount,
              TextStyle(
                color: isIncome
                    ? (isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669))
                    : (isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFDC2626)),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              hideService.isHidden,
              prefix: isIncome ? '+ ' : '- ',
            ),
          ],
        ),
      ),
    ),
    ),
    ),
    ),
    );
  }
  //#endregion

  //#region Empty State
  @override
  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 32,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.l10n.noTransactions,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.tapToAddFirstExpense,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
  //#endregion

  //#region Error Widget
  @override
  Widget _buildErrorWidget(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFF43F5E),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.somethingWentWrong,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHomeData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.white : Colors.black,
                foregroundColor: isDarkMode ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
  //#endregion

  //#region Blur Number Helper
  Widget _buildBlurrableNumber(
    double amount,
    TextStyle style,
    bool blurred, {
    String prefix = '',
    String? currencyCode,
  }) {
    final formatted = _formatAmount(amount, currencyCode: currencyCode, prefix: prefix);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: blurred ? 0 : 8, end: blurred ? 8 : 0),
      duration: const Duration(milliseconds: 250),
      builder: (context, sigma, child) {
        if (sigma == 0) {
          return Text(
            formatted,
            style: style,
            textDirection: ui.TextDirection.ltr,
          );
        }
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Text(
            formatted,
            style: style,
            textDirection: ui.TextDirection.ltr,
          ),
        );
      },
    );
  }
  //#endregion
}

//#region Mini Donut / Pie Chart Component
class _MiniDonutChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final Widget? centerChild;
  final double size;
  final double strokeWidth;

  const _MiniDonutChart({
    required this.values,
    required this.colors,
    this.centerChild,
    this.size = 46,
    this.strokeWidth = 5.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _MiniDonutChartPainter(
              values: values,
              colors: colors,
              strokeWidth: strokeWidth,
            ),
          ),
          if (centerChild != null) centerChild!,
        ],
      ),
    );
  }
}

class _MiniDonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;

  _MiniDonutChartPainter({
    required this.values,
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final total = values.fold<double>(0.0, (s, v) => s + (v > 0 ? v : 0.0));

    // Base subtle track ring
    final trackPaint = Paint()
      ..color = (colors.isNotEmpty ? colors.first : Colors.grey).withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (total <= 0 || values.isEmpty) {
      return;
    }

    const startAngleBase = -math.pi / 2;
    double currentAngle = startAngleBase;
    final nonZeroCount = values.where((v) => v > 0).length;
    final hasMultiple = nonZeroCount > 1;
    // 0.08 radians (~4.6 degrees) clean gap between slices
    final gapAngle = hasMultiple ? 0.08 : 0.0;

    for (int i = 0; i < values.length; i++) {
      final val = values[i];
      if (val <= 0) continue;
      final sweepAngle = (val / total) * 2 * math.pi;
      final actualSweep = hasMultiple ? math.max(0.04, sweepAngle - gapAngle) : sweepAngle;
      final actualStart = hasMultiple ? currentAngle + (gapAngle / 2) : currentAngle;

      final paint = Paint()
        ..color = colors[i % colors.length]
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
  bool shouldRepaint(covariant _MiniDonutChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.colors != colors ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
//#endregion

//#region Slidable Seamless Stretch Motion
class _SlidableSeamlessStretchMotion extends StatelessWidget {
  const _SlidableSeamlessStretchMotion();

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context);
    final controller = Slidable.of(context);

    if (paneData == null || controller == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: controller.animation,
      builder: (BuildContext context, Widget? child) {
        final value = controller.animation.value.clamp(0.0, 1.0);
        return FractionallySizedBox(
          alignment: paneData.alignment,
          widthFactor: paneData.direction == Axis.horizontal ? value : 1.0,
          heightFactor: paneData.direction == Axis.horizontal ? 1.0 : value,
          child: child,
        );
      },
      child: const ClipRect(
        child: BehindMotion(),
      ),
    );
  }
}
//#endregion

