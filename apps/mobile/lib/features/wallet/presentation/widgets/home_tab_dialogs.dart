part of '../screens/home_tab.dart';

mixin _HomeTabDialogs on _HomeTabState {
  //#region Dialog Helpers (Add / Edit / Delete)
  void _showAddTransactionDialog(
    TransactionType type, {
    VoiceExpenseResult? prefillFromVoice,
  }) {
    final isIncome = type == TransactionType.income;

    final filteredCategories = _categories.where((c) => isIncome
        ? ['Salary', 'Bonus', 'Income'].contains(c.nameEn)
        : !['Salary', 'Bonus', 'Income'].contains(c.nameEn)).toList();

    int? selectedCategoryId = prefillFromVoice?.categoryId != null
        ? prefillFromVoice!.categoryId
        : (filteredCategories.isNotEmpty ? filteredCategories.first.id : null);

    final descriptionController = TextEditingController(
      text: prefillFromVoice?.note ?? '',
    );
    final amountController = TextEditingController(
      text: prefillFromVoice?.amount?.toString() ?? '',
    );

    bool _isSubmitting = false;
    double? _previewAmount = prefillFromVoice?.amount;

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
                color: isDarkMode ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
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
                        height: 4, width: 40,
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
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isIncome ? Colors.green[800] : Colors.red[800],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              isIncome ? context.l10n.addDeposit : context.l10n.addWithdrawal,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_previewAmount != null && _previewAmount! > 0)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isIncome ? Colors.green[800]! : Colors.red[800]!,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.l10n.amount,
                                  style: TextStyle(
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                              Text(
                                '${isIncome ? '+' : '-'}$currencySymbol${_previewAmount!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isIncome ? Colors.green[800] : Colors.red[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                          ],
                          onChanged: (value) {
                            setState(() => _previewAmount = double.tryParse(value));
                          },
                          decoration: InputDecoration(
                            labelText: context.l10n.amount,
                            prefixIcon: Icon(Icons.attach_money,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                            filled: true,
                            fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: (isIncome
                                  ? [50, 500, 1000, 2000]
                                  : [10, 50, 100, 200])
                              .map((value) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text('$currencySymbol$value'),
                                      onSelected: (_) => setState(() {
                                        amountController.text = value.toString();
                                        _previewAmount = value.toDouble();
                                      }),
                                      backgroundColor:
                                          isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                      selected: false,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
const SizedBox(height: 16),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.category,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      const SizedBox(height: 12),
      _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : filteredCategories.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.l10n.noCategoriesAvailable,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                )
              : SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      final isSelected = selectedCategoryId == category.id;
                      final categoryName = Localizations.localeOf(context).languageCode == 'ar'
                          ? category.nameAr
                          : category.nameEn;
                      String shortName = categoryName.length >= 2
                          ? categoryName.substring(0, 2).toUpperCase()
                          : categoryName.toUpperCase();

                      return GestureDetector(
                        onTap: () => setState(() => selectedCategoryId = category.id),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? (isIncome ? Colors.green[800]! : Colors.red[800]!)
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? (isIncome
                                          ? Colors.green.withValues(alpha: 0.2)
                                          : Colors.red.withValues(alpha: 0.2))
                                      : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                                  radius: 35,
                                  child: Text(
                                    shortName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? (isIncome ? Colors.green[800] : Colors.red[800])
                                          : (isDarkMode ? Colors.white70 : Colors.black54),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                categoryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? (isIncome ? Colors.green[800] : Colors.red[800])
                                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
  ),
),
const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: descriptionController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: context.l10n.descriptionOptional,
                            prefixIcon: Icon(Icons.description,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                            filled: true,
                            fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: isDarkMode
                                          ? Colors.grey[700]!
                                          : Colors.grey[300]!),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(context.l10n.cancel,
                                    style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async {
                                        if (amountController.text.isEmpty) {
                                          MessageService.showError(context: context, message: context.l10n.enterAmount);
                                          return;
                                        }
                                        final amount = double.tryParse(amountController.text);
                                        if (amount == null || amount <= 0) {
                                          MessageService.showError(context: context, message: context.l10n.enterValidAmount);
                                          return;
                                        }
                                        if (selectedCategoryId == null) {
                                          MessageService.showError(context: context, message: context.l10n.selectCategory);
                                          return;
                                        }

                                        setState(() => _isSubmitting = true);
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
                                          MessageService.showError(context: context, message: context.l10n.failedToAddTransaction(e.toString()));
                                        } finally {
                                          if (shouldPop) {
                                            if (!context.mounted) return;
                                            Navigator.pop(context);
                                          } else {
                                            setState(() => _isSubmitting = false);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isIncome ? Colors.green[800] : Colors.red[800],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2))
                                    : Text(context.l10n.add,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
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

    bool _isSubmitting = false;
    double? _previewAmount = transaction.amount;

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
                color: isDarkMode ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
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
                        height: 4, width: 40,
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
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isIncome ? Colors.green[800] : Colors.red[800],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              isIncome ? context.l10n.editDeposit : context.l10n.editWithdrawal,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_previewAmount != null && _previewAmount! > 0)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isIncome ? Colors.green[800]! : Colors.red[800]!,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.l10n.amount,
                                  style: TextStyle(
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                              Text(
                                '${isIncome ? '+' : '-'}$currencySymbol${_previewAmount!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isIncome ? Colors.green[800] : Colors.red[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                          ],
                          onChanged: (value) {
                            setState(() => _previewAmount = double.tryParse(value));
                          },
                          decoration: InputDecoration(
                            labelText: context.l10n.amount,
                            prefixIcon: Icon(Icons.attach_money,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                            filled: true,
                            fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: (isIncome
                                  ? [50, 500, 1000, 2000]
                                  : [10, 50, 100, 200])
                              .map((value) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text('$currencySymbol$value'),
                                      onSelected: (_) => setState(() {
                                        amountController.text = value.toString();
                                        _previewAmount = value.toDouble();
                                      }),
                                      backgroundColor:
                                          isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                      selected: false,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _isLoadingCategories
                            ? const Center(child: CircularProgressIndicator())
                            : filteredCategories.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      context.l10n.noCategoriesAvailable,
                                      style: TextStyle(
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                    ),
                                  )
                                : DropdownButtonFormField<int>(
                                    value: selectedCategoryId,
                                    decoration: InputDecoration(
                                      labelText: context.l10n.category,
                                      prefixIcon: Icon(Icons.category,
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                      filled: true,
                                      fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    items: filteredCategories
                                        .map((category) => DropdownMenuItem<int>(
                                              value: category.id,
                                              child: Text(
                                                Localizations.localeOf(context).languageCode == 'ar'
                                                    ? category.nameAr
                                                    : category.nameEn,
                                                style: TextStyle(
                                                    color: isDarkMode ? Colors.white : Colors.black),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) =>
                                        setState(() => selectedCategoryId = value),
                                  ),
                      ),
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          controller: descriptionController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: context.l10n.descriptionOptional,
                            prefixIcon: Icon(Icons.description,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                            filled: true,
                            fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(context.l10n.cancel,
                                    style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async {
                                        if (amountController.text.isEmpty) {
                                          MessageService.showError(context: context, message: context.l10n.enterAmount);
                                          return;
                                        }
                                        final amount = double.tryParse(amountController.text);
                                        if (amount == null || amount <= 0) {
                                          MessageService.showError(context: context, message: context.l10n.enterValidAmount);
                                          return;
                                        }
                                        if (selectedCategoryId == null) {
                                          MessageService.showError(context: context, message: context.l10n.selectCategory);
                                          return;
                                        }

                                        setState(() => _isSubmitting = true);
                                        bool shouldPop = false;

                                        try {
                                          await _walletRepository.updateTransaction(
                                            transaction.id,
                                            title: transaction.title,
                                            description: descriptionController.text,
                                            amount: amount,
                                            type: isIncome ? 'Deposit' : 'Withdrawal',
                                            categoryId: selectedCategoryId!,
                                            transactionDate: transaction.transactionDate,
                                            isRecurring: transaction.isRecurring,
                                            recurringInterval: transaction.recurringInterval,
                                            recurringEndDate: transaction.recurringEndDate,
                                          );
                                          shouldPop = true;
                                          await _loadHomeData();
                                          if (!context.mounted) return;
                                          MessageService.showSuccess(context: context, message: context.l10n.transactionUpdatedSuccess);
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          MessageService.showError(context: context, message: context.l10n.failedToUpdateTransaction(e.toString()));
                                        } finally {
                                          if (shouldPop) {
                                            if (context.mounted) Navigator.pop(context);
                                          } else {
                                            setState(() => _isSubmitting = false);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isIncome ? Colors.green[800] : Colors.red[800],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2))
                                    : Text(context.l10n.update,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
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

  void _showDeleteConfirmationDialog(WalletTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          title: Text(
            context.l10n.deleteTransaction,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
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
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTransaction(transaction);
              },
              child: Text(
                context.l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
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
                color: isDarkMode ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.transactions,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: transactions.isEmpty
                        ? _buildEmptyState(isDarkMode)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
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
}
