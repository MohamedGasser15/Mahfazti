import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_adaptive_context_menu/ios_adaptive_context_menu.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/data/models/budget_models.dart';

class BudgetsTab extends StatefulWidget {
  const BudgetsTab({super.key});

  @override
  State<BudgetsTab> createState() => _BudgetsTabState();
}

class _BudgetsTabState extends State<BudgetsTab> {
  bool _isLoading = true;
  String _currencyCode = 'EGP';
  BudgetDto? _budgetData;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final code = await SharedPrefs.getCurrency();
    if (mounted) {
      setState(() => _currencyCode = code ?? 'EGP');
      await _loadBudget();
    }
  }

  Future<void> _loadBudget({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await WalletCacheService.getBudget();
      if (cached != null) {
        try {
          final data = BudgetDto.fromJson(cached);
          final sanitizedData = data.copyWith(
            categoryBudgets: data.categoryBudgets
                .map((c) => c.copyWith(clearGroup: true))
                .toList(),
          );
          final hasUnset = sanitizedData.categoryBudgets.any((c) => c.budget <= 0);
          if (hasUnset && sanitizedData.categoryBudgets.length >= 4 && sanitizedData.monthlyBudget == 0.0) {
            if (mounted) {
              setState(() {
                _budgetData = sanitizedData;
                _isLoading = false;
              });
              return;
            }
          }
        } catch (_) {}
      }
    }

    // Backend is disabled temporarily; always seed with realistic data including unset category
    final seed = BudgetDto.defaultSeed();
    if (mounted) {
      setState(() {
        _budgetData = seed;
        _isLoading = false;
      });
    }
    await WalletCacheService.saveBudget(seed.toJson());
  }

  String _formatAmount(double amount) {
    final symbol = currencySymbols[_currencyCode] ?? _currencyCode;
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$symbol ${formatter.format(amount)}';
  }

  IconData _getCategoryIcon(int catId, String name) {
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

  void _showSetMonthlyBudgetDialog(bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final hasExistingBudget = (_budgetData?.monthlyBudget ?? 0) > 0;
    final controller = TextEditingController(
      text: hasExistingBudget
          ? (_budgetData!.monthlyBudget).toStringAsFixed(0)
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 20,
            bottom: bottomInset > 0 ? bottomInset + 16 : 32,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF141418) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isAr ? 'تحديد الميزانية الشهرية' : 'Set Monthly Budget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isAr
                    ? 'حدد الحد الأقصى للمصاريف المتوقعة لهذا الشهر'
                    : 'Set your spending target for this month',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _currencyCode,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final text = controller.text.trim();
                    final amount = double.tryParse(text);
                    if (amount == null || amount < 0) {
                      MessageService.showError(
                        context: context,
                        message: isAr ? 'يرجى إدخال مبلغ صحيح' : 'Please enter a valid amount',
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    HapticFeedback.mediumImpact();

                    setState(() {
                      _budgetData = _budgetData != null
                          ? _budgetData!.copyWith(monthlyBudget: amount)
                          : BudgetDto(
                              monthlyBudget: amount,
                              currentSpending: 0,
                              categoryBudgets: BudgetDto.defaultSeed().categoryBudgets,
                            );
                    });
                    await WalletCacheService.saveBudget(_budgetData!.toJson());

                    if (mounted) {
                      MessageService.showSuccess(
                        context: context,
                        message: isAr ? 'تم تحديث الميزانية بنجاح' : 'Budget updated successfully',
                      );
                    }

                    // Backend API call disabled temporarily
                    // try {
                    //   await _repository.updateMonthlyBudget(amount);
                    // } catch (_) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white : Colors.black,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    isAr ? 'حفظ الميزانية' : 'Save Budget',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (hasExistingBudget) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      HapticFeedback.mediumImpact();
                      setState(() {
                        if (_budgetData != null) {
                          _budgetData = _budgetData!.copyWith(monthlyBudget: 0.0);
                        }
                      });
                      if (_budgetData != null) {
                        await WalletCacheService.saveBudget(_budgetData!.toJson());
                      }
                      if (mounted) {
                        MessageService.showSuccess(
                          context: context,
                          message: isAr ? 'تم إلغاء الميزانية الشهرية' : 'Monthly budget removed',
                        );
                      }
                    },
                    icon: const Icon(Icons.money_off_rounded, size: 17, color: Colors.redAccent),
                    label: Text(
                      isAr ? 'إلغاء الميزانية الشهرية' : 'Remove Monthly Budget',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showSetCategoryBudgetDialog(CategoryBudgetDto cat, bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final name = isAr ? cat.categoryNameAr : cat.categoryNameEn;
    final controller = TextEditingController(
      text: cat.budget > 0 ? cat.budget.toStringAsFixed(0) : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 20,
            bottom: bottomInset > 0 ? bottomInset + 16 : 32,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF141418) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isAr ? 'ميزانية $name' : 'Budget for $name',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isAr
                    ? 'حدد الحد الأقصى للمصاريف في هذا التصنيف'
                    : 'Set spending limit for this category',
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _currencyCode,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final text = controller.text.trim();
                    final amount = double.tryParse(text);
                    if (amount == null || amount < 0) {
                      MessageService.showError(
                        context: context,
                        message: isAr ? 'يرجى إدخال مبلغ صحيح' : 'Please enter a valid amount',
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    HapticFeedback.mediumImpact();

                    setState(() {
                      if (_budgetData != null) {
                        final updatedList = _budgetData!.categoryBudgets.map((item) {
                          if (item.categoryId == cat.categoryId) {
                            return item.copyWith(budget: amount);
                          }
                          return item;
                        }).toList();
                        _budgetData = _budgetData!.copyWith(categoryBudgets: updatedList);
                      }
                    });
                    if (_budgetData != null) {
                      await WalletCacheService.saveBudget(_budgetData!.toJson());
                    }

                    if (mounted) {
                      MessageService.showSuccess(
                        context: context,
                        message: isAr ? 'تم تحديث ميزانية التصنيف' : 'Category budget updated',
                      );
                    }

                    // Backend API call disabled temporarily
                    // try {
                    //   await _repository.updateCategoryBudget(cat.categoryId, amount);
                    // } catch (_) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white : Colors.black,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    isAr ? 'حفظ' : 'Save',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMenuAndroid(bool isDarkMode, bool isAr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF141418) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                title: Text(
                  isAr ? 'فئة جديدة' : 'New Category',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  isAr ? 'إضافة فئة جديدة وتحديد سقف مصاريفها' : 'Add a new category with a budget limit',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddCategoryDialog(isDarkMode);
                },
              ),
              Divider(
                height: 16,
                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                title: Text(
                  isAr ? 'الميزانية الشهرية' : 'Monthly Budget',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  isAr ? 'تحديد أو تعديل الحد الإجمالي للشهر' : 'Set or edit overall monthly limit',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSetMonthlyBudgetDialog(isDarkMode);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final nameController = TextEditingController();
    final budgetController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            final bottomInset = MediaQuery.of(dialogCtx).viewInsets.bottom;

            return Container(
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 20,
                bottom: bottomInset > 0 ? bottomInset + 16 : 32,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFD4D4D8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isAr ? 'فئة جديدة' : 'New Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAr
                          ? 'أضف فئة جديدة لتتبع مصاريفها وميزانيتها'
                          : 'Add a new category to track its spending & budget',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isAr ? 'اسم الفئة' : 'Category Name',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: nameController,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: isAr ? 'مثال: اشتراكات، مواصلات...' : 'e.g. Subscriptions, Transport',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAr ? 'حد الميزانية (اختياري)' : 'Budget Limit (optional)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: budgetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _currencyCode,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            MessageService.showError(
                              context: context,
                              message: isAr ? 'يرجى إدخال اسم الفئة' : 'Please enter category name',
                            );
                            return;
                          }
                          final budgetVal = double.tryParse(budgetController.text.trim()) ?? 0.0;
                          Navigator.pop(ctx);
                          HapticFeedback.mediumImpact();

                          final currentCats = _budgetData?.categoryBudgets ?? [];
                          final maxId = currentCats.fold<int>(0, (prev, c) => c.categoryId > prev ? c.categoryId : prev);
                          final newCat = CategoryBudgetDto(
                            id: maxId + 1,
                            categoryId: maxId + 1,
                            categoryNameAr: name,
                            categoryNameEn: name,
                            budget: budgetVal,
                            spent: 0.0,
                          );

                          setState(() {
                            if (_budgetData != null) {
                              _budgetData = _budgetData!.copyWith(
                                categoryBudgets: [..._budgetData!.categoryBudgets, newCat],
                              );
                            }
                          });
                          if (_budgetData != null) {
                            await WalletCacheService.saveBudget(_budgetData!.toJson());
                          }
                          if (mounted) {
                            MessageService.showSuccess(
                              context: context,
                              message: isAr ? 'تمت إضافة الفئة بنجاح' : 'Category added successfully',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.white : Colors.black,
                          foregroundColor: isDarkMode ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          isAr ? 'إضافة الفئة' : 'Add Category',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
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

  void _confirmDeleteCategory(CategoryBudgetDto cat, bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final name = isAr ? cat.categoryNameAr : cat.categoryNameEn;
    final isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(isAr ? 'حذف الفئة' : 'Delete Category'),
          content: Text(
            isAr
                ? 'هل أنت متأكد من حذف فئة "$name" من الميزانية؟'
                : 'Are you sure you want to delete "$name" from budgets?',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.pop(ctx);
                HapticFeedback.mediumImpact();
                setState(() {
                  if (_budgetData != null) {
                    final updated = _budgetData!.categoryBudgets
                        .where((item) => item.categoryId != cat.categoryId)
                        .toList();
                    _budgetData = _budgetData!.copyWith(categoryBudgets: updated);
                  }
                });
                if (_budgetData != null) {
                  await WalletCacheService.saveBudget(_budgetData!.toJson());
                }
                if (mounted) {
                  MessageService.showSuccess(
                    context: context,
                    message: isAr ? 'تم حذف الفئة بنجاح' : 'Category deleted successfully',
                  );
                }
              },
              child: Text(isAr ? 'حذف' : 'Delete'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF18181B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? 'حذف الفئة' : 'Delete Category',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          isAr
              ? 'هل أنت متأكد من حذف فئة "$name" من الميزانية؟'
              : 'Are you sure you want to delete "$name" from budgets?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isAr ? 'إلغاء' : 'Cancel',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              setState(() {
                if (_budgetData != null) {
                  final updated = _budgetData!.categoryBudgets
                      .where((item) => item.categoryId != cat.categoryId)
                      .toList();
                  _budgetData = _budgetData!.copyWith(categoryBudgets: updated);
                }
              });
              if (_budgetData != null) {
                await WalletCacheService.saveBudget(_budgetData!.toJson());
              }
              if (mounted) {
                MessageService.showSuccess(
                  context: context,
                  message: isAr ? 'تم حذف الفئة بنجاح' : 'Category deleted successfully',
                );
              }
            },
            child: Text(
              isAr ? 'حذف' : 'Delete',
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryOptions(CategoryBudgetDto cat, bool isDarkMode, bool isAr) {
    final name = isAr ? cat.categoryNameAr : cat.categoryNameEn;
    final icon = _getCategoryIcon(cat.categoryId, name);
    final hasBudget = cat.budget > 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF141418) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasBudget
                              ? (isAr
                                  ? 'الحد الحالي: ${_formatAmount(cat.budget)}'
                                  : 'Current limit: ${_formatAmount(cat.budget)}')
                              : (isAr ? 'بدون حد ميزانية' : 'No limit set'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(
                height: 1,
                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              ),
              const SizedBox(height: 10),
              // 1. تحديد الميزانية
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                title: Text(
                  hasBudget
                      ? (isAr ? 'تعديل الميزانية' : 'Edit Budget')
                      : (isAr ? 'تحديد الميزانية' : 'Set Budget'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSetCategoryBudgetDialog(cat, isDarkMode);
                },
              ),
              // 2. حذف الفئة
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                ),
                title: Text(
                  isAr ? 'حذف الفئة' : 'Delete Category',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.redAccent,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteCategory(cat, isDarkMode);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final bgColor = isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          isAr ? 'الميزانيات' : 'Budgets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDarkMode ? Colors.white : const Color(0xFF09090B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Center(
            child: isIOS
                ? GlassContainer(
                    width: 38,
                    height: 38,
                    shape: const LiquidOval(),
                    useOwnLayer: true,
                    platformViewBackdrop: true,
                    settings: LiquidGlassSettings(
                      thickness: 14,
                      blur: 10,
                      glassColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.85),
                    ),
                    child: Center(
                      child: IosSingleTapContextMenu(
                        actions: [
                          IosContextMenuAction(
                            id: 'new_category',
                            title: isAr ? 'فئة جديدة' : 'New Category',
                            iconSystemName: 'plus.circle',
                          ),
                          IosContextMenuAction(
                            id: 'monthly_budget',
                            title: isAr ? 'الميزانية الشهرية' : 'Monthly Budget',
                            iconSystemName: 'slider.horizontal.3',
                          ),
                        ],
                        onSelected: (id) {
                          if (id == 'new_category') {
                            _showAddCategoryDialog(isDarkMode);
                          } else if (id == 'monthly_budget') {
                            _showSetMonthlyBudgetDialog(isDarkMode);
                          }
                        },
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Center(
                            child: Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showAddMenuAndroid(isDarkMode, isAr),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadBudget(forceRefresh: true),
        color: isDarkMode ? Colors.white : Colors.black,
        backgroundColor: isDarkMode ? const Color(0xFF141418) : Colors.white,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(isDarkMode, isAr, borderColor),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode, bool isAr, Color borderColor) {
    final data = _budgetData ?? BudgetDto.defaultSeed();
    final monthlyBudget = data.monthlyBudget;
    final hasMonthlyBudget = monthlyBudget > 0;
    final currentSpending = data.currentSpending;
    final remaining = (monthlyBudget - currentSpending).clamp(0.0, double.infinity);
    final ratio = monthlyBudget > 0 ? (currentSpending / monthlyBudget).clamp(0.0, 1.0) : 0.0;
    final percentage = (ratio * 100).toInt();
    final isOverBudget = monthlyBudget > 0 && currentSpending > monthlyBudget;

    // Daily safe spend calculation
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (lastDayOfMonth - now.day + 1).clamp(1, 31);
    final dailySafeSpend = remaining / daysLeft;

    final categories = data.categoryBudgets;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
      child: ResponsiveWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 1. HERO MONTHLY BUDGET CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: hasMonthlyBudget
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'ميزانية الشهر الإجمالية' : 'Monthly Spending Budget',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: isOverBudget
                                    ? Colors.red.withValues(alpha: 0.15)
                                    : (isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isOverBudget
                                      ? Colors.redAccent.withValues(alpha: 0.3)
                                      : borderColor,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: isOverBudget
                                      ? Colors.redAccent
                                      : (isDarkMode ? Colors.white : Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatAmount(currentSpending),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAr
                                  ? 'من ${_formatAmount(monthlyBudget)}'
                                  : 'of ${_formatAmount(monthlyBudget)}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 7,
                            child: LinearProgressIndicator(
                              value: ratio,
                              backgroundColor:
                                  isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isOverBudget
                                    ? Colors.redAccent
                                    : ratio > 0.85
                                        ? Colors.amber
                                        : (isDarkMode ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Stats Grid (2 Clean boxes)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF1B1B22)
                                      : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderColor, width: 0.8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAr ? 'المتبقي للشهر' : 'Remaining Budget',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isOverBudget
                                          ? (isAr ? 'تجاوزت الميزانية!' : 'Over budget!')
                                          : _formatAmount(remaining),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: isOverBudget
                                            ? Colors.redAccent
                                            : (isDarkMode ? Colors.white : Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF1B1B22)
                                      : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderColor, width: 0.8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAr ? 'متاح يومياً (آمن)' : 'Daily Safe Spend',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '~${_formatAmount(dailySafeSpend)} / ${isAr ? 'يوم' : 'day'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'ميزانية الشهر الإجمالية' : 'Monthly Spending Budget',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isAr ? 'غير محددة' : 'Not set',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatAmount(currentSpending),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'إجمالي المصاريف حتى الآن' : 'total spent this month',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _showSetMonthlyBudgetDialog(isDarkMode);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF1B1B22) : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.add_chart_rounded,
                                    size: 19,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isAr ? 'تحديد ميزانية الشهر' : 'Set Monthly Budget',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isAr
                                            ? 'حدد سقفاً لمتابعة المتبقي والمصروف الآمن'
                                            : 'Set a limit to track remaining & safe spend',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isAr ? 'تحديد' : 'Set',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            // ================= 2. CATEGORY BUDGETS HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      isAr ? 'ميزانيات التصنيفات' : 'Category Budgets',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${categories.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  isAr ? 'اضغط للتعديل' : 'Tap to edit',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ================= 3. CATEGORIES CARD =================
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final name = isAr ? cat.categoryNameAr : cat.categoryNameEn;
                  final catBudget = cat.budget;
                  final spent = cat.spent;
                  final catRatio = catBudget > 0 ? (spent / catBudget).clamp(0.0, 1.0) : 0.0;
                  final catPercent = (catRatio * 100).toInt();
                  final isCatOver = catBudget > 0 && spent > catBudget;
                  final hasBudget = catBudget > 0;
                  final isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
                  final icon = _getCategoryIcon(cat.categoryId, name);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _showSetCategoryBudgetDialog(cat, isDarkMode);
                      },
                      borderRadius: index == 0
                          ? const BorderRadius.vertical(top: Radius.circular(22))
                          : index == categories.length - 1
                              ? const BorderRadius.vertical(bottom: Radius.circular(22))
                              : BorderRadius.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: (isDarkMode ? Colors.white : Colors.black)
                                        .withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    icon,
                                    size: 19,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (catBudget > 0)
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                                    decoration: BoxDecoration(
                                      color: isCatOver
                                          ? Colors.red.withValues(alpha: 0.15)
                                          : (isDarkMode
                                              ? const Color(0xFF222228)
                                              : const Color(0xFFF4F4F5)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$catPercent%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isCatOver
                                            ? Colors.redAccent
                                            : (isDarkMode ? Colors.white : Colors.black),
                                      ),
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      _showSetCategoryBudgetDialog(cat, isDarkMode);
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? const Color(0xFF222228)
                                            : const Color(0xFFF4F4F5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isDarkMode
                                              ? const Color(0xFF3F3F46)
                                              : const Color(0xFFD4D4D8),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        isAr ? 'تحديد' : 'Set',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 30,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? const Color(0xFF222228)
                                        : const Color(0xFFF4F4F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: isIOS
                                      ? Center(
                                          child: IosSingleTapContextMenu(
                                            actions: [
                                              IosContextMenuAction(
                                                id: 'budget',
                                                title: hasBudget
                                                    ? (isAr ? 'تعديل الميزانية' : 'Edit Budget')
                                                    : (isAr ? 'تحديد الميزانية' : 'Set Budget'),
                                                iconSystemName: 'pencil',
                                              ),
                                              IosContextMenuAction(
                                                id: 'delete',
                                                title: isAr ? 'حذف الفئة' : 'Delete Category',
                                                iconSystemName: 'trash',
                                                destructive: true,
                                              ),
                                            ],
                                            onSelected: (id) {
                                              if (id == 'budget') {
                                                _showSetCategoryBudgetDialog(cat, isDarkMode);
                                              } else if (id == 'delete') {
                                                _confirmDeleteCategory(cat, isDarkMode);
                                              }
                                            },
                                            child: SizedBox(
                                              width: 28,
                                              height: 28,
                                              child: Center(
                                                child: Icon(
                                                  CupertinoIcons.ellipsis,
                                                  size: 15.0,
                                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            _showCategoryOptions(cat, isDarkMode, isAr);
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Icon(
                                            Icons.more_horiz_rounded,
                                            size: 16,
                                            color: isDarkMode
                                                ? Colors.grey[300]
                                                : Colors.grey[700],
                                          ),
                                        ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Micro progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: SizedBox(
                                height: 4.5,
                                child: LinearProgressIndicator(
                                  value: catRatio,
                                  backgroundColor: isDarkMode
                                      ? const Color(0xFF27272A)
                                      : const Color(0xFFE4E4E7),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCatOver
                                        ? Colors.redAccent
                                        : catRatio > 0.85
                                            ? Colors.amber
                                            : (isDarkMode ? Colors.white : Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Amounts under progress bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isAr
                                      ? 'صرفت ${_formatAmount(spent)}'
                                      : 'Spent ${_formatAmount(spent)}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  catBudget > 0
                                      ? (isAr
                                          ? 'الحد: ${_formatAmount(catBudget)}'
                                          : 'Limit: ${_formatAmount(catBudget)}')
                                      : (isAr ? 'الحد: غير محدد' : 'Limit: Not set'),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
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
          ],
        ),
      ),
    );
  }
}
