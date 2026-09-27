part of '../screens/home_tab.dart';
// ignore_for_file: annotate_overrides

mixin _HomeTabDialogs on _HomeTabState {
  //#region Unified 3-in-1 Transaction Sheet (Say / Linear Minimalist)
  void _showUnifiedAddModal({
    VoiceExpenseResult? prefillFromVoice,
  }) {
    TransactionType activeType = prefillFromVoice != null
        ? (prefillFromVoice.transactionType == 'Deposit'
            ? TransactionType.income
            : TransactionType.expense)
        : TransactionType.expense;

    final availableAccounts = _accounts.where((a) => !a.isAll).toList();
    String selectedAccountId = _selectedAccountId != 'all' && availableAccounts.any((a) => a.id == _selectedAccountId)
        ? _selectedAccountId
        : (availableAccounts.isNotEmpty ? availableAccounts.first.id : 'cash');
    String fromAccountId = availableAccounts.isNotEmpty ? availableAccounts.first.id : 'cash';
    String toAccountId = availableAccounts.length > 1 ? availableAccounts[1].id : (availableAccounts.isNotEmpty ? availableAccounts.first.id : 'bank');

    final amountController = TextEditingController(
      text: prefillFromVoice?.amount != null ? prefillFromVoice!.amount.toString() : '',
    );
    final descriptionController = TextEditingController(
      text: prefillFromVoice?.title ?? prefillFromVoice?.note ?? '',
    );

    int? selectedCategoryId = prefillFromVoice?.categoryId;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final isAr = Localizations.localeOf(context).languageCode == 'ar';
            final currencySymbol = currencySymbols[_currencyCode ?? 'USD'] ?? '\$';

            final isIncome = activeType == TransactionType.income;
            final isExpense = activeType == TransactionType.expense;
            final isTransfer = activeType == TransactionType.transfer;

            final filteredCategories = _categories.where((c) => isIncome
                ? ['Salary', 'Bonus', 'Income'].contains(c.nameEn)
                : !['Salary', 'Bonus', 'Income'].contains(c.nameEn)).toList();

            if (selectedCategoryId == null && filteredCategories.isNotEmpty && !isTransfer) {
              selectedCategoryId = filteredCategories.first.id;
            }

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

            final selectedCategory = filteredCategories.isNotEmpty
                ? filteredCategories.firstWhere(
                    (c) => c.id == selectedCategoryId,
                    orElse: () => filteredCategories.first,
                  )
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

            void pickAccount({
              required String currentId,
              required String title,
              required void Function(String newId) onSelect,
            }) {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (pickerCtx) {
                  final pickerDarkMode = Theme.of(pickerCtx).brightness == Brightness.dark;
                  return Container(
                    decoration: BoxDecoration(
                      color: pickerDarkMode ? const Color(0xFF18181B) : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border.all(
                        color: pickerDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              height: 4,
                              width: 36,
                              decoration: BoxDecoration(
                                color: pickerDarkMode ? Colors.grey[700] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: pickerDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...availableAccounts.map((acc) {
                            final isSelected = acc.id == currentId;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () {
                                  onSelect(acc.id);
                                  Navigator.pop(pickerCtx);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (pickerDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? (pickerDarkMode ? Colors.white24 : Colors.black12)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: pickerDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          acc.icon,
                                          size: 18,
                                          color: pickerDarkMode ? Colors.white : Colors.black,
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
                                                color: pickerDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${acc.balance.toStringAsFixed(2)} $currencySymbol',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: pickerDarkMode ? Colors.grey[400] : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 20,
                                          color: pickerDarkMode ? Colors.white : Colors.black,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            void pickCategory() {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (pickerCtx) {
                  final pickerDarkMode = Theme.of(pickerCtx).brightness == Brightness.dark;
                  return Container(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.65,
                    ),
                    decoration: BoxDecoration(
                      color: pickerDarkMode ? const Color(0xFF18181B) : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border.all(
                        color: pickerDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              height: 4,
                              width: 36,
                              decoration: BoxDecoration(
                                color: pickerDarkMode ? Colors.grey[700] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isAr ? 'اختر التصنيف' : 'Select Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: pickerDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (filteredCategories.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  isAr ? 'لا توجد تصنيفات متاحة' : 'No categories available',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: pickerDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: filteredCategories.length,
                                itemBuilder: (context, idx) {
                                  final cat = filteredCategories[idx];
                                  final isSelected = cat.id == selectedCategoryId;
                                  final itemCatName = isAr ? cat.nameAr : cat.nameEn;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() => selectedCategoryId = cat.id);
                                        Navigator.pop(pickerCtx);
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (pickerDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isSelected
                                                ? (pickerDarkMode ? Colors.white24 : Colors.black12)
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 34,
                                              height: 34,
                                              decoration: BoxDecoration(
                                                color: themeColor.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  itemCatName.isNotEmpty ? itemCatName.characters.first : '★',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    color: themeColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                itemCatName,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                                  color: pickerDarkMode ? Colors.white : Colors.black,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle_rounded,
                                                size: 20,
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
                    ),
                  );
                },
              );
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.9,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF121214) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                  width: 1,
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 12,
                left: 20,
                right: 20,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      height: 4,
                      width: 38,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Top Bar (Say Style from video):
                  // Close (X) on left, "New Transaction" in center, Confirm (✓) on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close Button (X)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                              ),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 19,
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ),

                      // Title: New Transaction
                      Text(
                        isAr ? 'معاملة جديدة' : 'New Transaction',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),

                      // Confirm Button (✓)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isSubmitting ? null : submitTransaction,
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white : Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isSubmitting
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: isDarkMode ? Colors.black : Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      Icons.check_rounded,
                                      size: 20,
                                      color: isDarkMode ? Colors.black : Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3 Tabs Switcher with Sliding Pill Indicator (Expense, Income, Transfer)
                  Container(
                    height: 44,
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
                        final isRtl = isAr;
                        final selectedIndex = isExpense ? 0 : (isIncome ? 1 : 2);
                        final leftOffset = isRtl
                            ? (2 - selectedIndex) * tabWidth
                            : selectedIndex * tabWidth;

                        return Stack(
                          children: [
                            // Sliding Pill Indicator (Clean flat border - no shadow)
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.fastOutSlowIn,
                              left: leftOffset,
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
                              amountFontSize = 44;
                              symbolFontSize = 24;
                              letterSpacing = -0.5;
                            } else if (length <= 9) {
                              amountFontSize = 38;
                              symbolFontSize = 21;
                              letterSpacing = -0.4;
                            } else if (length <= 12) {
                              amountFontSize = 32;
                              symbolFontSize = 18;
                              letterSpacing = -0.3;
                            } else {
                              amountFontSize = 28;
                              symbolFontSize = 16;
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
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      autofocus: prefillFromVoice == null,
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
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.fastOutSlowIn,
                          child: !isTransfer
                              ? Padding(
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
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                                  fontSize: 12,
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
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                    const SizedBox(height: 10),

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
                            ? Container(
                                key: const ValueKey('transfer_mode_content'),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // From
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => pickAccount(
                                          currentId: fromAccountId,
                                          title: isAr ? 'تحويل من محفظة' : 'Transfer From',
                                          onSelect: (id) => setState(() => fromAccountId = id),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isAr ? 'من محفظة' : 'From',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      fromAccount.name,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700,
                                                        color: isDarkMode ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_arrow_down_rounded,
                                                    size: 16,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: Color(0xFF3B82F6),
                                      ),
                                    ),
                                    // To
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => pickAccount(
                                          currentId: toAccountId,
                                          title: isAr ? 'تحويل إلى محفظة' : 'Transfer To',
                                          onSelect: (id) => setState(() => toAccountId = id),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isAr ? 'إلى محفظة' : 'To',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      toAccount.name,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700,
                                                        color: isDarkMode ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_arrow_down_rounded,
                                                    size: 16,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                key: const ValueKey('expense_income_content'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Wallet Account Selector Card (Tap opens picker bottom sheet)
                                  InkWell(
                                    onTap: () => pickAccount(
                                      currentId: selectedAccountId,
                                      title: isAr ? 'اختر المحفظة أو الحساب' : 'Select Wallet / Account',
                                      onSelect: (id) => setState(() => selectedAccountId = id),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              selectedAccount.icon,
                                              size: 18,
                                              color: isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isAr ? 'المحفظة / الحساب' : 'Wallet / Account',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  selectedAccount.name,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDarkMode ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${selectedAccount.balance.toStringAsFixed(2)} $currencySymbol',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 20,
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Category Selector Card (Tap opens picker bottom sheet)
                                  InkWell(
                                    onTap: pickCategory,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 250),
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: themeColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                catName.isNotEmpty ? catName.characters.first : '★',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: themeColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  context.l10n.category,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  catName,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDarkMode ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 20,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.edit_note_rounded,
                              size: 19,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: descriptionController,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                hintText: isAr ? 'ملاحظة أو وصف (اختياري)...' : 'Note / Description (optional)...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
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
                                    size: 18,
                                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Full-Width Hero Confirm Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isSubmitting ? null : submitTransaction,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.white : Colors.black,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDarkMode ? 0.30 : 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isSubmitting
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: isDarkMode ? Colors.black : Colors.white,
                                    ),
                                  )
                                : AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(opacity: animation, child: child),
                                    child: Row(
                                      key: ValueKey(activeType),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isTransfer ? Icons.swap_horiz_rounded : Icons.check_rounded,
                                          color: isDarkMode ? Colors.black : Colors.white,
                                          size: 19,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isTransfer
                                              ? (isAr ? 'تأكيد التحويل' : 'Confirm Transfer')
                                              : (isIncome ? context.l10n.addDeposit : context.l10n.addWithdrawal),
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.black : Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                width: isSelected ? 5.5 : 0,
                height: isSelected ? 5.5 : 0,
                margin: EdgeInsets.only(right: isSelected ? 5 : 0),
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: 12.5,
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
    bool isSubmitting = false;
    final currencySymbol = currencySymbols[_currencyCode ?? 'USD'] ?? '\$';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
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
                      Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
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
                            const SizedBox(width: 14),
                            Text(
                              isIncome ? context.l10n.editDeposit : context.l10n.editWithdrawal,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode ? Colors.white : Colors.black,
                                letterSpacing: -0.3,
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

                      // Actions
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
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
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
                                      },
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
            );
          },
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
    String selectedType = 'bank';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final isAr = Localizations.localeOf(context).languageCode == 'ar';

            final accountTypes = [
              {'id': 'bank', 'label': isAr ? 'حساب بنكي' : 'Bank Account', 'icon': Icons.account_balance_rounded},
              {'id': 'cash', 'label': isAr ? 'كاش (نقدية)' : 'Cash Wallet', 'icon': Icons.payments_rounded},
              {'id': 'ewallet', 'label': isAr ? 'محفظة إلكترونية' : 'E-Wallet', 'icon': Icons.phone_iphone_rounded},
              {'id': 'savings', 'label': isAr ? 'صندوق ادخار' : 'Savings Vault', 'icon': Icons.savings_rounded},
            ];

            return Container(
              decoration: BoxDecoration(
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
                      Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
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
                            const SizedBox(width: 14),
                            Text(
                              isAr ? 'إضافة حساب جديد' : 'Add New Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode ? Colors.white : Colors.black,
                                letterSpacing: -0.3,
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
                          decoration: InputDecoration(
                            labelText: isAr ? 'اسم الحساب (مثال: بنك مصر، CIB)' : 'Account Name (e.g. Banque Misr)',
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                          ],
                          decoration: InputDecoration(
                            labelText: isAr ? 'الرصيد الافتتاحي الحالي' : 'Initial Balance',
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
                            isAr ? 'نوع الحساب' : 'Account Type',
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

                      // Buttons
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
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        if (nameController.text.trim().isEmpty) {
                                          MessageService.showError(
                                            context: context,
                                            message: isAr ? 'يرجى إدخال اسم الحساب' : 'Please enter account name',
                                          );
                                          return;
                                        }

                                        setState(() => isSubmitting = true);
                                        await Future.delayed(const Duration(milliseconds: 500));
                                        if (!context.mounted) return;
                                        Navigator.pop(context);
                                        MessageService.showSuccess(
                                          context: context,
                                          message: isAr
                                              ? 'تمت إضافة الحساب بنجاح 💳'
                                              : 'Account added successfully 💳',
                                        );
                                      },
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
                                        isAr ? 'حفظ الحساب' : 'Save Account',
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
            );
          },
        );
      },
    );
  }
  //#endregion

  //#region All Transactions Modal
  void _showAllTransactionsModal(List<WalletTransaction> transactions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
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
                  Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
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
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              return _buildTransactionCard(transaction, isDarkMode);
                            },
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        final currencySymbol = currencySymbols[_currencyCode ?? 'USD'] ?? '\$';

        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF18181B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'اختر المحفظة المعروضة' : 'Select Active Wallet',
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
                                    '${NumberFormat('#,##0.00').format(acc.balance)} $currencySymbol',
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final isAr = Localizations.localeOf(context).languageCode == 'ar';
        final currencySymbol = currencySymbols[_currencyCode ?? 'USD'] ?? '\$';

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF18181B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                height: 4,
                width: 36,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

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
                          isAr ? 'إدارة المحافظ والحسابات' : 'Manage Accounts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.black,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr ? 'تحكم في محافظك، حساباتك البنكية، والمحافظ الإلكترونية' : 'Manage your cash, bank, and digital wallets',
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
                          color: isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(20),
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF18181B) : Colors.white,
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
                                      if (isSelected) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isAr ? 'النشط' : 'Active',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${NumberFormat('#,##0.00').format(acc.balance)} $currencySymbol',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedAccountId = acc.id;
                                });
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
                                  isSelected ? (isAr ? 'محدد' : 'Selected') : (isAr ? 'تحديد' : 'Select'),
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
                            isAr ? 'إضافة محفظة / حساب جديد' : 'Add New Account',
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
