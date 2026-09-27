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
          const SizedBox(height: 16),
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
                        } else if (index == 3) { // index 2 is divider
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
                          title: isAr ? 'فترة مخصصة...' : 'Custom Range...',
                          icon: Icons.date_range_rounded,
                          isSelected: !isThisMonth && !isLastMonth,
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
            // "Spent" Label
            Text(
              isAr ? 'المصروفات' : 'Spent',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 2),

            // Big Amount: e.g. $ 0.00 (Animated on swipe/switch)
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
                key: ValueKey('spent_$_selectedAccountId'),
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  _buildBlurrableNumber(
                    _totalSpentAmount,
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
                            return CNPopupMenuItem(
                              label: acc.name,
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

            const SizedBox(height: 8),

            // Balance Subtitle Line (Animated on swipe/switch)
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
                key: ValueKey('balance_$_selectedAccountId'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isAr ? 'الرصيد ' : 'Balance ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  _buildBlurrableNumber(
                    _selectedAccount.balance,
                    const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    hideService.isHidden,
                  ),
                ],
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (ctx, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    surface: Color(0xFF18181B),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

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
            child: Text(
              account.name,
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

  Widget _buildAutoTrackingBanner(bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final allCards = [
      (
        id: 'auto_track',
        icon: Icons.bolt_rounded,
        iconColor: const Color(0xFF10B981),
        title: isAr ? 'تتبع المصاريف تلقائياً' : 'Track spending automatically',
        subtitle: isAr
            ? 'من رسائل البنك وإشعارات التطبيقات، محفظتي تسجل كل حركة شراء تلقائياً.'
            : "From your bank's texts or app notifications. Mahfazti logs every purchase for you.",
        actionText: isAr ? 'تفعيل التتبع التلقائي' : 'Set Up Auto-Tracking',
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
        iconColor: const Color(0xFF3B82F6),
        title: isAr ? 'أضف راتبك ومصادر دخلك' : 'Add your salary & income',
        subtitle: isAr
            ? 'سجّل راتبك ومواعيد نزوله لتوقع رصيدك بدقة والتخطيط لمصاريف الشهر.'
            : 'Record your monthly salary to predict cash flow and plan your savings ahead.',
        actionText: isAr ? 'إضافة راتب / دخل' : 'Add Salary',
        onTap: () => _showUnifiedAddModal(),
      ),
      (
        id: 'accounts',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: const Color(0xFF8B5CF6),
        title: isAr ? 'نظّم محافظك وبطاقاتك' : 'Organize your accounts',
        subtitle: isAr
            ? 'أضف بطاقاتك البنكية ومحفظة الكاش لترى صافي ثروتك مجمعة في مكان واحد.'
            : 'Add your bank cards and cash wallets to see your total net worth at a glance.',
        actionText: isAr ? 'إضافة محفظة أو بطاقة' : 'Add Account',
        onTap: () => _showAddAccountModal(),
      ),
      (
        id: 'budget',
        icon: Icons.pie_chart_rounded,
        iconColor: const Color(0xFFF59E0B),
        title: isAr ? 'حدد ميزانية لمصاريفك' : 'Set a monthly budget',
        subtitle: isAr
            ? 'حدد سقف مصاريفك لكل فئة وتجنب الإنفاق الزائد مع تنبيهات ذكية.'
            : 'Set monthly spending caps for categories and get notified before overspending.',
        actionText: isAr ? 'تحديد الميزانية' : 'Create Budget',
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
          height: 178,
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF18181B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Icon + Title + Individual Dismiss 'x'
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: card.iconColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  card.icon,
                                  color: card.iconColor,
                                  size: 19,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  card.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _dismissGetStartedCard(card.id, index, cards.length),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 17,
                                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Subtitle
                          Expanded(
                            child: Text(
                              card.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Action Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: card.onTap,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    card.actionText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
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
          if (transactions.isEmpty)
            _buildEmptyState(isDarkMode)
          else
            ...transactions.take(4).map((t) => _buildTransactionCard(t, isDarkMode)),
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
                color: isIncome ? const Color(0xFF34D399) : (isDarkMode ? Colors.white : Colors.black),
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
  Widget _buildBlurrableNumber(double amount, TextStyle style, bool blurred, {String prefix = ''}) {
    final formatted = '$prefix${_formatAmount(amount)}';
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
