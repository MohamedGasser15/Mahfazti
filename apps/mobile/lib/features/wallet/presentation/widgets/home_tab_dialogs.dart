part of '../screens/home_tab.dart';
// ignore_for_file: annotate_overrides

mixin _HomeTabDialogs on _HomeTabState {
  //#region Unified 3-in-1 Transaction Sheet (Say / Linear Minimalist)
  Future<void> _showUnifiedAddModal({
    VoiceExpenseResult? prefillFromVoice,
    TransactionType? initialType,
    String? initialAccountId,
    WalletTransaction? editing,
  }) async {
    final isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      await _showAdaptiveBottomSheet(
        isScrollControlled: true,
        showDragHandle: true,
        dismissible: true,
        enableDrag: true,
        initialState: GlassSheetState.full,
        detents: const {GlassSheetDetent.large},
        fullSize: 0.93,
        topBorderRadius: 44,
        fullTopBorderRadius: 40,
        bottomBorderRadius: 0,
        fullBottomBorderRadius: 0,
        horizontalMargin: 0,
        bottomMargin: 0,
        builder: (context, isGlass, controller) {
          return _UnifiedAddTransactionSheet(
            homeState: this,
            prefillFromVoice: prefillFromVoice,
            initialType: initialType,
            initialAccountId: initialAccountId,
            editing: editing,
            isGlass: isGlass,
            isPage: false,
          );
        },
      );
    } else {
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute(
          builder: (pageContext) {
            final isDarkMode = Theme.of(pageContext).brightness == Brightness.dark;
            return Scaffold(
              backgroundColor: isDarkMode ? const Color(0xFF121214) : Colors.white,
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                child: _UnifiedAddTransactionSheet(
                  homeState: this,
                  prefillFromVoice: prefillFromVoice,
                  initialType: initialType,
                  initialAccountId: initialAccountId,
                  editing: editing,
                  isGlass: false,
                  isPage: true,
                ),
              ),
            );
          },
        ),
      );
    }
  }


  Future<void> _showEditTransactionDialog(WalletTransaction transaction) {
    // Editing reuses the exact same sheet as "Add Transaction".
    return _showUnifiedAddModal(editing: transaction);
  }

  void _showDeleteConfirmationDialog(WalletTransaction transaction) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (Platform.isIOS) {
      NeoAlertDialog.show(
        context: context,
        title: context.l10n.deleteTransaction,
        message: context.l10n.confirmDeleteTransaction(transaction.title),
        actions: [
          NeoDialogAction(
            title: context.l10n.cancel,
            role: NeoDialogActionRole.cancel,
            onPressed: () {},
          ),
          NeoDialogAction(
            title: isAr ? 'حذف' : 'Delete',
            role: NeoDialogActionRole.destructive,
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await _deleteTransaction(transaction);
            },
          ),
        ],
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF18181B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            context.l10n.deleteTransaction,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            context.l10n.confirmDeleteTransaction(transaction.title),
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.cancel,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTransaction(transaction);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
  //#endregion

  //#region Add Account Full Page Navigation
  void _showAddAccountModal() async {
    final AccountItem? newAccount = await Navigator.push<AccountItem>(
      context,
      Platform.isIOS
          ? CupertinoPageRoute(
              builder: (_) => AddAccountScreen(
                currencyCode: _currencyCode ?? 'EGP',
              ),
            )
          : MaterialPageRoute(
              builder: (_) => AddAccountScreen(
                currencyCode: _currencyCode ?? 'EGP',
              ),
            ),
    );

    if (newAccount != null && mounted) {
      setState(() {
        _customAccounts.add(newAccount);
      });
      _saveAccountOverrides();
      MessageService.showSuccess(
        context: context,
        message: context.l10n.accountAddedSuccess,
      );
    }
  }
  //#endregion

  //#region All Transactions Page Navigation
  void _showAllTransactionsModal(List<WalletTransaction> transactions) {
    Navigator.push(
      context,
      Platform.isIOS
          ? CupertinoPageRoute(
              builder: (_) => TransactionsPage(
                initialTransactions: transactions,
                onEditTransaction: _showEditTransactionDialog,
              ),
            )
          : MaterialPageRoute(
              builder: (_) => TransactionsPage(
                initialTransactions: transactions,
                onEditTransaction: _showEditTransactionDialog,
              ),
            ),
    ).then((_) {
      if (mounted) _loadHomeData();
    });
  }
  //#endregion

  //#region Account Switcher Modal (Quickly switch active wallet)
  void _showAccountSwitcherModal() {
    _showAdaptiveBottomSheet(
      showDragHandle: true,
      builder: (context, isGlass, _) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: isGlass
              ? const BoxDecoration(color: Colors.transparent)
              : BoxDecoration(
                  color: isDarkMode ? const Color(0xFF18181B) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                    color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                    width: 1,
                  ),
                ),
          padding: EdgeInsets.fromLTRB(20, isGlass ? 4 : 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isGlass)
                Center(
                  child: Container(
                    height: 4,
                    width: 36,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              if (isGlass) const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.selectActiveWallet,
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._accounts.map((acc) {
                final isSelected = acc.id == _selectedAccountId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAccountId = acc.id;
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                acc.icon,
                                color: isDarkMode ? Colors.white : Colors.black,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    _formatAmount(acc.balance, currencyCode: acc.currency),
                                    textDirection: ui.TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: isDarkMode ? Colors.black : Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
  //#endregion

  //#region Manage Accounts Sheet (Full list, balances, Add Account)
  void _showManageAccountsModal() {
    _showAdaptiveBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context, isGlass, _) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final screenWidth = MediaQuery.of(context).size.width;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final accounts = _accounts;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: isGlass
                  ? const BoxDecoration(color: Colors.transparent)
                  : BoxDecoration(
                      color: isDarkMode ? const Color(0xFF18181B) : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        width: 1,
                      ),
                    ),
              child: Column(
                children: [
                  // Handle (only on standard Material sheet; GlassSheet provides its own)
                  if (!isGlass)
                    Container(
                      height: 4,
                      width: 36,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  if (isGlass) const SizedBox(height: 12),

                  // Top Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.manageAccounts,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                context.l10n.manageAccountsSubtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.white60 : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (isGlass)
                          GlassButton.custom(
                            width: 38,
                            height: 38,
                            shape: const LiquidOval(),
                            useOwnLayer: true,
                            quality: GlassQuality.premium,
                            stretch: 0.35,
                            interactionScale: 1.06,
                            settings: isDarkMode
                                ? const LiquidGlassSettings(
                                    thickness: 24,
                                    blur: 16,
                                    refractiveIndex: 1.25,
                                    lightIntensity: 1.6,
                                    glassColor: Color(0x25FFFFFF),
                                  )
                                : const LiquidGlassSettings(
                                    thickness: 24,
                                    blur: 16,
                                    refractiveIndex: 1.25,
                                    lightIntensity: 1.6,
                                    glassColor: Color(0x45FFFFFF),
                                  ),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          )
                        else
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(19),
                              child: Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                                  ),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Accounts list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: accounts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final acc = accounts[index];
                        final isSelected = acc.id == _selectedAccountId;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedAccountId = acc.id;
                              });
                              _syncWalletsCarouselToSelected();
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isGlass
                                    ? (isSelected
                                        ? (isDarkMode
                                            ? Colors.white.withValues(alpha: 0.12)
                                            : Colors.black.withValues(alpha: 0.05))
                                        : (isDarkMode
                                            ? Colors.white.withValues(alpha: 0.06)
                                            : Colors.white.withValues(alpha: 0.65)))
                                    : (isSelected
                                        ? (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                                        : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA))),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDarkMode
                                          ? Colors.white.withValues(alpha: 0.50)
                                          : Colors.black.withValues(alpha: 0.35))
                                      : (isGlass
                                          ? (isDarkMode
                                              ? Colors.white.withValues(alpha: 0.08)
                                              : Colors.black.withValues(alpha: 0.06))
                                          : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))),
                                  width: isSelected ? 1.3 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Account Icon
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isGlass
                                          ? (isDarkMode
                                              ? Colors.white.withValues(alpha: 0.10)
                                              : Colors.white.withValues(alpha: 0.90))
                                          : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isDarkMode
                                            ? const Color(0xFF3F3F46)
                                            : const Color(0xFFE4E4E7),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      acc.icon,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Name & Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                acc.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 15.5,
                                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                                  color: isDarkMode ? Colors.white : Colors.black,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                            ),
                                            if (acc.isMain) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? Colors.white.withValues(alpha: 0.12)
                                                      : Colors.black.withValues(alpha: 0.07),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: isDarkMode
                                                        ? Colors.white.withValues(alpha: 0.16)
                                                        : Colors.black.withValues(alpha: 0.1),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.star_rounded,
                                                      size: 11,
                                                      color: isDarkMode ? Colors.white : Colors.black,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      context.l10n.mainAcc,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w800,
                                                        color: isDarkMode ? Colors.white : Colors.black,
                                                        letterSpacing: -0.2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              _formatAmount(acc.balance, currencyCode: acc.currency),
                                              textDirection: ui.TextDirection.ltr,
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode ? Colors.white70 : Colors.black87,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            if (acc.accountNumber != null &&
                                                acc.accountNumber!.isNotEmpty &&
                                                !acc.isAll &&
                                                acc.accountNumber != acc.name &&
                                                acc.accountNumber != context.l10n.cash) ...[
                                              Text(
                                                '  ·  ${acc.accountNumber}',
                                                textDirection: ui.TextDirection.ltr,
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDarkMode ? Colors.white38 : Colors.black38,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Star Action Button (Set as Main)
                                  if (!acc.isAll && !acc.isMain) ...[
                                    Tooltip(
                                      message: context.l10n.setAsMain,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            setModalState(() {
                                              _mainAccountId = acc.id;
                                            });
                                            setState(() {
                                              _mainAccountId = acc.id;
                                            });
                                            MessageService.showSuccess(
                                              context: context,
                                              message: context.l10n.setAsMainSuccess(acc.name),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: isGlass
                                                  ? (isDarkMode
                                                      ? Colors.white.withValues(alpha: 0.08)
                                                      : Colors.black.withValues(alpha: 0.04))
                                                  : (isDarkMode
                                                      ? const Color(0xFF27272A)
                                                      : const Color(0xFFF4F4F5)),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isDarkMode
                                                    ? Colors.white.withValues(alpha: 0.10)
                                                    : Colors.black.withValues(alpha: 0.06),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.star_outline_rounded,
                                              size: 18,
                                              color: isDarkMode ? Colors.white60 : Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],

                                  // Active Checkmark Indicator
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? (isDarkMode ? Colors.white : Colors.black)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? (isDarkMode ? Colors.white : Colors.black)
                                            : (isDarkMode
                                                ? Colors.white.withValues(alpha: 0.22)
                                                : Colors.black.withValues(alpha: 0.20)),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check_rounded,
                                            size: 16,
                                            color: isDarkMode ? Colors.black : Colors.white,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Add Account Action Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: isGlass
                        ? GlassButton.custom(
                            width: screenWidth - 40,
                            height: 52,
                            shape: const LiquidRoundedRectangle(borderRadius: 18),
                            useOwnLayer: true,
                            quality: GlassQuality.premium,
                            stretch: 0.35,
                            interactionScale: 1.03,
                            settings: isDarkMode
                                ? const LiquidGlassSettings(
                                    thickness: 18,
                                    blur: 14,
                                    refractiveIndex: 1.25,
                                    lightIntensity: 1.6,
                                    glassColor: Color(0x30FFFFFF),
                                  )
                                : const LiquidGlassSettings(
                                    thickness: 18,
                                    blur: 14,
                                    refractiveIndex: 1.25,
                                    lightIntensity: 1.6,
                                    glassColor: Color(0x18000000),
                                  ),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.pop(context);
                              _showAddAccountModal();
                            },
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    size: 19,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.addNewAccountOrWallet,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
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
                                Navigator.pop(context);
                                _showAddAccountModal();
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_rounded,
                                      size: 19,
                                      color: isDarkMode ? Colors.black : Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.l10n.addNewAccountOrWallet,
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.black : Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
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
            );
          },
        );
      },
    );
  }

  //#endregion

  //#region Adjust Balance Modal
  void _showAdjustBalanceModal(AccountItem acc, bool isDarkMode, bool isAr) {
    final amountController = TextEditingController(
      text: _formatThousands(acc.balance.toInt().toString()),
    );
    final amountFocusNode = FocusNode();

    _showAdaptiveBottomSheet(
      isScrollControlled: true,
      showDragHandle: false,
      initialState: GlassSheetState.half,
      detents: const {GlassSheetDetent.medium, GlassSheetDetent.large},
      focusNodes: [amountFocusNode],
      builder: (context, isGlass, controller) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currencySymbol = currencySymbols[acc.currency] ?? acc.currency;

            void submitAdjustBalance() {
              final raw = _cleanNumberString(amountController.text.trim());
              final newBal = double.tryParse(raw);
              if (newBal == null) return;
              HapticFeedback.selectionClick();
              _updateAccountBalance(acc.id, newBal);
              Navigator.pop(context);
              MessageService.showSuccess(
                context: context,
                message: isAr
                    ? 'تم تحديث رصيد "${acc.name}" بنجاح'
                    : 'Balance updated successfully for "${acc.name}"',
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: (!isGlass) ? MediaQuery.of(context).viewInsets.bottom : 0,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: isGlass && MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom + 20
                      : 0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  acc.icon,
                                  size: 18,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'تعديل الرصيد' : 'Adjust Balance',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    acc.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Current balance info pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'الرصيد الحالي' : 'Current Balance',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            Text(
                              _formatAmount(acc.balance, currencyCode: acc.currency),
                              textDirection: ui.TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // New Balance Input
                      Text(
                        isAr ? 'الرصيد الجديد' : 'New Balance',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: amountController,
                        focusNode: amountFocusNode,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        keyboardAppearance: isDarkMode ? Brightness.dark : Brightness.light,
                        inputFormatters: [_ThousandsSeparatorInputFormatter()],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          prefixText: '$currencySymbol ',
                          prefixStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          filled: true,
                          fillColor: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: submitAdjustBalance,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white : Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isAr ? 'تحديث الرصيد' : 'Update Balance',
                              style: TextStyle(
                                color: isDarkMode ? Colors.black : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
  //#endregion

  //#region Edit Account Modal
  void _showEditAccountModal(AccountItem acc, bool isDarkMode, bool isAr) {
    final nameController = TextEditingController(text: acc.name);
    final nameFocusNode = FocusNode();
    IconData selectedIcon = acc.icon;

    const availableIcons = kAvailableAccountIcons;

    _showAdaptiveBottomSheet(
      isScrollControlled: true,
      showDragHandle: false,
      initialState: GlassSheetState.half,
      detents: const {GlassSheetDetent.medium, GlassSheetDetent.large},
      focusNodes: [nameFocusNode],
      builder: (context, isGlass, controller) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void submitEditAccount() {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              HapticFeedback.selectionClick();
              _updateAccountDetails(acc.id, newName, selectedIcon);
              Navigator.pop(context);
              MessageService.showSuccess(
                context: context,
                message: isAr
                    ? 'تم تعديل بيانات "$newName" بنجاح'
                    : 'Account "$newName" updated successfully',
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: (!isGlass) ? MediaQuery.of(context).viewInsets.bottom : 0,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: isGlass && MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom + 20
                      : 0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  selectedIcon,
                                  size: 18,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'تعديل الحساب' : 'Edit Account',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    acc.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Account Name Label
                      Text(
                        isAr ? 'اسم الحساب / المحفظة' : 'Account Name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        focusNode: nameFocusNode,
                        keyboardAppearance: isDarkMode ? Brightness.dark : Brightness.light,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: isAr ? 'أدخل اسم الحساب' : 'Enter account name',
                          filled: true,
                          fillColor: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Icon Selector Label
                      Text(
                        isAr ? 'أيقونة الحساب' : 'Account Icon',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: availableIcons.map((icon) {
                          final isIconSelected = icon.codePoint == selectedIcon.codePoint;
                          return InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() {
                                selectedIcon = icon;
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isIconSelected
                                    ? (isDarkMode ? Colors.white : Colors.black)
                                    : (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isIconSelected
                                      ? (isDarkMode ? Colors.white : Colors.black)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 20,
                                color: isIconSelected
                                    ? (isDarkMode ? Colors.black : Colors.white)
                                    : (isDarkMode ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: submitEditAccount,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white : Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isAr ? 'حفظ التعديلات' : 'Save Changes',
                              style: TextStyle(
                                color: isDarkMode ? Colors.black : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
  //#endregion
}

/// Normalizes Arabic-Indic and Persian numerals to Western digits, and strips any thousand commas.
String _cleanNumberString(String input) {
  const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  String result = input.replaceAll(',', '');
  for (int i = 0; i < 10; i++) {
    result = result.replaceAll(arabicDigits[i], '$i');
    result = result.replaceAll(persianDigits[i], '$i');
  }
  return result;
}

/// Formats integer digits with thousands separators (e.g. 1000000 -> 1,000,000).
String _formatThousands(String digits) {
  if (digits.isEmpty) return '';
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Formats inputs dynamically with thousand separators (e.g. 1,000,000) while supporting
/// both English and Arabic numerals, decimals, and maintaining accurate cursor positioning.
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final int maxDigits;

  _ThousandsSeparatorInputFormatter({this.maxDigits = 12});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Convert Arabic / Persian numerals to Western digits & strip commas
    final normalized = _cleanNumberString(newValue.text);

    // Validate number structure (optional decimal with digits)
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(normalized)) {
      return oldValue;
    }

    final parts = normalized.split('.');
    String integerPart = parts[0];
    final String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Check maximum total digits limit
    final totalDigits = integerPart.length + (decimalPart?.length ?? 0);
    if (totalDigits > maxDigits) {
      return oldValue;
    }

    // Format integer part with thousands commas (3,3,3)
    final formattedInt = _formatThousands(integerPart);
    final formattedText = decimalPart != null
        ? '$formattedInt.$decimalPart'
        : formattedInt;

    // Calculate cursor offset smartly based on digit count before old cursor
    final rawTextBeforeCursor = _cleanNumberString(
      newValue.text.substring(0, newValue.selection.end.clamp(0, newValue.text.length)),
    );
    final digitsBeforeCursor = rawTextBeforeCursor.replaceAll('.', '').length;
    final hasDecimalBeforeCursor = rawTextBeforeCursor.contains('.');

    int newCursorPos = 0;
    int digitCount = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (formattedText[i] == '.') {
        if (hasDecimalBeforeCursor && digitCount >= digitsBeforeCursor) {
          newCursorPos = i + 1;
          break;
        }
      } else if (formattedText[i] != ',') {
        digitCount++;
      }
      if (digitCount == digitsBeforeCursor && (!hasDecimalBeforeCursor || formattedText[i] == '.' || i >= formattedText.indexOf('.'))) {
        newCursorPos = i + 1;
        break;
      }
      newCursorPos = i + 1;
    }

    newCursorPos = newCursorPos.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}


  Widget _buildSegmentTab({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                width: isSelected ? 6.5 : 0,
                height: isSelected ? 6.5 : 0,
                margin: EdgeInsetsDirectional.only(end: isSelected ? 6 : 0),
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDarkMode ? Colors.white : Colors.black)
                      : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                  letterSpacing: -0.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _showFloatingDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required bool isDarkMode,
    required bool isAr,
    required Color themeColor,
  }) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final now = DateTime.now();

    return showCupertinoCalendarPicker(
      context,
      widgetRenderBox: renderBox,
      initialDate: initialDate,
      minimumDate: DateTime(2020, 1, 1),
      maximumDate: DateTime(2035, 12, 31),
      currentDate: now,
      mainColor: themeColor,
      barrierColor: Colors.transparent,
      dismissBehaviour: CalendarDismissBehavior.onOusideTapOrDateSelect,
      containerDecoration: CalendarContainerDecoration(
        backgroundColor: isDarkMode ? const Color(0xFF242428) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        backgroundType: CalendarBackgroundType.plainColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.08),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      headerDecoration: CalendarHeaderDecoration(
        mainColor: themeColor,
        monthDateStyle: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w700,
          color: isDarkMode ? Colors.white : Colors.black,
          letterSpacing: -0.4,
        ),
        monthDateArrowColor: isDarkMode ? Colors.white : Colors.black,
        forwardButtonColor: isDarkMode ? Colors.white : Colors.black,
        backwardButtonColor: isDarkMode ? Colors.white : Colors.black,
      ),
      weekdayDecoration: CalendarWeekdayDecoration(
        textStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
        ),
      ),
      monthPickerDecoration: CalendarMonthPickerDecoration(
        defaultDayStyle: CalendarMonthPickerDefaultDayStyle(
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        selectedDayStyle: CalendarMonthPickerSelectedDayStyle(
          backgroundCircleColor: themeColor,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        currentDayStyle: CalendarMonthPickerCurrentDayStyle(
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: themeColor,
          ),
        ),
        selectedCurrentDayStyle: CalendarMonthPickerSelectedCurrentDayStyle(
          backgroundCircleColor: themeColor,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        disabledDayStyle: CalendarMonthPickerDisabledDayStyle(
          textStyle: TextStyle(
            fontSize: 18,
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
        ),
      ),
    );
  }
  //#endregion

  //#region Edit Transaction Dialog

class _UnifiedAddTransactionSheet extends StatefulWidget {
  final _HomeTabState homeState;
  final VoiceExpenseResult? prefillFromVoice;
  final TransactionType? initialType;
  final String? initialAccountId;
  final WalletTransaction? editing;
  final bool isGlass;
  final bool isPage;

  const _UnifiedAddTransactionSheet({
        required this.homeState,
    this.prefillFromVoice,
    this.initialType,
    this.initialAccountId,
    this.editing,
    required this.isGlass,
    required this.isPage,
  });

  @override
  State<_UnifiedAddTransactionSheet> createState() => _UnifiedAddTransactionSheetState();
}

class _UnifiedAddTransactionSheetState extends State<_UnifiedAddTransactionSheet> {
  late TransactionType activeType;
  late String selectedAccountId;
  late String fromAccountId;
  late String toAccountId;

  late final TextEditingController amountController;
  late final TextEditingController descriptionController;
  late final TextEditingController categorySearchController;
  late final PageController pageController;

  late final FocusNode amountFocusNode;
  late final FocusNode descriptionFocusNode;

  String categorySearchQuery = '';
  String secondaryPageType = 'category';
  String walletPickTarget = 'single';

  int currentPage = 0;
  DateTime selectedDate = DateTime.now();
  int? selectedCategoryId;
  bool isSubmitting = false;
  Timer? focusTimer;
  final Map<int, int> categoryUsageCounts = {};

  List<AccountItem> get availableAccounts =>
      widget.homeState._accounts.where((a) => !a.isAll).toList();

  @override
  void initState() {
    super.initState();
    activeType = widget.initialType ??
        (widget.prefillFromVoice != null
            ? (widget.prefillFromVoice!.transactionType == 'Deposit'
                ? TransactionType.income
                : TransactionType.expense)
            : TransactionType.expense);

    final accounts = availableAccounts;
    selectedAccountId = widget.initialAccountId != null && accounts.any((a) => a.id == widget.initialAccountId)
        ? widget.initialAccountId!
        : (widget.homeState._selectedAccountId != 'all' && accounts.any((a) => a.id == widget.homeState._selectedAccountId)
            ? widget.homeState._selectedAccountId
            : (accounts.isNotEmpty ? accounts.first.id : 'cash'));

    fromAccountId = (activeType == TransactionType.transfer && widget.initialAccountId != null && accounts.any((a) => a.id == widget.initialAccountId))
        ? widget.initialAccountId!
        : (accounts.isNotEmpty ? accounts.first.id : 'cash');

    toAccountId = accounts.length > 1
        ? (accounts.firstWhere((a) => a.id != fromAccountId, orElse: () => accounts.last).id)
        : (accounts.isNotEmpty ? accounts.first.id : 'bank');

    amountController = TextEditingController(
      text: widget.prefillFromVoice?.amount != null ? widget.prefillFromVoice!.amount.toString() : '',
    );
    descriptionController = TextEditingController(
      text: widget.prefillFromVoice?.title ?? widget.prefillFromVoice?.note ?? '',
    );
    categorySearchController = TextEditingController();
    pageController = PageController();

    selectedCategoryId = widget.prefillFromVoice?.categoryId;

    amountFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();

    if (widget.prefillFromVoice == null) {
      focusTimer = Timer(const Duration(milliseconds: 280), () {
        if (mounted && currentPage == 0 && amountFocusNode.canRequestFocus) {
          amountFocusNode.requestFocus();
        }
      });
    }

    // Editing an existing transaction: prefill every field from it.
    final editing = widget.editing;
    if (editing != null) {
      activeType = editing.isDeposit
          ? TransactionType.income
          : TransactionType.expense;
      amountController.text = editing.amount == editing.amount.roundToDouble()
          ? editing.amount.toInt().toString()
          : editing.amount.toString();
      // The sheet's text field is the note/description, not the title.
      descriptionController.text = editing.description?.trim() ?? '';
      selectedCategoryId = editing.categoryId ?? selectedCategoryId;
      selectedDate = editing.transactionDate;
    }

    final recent = widget.homeState._homeData?.recentTransactions ?? [];
    for (final t in recent) {
      if (t.categoryId != null) {
        categoryUsageCounts[t.categoryId!] = (categoryUsageCounts[t.categoryId!] ?? 0) + 1;
      }
    }
  }

  @override
  void dispose() {
    focusTimer?.cancel();
    amountFocusNode.dispose();
    descriptionFocusNode.dispose();
    amountController.dispose();
    descriptionController.dispose();
    categorySearchController.dispose();
    pageController.dispose();
    super.dispose();
  }

  IconData getCategoryIcon(String? nameEn) {
    final cat = (nameEn ?? '').toLowerCase();
    switch (cat) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'bonus':
        return Icons.card_giftcard_rounded;
      case 'income':
        return Icons.trending_up_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'transport':
      case 'transportation':
        return Icons.directions_car_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'bill':
      case 'bills':
        return Icons.receipt_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGlass = widget.isGlass;
    final isPage = widget.isPage;

            void returnToPage0() {
              amountFocusNode.canRequestFocus = false;
              descriptionFocusNode.canRequestFocus = false;
              amountFocusNode.unfocus();
              descriptionFocusNode.unfocus();
              FocusScope.of(context).unfocus();
              pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              ).then((_) {
                if (!mounted) return;
                amountFocusNode.canRequestFocus = true;
                descriptionFocusNode.canRequestFocus = true;
                if (amountFocusNode.canRequestFocus) {
                  amountFocusNode.requestFocus();
                }
              });
            }

            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final isAr = Localizations.localeOf(context).languageCode == 'ar';
            final currencySymbol = currencySymbols[widget.homeState._currencyCode ?? 'EGP'] ?? 'E£';

            final isIncome = activeType == TransactionType.income;
            final isExpense = activeType == TransactionType.expense;
            final isTransfer = activeType == TransactionType.transfer;

            final filteredCategories = widget.homeState._categories.where((c) {
              if (selectedCategoryId != null && c.id == selectedCategoryId) return true;
              return isIncome
                  ? ['Salary', 'Bonus', 'Income'].contains(c.nameEn)
                  : !['Salary', 'Bonus', 'Income'].contains(c.nameEn);
            }).toList();


            final sortedByUsage = filteredCategories.where((c) => (categoryUsageCounts[c.id] ?? 0) > 0).toList()
              ..sort((a, b) => (categoryUsageCounts[b.id] ?? 0).compareTo(categoryUsageCounts[a.id] ?? 0));

            final List<Category> mostUsedCategories;
            if (sortedByUsage.length >= 2) {
              mostUsedCategories = sortedByUsage.take(4).toList();
            } else {
              final popularKeywords = ['food', 'طعام', 'مطاعم', 'shop', 'تسوق', 'trans', 'مواصلات', 'grocer', 'بقالة', 'bill', 'فواتير', 'cafe', 'قهوة', 'salary', 'راتب'];
              final popular = filteredCategories.where((c) {
                final lowerEn = c.nameEn.toLowerCase();
                final lowerAr = c.nameAr.toLowerCase();
                return popularKeywords.any((k) => lowerEn.contains(k) || lowerAr.contains(k));
              }).toList();
              final combined = [...sortedByUsage];
              for (final p in popular) {
                if (combined.length >= 4) break;
                if (!combined.any((c) => c.id == p.id)) {
                  combined.add(p);
                }
              }
              for (final f in filteredCategories) {
                if (combined.length >= 4) break;
                if (!combined.any((c) => c.id == f.id)) {
                  combined.add(f);
                }
              }
              mostUsedCategories = combined;
            }

            final displayedCategories = categorySearchQuery.trim().isEmpty
                ? filteredCategories
                : filteredCategories.where((c) {
                    final q = categorySearchQuery.trim().toLowerCase();
                    return c.nameAr.toLowerCase().contains(q) ||
                        c.nameEn.toLowerCase().contains(q);
                  }).toList();

            final otherCategories = displayedCategories
                .where((c) => !mostUsedCategories.any((m) => m.id == c.id))
                .toList();

            final Color themeColor = isIncome
                ? const Color(0xFF10B981)
                : (isExpense ? const Color(0xFFF43F5E) : const Color(0xFF3B82F6));

            Future<void> submitTransaction() async {
              final normalized = _cleanNumberString(amountController.text);
              final amount = double.tryParse(normalized);
              if (amount == null || amount <= 0) {
                MessageService.showErrorAlert(
                  context: context,
                  message: context.l10n.enterValidAmount,
                );
                return;
              }

              if (isTransfer) {
                if (fromAccountId == toAccountId) {
                  MessageService.showErrorAlert(
                    context: context,
                    message: isAr
                        ? 'لا يمكن التحويل لنفس الحساب'
                        : 'Cannot transfer to same account',
                  );
                  return;
                }
                setState(() => isSubmitting = true);
                await Future.delayed(const Duration(milliseconds: 400));
                if (!context.mounted) return;
                Navigator.pop(context);
                MessageService.showSuccess(
                  context: context,
                  message: isAr
                      ? 'تم التحويل بنجاح 🚀'
                      : 'Transfer completed 🚀',
                );
                return;
              }

              if (selectedCategoryId == null) {
                MessageService.showErrorAlert(
                  context: context,
                  message: context.l10n.selectCategory,
                );
                return;
              }

              setState(() => isSubmitting = true);
              bool shouldPop = false;

              final editingTx = widget.editing;
              try {
                if (editingTx != null) {
                  await widget.homeState._walletRepository.updateTransaction(
                    editingTx.id,
                    title: editingTx.title,
                    description: descriptionController.text,
                    amount: amount,
                    type: isIncome ? 'Deposit' : 'Withdrawal',
                    categoryId: selectedCategoryId!,
                    transactionDate: selectedDate,
                  );
                } else {
                  await widget.homeState._walletRepository.addTransaction(
                    description: descriptionController.text,
                    amount: amount,
                    type: isIncome ? 'Deposit' : 'Withdrawal',
                    categoryId: selectedCategoryId!,
                    transactionDate: selectedDate,
                  );
                }
                shouldPop = true;
                await widget.homeState._loadHomeData();
                if (!context.mounted) return;
                MessageService.showSuccess(
                  context: context,
                  message: editingTx != null
                      ? context.l10n.transactionUpdatedSuccess
                      : (isIncome
                          ? context.l10n.depositAddedSuccess
                          : context.l10n.withdrawalAddedSuccess),
                );
              } catch (e) {
                if (!context.mounted) return;
                MessageService.showErrorAlert(
                  context: context,
                  message: editingTx != null
                      ? context.l10n.failedToUpdateTransaction(e.toString())
                      : context.l10n.failedToAddTransaction(e.toString()),
                );
              } finally {
                if (shouldPop) {
                  if (context.mounted) Navigator.pop(context);
                } else {
                  setState(() => isSubmitting = false);
                }
              }
            }

            Future<void> showAddCategoryDialog() async {
              await CategoriesManagementScreen.showAddCategoryModal(
                context: context,
                isDarkMode: isDarkMode,
                onSave: (name, iconIndex, sheetContext) async {
                  final trimmedName = name.trim();
                  if (trimmedName.isEmpty) {
                    MessageService.showWarning(
                      context: context,
                      message: context.l10n.pleaseEnterCategoryName,
                    );
                    return;
                  }

                  Category newCat;
                  try {
                    final repo = CategoryRepository();
                    newCat = await repo.createCategory(trimmedName, trimmedName);
                  } catch (_) {
                    final maxId = widget.homeState._categories.fold<int>(0, (m, c) => c.id > m ? c.id : m);
                    newCat = Category(
                      id: maxId + 1,
                      nameAr: trimmedName,
                      nameEn: trimmedName,
                      createdAt: DateTime.now(),
                    );
                  }

                  if (iconIndex >= 0 &&
                      iconIndex < CategoriesManagementScreen.availableCategoryIcons.length) {
                    CategoryIconHelper.setCustomIcon(
                      newCat.id,
                      CategoriesManagementScreen.availableCategoryIcons[iconIndex],
                    );
                  }

                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                  if (!context.mounted) return;

                  setState(() {
                    if (!widget.homeState._categories.any((c) => c.id == newCat.id)) {
                      widget.homeState._categories = [newCat, ...widget.homeState._categories];
                    }
                    selectedCategoryId = newCat.id;
                    categorySearchQuery = '';
                    categorySearchController.clear();
                  });

                  returnToPage0();

                  MessageService.showSuccess(
                    context: context,
                    message: context.l10n.categoryAddedSuccess,
                  );
                },
              );
            }

            final screenHeight = MediaQuery.of(context).size.height;

            final selectedAccount = availableAccounts.firstWhere(
              (a) => a.id == selectedAccountId,
              orElse: () => availableAccounts.isNotEmpty
                  ? availableAccounts.first
                  : AccountItem(
                      id: 'cash',
                      name: isAr ? 'كاش' : 'Cash',
                      type: 'cash',
                      balance: 0,
                      income: 0,
                      expense: 0,
                      icon: Icons.payments_rounded,
                    ),
            );

            final selectedCategory = selectedCategoryId != null
                ? filteredCategories.where((c) => c.id == selectedCategoryId).firstOrNull
                : null;
            final catName = selectedCategory != null
                ? (isAr ? selectedCategory.nameAr : selectedCategory.nameEn)
                : (isAr ? 'اختر تصنيف' : 'Select Category');

            final fromAccount = availableAccounts.firstWhere(
              (a) => a.id == fromAccountId,
              orElse: () => selectedAccount,
            );

            final toAccount = availableAccounts.firstWhere(
              (a) => a.id == toAccountId,
              orElse: () => availableAccounts.length > 1
                  ? availableAccounts[1]
                  : selectedAccount,
            );

            void openWalletPicker(String target) {
              focusTimer?.cancel();
              amountFocusNode.unfocus();
              descriptionFocusNode.unfocus();
              FocusScope.of(context).unfocus();
              HapticFeedback.selectionClick();
              setState(() {
                secondaryPageType = 'wallet';
                walletPickTarget = target;
              });
              pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic,
              );
            }

            Widget buildCategoryGroup(List<Category> categories) {
              if (categories.isEmpty) return const SizedBox.shrink();
              const double cardRadius = 18.0;
              return Container(
                decoration: BoxDecoration(
                  color: isGlass
                      ? (isDarkMode
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.white.withValues(alpha: 0.55))
                      : (isDarkMode ? const Color(0xFF141418) : Colors.white),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(
                    color: isGlass
                        ? (isDarkMode
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.85))
                        : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                    width: isGlass ? 0.8 : 1,
                  ),
                  boxShadow: isDarkMode
                      ? (isGlass
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null)
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isGlass ? 0.03 : 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cardRadius - 0.5),
                  child: Column(
                    children: List.generate(categories.length, (index) {
                      final cat = categories[index];
                      final isLast = index == categories.length - 1;
                      final catName = isAr ? cat.nameAr : cat.nameEn;
                      final meta = CategoryIconHelper.getMeta(cat.id, catName);
                      final isSelected = cat.id == selectedCategoryId;

                      final BorderRadius itemRadius;
                      if (categories.length == 1) {
                        itemRadius = BorderRadius.circular(cardRadius - 0.5);
                      } else if (index == 0) {
                        itemRadius = const BorderRadius.vertical(top: Radius.circular(cardRadius - 0.5));
                      } else if (isLast) {
                        itemRadius = const BorderRadius.vertical(bottom: Radius.circular(cardRadius - 0.5));
                      } else {
                        itemRadius = BorderRadius.zero;
                      }

                      return Column(
                        children: [
                          Material(
                            color: isGlass
                                ? Colors.transparent
                                : (isDarkMode ? const Color(0xFF141418) : Colors.white),
                            borderRadius: itemRadius,
                            child: InkWell(
                              borderRadius: itemRadius,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  selectedCategoryId = cat.id;
                                  categorySearchQuery = '';
                                  categorySearchController.clear();
                                });
                                returnToPage0();
                              },
                              splashColor: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.04),
                              highlightColor: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.02),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // Monochrome Category Icon Box
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? const Color(0xFF27272A)
                                            : const Color(0xFFE4E4E7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDarkMode
                                              ? const Color(0xFF3F3F46)
                                              : const Color(0xFFD4D4D8),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Icon(
                                        meta.icon,
                                        size: 20,
                                        color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Category Name
                                    Expanded(
                                      child: Text(
                                        catName,
                                        style: TextStyle(
                                          color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF09090B),
                                          fontSize: 15.5,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ),

                                    // Selection Checkmark
                                    if (isSelected)
                                      Icon(
                                        Icons.check_rounded,
                                        size: 21,
                                        color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 70, end: 16),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: isGlass
                                    ? (isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05))
                                    : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF1F1F5)),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              );
            }

            return PopScope(
              canPop: currentPage == 0,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (currentPage != 0) {
                  returnToPage0();
                }
              },
              child: Directionality(
                textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: isPage ? double.infinity : (screenHeight * 0.93).clamp(640.0, screenHeight - 28),
                    decoration: (isGlass || isPage)
                        ? const BoxDecoration(color: Colors.transparent)
                        : BoxDecoration(
                            color: isDarkMode ? const Color(0xFF121214) : Colors.white,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                            border: Border.all(
                              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                              width: 1,
                            ),
                          ),
                    padding: EdgeInsets.only(
                      bottom: (!isGlass && !isPage && MediaQuery.of(context).viewInsets.bottom > 0)
                          ? MediaQuery.of(context).viewInsets.bottom
                          : 8,
                      top: 0,
                      left: 16,
                      right: 16,
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle Bar (Android only, on iOS GlassModalSheet provides drag indicator)
                      if (!isGlass && !isPage)
                        Center(
                          child: Container(
                            height: 4,
                            width: 38,
                            margin: const EdgeInsets.only(top: 10, bottom: 8),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                      // Horizontal Sliding PageView
                      Expanded(
                        child: PageView(
                          clipBehavior: Clip.none,
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (idx) {
                            setState(() => currentPage = idx);
                            if (idx != 0) {
                              focusTimer?.cancel();
                            }
                          },
                          children: [
                            // ─── PAGE 0: MAIN TRANSACTION FORM ───
                            // ─── PAGE 0: MAIN TRANSACTION FORM ───
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => FocusScope.of(context).unfocus(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Top Bar (Page 0) - Fixed
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: isPage ? 14.0 : (isGlass ? 16.0 : 8.0),
                                      bottom: 20.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Close Button (X)
                                        if (isGlass)
                                          GlassButton.custom(
                                            width: 42,
                                            height: 42,
                                            shape: const LiquidOval(),
                                            useOwnLayer: true,
                                            quality: GlassQuality.premium,
                                            stretch: 0.35,
                                            interactionScale: 1.06,
                                            settings: isDarkMode
                                                ? const LiquidGlassSettings(
                                                    thickness: 28,
                                                    blur: 16,
                                                    refractiveIndex: 1.25,
                                                    lightIntensity: 1.8,
                                                    glassColor: Color(0x25FFFFFF),
                                                  )
                                                : const LiquidGlassSettings(
                                                    thickness: 28,
                                                    blur: 16,
                                                    refractiveIndex: 1.25,
                                                    lightIntensity: 1.8,
                                                    glassColor: Color(0x45FFFFFF),
                                                  ),
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              Navigator.pop(context);
                                            },
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 21,
                                              color: isDarkMode ? Colors.white : Colors.black87,
                                            ),
                                          )
                                        else
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () => Navigator.pop(context),
                                              borderRadius: BorderRadius.circular(21),
                                              child: Container(
                                                height: 42,
                                                width: 42,
                                                decoration: BoxDecoration(
                                                  color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.close_rounded,
                                                  size: 21,
                                                  color: isDarkMode ? Colors.white70 : Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ),

                                        // Title: New / Edit Transaction
                                        Text(
                                          widget.editing != null
                                              ? (isAr ? 'تعديل المعاملة' : 'Edit Transaction')
                                              : (isAr ? 'معاملة جديدة' : 'New Transaction'),
                                          style: TextStyle(
                                            fontSize: 17.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.3,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),

                                        // Confirm Button (✓)
                                        if (isGlass)
                                          GlassButton.custom(
                                            width: 42,
                                            height: 42,
                                            shape: const LiquidOval(),
                                            useOwnLayer: true,
                                            quality: GlassQuality.premium,
                                            stretch: 0.35,
                                            interactionScale: 1.06,
                                            settings: isDarkMode
                                                ? const LiquidGlassSettings(
                                                    thickness: 28,
                                                    blur: 16,
                                                    refractiveIndex: 1.25,
                                                    lightIntensity: 1.8,
                                                    glassColor: Color(0x25FFFFFF),
                                                  )
                                                : const LiquidGlassSettings(
                                                    thickness: 28,
                                                    blur: 16,
                                                    refractiveIndex: 1.25,
                                                    lightIntensity: 1.8,
                                                    glassColor: Color(0x45FFFFFF),
                                                  ),
                                            onTap: () {
                                              if (isSubmitting) return;
                                              HapticFeedback.selectionClick();
                                              submitTransaction();
                                            },
                                            child: Center(
                                              child: isSubmitting
                                                  ? SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2.2,
                                                        color: isDarkMode ? Colors.white : Colors.black,
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.check_rounded,
                                                      size: 22,
                                                      color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                                                    ),
                                            ),
                                          )
                                        else
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: isSubmitting ? null : submitTransaction,
                                              borderRadius: BorderRadius.circular(21),
                                              child: Container(
                                                height: 42,
                                                width: 42,
                                                decoration: BoxDecoration(
                                                  color: isDarkMode ? Colors.white : Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: isSubmitting
                                                      ? SizedBox(
                                                          width: 18,
                                                          height: 18,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2.2,
                                                            color: isDarkMode ? Colors.black : Colors.white,
                                                          ),
                                                        )
                                                      : Icon(
                                                          Icons.check_rounded,
                                                          size: 22,
                                                          color: isDarkMode ? Colors.black : Colors.white,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Scrollable Form Content
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const AlwaysScrollableScrollPhysics(
                                        parent: BouncingScrollPhysics(),
                                      ),
                                      padding: EdgeInsets.only(
                                        bottom: isGlass && MediaQuery.of(context).viewInsets.bottom > 0
                                            ? MediaQuery.of(context).viewInsets.bottom + 24
                                            : 16,
                                      ),
                                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [

                  // 3 Tabs Switcher (Expense, Income, Transfer)
                  if (isGlass)
                    GlassSegmentedControl(
                      selectedIndex: isExpense ? 0 : (isIncome ? 1 : 2),
                      onSegmentSelected: (idx) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (idx == 0) {
                            activeType = TransactionType.expense;
                            selectedCategoryId = null;
                          } else if (idx == 1) {
                            activeType = TransactionType.income;
                            selectedCategoryId = null;
                          } else {
                            activeType = TransactionType.transfer;
                          }
                        });
                      },
                      segments: [
                        GlassSegment(label: isAr ? 'صرف' : 'Expense'),
                        GlassSegment(label: isAr ? 'دخل' : 'Income'),
                        // A transfer is not an editable transaction type.
                        if (widget.editing == null)
                          GlassSegment(label: isAr ? 'تحويل' : 'Transfer'),
                      ],
                      height: 42,
                      useOwnLayer: true,
                      backgroundColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      indicatorColor: isDarkMode
                          ? const Color(0xFF27272A)
                          : Colors.white,
                      selectedTextStyle: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      unselectedTextStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.55),
                      ),
                    )
                  else
                    Container(
                      height: 48,
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          final tabWidth = totalWidth / 3;
                          final selectedIndex = isExpense ? 0 : (isIncome ? 1 : 2);
                          return Stack(
                            children: [
                              // Sliding Pill Indicator (Directionality-aware for LTR & RTL)
                              AnimatedPositionedDirectional(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.fastOutSlowIn,
                                start: selectedIndex * tabWidth,
                                top: 0,
                                bottom: 0,
                                width: tabWidth,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF27272A) : Colors.white,
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                      color: isDarkMode
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black.withValues(alpha: 0.06),
                                    ),
                                  ),
                                ),
                              ),
                              // 3 Tabs
                              Row(
                                children: [
                                  _buildSegmentTab(
                                    label: isAr ? 'صرف' : 'Expense',
                                    isSelected: isExpense,
                                    activeColor: const Color(0xFFF43F5E),
                                    isDarkMode: isDarkMode,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        activeType = TransactionType.expense;
                                        selectedCategoryId = null;
                                      });
                                    },
                                  ),
                                  _buildSegmentTab(
                                    label: isAr ? 'دخل' : 'Income',
                                    isSelected: isIncome,
                                    activeColor: const Color(0xFF10B981),
                                    isDarkMode: isDarkMode,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        activeType = TransactionType.income;
                                        selectedCategoryId = null;
                                      });
                                    },
                                  ),
                                  if (widget.editing == null)
                                    _buildSegmentTab(
                                      label: isAr ? 'تحويل' : 'Transfer',
                                      isSelected: isTransfer,
                                      activeColor: const Color(0xFF3B82F6),
                                      isDarkMode: isDarkMode,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          activeType = TransactionType.transfer;
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 18),

                  // Amount Display Area (Dynamic auto-scaling, max 12 digits)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: amountController,
                          builder: (context, value, _) {
                            final rawDigits = value.text.replaceAll(RegExp(r'[^0-9\.]'), '');
                            final length = rawDigits.length;
                            final double amountFontSize;
                            final double symbolFontSize;
                            final double letterSpacing;

                            if (length <= 6) {
                              amountFontSize = 48;
                              symbolFontSize = 26;
                              letterSpacing = -0.5;
                            } else if (length <= 9) {
                              amountFontSize = 42;
                              symbolFontSize = 23;
                              letterSpacing = -0.4;
                            } else if (length <= 12) {
                              amountFontSize = 35;
                              symbolFontSize = 20;
                              letterSpacing = -0.3;
                            } else {
                              amountFontSize = 30;
                              symbolFontSize = 17;
                              letterSpacing = -0.2;
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 150),
                                  curve: Curves.fastOutSlowIn,
                                  style: TextStyle(
                                    fontSize: symbolFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: themeColor,
                                  ),
                                  child: Text(currencySymbol),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: IntrinsicWidth(
                                    child: TextFormField(
                                      controller: amountController,
                                      focusNode: amountFocusNode,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      keyboardAppearance: isDarkMode ? Brightness.dark : Brightness.light,
                                      autofocus: false,
                                      textAlign: TextAlign.center,
                                      cursorColor: themeColor,
                                      cursorWidth: 2.2,
                                      cursorRadius: const Radius.circular(2),
                                      inputFormatters: [
                                        _ThousandsSeparatorInputFormatter(maxDigits: 12),
                                      ],
                                      style: TextStyle(
                                        fontSize: amountFontSize,
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                                        letterSpacing: letterSpacing,
                                      ),
                                      decoration: InputDecoration(
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          fontSize: amountFontSize,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8),
                                          letterSpacing: letterSpacing,
                                        ),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [50, 100, 200, 500, 1000].map((val) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        final normalized = _cleanNumberString(amountController.text);
                                        final cur = double.tryParse(normalized) ?? 0.0;
                                        final nextVal = (cur + val).toStringAsFixed(0);
                                        if (nextVal.length <= 12) {
                                          final formatted = _formatThousands(nextVal);
                                          amountController.value = TextEditingValue(
                                            text: formatted,
                                            selection: TextSelection.collapsed(offset: formatted.length),
                                          );
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: isGlass
                                            ? (isDarkMode
                                                ? Colors.white.withValues(alpha: 0.08)
                                                : Colors.white.withValues(alpha: 0.55))
                                            : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isGlass
                                              ? (isDarkMode
                                                  ? Colors.white.withValues(alpha: 0.14)
                                                  : Colors.white.withValues(alpha: 0.85))
                                              : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                          width: isGlass ? 0.8 : 1.0,
                                        ),
                                        boxShadow: isGlass
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        '+$val',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: isGlass
                                              ? (isDarkMode ? Colors.white.withValues(alpha: 0.90) : const Color(0xFF18181B))
                                              : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                    const SizedBox(height: 14),

                    // Account & Category Selectors (or Transfer Row) with smooth fluid transition
                    AnimatedSize(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.fastOutSlowIn,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: isTransfer
                            ? Column(
                                key: const ValueKey('transfer_mode_content'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Label: From Account
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 7),
                                    child: Text(
                                      isAr ? 'من حساب' : 'From account',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  // Top Button: From Account
                                  InkWell(
                                    onTap: () => openWalletPicker('from'),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isGlass
                                            ? (isDarkMode
                                                ? Colors.white.withValues(alpha: 0.07)
                                                : Colors.white.withValues(alpha: 0.52))
                                            : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isGlass
                                              ? (isDarkMode
                                                  ? Colors.white.withValues(alpha: 0.12)
                                                  : Colors.white.withValues(alpha: 0.85))
                                              : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                          width: isGlass ? 0.8 : 1.0,
                                        ),
                                        boxShadow: isGlass
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              fromAccount.icon,
                                              size: 20,
                                              color: const Color(0xFFF43F5E),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              fromAccount.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w700,
                                                color: isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            appForwardIconOf(context),
                                            size: 22,
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Middle: Down Arrow / Swap Button
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Center(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            setState(() {
                                              final temp = fromAccountId;
                                              fromAccountId = toAccountId;
                                              toAccountId = temp;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isGlass
                                                  ? (isDarkMode
                                                      ? Colors.white.withValues(alpha: 0.08)
                                                      : Colors.white.withValues(alpha: 0.60))
                                                  : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isGlass
                                                    ? (isDarkMode
                                                        ? Colors.white.withValues(alpha: 0.15)
                                                        : Colors.white.withValues(alpha: 0.85))
                                                    : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                                width: isGlass ? 0.8 : 1.5,
                                              ),
                                              boxShadow: isGlass
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
                                                        blurRadius: 6,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Icon(
                                              Icons.arrow_downward_rounded,
                                              size: 20,
                                              color: themeColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Label: To Account
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 7),
                                    child: Text(
                                      isAr ? 'إلى حساب' : 'To account',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  // Bottom Button: To Account
                                  InkWell(
                                    onTap: () => openWalletPicker('to'),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isGlass
                                            ? (isDarkMode
                                                ? Colors.white.withValues(alpha: 0.07)
                                                : Colors.white.withValues(alpha: 0.52))
                                            : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isGlass
                                              ? (isDarkMode
                                                  ? Colors.white.withValues(alpha: 0.12)
                                                  : Colors.white.withValues(alpha: 0.85))
                                              : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                          width: isGlass ? 0.8 : 1.0,
                                        ),
                                        boxShadow: isGlass
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              toAccount.icon,
                                              size: 20,
                                              color: const Color(0xFF10B981),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              toAccount.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w700,
                                                color: isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            appForwardIconOf(context),
                                            size: 22,
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                key: const ValueKey('expense_income_content'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Category Selector Card (Tap opens in-sheet category tab)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 7),
                                    child: Text(
                                      isAr ? 'التصنيف' : 'Category',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      focusTimer?.cancel();
                                      amountFocusNode.unfocus();
                                      descriptionFocusNode.unfocus();
                                      FocusScope.of(context).unfocus();
                                      HapticFeedback.selectionClick();
                                      setState(() => secondaryPageType = 'category');
                                      pageController.animateToPage(
                                        1,
                                        duration: const Duration(milliseconds: 320),
                                        curve: Curves.easeInOutCubic,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isGlass
                                            ? (isDarkMode
                                                ? Colors.white.withValues(alpha: 0.07)
                                                : Colors.white.withValues(alpha: 0.52))
                                            : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isGlass
                                              ? (isDarkMode
                                                  ? Colors.white.withValues(alpha: 0.12)
                                                  : Colors.white.withValues(alpha: 0.85))
                                              : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                          width: isGlass ? 0.8 : 1.0,
                                        ),
                                        boxShadow: isGlass
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? const Color(0xFF27272A)
                                                  : const Color(0xFFE4E4E7),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isDarkMode
                                                    ? const Color(0xFF3F3F46)
                                                    : const Color(0xFFD4D4D8),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Icon(
                                              selectedCategory != null
                                                  ? getCategoryIcon(selectedCategory.nameEn)
                                                  : Icons.category_outlined,
                                              size: 20,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : const Color(0xFF09090B),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  catName,
                                                  style: TextStyle(
                                                    fontSize: 15.5,
                                                    fontWeight: selectedCategory != null ? FontWeight.w700 : FontWeight.w500,
                                                    color: selectedCategory != null
                                                        ? (isDarkMode ? Colors.white : Colors.black)
                                                        : (isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            appForwardIconOf(context),
                                            size: 24,
                                            color: isGlass
                                                ? (isDarkMode ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.35))
                                                : (isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Wallet Account Selector Card (Tap opens picker bottom sheet)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 7),
                                    child: Text(
                                      isAr ? 'الحساب' : 'Account',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => openWalletPicker('single'),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isGlass
                                            ? (isDarkMode
                                                ? Colors.white.withValues(alpha: 0.07)
                                                : Colors.white.withValues(alpha: 0.52))
                                            : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isGlass
                                              ? (isDarkMode
                                                  ? Colors.white.withValues(alpha: 0.12)
                                                  : Colors.white.withValues(alpha: 0.85))
                                              : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                          width: isGlass ? 0.8 : 1.0,
                                        ),
                                        boxShadow: isGlass
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isGlass
                                                  ? (isDarkMode
                                                      ? Colors.white.withValues(alpha: 0.10)
                                                      : Colors.black.withValues(alpha: 0.05))
                                                  : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              selectedAccount.icon,
                                              size: 21,
                                              color: isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selectedAccount.name,
                                                  style: TextStyle(
                                                    fontSize: 15.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDarkMode ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            appForwardIconOf(context),
                                            size: 24,
                                            color: isGlass
                                                ? (isDarkMode ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.35))
                                                : (isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Note / Description Input Field
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 7),
                      child: Text(
                        isAr ? 'الوصف أو الملاحظة' : 'Note / Description',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isGlass
                            ? (isDarkMode
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.white.withValues(alpha: 0.52))
                            : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isGlass
                              ? (isDarkMode
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.85))
                              : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                          width: isGlass ? 0.8 : 1.0,
                        ),
                        boxShadow: isGlass
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isGlass
                                  ? (isDarkMode
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : Colors.black.withValues(alpha: 0.05))
                                  : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.edit_note_rounded,
                              size: 21,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: descriptionController,
                              focusNode: descriptionFocusNode,
                              keyboardAppearance: isDarkMode ? Brightness.dark : Brightness.light,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                hintText: isAr ? 'ملاحظة أو وصف (اختياري)...' : 'Note / Description (optional)...',
                                hintStyle: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: descriptionController,
                            builder: (context, val, _) {
                              if (val.text.isEmpty) return const SizedBox.shrink();
                              return GestureDetector(
                                onTap: () => descriptionController.clear(),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 6, right: 2),
                                  child: Icon(
                                    Icons.cancel_rounded,
                                    size: 20,
                                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Date Selector Field (Replaces bottom button, defaults to 'النهارده' / Today)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 7),
                      child: Text(
                        isAr ? 'التاريخ' : 'Date',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    Builder(
                      builder: (btnContext) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              HapticFeedback.selectionClick();
                              final picked = await _showFloatingDatePicker(
                                context: btnContext,
                                initialDate: selectedDate,
                                isDarkMode: isDarkMode,
                                isAr: isAr,
                                themeColor: themeColor,
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isGlass
                                    ? (isDarkMode
                                        ? Colors.white.withValues(alpha: 0.07)
                                        : Colors.white.withValues(alpha: 0.52))
                                    : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isGlass
                                      ? (isDarkMode
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : Colors.white.withValues(alpha: 0.85))
                                      : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                  width: isGlass ? 0.8 : 1.0,
                                ),
                                boxShadow: isGlass
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 24,
                                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      isAr ? 'اختر التاريخ' : 'Pick date',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (pillContext) {
                                      return InkWell(
                                        onTap: () async {
                                          FocusScope.of(context).unfocus();
                                          HapticFeedback.selectionClick();
                                          final picked = await _showFloatingDatePicker(
                                            context: pillContext,
                                            initialDate: selectedDate,
                                            isDarkMode: isDarkMode,
                                            isAr: isAr,
                                            themeColor: themeColor,
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              selectedDate = picked;
                                            });
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: isGlass
                                                ? (isDarkMode
                                                    ? Colors.white.withValues(alpha: 0.10)
                                                    : Colors.white.withValues(alpha: 0.70))
                                                : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isGlass
                                                  ? (isDarkMode
                                                      ? Colors.white.withValues(alpha: 0.16)
                                                      : Colors.white.withValues(alpha: 0.90))
                                                  : (isDarkMode
                                                      ? Colors.white.withValues(alpha: 0.08)
                                                      : Colors.black.withValues(alpha: 0.06)),
                                              width: isGlass ? 0.8 : 1.0,
                                            ),
                                            boxShadow: isGlass
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: isDarkMode ? 0.10 : 0.03),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                DateFormat('d MMM yyyy', isAr ? 'ar' : 'en').format(selectedDate),
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDarkMode ? Colors.white : Colors.black87,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.keyboard_arrow_down_rounded,
                                                size: 16,
                                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                SizedBox(
                  height: Platform.isIOS && amountFocusNode.hasFocus && MediaQuery.of(context).viewInsets.bottom > 0
                      ? 56
                      : 16,
                ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                  // ─── PAGE 1: SECONDARY SUB-PAGE (CATEGORY OR WALLET) ───
                  if (secondaryPageType == 'category')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Bar (Category) - Fixed
                        Padding(
                          padding: EdgeInsets.only(
                            top: isPage ? 14.0 : (isGlass ? 16.0 : 8.0),
                            bottom: 12.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button (←)
                              if (isGlass)
                                GlassButton.custom(
                                  width: 42,
                                  height: 42,
                                  shape: const LiquidOval(),
                                  useOwnLayer: true,
                                  quality: GlassQuality.premium,
                                  stretch: 0.35,
                                  interactionScale: 1.06,
                                  settings: isDarkMode
                                      ? const LiquidGlassSettings(
                                          thickness: 28,
                                          blur: 16,
                                          refractiveIndex: 1.25,
                                          lightIntensity: 1.8,
                                          glassColor: Color(0x25FFFFFF),
                                        )
                                      : const LiquidGlassSettings(
                                          thickness: 28,
                                          blur: 16,
                                          refractiveIndex: 1.25,
                                          lightIntensity: 1.8,
                                          glassColor: Color(0x45FFFFFF),
                                        ),
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    returnToPage0();
                                  },
                                  child: Icon(
                                    appBackIcon(isIOS: isGlass, isRtl: isAr),
                                    size: 21,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                )
                              else
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      returnToPage0();
                                    },
                                    borderRadius: BorderRadius.circular(21),
                                    child: Container(
                                      height: 42,
                                      width: 42,
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                        ),
                                      ),
                                      child: Icon(
                                        appBackIcon(isIOS: isGlass, isRtl: isAr),
                                        size: 21,
                                        color: isDarkMode ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),

                              // Title: Select Category
                              Text(
                                isAr ? 'اختر التصنيف' : 'Select Category',
                                style: TextStyle(
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),

                              // Balanced spacer
                              const SizedBox(width: 42),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Scrollable Content & Floating Add Button
                        Expanded(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned.fill(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.only(
                                    bottom: isGlass && MediaQuery.of(context).viewInsets.bottom > 0
                                        ? MediaQuery.of(context).viewInsets.bottom + 80
                                        : 0,
                                  ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Search Bar
                                Container(
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: isGlass
                                        ? (isDarkMode
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.white.withValues(alpha: 0.52))
                                        : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isGlass
                                          ? (isDarkMode
                                              ? Colors.white.withValues(alpha: 0.12)
                                              : Colors.white.withValues(alpha: 0.85))
                                          : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                      width: isGlass ? 0.8 : 1.0,
                                    ),
                                    boxShadow: isGlass
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
                                              blurRadius: 6,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search_rounded,
                                        size: 21,
                                        color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: categorySearchController,
                                          keyboardAppearance: isDarkMode ? Brightness.dark : Brightness.light,
                                          onChanged: (val) {
                                            setState(() {
                                              categorySearchQuery = val;
                                            });
                                          },
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                          decoration: InputDecoration(
                                            filled: false,
                                            fillColor: Colors.transparent,
                                            hintText: isAr ? 'ابحث عن تصنيف...' : 'Search categories...',
                                            hintStyle: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                            ),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                      if (categorySearchQuery.isNotEmpty)
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            categorySearchController.clear();
                                            setState(() {
                                              categorySearchQuery = '';
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(
                                              Icons.cancel_rounded,
                                              size: 17,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Grouped Categories Cards (Matching Categories Management screen)
                                const SizedBox(height: 14),
                                if (displayedCategories.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 40),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.category_outlined,
                                          size: 44,
                                          color: isDarkMode
                                              ? const Color(0xFF3F3F46)
                                              : const Color(0xFFE4E4E7),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          categorySearchQuery.trim().isNotEmpty
                                              ? (isAr ? 'لا توجد نتائج مطابقة' : 'No matching categories found')
                                              : (isAr ? 'لا توجد تصنيفات متاحة' : 'No categories available'),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDarkMode
                                                ? const Color(0xFFA1A1AA)
                                                : const Color(0xFF71717A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (categorySearchQuery.trim().isNotEmpty) ...[
                                  buildCategoryGroup(displayedCategories),
                                ] else ...[
                                  // Most Used Section
                                  if (mostUsedCategories.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                                      child: Text(
                                        isAr ? 'الأكثر استخداماً' : 'Most Used',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    buildCategoryGroup(mostUsedCategories),
                                    const SizedBox(height: 16),
                                  ],

                                  // Others Section (excluding most used categories)
                                  if (otherCategories.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                                      child: Text(
                                        isAr ? 'أخرى' : 'Others',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    buildCategoryGroup(otherCategories),
                                  ],
                                ],
                                const SizedBox(height: 130),
                              ],
                            ),
                          ),
                        ),

                        // Floating "Add Category" Button
                        Positioned(
                          bottom: (isGlass && MediaQuery.of(context).viewInsets.bottom > 0)
                              ? MediaQuery.of(context).viewInsets.bottom + 16
                              : 44,
                          child: isGlass
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.12),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: GlassButton.custom(
                                    height: 46,
                                    shape: const LiquidRoundedRectangle(borderRadius: 23),
                                    useOwnLayer: true,
                                    quality: GlassQuality.premium,
                                    stretch: 0.15,
                                    interactionScale: 1.04,
                                    settings: isDarkMode
                                        ? const LiquidGlassSettings(
                                            thickness: 28,
                                            blur: 16,
                                            refractiveIndex: 1.25,
                                            lightIntensity: 1.8,
                                            glassColor: Color(0x35FFFFFF),
                                          )
                                        : const LiquidGlassSettings(
                                            thickness: 28,
                                            blur: 16,
                                            refractiveIndex: 1.25,
                                            lightIntensity: 1.8,
                                            glassColor: Color(0x75FFFFFF),
                                          ),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      showAddCategoryDialog();
                                    },
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_rounded,
                                              size: 21,
                                              color: isDarkMode ? Colors.white : Colors.black87,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isAr ? 'إضافة تصنيف' : 'Add Category',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                height: 1.2,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      showAddCategoryDialog();
                                    },
                                    borderRadius: BorderRadius.circular(23),
                                    child: Container(
                                      height: 46,
                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                      decoration: BoxDecoration(
                                        color: themeColor,
                                        borderRadius: BorderRadius.circular(23),
                                        boxShadow: [
                                          BoxShadow(
                                            color: themeColor.withValues(alpha: 0.35),
                                            blurRadius: 14,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.add_rounded,
                                            size: 21,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isAr ? 'إضافة تصنيف' : 'Add Category',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                              color: Colors.white,
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
                  ),
                ],
              )
                  else
                    // ─── SECONDARY TAB: WALLET SELECTION (Clean: No Search, No Recently Used) ───
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Bar (Wallet) - Fixed
                        Padding(
                          padding: EdgeInsets.only(
                            top: isPage ? 14.0 : (isGlass ? 16.0 : 8.0),
                            bottom: 12.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back Button (←)
                              if (isGlass)
                                GlassButton.custom(
                                  width: 42,
                                  height: 42,
                                  shape: const LiquidOval(),
                                  useOwnLayer: true,
                                  quality: GlassQuality.premium,
                                  stretch: 0.35,
                                  interactionScale: 1.06,
                                  settings: isDarkMode
                                      ? const LiquidGlassSettings(
                                          thickness: 28,
                                          blur: 16,
                                          refractiveIndex: 1.25,
                                          lightIntensity: 1.8,
                                          glassColor: Color(0x25FFFFFF),
                                        )
                                      : const LiquidGlassSettings(
                                          thickness: 28,
                                          blur: 16,
                                          refractiveIndex: 1.25,
                                          lightIntensity: 1.8,
                                          glassColor: Color(0x45FFFFFF),
                                        ),
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    returnToPage0();
                                  },
                                  child: Icon(
                                    appBackIcon(isIOS: isGlass, isRtl: isAr),
                                    size: 21,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                )
                              else
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      returnToPage0();
                                    },
                                    borderRadius: BorderRadius.circular(21),
                                    child: Container(
                                      height: 42,
                                      width: 42,
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                        ),
                                      ),
                                      child: Icon(
                                        appBackIcon(isIOS: isGlass, isRtl: isAr),
                                        size: 21,
                                        color: isDarkMode ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),

                              // Title
                              Text(
                                walletPickTarget == 'from'
                                    ? (isAr ? 'من حساب' : 'From Account')
                                    : (walletPickTarget == 'to'
                                        ? (isAr ? 'إلى حساب' : 'To Account')
                                        : (isAr ? 'اختر الحساب' : 'Select Account')),
                                style: TextStyle(
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),

                              // Balanced spacer
                              const SizedBox(width: 42),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Direct Wallets List (Clean, No Search, No Recently Used)
                        Expanded(
                          child: availableAccounts.isEmpty
                              ? Center(
                                  child: Text(
                                    isAr ? 'لا توجد حسابات متاحة' : 'No accounts available',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: availableAccounts.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final acc = availableAccounts[index];
                                    final isSelected = walletPickTarget == 'from'
                                        ? acc.id == fromAccountId
                                        : (walletPickTarget == 'to'
                                            ? acc.id == toAccountId
                                            : acc.id == selectedAccountId);
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            if (walletPickTarget == 'from') {
                                              fromAccountId = acc.id;
                                            } else if (walletPickTarget == 'to') {
                                              toAccountId = acc.id;
                                            } else {
                                              selectedAccountId = acc.id;
                                            }
                                          });
                                          returnToPage0();
                                        },
                                        borderRadius: BorderRadius.circular(18),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? themeColor.withValues(alpha: isGlass ? 0.18 : 0.12)
                                                : (isGlass
                                                    ? (isDarkMode
                                                        ? Colors.white.withValues(alpha: 0.07)
                                                        : Colors.white.withValues(alpha: 0.52))
                                                    : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5))),
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(
                                              color: isSelected
                                                  ? themeColor.withValues(alpha: 0.6)
                                                  : (isGlass
                                                      ? (isDarkMode
                                                          ? Colors.white.withValues(alpha: 0.12)
                                                          : Colors.white.withValues(alpha: 0.85))
                                                      : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))),
                                              width: isSelected ? 1.5 : (isGlass ? 0.8 : 1.0),
                                            ),
                                            boxShadow: isGlass
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: isDarkMode ? 0.12 : 0.03),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? themeColor.withValues(alpha: 0.2)
                                                      : (isGlass
                                                          ? (isDarkMode
                                                              ? Colors.white.withValues(alpha: 0.10)
                                                              : Colors.black.withValues(alpha: 0.05))
                                                          : (isDarkMode
                                                              ? const Color(0xFF27272A)
                                                              : const Color(0xFFE4E4E7))),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  acc.icon,
                                                  size: 21,
                                                  color: isSelected
                                                      ? themeColor
                                                      : (isDarkMode ? Colors.white70 : Colors.black87),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      acc.name,
                                                      style: TextStyle(
                                                        fontSize: 15.5,
                                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                        color: isDarkMode ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      '${acc.balance.toStringAsFixed(2)} $currencySymbol',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 22,
                                                  color: themeColor,
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
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating Glass "Next" button above iOS numeric keyboard only
      IosKeyboardFloatingButton(
        focusNode: amountFocusNode,
        isVisible: () => currentPage == 0,
        isGlass: isGlass,
      ),
    ],
  ),
),
  );

  }
}
