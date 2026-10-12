part of '../screens/home_tab.dart';
// ignore_for_file: annotate_overrides

mixin _HomeTabDialogs on _HomeTabState {
  //#region Unified 3-in-1 Transaction Sheet (Say / Linear Minimalist)
  void _showUnifiedAddModal({
    VoiceExpenseResult? prefillFromVoice,
    TransactionType? initialType,
    String? initialAccountId,
  }) {
    TransactionType activeType = initialType ??
        (prefillFromVoice != null
            ? (prefillFromVoice.transactionType == 'Deposit'
                ? TransactionType.income
                : TransactionType.expense)
            : TransactionType.expense);

    final availableAccounts = _accounts.where((a) => !a.isAll).toList();
    String selectedAccountId = initialAccountId != null && availableAccounts.any((a) => a.id == initialAccountId)
        ? initialAccountId
        : (_selectedAccountId != 'all' && availableAccounts.any((a) => a.id == _selectedAccountId)
            ? _selectedAccountId
            : (availableAccounts.isNotEmpty ? availableAccounts.first.id : 'cash'));
    String fromAccountId = (activeType == TransactionType.transfer && initialAccountId != null && availableAccounts.any((a) => a.id == initialAccountId))
        ? initialAccountId
        : (availableAccounts.isNotEmpty ? availableAccounts.first.id : 'cash');
    String toAccountId = availableAccounts.length > 1
        ? (availableAccounts.firstWhere((a) => a.id != fromAccountId, orElse: () => availableAccounts.last).id)
        : (availableAccounts.isNotEmpty ? availableAccounts.first.id : 'bank');

    final amountController = TextEditingController(
      text: prefillFromVoice?.amount != null ? prefillFromVoice!.amount.toString() : '',
    );
    final descriptionController = TextEditingController(
      text: prefillFromVoice?.title ?? prefillFromVoice?.note ?? '',
    );
    final categorySearchController = TextEditingController();
    String categorySearchQuery = '';
    String secondaryPageType = 'category'; // 'category' or 'wallet'
    String walletPickTarget = 'single'; // 'single', 'from', 'to'

    final pageController = PageController();
    int currentPage = 0;
    DateTime selectedDate = DateTime.now();
    int? selectedCategoryId = prefillFromVoice?.categoryId;
    bool isSubmitting = false;

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

    final amountFocusNode = FocusNode();
    final descriptionFocusNode = FocusNode();
    bool shouldAutofocus = prefillFromVoice == null;
    amountFocusNode.addListener(() {
      if (!amountFocusNode.hasFocus) {
        shouldAutofocus = false;
      }
    });

    _showAdaptiveBottomSheet(
      isScrollControlled: true,
      showDragHandle: false,
      dismissible: false,
      enableDrag: false,
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
        return StatefulBuilder(
          builder: (context, setState) {
            if (shouldAutofocus) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                shouldAutofocus = false;
              });
            }

            void returnToPage0() {
              shouldAutofocus = false;
              amountFocusNode.canRequestFocus = false;
              descriptionFocusNode.canRequestFocus = false;
              amountFocusNode.unfocus();
              descriptionFocusNode.unfocus();
              FocusScope.of(context).unfocus();
              pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic,
              ).then((_) {
                amountFocusNode.canRequestFocus = true;
                descriptionFocusNode.canRequestFocus = true;
              });
            }

            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final isAr = Localizations.localeOf(context).languageCode == 'ar';
            final currencySymbol = currencySymbols[_currencyCode ?? 'USD'] ?? '\$';

            final isIncome = activeType == TransactionType.income;
            final isExpense = activeType == TransactionType.expense;
            final isTransfer = activeType == TransactionType.transfer;

            final filteredCategories = _categories.where((c) {
              if (selectedCategoryId != null && c.id == selectedCategoryId) return true;
              return isIncome
                  ? ['Salary', 'Bonus', 'Income'].contains(c.nameEn)
                  : !['Salary', 'Bonus', 'Income'].contains(c.nameEn);
            }).toList();


            // Calculate Most Used Categories based on transaction frequency
            final recent = _homeData?.recentTransactions ?? [];
            final Map<int, int> categoryUsageCounts = {};
            for (final t in recent) {
              if (t.categoryId != null) {
                categoryUsageCounts[t.categoryId!] = (categoryUsageCounts[t.categoryId!] ?? 0) + 1;
              }
            }
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
                MessageService.showError(
                  context: context,
                  message: context.l10n.enterValidAmount,
                );
                return;
              }

              if (isTransfer) {
                if (fromAccountId == toAccountId) {
                  MessageService.showError(
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
                MessageService.showError(
                  context: context,
                  message: context.l10n.selectCategory,
                );
                return;
              }

              setState(() => isSubmitting = true);
              bool shouldPop = false;

              try {
                await _walletRepository.addTransaction(
                  description: descriptionController.text,
                  amount: amount,
                  type: isIncome ? 'Deposit' : 'Withdrawal',
                  categoryId: selectedCategoryId!,
                  transactionDate: selectedDate,
                );
                shouldPop = true;
                await _loadHomeData();
                if (!context.mounted) return;
                MessageService.showSuccess(
                  context: context,
                  message: isIncome
                      ? context.l10n.depositAddedSuccess
                      : context.l10n.withdrawalAddedSuccess,
                );
              } catch (e) {
                if (!context.mounted) return;
                MessageService.showError(
                  context: context,
                  message: context.l10n.failedToAddTransaction(e.toString()),
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
                    final maxId = _categories.fold<int>(0, (m, c) => c.id > m ? c.id : m);
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
                    if (!_categories.any((c) => c.id == newCat.id)) {
                      _categories = [newCat, ..._categories];
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
              shouldAutofocus = false;
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
                  color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(
                    color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                    width: 1,
                  ),
                  boxShadow: isDarkMode
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
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
                            color: isDarkMode ? const Color(0xFF141418) : Colors.white,
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
                                    // Colored Category Icon Box
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: meta.color.withValues(alpha: isDarkMode ? 0.18 : 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: meta.color.withValues(alpha: isDarkMode ? 0.30 : 0.20),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Icon(
                                        meta.icon,
                                        size: 20,
                                        color: meta.color,
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
                                        color: themeColor,
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
                                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF1F1F5),
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
                  children: [
                    Container(
                      height: (screenHeight * 0.93).clamp(640.0, screenHeight - 28),
                    decoration: isGlass
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
                      bottom: MediaQuery.of(context).viewInsets.bottom > 0
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
                      if (!isGlass)
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
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (idx) {
                            setState(() => currentPage = idx);
                            if (idx != 0) {
                              shouldAutofocus = false;
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
                                      top: isGlass
                                          ? (MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top * 0.10 + 6 : 8.0)
                                          : 8.0,
                                      bottom: 22.0,
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
                                            stretch: 0.2,
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

                                        // Title: New Transaction
                                        Text(
                                          isAr ? 'معاملة جديدة' : 'New Transaction',
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
                                            style: GlassButtonStyle.prominent,
                                            stretch: 0.2,
                                            interactionScale: 1.06,
                                            settings: isDarkMode
                                                ? const LiquidGlassSettings(
                                                    thickness: 34,
                                                    blur: 18,
                                                    refractiveIndex: 1.28,
                                                    lightIntensity: 2.0,
                                                    glassColor: Color(0x35FFFFFF),
                                                  )
                                                : const LiquidGlassSettings(
                                                    thickness: 34,
                                                    blur: 18,
                                                    refractiveIndex: 1.28,
                                                    lightIntensity: 2.0,
                                                    glassColor: Color(0x55FFFFFF),
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
                                      autofocus: shouldAutofocus,
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
                                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                        ),
                                      ),
                                      child: Text(
                                        '+$val',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
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
                                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                        ),
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
                                            Icons.chevron_right_rounded,
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
                                              color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                                width: 1.5,
                                              ),
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
                                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                        ),
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
                                            Icons.chevron_right_rounded,
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
                                      shouldAutofocus = false;
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
                                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: selectedCategory != null
                                                  ? themeColor.withValues(alpha: 0.15)
                                                  : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              selectedCategory != null
                                                  ? getCategoryIcon(selectedCategory.nameEn)
                                                  : Icons.category_outlined,
                                              size: 21,
                                              color: selectedCategory != null
                                                  ? themeColor
                                                  : (isDarkMode ? Colors.grey[400] : Colors.grey[500]),
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
                                            Icons.chevron_right_rounded,
                                            size: 24,
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
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
                                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
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
                                            Icons.chevron_right_rounded,
                                            size: 24,
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
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
                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
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
                                color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                ),
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
                                            color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isDarkMode
                                                  ? Colors.white.withValues(alpha: 0.08)
                                                  : Colors.black.withValues(alpha: 0.06),
                                              width: 1,
                                            ),
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
                            top: isGlass
                                ? (MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top * 0.10 + 6 : 8.0)
                                : 8.0,
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
                                  stretch: 0.2,
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
                                    isAr ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
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
                                        isAr ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Search Bar
                                Container(
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                    ),
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
                          bottom: 44,
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
                                              color: themeColor,
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
                            top: isGlass
                                ? (MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top * 0.10 + 6 : 8.0)
                                : 8.0,
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
                                  stretch: 0.2,
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
                                    isAr ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
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
                                        isAr ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
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
                                                ? themeColor.withValues(alpha: 0.12)
                                                : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(
                                              color: isSelected
                                                  ? themeColor.withValues(alpha: 0.5)
                                                  : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                              width: isSelected ? 1.5 : 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? themeColor.withValues(alpha: 0.2)
                                                      : (isDarkMode
                                                          ? const Color(0xFF27272A)
                                                          : const Color(0xFFE4E4E7)),
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
  },
);
},
);
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
  void _showEditTransactionDialog(WalletTransaction transaction) {
    final isIncome = transaction.isDeposit;

    final filteredCategories = _categories.where((c) => isIncome
        ? ['Salary', 'Bonus', 'Income'].contains(c.nameEn)
        : !['Salary', 'Bonus', 'Income'].contains(c.nameEn)).toList();

    int? selectedCategoryId = filteredCategories.any((c) => c.id == transaction.categoryId)
        ? transaction.categoryId
        : (filteredCategories.isNotEmpty ? filteredCategories.first.id : null);

    final amountController = TextEditingController(text: transaction.amount.toString());
    final descriptionController = TextEditingController(text: transaction.description ?? '');
    final amountFocusNode = FocusNode();
    final descriptionFocusNode = FocusNode();
    bool isSubmitting = false;
    final currencySymbol = currencySymbols[_currencyCode ?? 'USD'] ?? '\$';

    _showAdaptiveBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      focusNodes: [amountFocusNode, descriptionFocusNode],
      builder: (context, isGlass, controller) {
        return AdaptiveSheetFocusScope(
          controller: controller,
          focusNodes: [amountFocusNode, descriptionFocusNode],
          child: StatefulBuilder(
          builder: (context, setState) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;

            Future<void> submitEditTransaction() async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                MessageService.showError(
                  context: context,
                  message: context.l10n.enterValidAmount,
                );
                return;
              }

              setState(() => isSubmitting = true);
              try {
                await _walletRepository.updateTransaction(
                  transaction.id,
                  title: transaction.title,
                  description: descriptionController.text,
                  amount: amount,
                  type: isIncome ? 'Deposit' : 'Withdrawal',
                  categoryId: selectedCategoryId ?? (filteredCategories.isNotEmpty ? filteredCategories.first.id : 1),
                  transactionDate: transaction.transactionDate,
                );
                await _loadHomeData();
                if (!context.mounted) return;
                Navigator.pop(context);
                MessageService.showSuccess(
                  context: context,
                  message: context.l10n.transactionUpdatedSuccess,
                );
              } catch (e) {
                if (!context.mounted) return;
                MessageService.showError(
                  context: context,
                  message: context.l10n.failedToUpdateTransaction(e.toString()),
                );
              } finally {
                if (mounted) setState(() => isSubmitting = false);
              }
            }

            return IosKeyboardFloatingButton.wrap(
              focusNode: amountFocusNode,
              isGlass: isGlass,
              child: Container(
              decoration: isGlass
                  ? const BoxDecoration(color: Colors.transparent)
                  : BoxDecoration(
                      color: isDarkMode ? const Color(0xFF121214) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                          width: 1,
                        ),
                      ),
                    ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isGlass)
                        Container(
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      if (isGlass) const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: isGlass ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                          children: [
                            if (isGlass)
                              GlassButton.custom(
                                height: 38,
                                shape: const LiquidRoundedRectangle(borderRadius: 19),
                                useOwnLayer: true,
                                settings: isDarkMode
                                    ? const LiquidGlassSettings(
                                        thickness: 12,
                                        blur: 10,
                                        glassColor: Color(0x22FFFFFF),
                                      )
                                    : const LiquidGlassSettings(
                                        thickness: 12,
                                        blur: 10,
                                        glassColor: Color(0x66FFFFFF),
                                      ),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Center(
                                    child: Text(
                                      context.l10n.cancel,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode
                                            ? const Color(0xFFE4E4E7)
                                            : const Color(0xFF71717A),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isIncome ? Colors.green[800] : Colors.red[800],
                                ),
                              ),
                            if (!isGlass) const SizedBox(width: 14),
                            Text(
                              isIncome ? context.l10n.editDeposit : context.l10n.editWithdrawal,
                              style: TextStyle(
                                fontSize: isGlass ? 16.5 : 18,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode ? Colors.white : Colors.black,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (isGlass)
                              GlassButton.custom(
                                width: 38,
                                height: 38,
                                shape: const LiquidOval(),
                                useOwnLayer: true,
                                settings: isDarkMode
                                    ? const LiquidGlassSettings(
                                        thickness: 12,
                                        blur: 10,
                                        glassColor: Color(0x30FFFFFF),
                                      )
                                    : const LiquidGlassSettings(
                                        thickness: 12,
                                        blur: 10,
                                        glassColor: Color(0x18000000),
                                      ),
                                onTap: () {
                                  if (isSubmitting) return;
                                  HapticFeedback.selectionClick();
                                  submitEditTransaction();
                                },
                                child: Center(
                                  child: isSubmitting
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        )
                                      : Icon(
                                          CupertinoIcons.checkmark,
                                          size: 20,
                                          color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: amountController,
                          focusNode: amountFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: context.l10n.amount,
                            prefixText: '$currencySymbol ',
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: descriptionController,
                          focusNode: descriptionFocusNode,
                          decoration: InputDecoration(
                            labelText: context.l10n.descriptionOptional,
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Actions (Android only; iOS uses top Cancel & Checkmark)
                      if (!isGlass)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    context.l10n.cancel,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isSubmitting ? null : submitEditTransaction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode ? Colors.white : Colors.black,
                                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isSubmitting
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: isDarkMode ? Colors.black : Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          context.l10n.update,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        ),
      );
    },
  );
}
  //#endregion

  //#region Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(WalletTransaction transaction) {
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

  //#region Add Account Modal (Say Style)
  void _showAddAccountModal() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final nameFocusNode = FocusNode();
    final balanceFocusNode = FocusNode();
    String selectedType = 'bank';
    bool isSubmitting = false;

    _showAdaptiveBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      focusNodes: [nameFocusNode, balanceFocusNode],
      builder: (context, isGlass, controller) {
        return AdaptiveSheetFocusScope(
          controller: controller,
          focusNodes: [nameFocusNode, balanceFocusNode],
          child: StatefulBuilder(
          builder: (context, setState) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;

            final accountTypes = [
              {'id': 'bank', 'label': context.l10n.bankAccount, 'icon': Icons.account_balance_rounded},
              {'id': 'cash', 'label': context.l10n.cashWallet, 'icon': Icons.payments_rounded},
              {'id': 'ewallet', 'label': context.l10n.eWalletType, 'icon': Icons.phone_iphone_rounded},
              {'id': 'savings', 'label': context.l10n.savingsVaultType, 'icon': Icons.savings_rounded},
            ];

            Future<void> submitNewAccount() async {
              if (nameController.text.trim().isEmpty) {
                MessageService.showError(
                  context: context,
                  message: context.l10n.pleaseEnterAccountName,
                );
                return;
              }

              setState(() => isSubmitting = true);
              await Future.delayed(const Duration(milliseconds: 300));
              if (!context.mounted) return;
              final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
              final newBal = double.tryParse(balanceController.text.trim()) ?? 0.0;
              IconData iconData = Icons.account_balance_rounded;
              if (selectedType == 'cash') iconData = Icons.payments_rounded;
              if (selectedType == 'ewallet') iconData = Icons.phone_iphone_rounded;
              if (selectedType == 'savings') iconData = Icons.savings_rounded;

              this.setState(() {
                _customAccounts.add(
                  AccountItem(
                    id: newId,
                    name: nameController.text.trim(),
                    type: selectedType,
                    balance: newBal,
                    icon: iconData,
                  ),
                );
              });
              Navigator.pop(context);
              MessageService.showSuccess(
                context: context,
                message: context.l10n.accountAddedSuccess,
              );
            }

            return IosKeyboardFloatingButton.wrap(
              focusNode: balanceFocusNode,
              isGlass: isGlass,
              child: Container(
              decoration: isGlass
                  ? const BoxDecoration(color: Colors.transparent)
                  : BoxDecoration(
                      color: isDarkMode ? const Color(0xFF121214) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                          width: 1,
                        ),
                      ),
                    ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isGlass)
                        Container(
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      if (isGlass) const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: isGlass ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                          children: [
                            if (isGlass)
                              GlassButton.custom(
                                height: 38,
                                shape: const LiquidRoundedRectangle(borderRadius: 19),
                                useOwnLayer: true,
                                settings: isDarkMode
                                    ? const LiquidGlassSettings(
                                        thickness: 12,
                                        blur: 10,
                                        glassColor: Color(0x22FFFFFF),
                                      )
                                    : const LiquidGlassSettings(
                                        thickness: 12,
                                        blur: 10,
                                        glassColor: Color(0x66FFFFFF),
                                      ),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Center(
                                    child: Text(
                                      context.l10n.cancel,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode
                                            ? const Color(0xFFE4E4E7)
                                            : const Color(0xFF71717A),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_card_rounded,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  size: 22,
                                ),
                              ),
                            if (!isGlass) const SizedBox(width: 14),
                            Text(
                              context.l10n.addNewAccount,
                              style: TextStyle(
                                fontSize: isGlass ? 16.5 : 18,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode ? Colors.white : Colors.black,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (isGlass)
                              GlassButton.custom(
                                width: 38,
                                height: 38,
                                shape: const LiquidOval(),
                                useOwnLayer: true,
                                settings: isDarkMode
                                    ? const LiquidGlassSettings(
                                        thickness: 12,
                                        blur: 10,
                                        glassColor: Color(0x30FFFFFF),
                                      )
                                    : const LiquidGlassSettings(
                                        thickness: 12,
                                        blur: 10,
                                        glassColor: Color(0x18000000),
                                      ),
                                onTap: () {
                                  if (isSubmitting) return;
                                  HapticFeedback.selectionClick();
                                  submitNewAccount();
                                },
                                child: Center(
                                  child: isSubmitting
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        )
                                      : Icon(
                                          CupertinoIcons.checkmark,
                                          size: 20,
                                          color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Account Name Input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: nameController,
                          focusNode: nameFocusNode,
                          decoration: InputDecoration(
                            labelText: context.l10n.accountNameHint,
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Initial Balance Input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: balanceController,
                          focusNode: balanceFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                          ],
                          decoration: InputDecoration(
                            labelText: context.l10n.initialBalance,
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Account Type Selector
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            context.l10n.accountType,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: accountTypes.map((t) {
                            final isSelected = selectedType == t['id'];
                            return GestureDetector(
                              onTap: () => setState(() => selectedType = t['id'] as String),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDarkMode ? Colors.white : Colors.black)
                                      : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      t['icon'] as IconData,
                                      size: 16,
                                      color: isSelected
                                          ? (isDarkMode ? Colors.black : Colors.white)
                                          : (isDarkMode ? Colors.white : Colors.black),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      t['label'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? (isDarkMode ? Colors.black : Colors.white)
                                            : (isDarkMode ? Colors.white : Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Buttons (Android only; iOS uses top Cancel & Checkmark)
                      if (!isGlass)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    context.l10n.cancel,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isSubmitting ? null : submitNewAccount,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode ? Colors.white : Colors.black,
                                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isSubmitting
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: isDarkMode ? Colors.black : Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          context.l10n.saveAccount,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        ),
      );
    },
  );
}
  //#endregion

  //#region All Transactions Modal
  void _showAllTransactionsModal(List<WalletTransaction> transactions) {
    _showAdaptiveBottomSheet(
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context, isGlass, _) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: isGlass
                  ? const BoxDecoration(color: Colors.transparent)
                  : BoxDecoration(
                      color: isDarkMode ? const Color(0xFF121214) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                          width: 1,
                        ),
                      ),
                    ),
              child: Column(
                children: [
                  if (!isGlass)
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  if (isGlass) const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.transactions,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.black,
                            letterSpacing: -0.3,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: transactions.isEmpty
                        ? _buildEmptyState(isDarkMode)
                        : SlidableAutoCloseBehavior(
                            closeWhenOpened: true,
                            closeWhenTapped: true,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                return _buildTransactionCard(transaction, isDarkMode);
                              },
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

              // Top Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.manageAccounts,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.black,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.manageAccountsSubtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Accounts list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ..._accounts.map((acc) {
                      final isSelected = acc.id == _selectedAccountId;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isGlass
                              ? (isDarkMode
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.7))
                              : (isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF9FAFB)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : (isGlass
                                    ? (isDarkMode
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.08))
                                    : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isGlass
                                    ? (isDarkMode ? Colors.white.withValues(alpha: 0.12) : Colors.white)
                                    : (isDarkMode ? const Color(0xFF18181B) : Colors.white),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                acc.icon,
                                color: isDarkMode ? Colors.white : Colors.black,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        acc.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      if (acc.isMain) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star_rounded, size: 11, color: Color(0xFF10B981)),
                                              const SizedBox(width: 2),
                                              Text(
                                                context.l10n.mainAcc,
                                                style: const TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (isSelected) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            context.l10n.active,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF3B82F6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatAmount(acc.balance, currencyCode: acc.currency),
                                    textDirection: ui.TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!acc.isAll && !acc.isMain)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _mainAccountId = acc.id;
                                  });
                                  Navigator.pop(context);
                                  MessageService.showSuccess(
                                    context: context,
                                    message: context.l10n.setAsMainSuccess(acc.name),
                                  );
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  margin: const EdgeInsetsDirectional.only(end: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_outline_rounded, size: 14, color: Color(0xFF10B981)),
                                      const SizedBox(width: 4),
                                      Text(
                                        context.l10n.setAsMain,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedAccountId = acc.id;
                                });
                                _syncWalletsCarouselToSelected();
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDarkMode ? Colors.white : Colors.black)
                                      : (isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isSelected ? context.l10n.selected : context.l10n.selectActionKey,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? (isDarkMode ? Colors.black : Colors.white)
                                        : (isDarkMode ? Colors.white : Colors.black),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Bottom Add Account Action Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
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
                            size: 18,
                            color: isDarkMode ? Colors.black : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.addNewAccountOrWallet,
                            style: TextStyle(
                              color: isDarkMode ? Colors.black : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
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
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
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

    final availableIcons = <IconData>[
      Icons.account_balance_rounded,
      Icons.payments_rounded,
      Icons.phone_iphone_rounded,
      Icons.credit_card_rounded,
      Icons.savings_rounded,
      Icons.account_balance_wallet_rounded,
      Icons.storefront_rounded,
      Icons.currency_exchange_rounded,
      Icons.monetization_on_rounded,
      Icons.trending_up_rounded,
      Icons.savings_outlined,
      Icons.attach_money_rounded,
    ];

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
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
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
