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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isIOS = Platform.isIOS;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: User Profile Avatar
          Material(
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
              ? Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: CNPopupMenuButton(
                      buttonLabel: '$_formattedDateRange ⌵',
                      height: 26,
                      tint: Colors.white,
                      shrinkWrap: true,
                      buttonStyle: CNButtonStyle.plain,
                      items: [
                        CNPopupMenuItem(
                          label: isAr ? 'هذا الشهر' : 'This Month',
                          icon: const CNSymbol('calendar', size: 18.0),
                        ),
                        CNPopupMenuItem(
                          label: isAr ? 'الشهر السابق' : 'Last Month',
                          icon: const CNSymbol('clock.arrow.circlepath', size: 18.0),
                        ),
                        const CNPopupMenuDivider(),
                        CNPopupMenuItem(
                          label: isAr ? 'بالشهر...' : 'By Month...',
                          icon: const CNSymbol('calendar.day.timeline.left', size: 18.0),
                        ),
                        CNPopupMenuItem(
                          label: isAr ? 'فترة مخصصة...' : 'Custom Range...',
                          icon: const CNSymbol('calendar.badge.clock', size: 18.0),
                        ),
                      ],
                      onSelected: (index) async {
                        final now = DateTime.now();
                        if (index == 0) {
                          setState(() {
                            _startDate = DateTime(now.year, now.month, 1);
                            _endDate = DateTime(now.year, now.month + 1, 0);
                          });
                        } else if (index == 1) {
                          setState(() {
                            _startDate = DateTime(now.year, now.month - 1, 1);
                            _endDate = DateTime(now.year, now.month, 0);
                          });
                        } else if (index == 3) { // By Month (index 2 is divider)
                          await _pickMonthPicker(context);
                        } else if (index == 4) { // Custom Range
                          await _pickCustomDateRange(context);
                        }
                      },
                    ),
                  ),
                )
              : Theme(
                  data: Theme.of(context).copyWith(
                    popupMenuTheme: PopupMenuThemeData(
                      color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFE4E4E7),
                          width: 1,
                        ),
                      ),
                      shadowColor: Colors.black.withValues(alpha: 0.25),
                    ),
                  ),
                  child: PopupMenuButton<int>(
                    tooltip: isAr ? 'تحديد الفترة' : 'Select date range',
                    offset: const Offset(0, 34),
                    position: PopupMenuPosition.under,
                    elevation: 8,
                    color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFE4E4E7),
                        width: 1,
                      ),
                    ),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    onSelected: (index) async {
                      HapticFeedback.selectionClick();
                      final now = DateTime.now();
                      if (index == 0) {
                        setState(() {
                          _startDate = DateTime(now.year, now.month, 1);
                          _endDate = DateTime(now.year, now.month + 1, 0);
                        });
                      } else if (index == 1) {
                        setState(() {
                          _startDate = DateTime(now.year, now.month - 1, 1);
                          _endDate = DateTime(now.year, now.month, 0);
                        });
                      } else if (index == 2) {
                        await _pickMonthPicker(context);
                      } else if (index == 3) {
                        await _pickCustomDateRange(context);
                      }
                    },
                    itemBuilder: (context) {
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

                      return [
                        _buildMenuOptionItem(
                          value: 0,
                          title: isAr ? 'هذا الشهر' : 'This Month',
                          icon: Icons.calendar_today_rounded,
                          isSelected: isThisMonth,
                          isDarkMode: isDarkMode,
                        ),
                        _buildMenuOptionItem(
                          value: 1,
                          title: isAr ? 'الشهر السابق' : 'Last Month',
                          icon: Icons.history_rounded,
                          isSelected: isLastMonth,
                          isDarkMode: isDarkMode,
                        ),
                        const PopupMenuDivider(height: 8),
                        _buildMenuOptionItem(
                          value: 2,
                          title: isAr ? 'بالشهر...' : 'By Month...',
                          icon: Icons.calendar_month_rounded,
                          isSelected: !isThisMonth && !isLastMonth && _startDate.day == 1 && _endDate.day == DateTime(_startDate.year, _startDate.month + 1, 0).day,
                          isDarkMode: isDarkMode,
                        ),
                        _buildMenuOptionItem(
                          value: 3,
                          title: isAr ? 'فترة مخصصة...' : 'Custom Range...',
                          icon: Icons.date_range_rounded,
                          isSelected: !isThisMonth && !isLastMonth && !(_startDate.day == 1 && _endDate.day == DateTime(_startDate.year, _startDate.month + 1, 0).day),
                          isDarkMode: isDarkMode,
                        ),
                      ];
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formattedDateRange,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

          // Right: Analytics Chart Icon
          Material(
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
  //#endregion

  //#region Hero Header (Say Style - Spent & Balance)
  Widget _buildSayHeroHeader(bool isDarkMode, HideBalanceService hideService) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
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
            // "Wallet Balance" Label
            Text(
              isAr ? 'الرصيد' : 'Balance',
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
                    ? CNPopupMenuButton(
                        buttonLabel: '${_selectedAccount.name} ⌵',
                        height: 22,
                        tint: Colors.white.withValues(alpha: 0.90),
                        shrinkWrap: true,
                        buttonStyle: CNButtonStyle.plain,
                        items: [
                          ..._accounts.map((acc) {
                            final isSelected = acc.id == _selectedAccountId;
                            final label = acc.isMain ? '${acc.name} ⭐' : acc.name;
                            return CNPopupMenuItem(
                              label: label,
                              icon: CNSymbol(
                                isSelected ? 'checkmark.circle.fill' : 'circle',
                                size: 16.0,
                              ),
                            );
                          }),
                          const CNPopupMenuDivider(),
                          CNPopupMenuItem(
                            label: isAr ? 'إضافة حساب جديد' : 'Add account',
                            icon: const CNSymbol('plus', size: 16.0),
                          ),
                          CNPopupMenuItem(
                            label: isAr ? 'إدارة المحافظ والحسابات' : 'Manage accounts',
                            icon: const CNSymbol('slider.horizontal.3', size: 16.0),
                          ),
                        ],
                        onSelected: (index) {
                          final accountsCount = _accounts.length;
                          if (index < accountsCount) {
                            final targetAcc = _accounts[index];
                            final curIdx = _accounts.indexWhere((a) => a.id == _selectedAccountId);
                            final isMovingForward = index > curIdx;
                            setState(() {
                              _heroSlideFromLeft = isRtl ? isMovingForward : !isMovingForward;
                              _selectedAccountId = targetAcc.id;
                            });
                            _syncWalletsCarouselToSelected();
                          } else if (index == accountsCount + 1) { // after divider
                            _showAddAccountModal();
                          } else if (index == accountsCount + 2) {
                            _showManageAccountsModal();
                          }
                        },
                      )
                    : Theme(
                        data: Theme.of(context).copyWith(
                          popupMenuTheme: PopupMenuThemeData(
                            color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
                            surfaceTintColor: Colors.transparent,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFE4E4E7),
                                width: 1,
                              ),
                            ),
                            shadowColor: Colors.black.withValues(alpha: 0.25),
                          ),
                        ),
                        child: PopupMenuButton<int>(
                          tooltip: isAr ? 'تبديل المحفظة' : 'Switch wallet',
                          offset: const Offset(0, 26),
                          position: PopupMenuPosition.under,
                          elevation: 8,
                          color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFE4E4E7),
                              width: 1,
                            ),
                          ),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          onSelected: (index) {
                            HapticFeedback.selectionClick();
                            final accountsCount = _accounts.length;
                            if (index < accountsCount) {
                              final targetAcc = _accounts[index];
                              final curIdx = _accounts.indexWhere((a) => a.id == _selectedAccountId);
                              final isMovingForward = index > curIdx;
                              setState(() {
                                _heroSlideFromLeft = isRtl ? isMovingForward : !isMovingForward;
                                _selectedAccountId = targetAcc.id;
                              });
                              _syncWalletsCarouselToSelected();
                            } else if (index == accountsCount + 1) { // after divider
                              _showAddAccountModal();
                            } else if (index == accountsCount + 2) {
                              _showManageAccountsModal();
                            }
                          },
                          itemBuilder: (context) {
                            final accountsCount = _accounts.length;
                            return [
                              for (int i = 0; i < accountsCount; i++)
                                _buildAccountPopupMenuItem(
                                  value: i,
                                  account: _accounts[i],
                                  isSelected: _accounts[i].id == _selectedAccountId,
                                  isDarkMode: isDarkMode,
                                ),
                              const PopupMenuDivider(height: 8),
                              _buildMenuOptionItem(
                                value: accountsCount + 1,
                                title: isAr ? 'إضافة حساب جديد' : 'Add account',
                                icon: Icons.add_card_rounded,
                                isDarkMode: isDarkMode,
                              ),
                              _buildMenuOptionItem(
                                value: accountsCount + 2,
                                title: isAr ? 'إدارة المحافظ والحسابات' : 'Manage accounts',
                                icon: Icons.tune_rounded,
                                isDarkMode: isDarkMode,
                              ),
                            ];
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedAccount.name,
                                  style: TextStyle(
                                    fontSize: 12.5,
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

  //#region 3 Circular Action Buttons (Say Style: Add, Voice, More)
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
            label: isAr ? 'إضافة' : 'Add',
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

          // 3. More (••• with Native iOS Popover Menu via CNPopupMenuButton)
          _buildMoreActionButton(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildMoreActionButton(bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isIOS = Platform.isIOS;

    if (isIOS) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.32)
                    : Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Center(
              child: CNPopupMenuButton.icon(
                size: 52.0,
                tint: Colors.white,
                buttonStyle: CNButtonStyle.plain,
                buttonIcon: const CNSymbol(
                  'ellipsis',
                  size: 20.0,
                  color: Colors.white,
                ),
                items: [
                  CNPopupMenuItem(
                    label: isAr ? 'إضافة حساب جديد' : 'Add account',
                    icon: const CNSymbol('plus', size: 18.0),
                  ),
                  CNPopupMenuItem(
                    label: isAr ? 'إدارة المحافظ والحسابات' : 'Manage accounts',
                    icon: const CNSymbol('slider.horizontal.3', size: 18.0),
                  ),
                  const CNPopupMenuDivider(),
                  CNPopupMenuItem(
                    label: isAr ? 'تبديل المحفظة' : 'Switch account',
                    icon: const CNSymbol('arrow.left.arrow.right', size: 18.0),
                  ),
                ],
                onSelected: (index) {
                  switch (index) {
                    case 0:
                      _showAddAccountModal();
                      break;
                    case 1:
                      _showManageAccountsModal();
                      break;
                    case 3: // index 2 is CNPopupMenuDivider
                      _showAccountSwitcherModal();
                      break;
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAr ? 'المزيد' : 'More',
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
        Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFE4E4E7),
                  width: 1,
                ),
              ),
              shadowColor: Colors.black.withValues(alpha: 0.25),
            ),
          ),
          child: PopupMenuButton<int>(
            tooltip: isAr ? 'المزيد' : 'More',
            offset: const Offset(0, 10),
            position: PopupMenuPosition.under,
            elevation: 8,
            color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFE4E4E7),
                width: 1,
              ),
            ),
            splashRadius: 28,
            padding: EdgeInsets.zero,
            onSelected: (value) {
              HapticFeedback.selectionClick();
              switch (value) {
                case 0:
                  _showAddAccountModal();
                  break;
                case 1:
                  _showManageAccountsModal();
                  break;
                case 2:
                  _showAccountSwitcherModal();
                  break;
              }
            },
            itemBuilder: (context) => [
              _buildMenuOptionItem(
                value: 0,
                icon: Icons.add_card_rounded,
                title: isAr ? 'إضافة حساب جديد' : 'Add account',
                isDarkMode: isDarkMode,
              ),
              _buildMenuOptionItem(
                value: 1,
                icon: Icons.tune_rounded,
                title: isAr ? 'إدارة المحافظ والحسابات' : 'Manage accounts',
                isDarkMode: isDarkMode,
              ),
              const PopupMenuDivider(height: 8),
              _buildMenuOptionItem(
                value: 2,
                icon: Icons.swap_horiz_rounded,
                title: isAr ? 'تبديل المحفظة' : 'Switch account',
                isDarkMode: isDarkMode,
              ),
            ],
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.32)
                      : Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
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
          isAr ? 'المزيد' : 'More',
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
    final sheetBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
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

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'فترة مخصصة' : 'Custom Range',
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
                          '$dayCount ${isAr ? 'يوم' : 'days'}',
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
                          label: isAr ? 'آخر 7 أيام' : 'Last 7 days',
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => applyDaysPreset(7),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: isAr ? 'آخر 30 يوم' : 'Last 30 days',
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => applyDaysPreset(30),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: isAr ? 'هذا الشهر' : 'This month',
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
                                        isAr ? 'من' : 'From',
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
                                        isAr ? 'إلى' : 'To',
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
                        isAr ? 'تأكيد' : 'Confirm',
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

  Future<void> _pickMonthPickerIOS(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final sheetBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
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

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
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

                  // Header with selection pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'اختر الشهر' : 'Select Month',
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
                        isAr ? 'تأكيد' : 'Confirm',
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
                        isAr ? 'فترة مخصصة' : 'Custom Range',
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
                          label: isAr ? 'آخر 7 أيام' : 'Last 7 days',
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => applyDaysPreset(7),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: isAr ? 'آخر 30 يوم' : 'Last 30 days',
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => applyDaysPreset(30),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: isAr ? 'هذا الشهر' : 'This month',
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
                            '($dayCount ${isAr ? 'يوم' : 'days'})',
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
                        isAr ? 'تأكيد' : 'Confirm',
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
                        isAr ? 'اختر الشهر' : 'Select Month',
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
                        isAr ? 'تأكيد' : 'Confirm',
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

  PopupMenuItem<int> _buildMenuOptionItem({
    required int value,
    required String title,
    required IconData icon,
    bool isSelected = false,
    required bool isDarkMode,
  }) {
    return PopupMenuItem<int>(
      value: value,
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? (isDarkMode ? Colors.white : Colors.black)
                : (isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.check_rounded,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ],
        ],
      ),
    );
  }

  PopupMenuItem<int> _buildAccountPopupMenuItem({
    required int value,
    required AccountItem account,
    required bool isSelected,
    required bool isDarkMode,
  }) {
    return PopupMenuItem<int>(
      value: value,
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            account.icon,
            size: 20,
            color: isSelected
                ? (isDarkMode ? Colors.white : Colors.black)
                : (isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    account.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (account.isMain) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'ar' ? 'الرئيسي' : 'Main',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCircularActionItem({
    required IconData icon,
    required String label,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.32)
                      : Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
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
                isAr ? 'محافظي' : 'My Wallets',
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
                          isAr ? 'عرض الكل' : 'View all',
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
                            isAr ? 'إضافة' : 'Add',
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

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _heroSlideFromLeft = false;
                      _selectedAccountId = acc.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
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
        title: isAr ? 'تتبع المصاريف تلقائياً' : 'Track spending automatically',
        subtitle: isAr
            ? 'سجّل مشترياتك ومعاملاتك من إشعارات ورسائل البنوك تلقائياً وبدقة دون الحاجة لإدخالها يدوياً كل مرة'
            : 'Automatically sync and log your transactions from bank SMS and alerts with zero manual entry required',
        actionText: isAr ? 'تفعيل الآن' : 'Set Up',
        onTap: () {
          MessageService.showSuccess(
            context: context,
            message: isAr
                ? 'سيتم تفعيل المزامنة التلقائية قريباً 🚀'
                : 'Auto-tracking sync coming soon 🚀',
          );
        },
      ),
      (
        id: 'salary',
        icon: Icons.payments_rounded,
        title: isAr ? 'أضف راتبك ومصادر دخلك' : 'Add your salary & income',
        subtitle: isAr
            ? 'حدّد موعد نزول دخلك الشهري والمصادر الإضافية لتوقع صافي التدفق المالي والتخطيط لمدخراتك مبكراً'
            : 'Schedule your monthly salary and additional income streams to forecast cash flow and plan your savings',
        actionText: isAr ? 'إضافة دخل' : 'Add Salary',
        onTap: () => _showUnifiedAddModal(),
      ),
      (
        id: 'accounts',
        icon: Icons.account_balance_wallet_rounded,
        title: isAr ? 'نظّم محافظك وبطاقاتك' : 'Organize your accounts',
        subtitle: isAr
            ? 'اجمع بطاقاتك البنكية، محافظك الإلكترونية ونقد الكاش في مكان واحد لمتابعة إجمالي ثروتك لحظة بلحظة'
            : 'Consolidate bank cards, e-wallets, and cash accounts in one unified space to see your total net worth',
        actionText: isAr ? 'إضافة محفظة' : 'Add Account',
        onTap: () => _showAddAccountModal(),
      ),
      (
        id: 'budget',
        icon: Icons.pie_chart_rounded,
        title: isAr ? 'حدد ميزانية لمصاريفك' : 'Set a monthly budget',
        subtitle: isAr
            ? 'ضع سقفاً ذكياً للإنفاق على المطاعم والتسوق والفواتير لتصلك تنبيهات مبكرة قبل تجاوز الميزانية المحددة'
            : 'Set smart spending limits for dining, shopping, and bills to receive early warnings before overspending',
        actionText: isAr ? 'تحديد ميزانية' : 'Create Budget',
        onTap: () {
          MessageService.showSuccess(
            context: context,
            message: isAr
                ? 'قريباً: تحديد الميزانيات والتنبيهات الذكية 🎯'
                : 'Coming soon: Smart Budgets & Alerts 🎯',
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
                isAr ? 'ابدأ الآن' : 'Get started',
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
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
                isAr ? 'أحدث المعاملات' : 'Recent Transactions',
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
                          isAr ? 'عرض الكل' : 'View all',
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
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: transactions
                          .take(4)
                          .map((t) => _buildTransactionCard(t, isDarkMode))
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  //#endregion

  //#region Insights Grid Section (Say Style)
  Widget _buildInsightsGridSection(bool isDarkMode, HideBalanceService hideService) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final balance = _homeData?.balance;
    final totalBalance = balance?.totalBalance ?? 0.0;
    final totalIncome = balance?.totalDeposits ?? 0.0;

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
                isAr ? 'التحليلات والمحفظة' : 'Insights',
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          isAr ? 'التحليلات' : 'Analytics',
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
          const SizedBox(height: 14),

          // Row 1: Top Spending & Subscriptions
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.pie_chart_outline_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: isAr ? 'أعلى المصروفات' : 'Top Spending',
                  mainText: isAr ? 'لا يوجد بعد' : 'Nothing yet',
                  subText: isAr ? 'سيظهر تصنيفك الأكثر إنفاقاً هنا' : 'Your top category shows up here',
                  isDarkMode: isDarkMode,
                  visualWidget: Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.autorenew_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: isAr ? 'الاشتراكات' : 'Subscriptions',
                  mainText: isAr ? 'لا مستحقات' : 'Nothing due',
                  subText: isAr ? 'لا توجد اشتراكات مضافة' : 'No subscriptions yet',
                  isDarkMode: isDarkMode,
                  visualWidget: Column(
                    children: [
                      Container(height: 3, width: 34, decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 4),
                      Container(height: 3, width: 24, decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7), borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Budget & Money Flow
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.savings_outlined,
                  iconColor: const Color(0xFFF97316),
                  title: isAr ? 'الميزانية' : 'Budget',
                  mainText: isAr ? 'تحديد ميزانية' : 'Set Budget',
                  subText: isAr ? 'اضغط لتحديد ميزانية الشهر' : 'Tap to set monthly budget',
                  isDarkMode: isDarkMode,
                  onTap: () {
                    MessageService.showSuccess(
                      context: context,
                      message: isAr ? 'خاصية الميزانية قادمة في التحديث القادم' : 'Budgeting coming in next update',
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.compare_arrows_rounded,
                  iconColor: const Color(0xFF06B6D4),
                  title: isAr ? 'حركة الأموال' : 'Money Flow',
                  mainText: isAr ? 'حركة الشهر' : 'Money Flow',
                  subText: isAr ? 'حركة الدخول والخروج' : 'Money in and out shows here',
                  isDarkMode: isDarkMode,
                  visualWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(height: 18, width: 6, decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.6), borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 4),
                      Container(height: 26, width: 6, decoration: BoxDecoration(color: const Color(0xFFF43F5E).withValues(alpha: 0.6), borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 4),
                      Container(height: 14, width: 6, decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7), borderRadius: BorderRadius.circular(3))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: Income breakdown & Accounts
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: isAr ? 'ملخص الدخل' : 'Income breakdown',
                  mainText: totalIncome > 0
                      ? _formatAmount(totalIncome)
                      : (isAr ? 'لا يوجد دخل' : 'No activity'),
                  subText: isAr ? 'الدخل المسجل في هذه الفترة' : 'No income recorded in this period',
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.credit_card_rounded,
                  iconColor: const Color(0xFF14B8A6),
                  title: isAr ? 'الحسابات' : 'Accounts',
                  mainText: _formatAmount(totalBalance),
                  subText: isAr
                      ? 'عبر ${_accounts.where((a) => !a.isAll).length} حسابات'
                      : 'across ${_accounts.where((a) => !a.isAll).length} accounts',
                  isDarkMode: isDarkMode,
                  onTap: _showAccountSwitcherModal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 4: Add Widget
          _buildAddWidgetCard(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String mainText,
    required String subText,
    required bool isDarkMode,
    Widget? visualWidget,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 135,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header: Icon & Title
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Main text & visual if any
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      mainText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  if (visualWidget != null) visualWidget,
                ],
              ),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                subText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddWidgetCard(bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          MessageService.showSuccess(
            context: context,
            message: isAr ? 'تخصيص وإضافة ويدجتس قادمة قريباً 🚀' : 'Custom widgets coming soon 🚀',
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 140,
          height: 120,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isAr ? 'إضافة ويدجت' : 'Add widget',
                style: TextStyle(
                  fontSize: 12,
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

    return Slidable(
      key: Key('transaction_${transaction.id}'),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) => _showEditTransactionDialog(transaction),
            backgroundColor: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            icon: Icons.edit_outlined,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
          ),
          SlidableAction(
            onPressed: (_) => _showDeleteConfirmationDialog(transaction),
            backgroundColor: const Color(0xFFF43F5E),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            width: 1,
          ),
        ),
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
              context.l10n.all == 'All'
                  ? 'Tap + or use voice to add your first expense'
                  : 'اضغط + أو استخدم الصوت لإضافة أول حركة',
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
  Widget _buildBlurrableNumber(double amount, TextStyle style, bool blurred, {String prefix = '', String? currencyCode}) {
    final formatted = '$prefix${_formatAmount(amount, currencyCode: currencyCode)}';
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: blurred ? 0 : 8, end: blurred ? 8 : 0),
      duration: const Duration(milliseconds: 250),
      builder: (context, sigma, child) {
        if (sigma == 0) {
          return Text(formatted, style: style);
        }
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Text(formatted, style: style),
        );
      },
    );
  }
  //#endregion
}
