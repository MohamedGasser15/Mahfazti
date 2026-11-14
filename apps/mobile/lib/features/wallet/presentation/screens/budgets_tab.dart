import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neo_cupertino/neo_cupertino.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/core/widgets/app_progress_indicator.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/data/models/budget_models.dart';
import 'package:my_wallet/features/wallet/data/models/category_group_model.dart';
import 'package:my_wallet/features/wallet/data/repositories/category_group_service.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/presentation/utils/category_icon_helper.dart';
import 'package:my_wallet/features/settings/presentation/screens/categories_management_screen.dart';

class BudgetsTab extends StatefulWidget {
  const BudgetsTab({super.key});

  @override
  State<BudgetsTab> createState() => _BudgetsTabState();
}

class _BudgetsTabState extends State<BudgetsTab>
    with AutomaticKeepAliveClientMixin<BudgetsTab> {
  @override
  bool get wantKeepAlive => true;

  final WalletRepository _repository = WalletRepository();
  StreamSubscription<void>? _syncSubscription;
  StreamSubscription<void>? _groupsSubscription;
  bool _isLoading = true;
  String _currencyCode = 'EGP';
  BudgetDto? _budgetData;
  List<CategoryGroup> _groups = [];
  Map<int, String> _categoryGroupMap = {};
  final Set<String> _collapsedGroupIds = {};

  @override
  void initState() {
    super.initState();
    SharedPrefs.currencyNotifier.addListener(_onCurrencyPreferenceChanged);
    _loadInitialData();
    _syncSubscription = WalletDataSyncService.onDataChanged.listen((_) {
      if (mounted) {
        _loadBudget(forceRefresh: true);
        _loadGroups();
      }
    });
    _groupsSubscription = CategoryGroupService.onGroupsChanged.listen((_) {
      if (mounted) {
        _loadGroups();
      }
    });
  }

  @override
  void dispose() {
    SharedPrefs.currencyNotifier.removeListener(_onCurrencyPreferenceChanged);
    _syncSubscription?.cancel();
    _groupsSubscription?.cancel();
    super.dispose();
  }

  void _onCurrencyPreferenceChanged() {
    if (mounted)
      setState(() => _currencyCode = SharedPrefs.currencyNotifier.value);
  }

  Future<void> _loadInitialData() async {
    final code = await SharedPrefs.getCurrency();
    if (mounted) {
      setState(() => _currencyCode = code ?? 'EGP');
      await Future.wait([_loadBudget(), _loadGroups()]);
    }
  }

  Future<void> _loadGroups() async {
    try {
      final localGroups = await CategoryGroupService.getLocalGroups();
      final localMappings =
          await CategoryGroupService.getCategoryGroupMappings();
      if (mounted && localGroups.isNotEmpty) {
        setState(() {
          _groups = localGroups;
          _categoryGroupMap = localMappings;
        });
      }

      final groups = await CategoryGroupService.getGroups();
      final mappings = await CategoryGroupService.getCategoryGroupMappings();
      if (mounted) {
        setState(() {
          _groups = groups;
          _categoryGroupMap = mappings;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadBudget({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      try {
        final cached = await WalletCacheService.getBudget();
        if (cached != null) {
          final cachedBudget = BudgetDto.fromJson(cached);
          if (mounted) {
            setState(() {
              _budgetData = cachedBudget;
              _isLoading = false;
            });
          }
          // Fetch from API in background silently
          _fetchBudgetFromApi(silent: true);
          return;
        }
      } catch (e) {
        debugPrint('Error reading cached budget: $e');
      }
    }

    await _fetchBudgetFromApi(silent: false);
  }

  Future<void> _fetchBudgetFromApi({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final budget = await _repository.getBudget();
      if (mounted) {
        setState(() {
          _budgetData = budget;
          _isLoading = false;
        });
      }
      await WalletCacheService.saveBudget(budget.toJson());
    } catch (_) {
      if (mounted) {
        setState(() {
          _budgetData ??= BudgetDto.defaultSeed();
          _isLoading = false;
        });
      }
    }
  }

  String _formatAmount(double amount) {
    final symbol = currencySymbols[_currencyCode] ?? _currencyCode;
    final formatter = NumberFormat('#,##0', 'en_US');
    return '$symbol ${formatter.format(amount.round())}';
  }

  IconData _getCategoryIcon(int catId, String name) {
    return CategoryIconHelper.getMeta(catId, name).icon;
  }

  IconData _getGroupIcon(CategoryGroup group) {
    final icons = CategoriesManagementScreen.availableCategoryIcons;
    if (group.iconIndex >= 0 && group.iconIndex < icons.length) {
      return icons[group.iconIndex];
    }
    return Icons.folder_rounded;
  }

  void _showSetMonthlyBudgetDialog(bool isDarkMode) {
    if (Platform.isIOS) {
      _showIosSetMonthlyBudgetDialog(isDarkMode);
    } else {
      _showAndroidSetMonthlyBudgetDialog(isDarkMode);
    }
  }

  void _showIosSetMonthlyBudgetDialog(bool isDarkMode) {
    final hasExistingBudget = (_budgetData?.monthlyBudget ?? 0) > 0;
    final controller = TextEditingController(
      text: hasExistingBudget
          ? (_budgetData!.monthlyBudget).toStringAsFixed(0)
          : '',
    );

    showGlassModalSheet(
      context: context,
      halfSize: 0.55,
      fullSize: 0.85,
      builder: (ctx) {
        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.setMonthlyBudget,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF09090B),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(ctx),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.setMonthlyBudgetSpending,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: (isDarkMode ? Colors.white : Colors.black)
                            .withValues(alpha: isDarkMode ? 0.08 : 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF27272A)
                              : const Color(0xFFE4E4E7),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: controller,
                        keyboardAppearance: isDarkMode
                            ? Brightness.dark
                            : Brightness.light,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400],
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _currencyCode,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                              message: context.l10n.pleaseEnterValidAmount,
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
                                    categoryBudgets:
                                        BudgetDto.defaultSeed().categoryBudgets,
                                  );
                          });
                          await _repository.updateMonthlyBudget(amount);
                          await WalletCacheService.saveBudget(
                            _budgetData!.toJson(),
                          );

                          if (mounted) {
                            MessageService.showSuccess(
                              context: context,
                              message: context.l10n.budgetUpdatedSuccessfully,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.white
                              : const Color(0xFF09090B),
                          foregroundColor: isDarkMode
                              ? const Color(0xFF09090B)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.l10n.saveBudget,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (hasExistingBudget) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            Navigator.pop(ctx);
                            HapticFeedback.mediumImpact();
                            setState(() {
                              if (_budgetData != null) {
                                _budgetData = _budgetData!.copyWith(
                                  monthlyBudget: 0.0,
                                );
                              }
                            });
                            if (_budgetData != null) {
                              await _repository.updateMonthlyBudget(0.0);
                              await WalletCacheService.saveBudget(
                                _budgetData!.toJson(),
                              );
                            }
                            if (mounted) {
                              MessageService.showSuccess(
                                context: context,
                                message: context.l10n.monthlyBudgetRemoved,
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.trash,
                                size: 16,
                                color: CupertinoColors.destructiveRed,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.l10n.removeMonthlyBudget,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.destructiveRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAndroidSetMonthlyBudgetDialog(bool isDarkMode) {
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
              color: isDarkMode
                  ? const Color(0xFF27272A)
                  : const Color(0xFFE4E4E7),
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
                    color: isDarkMode
                        ? const Color(0xFF2E2E36)
                        : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.setMonthlyBudget,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.setMonthlyBudgetSpending,
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF09090B)
                      : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFF27272A)
                        : const Color(0xFFE4E4E7),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  controller: controller,
                  keyboardAppearance: isDarkMode
                      ? Brightness.dark
                      : Brightness.light,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
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
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 0,
                    ),
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
                        message: context.l10n.pleaseEnterValidAmount,
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
                              categoryBudgets:
                                  BudgetDto.defaultSeed().categoryBudgets,
                            );
                    });
                    await _repository.updateMonthlyBudget(amount);
                    await WalletCacheService.saveBudget(_budgetData!.toJson());

                    if (mounted) {
                      MessageService.showSuccess(
                        context: context,
                        message: context.l10n.budgetUpdatedSuccessfully,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.saveBudget,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
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
                          _budgetData = _budgetData!.copyWith(
                            monthlyBudget: 0.0,
                          );
                        }
                      });
                      if (_budgetData != null) {
                        await _repository.updateMonthlyBudget(0.0);
                        await WalletCacheService.saveBudget(
                          _budgetData!.toJson(),
                        );
                      }
                      if (mounted) {
                        MessageService.showSuccess(
                          context: context,
                          message: context.l10n.monthlyBudgetRemoved,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.money_off_rounded,
                      size: 17,
                      color: Colors.redAccent,
                    ),
                    label: Text(
                      context.l10n.removeMonthlyBudget,
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
    if (Platform.isIOS) {
      _showIosSetCategoryBudgetDialog(cat, isDarkMode);
    } else {
      _showAndroidSetCategoryBudgetDialog(cat, isDarkMode);
    }
  }

  void _showIosSetCategoryBudgetDialog(CategoryBudgetDto cat, bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final name = isAr ? cat.categoryNameAr : cat.categoryNameEn;
    final controller = TextEditingController(
      text: cat.budget > 0 ? cat.budget.toStringAsFixed(0) : '',
    );

    showGlassModalSheet(
      context: context,
      halfSize: 0.52,
      fullSize: 0.82,
      builder: (ctx) {
        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF09090B),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(ctx),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.setCategorySpendingLimit,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: (isDarkMode ? Colors.white : Colors.black)
                            .withValues(alpha: isDarkMode ? 0.08 : 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF27272A)
                              : const Color(0xFFE4E4E7),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: controller,
                        keyboardAppearance: isDarkMode
                            ? Brightness.dark
                            : Brightness.light,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400],
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _currencyCode,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                              message: context.l10n.pleaseEnterValidAmount,
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          HapticFeedback.mediumImpact();

                          setState(() {
                            if (_budgetData != null) {
                              final updatedList = _budgetData!.categoryBudgets
                                  .map((item) {
                                    if (item.categoryId == cat.categoryId) {
                                      return item.copyWith(budget: amount);
                                    }
                                    return item;
                                  })
                                  .toList();
                              _budgetData = _budgetData!.copyWith(
                                categoryBudgets: updatedList,
                              );
                            }
                          });
                          if (_budgetData != null) {
                            await _repository.updateCategoryBudget(
                              cat.categoryId,
                              amount,
                            );
                            await WalletCacheService.saveBudget(
                              _budgetData!.toJson(),
                            );
                          }

                          if (mounted) {
                            MessageService.showSuccess(
                              context: context,
                              message: context.l10n.categoryBudgetUpdated,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.white
                              : const Color(0xFF09090B),
                          foregroundColor: isDarkMode
                              ? const Color(0xFF09090B)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.l10n.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
    );
  }

  void _showAndroidSetCategoryBudgetDialog(
    CategoryBudgetDto cat,
    bool isDarkMode,
  ) {
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
              color: isDarkMode
                  ? const Color(0xFF27272A)
                  : const Color(0xFFE4E4E7),
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
                    color: isDarkMode
                        ? const Color(0xFF2E2E36)
                        : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.budgetForCategory(name),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.setCategorySpendingLimit,
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF09090B)
                      : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFF27272A)
                        : const Color(0xFFE4E4E7),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextField(
                  controller: controller,
                  keyboardAppearance: isDarkMode
                      ? Brightness.dark
                      : Brightness.light,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
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
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 0,
                    ),
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
                        message: context.l10n.pleaseEnterValidAmount,
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    HapticFeedback.mediumImpact();

                    setState(() {
                      if (_budgetData != null) {
                        final updatedList = _budgetData!.categoryBudgets.map((
                          item,
                        ) {
                          if (item.categoryId == cat.categoryId) {
                            return item.copyWith(budget: amount);
                          }
                          return item;
                        }).toList();
                        _budgetData = _budgetData!.copyWith(
                          categoryBudgets: updatedList,
                        );
                      }
                    });
                    if (_budgetData != null) {
                      await _repository.updateCategoryBudget(
                        cat.categoryId,
                        amount,
                      );
                      await WalletCacheService.saveBudget(
                        _budgetData!.toJson(),
                      );
                    }

                    if (mounted) {
                      MessageService.showSuccess(
                        context: context,
                        message: context.l10n.categoryBudgetUpdated,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white : Colors.black,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.save,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
              color: isDarkMode
                  ? const Color(0xFF27272A)
                  : const Color(0xFFE4E4E7),
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
                    color: isDarkMode
                        ? const Color(0xFF2E2E36)
                        : const Color(0xFFD4D4D8),
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
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                title: Text(
                  context.l10n.newCategory,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  context.l10n.addNewCategorySubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: Icon(
                  appForwardIconOf(context),
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
                color: isDarkMode
                    ? const Color(0xFF27272A)
                    : const Color(0xFFE4E4E7),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.create_new_folder_outlined,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                title: Text(
                  isAr ? 'مجموعة جديدة' : 'New Group',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  isAr
                      ? 'إنشاء مجموعة لتنظيم ومتابعة فئات متعددة معاً'
                      : 'Create a group to organize multiple categories together',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: Icon(
                  appForwardIconOf(context),
                  size: 14,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddGroupDialog(isDarkMode);
                },
              ),
              Divider(
                height: 16,
                color: isDarkMode
                    ? const Color(0xFF27272A)
                    : const Color(0xFFE4E4E7),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                title: Text(
                  context.l10n.monthlyBudget,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  context.l10n.setOrEditOverallMonthlyLimit,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: Icon(
                  appForwardIconOf(context),
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

  Future<void> _showAddGroupDialog(bool isDarkMode) async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    await CategoriesManagementScreen.showAddGroupModal(
      context: context,
      isDarkMode: isDarkMode,
      onSave: (name, colorValue, iconIndex, sheetContext) async {
        final trimmed = name.trim();
        if (trimmed.isEmpty) return;
        final newGroup = CategoryGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: trimmed,
          colorValue: colorValue,
          iconIndex: iconIndex,
          createdAt: DateTime.now(),
        );
        try {
          await CategoryGroupService.saveGroup(newGroup);
        } catch (error) {
          if (mounted) {
            MessageService.showError(
              context: context,
              message: error.toString(),
            );
          }
          return;
        }
        if (sheetContext.mounted) Navigator.pop(sheetContext);
        if (mounted) {
          MessageService.showSuccess(
            context: context,
            message: isAr
                ? 'تم إنشاء المجموعة بنجاح'
                : 'Group created successfully',
          );
        }
      },
    );
  }

  Future<void> _showEditGroupDialog(
    CategoryGroup group,
    bool isDarkMode,
  ) async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    await CategoriesManagementScreen.showEditGroupModal(
      context: context,
      isDarkMode: isDarkMode,
      groupToEdit: group,
      onSave: (name, colorValue, iconIndex, sheetContext) async {
        final trimmed = name.trim();
        if (trimmed.isEmpty) return;
        final updated = group.copyWith(
          name: trimmed,
          colorValue: colorValue,
          iconIndex: iconIndex,
        );
        try {
          await CategoryGroupService.saveGroup(updated);
        } catch (error) {
          if (mounted) {
            MessageService.showError(
              context: context,
              message: error.toString(),
            );
          }
          return;
        }
        if (sheetContext.mounted) Navigator.pop(sheetContext);
        if (mounted) {
          MessageService.showSuccess(
            context: context,
            message: isAr
                ? 'تم تعديل المجموعة بنجاح'
                : 'Group updated successfully',
          );
        }
      },
      onDelete: (sheetContext) {
        Navigator.pop(sheetContext);
        _confirmDeleteGroup(group, isDarkMode);
      },
    );
  }

  void _confirmDeleteGroup(CategoryGroup group, bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(isAr ? 'حذف المجموعة' : 'Delete Group'),
          content: Text(
            isAr
                ? 'هل أنت متأكد من حذف "${group.name}"؟ لن يتم حذف الفئات بل ستصبح غير مصنفة.'
                : 'Are you sure you want to delete "${group.name}"? Categories will not be deleted.',
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await CategoryGroupService.deleteGroup(group.id);
                } catch (error) {
                  if (mounted) {
                    MessageService.showError(
                      context: context,
                      message: error.toString(),
                    );
                  }
                  return;
                }
                if (mounted) {
                  MessageService.showSuccess(
                    context: context,
                    message: isAr ? 'تم حذف المجموعة' : 'Group deleted',
                  );
                }
              },
              child: Text(isAr ? 'حذف' : 'Delete'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF141418) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(isAr ? 'حذف المجموعة' : 'Delete Group'),
          content: Text(
            isAr
                ? 'هل أنت متأكد من حذف "${group.name}"؟ لن يتم حذف الفئات بل ستصبح غير مصنفة.'
                : 'Are you sure you want to delete "${group.name}"? Categories will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await CategoryGroupService.deleteGroup(group.id);
                } catch (error) {
                  if (mounted) {
                    MessageService.showError(
                      context: context,
                      message: error.toString(),
                    );
                  }
                  return;
                }
                if (mounted) {
                  MessageService.showSuccess(
                    context: context,
                    message: isAr ? 'تم حذف المجموعة' : 'Group deleted',
                  );
                }
              },
              child: Text(isAr ? 'حذف' : 'Delete'),
            ),
          ],
        ),
      );
    }
  }

  void _showGroupOptionsMenu(CategoryGroup group, bool isDarkMode, bool isAr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF141418) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(isAr ? 'تعديل المجموعة' : 'Edit Group'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditGroupDialog(group, isDarkMode);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: Text(
                  isAr ? 'حذف المجموعة' : 'Delete Group',
                  style: const TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteGroup(group, isDarkMode);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(bool isDarkMode) {
    if (Platform.isIOS) {
      _showIosAddCategoryDialog(isDarkMode);
    } else {
      _showAndroidAddCategoryDialog(isDarkMode);
    }
  }

  void _showIosAddCategoryDialog(bool isDarkMode) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();

    showGlassModalSheet(
      context: context,
      halfSize: 0.60,
      fullSize: 0.88,
      builder: (ctx) {
        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.newCategory,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF09090B),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(ctx),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.addCategoryToTrackSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      context.l10n.categoryName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: (isDarkMode ? Colors.white : Colors.black)
                            .withValues(alpha: isDarkMode ? 0.08 : 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF27272A)
                              : const Color(0xFFE4E4E7),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: nameController,
                        keyboardAppearance: isDarkMode
                            ? Brightness.dark
                            : Brightness.light,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: context.l10n.categoryNameHint,
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.budgetLimitOptional,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: (isDarkMode ? Colors.white : Colors.black)
                            .withValues(alpha: isDarkMode ? 0.08 : 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF27272A)
                              : const Color(0xFFE4E4E7),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: budgetController,
                        keyboardAppearance: isDarkMode
                            ? Brightness.dark
                            : Brightness.light,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400],
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _currencyCode,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 0,
                          ),
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
                              message: context.l10n.pleaseEnterCategoryName,
                            );
                            return;
                          }
                          final budgetVal =
                              double.tryParse(budgetController.text.trim()) ??
                              0.0;
                          Navigator.pop(ctx);
                          HapticFeedback.mediumImpact();

                          final currentCats =
                              _budgetData?.categoryBudgets ?? [];
                          final maxId = currentCats.fold<int>(
                            0,
                            (prev, c) =>
                                c.categoryId > prev ? c.categoryId : prev,
                          );
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
                                categoryBudgets: [
                                  ..._budgetData!.categoryBudgets,
                                  newCat,
                                ],
                              );
                            }
                          });
                          if (_budgetData != null) {
                            await _repository.updateMonthlyBudget(0.0);
                            await WalletCacheService.saveBudget(
                              _budgetData!.toJson(),
                            );
                          }
                          if (mounted) {
                            MessageService.showSuccess(
                              context: context,
                              message: context.l10n.categoryAddedSuccess,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.white
                              : const Color(0xFF09090B),
                          foregroundColor: isDarkMode
                              ? const Color(0xFF09090B)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.l10n.addCategory,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
    );
  }

  void _showAndroidAddCategoryDialog(bool isDarkMode) {
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0xFF27272A)
                      : const Color(0xFFE4E4E7),
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
                          color: isDarkMode
                              ? const Color(0xFF2E2E36)
                              : const Color(0xFFD4D4D8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      context.l10n.newCategory,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.addCategoryToTrackSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      context.l10n.categoryName,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF09090B)
                            : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF27272A)
                              : const Color(0xFFE4E4E7),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: nameController,
                        keyboardAppearance: isDarkMode
                            ? Brightness.dark
                            : Brightness.light,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: context.l10n.categoryNameHint,
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.budgetLimitOptional,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF09090B)
                            : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF27272A)
                              : const Color(0xFFE4E4E7),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: budgetController,
                        keyboardAppearance: isDarkMode
                            ? Brightness.dark
                            : Brightness.light,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400],
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _currencyCode,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 0,
                          ),
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
                              message: context.l10n.pleaseEnterCategoryName,
                            );
                            return;
                          }
                          final budgetVal =
                              double.tryParse(budgetController.text.trim()) ??
                              0.0;
                          Navigator.pop(ctx);
                          HapticFeedback.mediumImpact();

                          final currentCats =
                              _budgetData?.categoryBudgets ?? [];
                          final maxId = currentCats.fold<int>(
                            0,
                            (prev, c) =>
                                c.categoryId > prev ? c.categoryId : prev,
                          );
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
                                categoryBudgets: [
                                  ..._budgetData!.categoryBudgets,
                                  newCat,
                                ],
                              );
                            }
                          });
                          if (_budgetData != null) {
                            await WalletCacheService.saveBudget(
                              _budgetData!.toJson(),
                            );
                          }
                          if (mounted) {
                            MessageService.showSuccess(
                              context: context,
                              message: context.l10n.categoryAddedSuccess,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.white
                              : Colors.black,
                          foregroundColor: isDarkMode
                              ? Colors.black
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.l10n.addCategory,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
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
    final isIOS =
        Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      NeoAlertDialog.show(
        context: context,
        title: context.l10n.deleteCategory,
        message: context.l10n.confirmDeleteCategory(name),
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
                  message: context.l10n.categoryDeletedSuccess,
                );
              }
            },
          ),
        ],
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF18181B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.l10n.deleteCategory,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          context.l10n.confirmDeleteCategory(name),
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancel,
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
                  message: context.l10n.categoryDeletedSuccess,
                );
              }
            },
            child: Text(
              context.l10n.delete,
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
    if (Platform.isIOS) {
      _showIosCategoryOptions(cat, isDarkMode, isAr);
    } else {
      _showAndroidCategoryOptions(cat, isDarkMode, isAr);
    }
  }

  void _showIosCategoryOptions(
    CategoryBudgetDto cat,
    bool isDarkMode,
    bool isAr,
  ) {
    final name = isAr ? cat.categoryNameAr : cat.categoryNameEn;
    final icon = _getCategoryIcon(cat.categoryId, name);
    final hasBudget = cat.budget > 0;

    showGlassModalSheet(
      context: context,
      halfSize: 0.38,
      fullSize: 0.50,
      builder: (ctx) {
        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (isDarkMode ? Colors.white : Colors.black)
                              .withValues(alpha: 0.08),
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
                            Text(
                              hasBudget
                                  ? context.l10n.currentLimitAmount(
                                      _formatAmount(cat.budget),
                                    )
                                  : context.l10n.noLimitSet,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CupertinoListTile(
                    leading: Icon(
                      CupertinoIcons.pencil,
                      size: 20,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      hasBudget
                          ? context.l10n.editBudget
                          : context.l10n.setBudget,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showSetCategoryBudgetDialog(cat, isDarkMode);
                    },
                  ),
                  CupertinoListTile(
                    leading: const Icon(
                      CupertinoIcons.trash,
                      size: 20,
                      color: CupertinoColors.destructiveRed,
                    ),
                    title: Text(
                      context.l10n.deleteCategory,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.destructiveRed,
                      ),
                    ),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDeleteCategory(cat, isDarkMode);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAndroidCategoryOptions(
    CategoryBudgetDto cat,
    bool isDarkMode,
    bool isAr,
  ) {
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
              color: isDarkMode
                  ? const Color(0xFF27272A)
                  : const Color(0xFFE4E4E7),
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
                    color: isDarkMode
                        ? const Color(0xFF2E2E36)
                        : const Color(0xFFD4D4D8),
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
                      color: (isDarkMode ? Colors.white : Colors.black)
                          .withValues(alpha: 0.07),
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
                              ? context.l10n.currentLimitAmount(
                                  _formatAmount(cat.budget),
                                )
                              : context.l10n.noLimitSet,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
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
                color: isDarkMode
                    ? const Color(0xFF27272A)
                    : const Color(0xFFE4E4E7),
              ),
              const SizedBox(height: 10),
              // 1. تحديد الميزانية
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                title: Text(
                  hasBudget ? context.l10n.editBudget : context.l10n.setBudget,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Icon(
                  appForwardIconOf(context),
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
                  context.l10n.deleteCategory,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
                trailing: Icon(
                  appForwardIconOf(context),
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
    super.build(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isIOS =
        Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final bgColor = isDarkMode
        ? const Color(0xFF09090B)
        : const Color(0xFFF8F8FA);
    final borderColor = isDarkMode
        ? const Color(0xFF27272A)
        : const Color(0xFFE4E4E7);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: !isIOS,
      appBar: AppBar(
        title: Text(
          context.l10n.budgets,
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
                            title: context.l10n.newCategory,
                            iconSystemName: 'plus.circle',
                          ),
                          IosContextMenuAction(
                            id: 'new_group',
                            title: isAr ? 'مجموعة جديدة' : 'New Group',
                            iconSystemName: 'folder.badge.plus',
                          ),
                          IosContextMenuAction(
                            id: 'monthly_budget',
                            title: context.l10n.monthlyBudget,
                            iconSystemName: 'slider.horizontal.3',
                          ),
                        ],
                        onSelected: (id) {
                          if (id == 'new_category') {
                            _showAddCategoryDialog(isDarkMode);
                          } else if (id == 'new_group') {
                            _showAddGroupDialog(isDarkMode);
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
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF09090B),
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
                          color: isDarkMode
                              ? const Color(0xFF141418)
                              : Colors.white,
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
      body: Platform.isIOS
          ? CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () => _loadBudget(forceRefresh: true),
                ),
                SliverToBoxAdapter(
                  child: _isLoading
                      ? const SizedBox(
                          height: 300,
                          child: Center(child: AppProgressIndicator()),
                        )
                      : _buildContent(
                          isDarkMode,
                          isAr,
                          borderColor,
                          scrollable: false,
                        ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: () => _loadBudget(forceRefresh: true),
              color: isDarkMode ? Colors.white : Colors.black,
              backgroundColor: isDarkMode
                  ? const Color(0xFF141418)
                  : Colors.white,
              child: _isLoading
                  ? const Center(child: AppProgressIndicator())
                  : _buildContent(
                      isDarkMode,
                      isAr,
                      borderColor,
                      scrollable: true,
                    ),
            ),
    );
  }

  Widget _buildContent(
    bool isDarkMode,
    bool isAr,
    Color borderColor, {
    bool scrollable = true,
  }) {
    final data = _budgetData ?? BudgetDto.defaultSeed();
    final monthlyBudget = data.monthlyBudget;
    final hasMonthlyBudget = monthlyBudget > 0;
    final currentSpending = data.currentSpending;
    final remaining = (monthlyBudget - currentSpending).clamp(
      0.0,
      double.infinity,
    );
    final ratio = monthlyBudget > 0
        ? (currentSpending / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final percentage = (ratio * 100).toInt();
    final isOverBudget = monthlyBudget > 0 && currentSpending > monthlyBudget;

    // Daily safe spend calculation
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (lastDayOfMonth - now.day + 1).clamp(1, 31);
    final dailySafeSpend = remaining / daysLeft;

    final categories = data.categoryBudgets;

    final content = Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 120),
      child: ResponsiveWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 1. HERO MONTHLY BUDGET CARD =================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDarkMode ? 0.30 : 0.04,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: hasMonthlyBudget
                  ? Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _showSetMonthlyBudgetDialog(isDarkMode);
                        },
                        borderRadius: BorderRadius.circular(22),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color:
                                              (isDarkMode
                                                      ? Colors.white
                                                      : Colors.black)
                                                  .withValues(alpha: 0.07),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.account_balance_wallet_rounded,
                                          size: 16,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        context.l10n.monthlySpendingBudget,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                          color: isDarkMode
                                              ? Colors.grey[300]
                                              : const Color(0xFF3F3F46),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.5,
                                          vertical: 3.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isOverBudget
                                              ? Colors.red.withValues(
                                                  alpha: 0.15,
                                                )
                                              : (isDarkMode
                                                    ? const Color(0xFF222228)
                                                    : const Color(0xFFF4F4F5)),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: isOverBudget
                                                ? Colors.redAccent.withValues(
                                                    alpha: 0.3,
                                                  )
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
                                                : (isDarkMode
                                                      ? Colors.white
                                                      : Colors.black),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        CupertinoIcons.pencil,
                                        size: 15,
                                        color: isDarkMode
                                            ? Colors.grey[500]
                                            : Colors.grey[400],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _formatAmount(currentSpending),
                                    style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.6,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.l10n.ofMonthlyBudget(
                                      _formatAmount(monthlyBudget),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Sleek Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  height: 5.5,
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    backgroundColor: isDarkMode
                                        ? const Color(0xFF27272A)
                                        : const Color(0xFFE4E4E7),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isOverBudget
                                          ? Colors.redAccent
                                          : ratio > 0.85
                                          ? Colors.amber
                                          : (isDarkMode
                                                ? Colors.white
                                                : const Color(0xFF09090B)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Stats Grid (2 Clean boxes)
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? const Color(0xFF1B1B22)
                                            : const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: borderColor,
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.l10n.remainingBudget,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isOverBudget
                                                ? context
                                                      .l10n
                                                      .overBudgetExclamation
                                                : _formatAmount(remaining),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: isOverBudget
                                                  ? Colors.redAccent
                                                  : (isDarkMode
                                                        ? Colors.white
                                                        : Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? const Color(0xFF1B1B22)
                                            : const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: borderColor,
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.l10n.dailySafeSpend,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '~${_formatAmount(dailySafeSpend)} / ${context.l10n.day}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.monthlySpendingBudget,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF222228)
                                      : const Color(0xFFF4F4F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  context.l10n.notSet,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
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
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.l10n.totalSpentThisMonth,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _showSetMonthlyBudgetDialog(isDarkMode);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF1B1B22)
                                    : const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: borderColor,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color:
                                          (isDarkMode
                                                  ? Colors.white
                                                  : Colors.black)
                                              .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Icon(
                                      Icons.add_chart_rounded,
                                      size: 18,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          context.l10n.setMonthlyBudget,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          context.l10n.setLimitToTrackSafeSpend,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 6.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Text(
                                      context.l10n.selectAction,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDarkMode
                                            ? Colors.black
                                            : Colors.white,
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
            ),

            const SizedBox(height: 22),

            // ================= 2. CATEGORY BUDGETS HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _groups.isNotEmpty
                          ? (isAr
                                ? 'المجموعات والتصنيفات'
                                : 'Groups & Categories')
                          : context.l10n.categoryBudgets,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF222228)
                            : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${categories.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  context.l10n.tapToEdit,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ================= 3. CATEGORIES / GROUPS LIST =================
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _groups.isEmpty
                  ? Container(
                      key: const ValueKey('budgets_flat_categories'),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF141418)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDarkMode ? 0.25 : 0.03,
                            ),
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
                          color: isDarkMode
                              ? const Color(0xFF222228)
                              : const Color(0xFFF4F4F5),
                        ),
                        itemBuilder: (context, index) =>
                            _buildCategoryBudgetRow(
                              cat: categories[index],
                              isDarkMode: isDarkMode,
                              isAr: isAr,
                              isFirst: index == 0,
                              isLast: index == categories.length - 1,
                            ),
                      ),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('budgets_groups_list'),
                      child: Column(
                        children: [
                          for (final group in _groups) ...[
                            Builder(
                              builder: (context) {
                                final groupCats = categories
                                    .where(
                                      (c) =>
                                          _categoryGroupMap[c.categoryId] ==
                                          group.id,
                                    )
                                    .toList();
                                return _buildGroupBudgetCard(
                                  group: group,
                                  groupCats: groupCats,
                                  isDarkMode: isDarkMode,
                                  isAr: isAr,
                                  borderColor: borderColor,
                                );
                              },
                            ),
                          ],
                          Builder(
                            builder: (context) {
                              final ungroupedCats = categories
                                  .where(
                                    (c) =>
                                        _categoryGroupMap[c.categoryId] == null,
                                  )
                                  .toList();
                              if (ungroupedCats.isEmpty)
                                return const SizedBox.shrink();
                              return _buildUngroupedBudgetCard(
                                ungroupedCats: ungroupedCats,
                                isDarkMode: isDarkMode,
                                isAr: isAr,
                                borderColor: borderColor,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );

    if (scrollable) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }
    return content;
  }

  Widget _buildGroupBudgetCard({
    required CategoryGroup group,
    required List<CategoryBudgetDto> groupCats,
    required bool isDarkMode,
    required bool isAr,
    required Color borderColor,
  }) {
    final groupBudget = groupCats.fold<double>(0.0, (s, c) => s + c.budget);
    final groupSpent = groupCats.fold<double>(0.0, (s, c) => s + c.spent);
    final hasBudget = groupBudget > 0;
    final groupRatio = hasBudget
        ? (groupSpent / groupBudget).clamp(0.0, 1.0)
        : 0.0;
    final groupPercent = (groupRatio * 100).toInt();
    final isGroupOver = hasBudget && groupSpent > groupBudget;
    final isCollapsed = _collapsedGroupIds.contains(group.id);
    final groupIcon = _getGroupIcon(group);
    final isIOS =
        Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF141418) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Header Row
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (isCollapsed) {
                  _collapsedGroupIds.remove(group.id);
                } else {
                  _collapsedGroupIds.add(group.id);
                }
              });
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(20),
              bottom: isCollapsed ? const Radius.circular(20) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Group Icon Squircle
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: group.color.withValues(
                        alpha: isDarkMode ? 0.22 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: group.color.withValues(
                          alpha: isDarkMode ? 0.40 : 0.25,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(groupIcon, size: 18, color: group.color),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Group Name & Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF09090B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${groupCats.length} ${isAr ? 'فئات' : 'categories'}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              '  ·  ',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDarkMode
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                            ),
                            Flexible(
                              child: Text(
                                hasBudget
                                    ? '${_formatAmount(groupSpent)} / ${_formatAmount(groupBudget)}'
                                    : _formatAmount(groupSpent),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isGroupOver
                                      ? Colors.redAccent
                                      : (isDarkMode
                                            ? Colors.grey[300]
                                            : Colors.grey[700]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Group Budget Pill (if has budget)
                  if (hasBudget)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7.5,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: isGroupOver
                            ? Colors.red.withValues(alpha: 0.15)
                            : (isDarkMode
                                  ? const Color(0xFF222228)
                                  : const Color(0xFFF4F4F5)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isGroupOver
                              ? Colors.redAccent.withValues(alpha: 0.3)
                              : borderColor,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '$groupPercent%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isGroupOver
                              ? Colors.redAccent
                              : (isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),

                  // Group 3-dots Menu
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
                                  id: 'edit_group',
                                  title: isAr ? 'تعديل المجموعة' : 'Edit Group',
                                  iconSystemName: 'pencil',
                                ),
                                IosContextMenuAction(
                                  id: 'delete_group',
                                  title: isAr ? 'حذف المجموعة' : 'Delete Group',
                                  iconSystemName: 'trash',
                                  destructive: true,
                                ),
                              ],
                              onSelected: (id) {
                                if (id == 'edit_group') {
                                  _showEditGroupDialog(group, isDarkMode);
                                } else if (id == 'delete_group') {
                                  _confirmDeleteGroup(group, isDarkMode);
                                }
                              },
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: Center(
                                  child: Icon(
                                    CupertinoIcons.ellipsis,
                                    size: 15.0,
                                    color: isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () =>
                                _showGroupOptionsMenu(group, isDarkMode, isAr),
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
                  const SizedBox(width: 4),

                  // Rotating Chevron
                  AnimatedRotation(
                    turns: isCollapsed ? (isAr ? 0.25 : -0.25) : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      size: 13,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Group Progress Bar (if budget exists for this group)
          if (hasBudget)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: groupRatio,
                    backgroundColor: isDarkMode
                        ? const Color(0xFF27272A)
                        : const Color(0xFFE4E4E7),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isGroupOver ? Colors.redAccent : group.color,
                    ),
                  ),
                ),
              ),
            ),

          // Collapsible Categories inside group
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDarkMode
                      ? const Color(0xFF222228)
                      : const Color(0xFFF4F4F5),
                ),
                if (groupCats.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        isAr
                            ? 'لا توجد فئات في هذه المجموعة بعد'
                            : 'No categories in this group yet',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groupCats.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: isDarkMode
                          ? const Color(0xFF222228)
                          : const Color(0xFFF4F4F5),
                    ),
                    itemBuilder: (context, index) => _buildCategoryBudgetRow(
                      cat: groupCats[index],
                      isDarkMode: isDarkMode,
                      isAr: isAr,
                      isFirst: false,
                      isLast: index == groupCats.length - 1,
                    ),
                  ),
              ],
            ),
            crossFadeState: isCollapsed
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildUngroupedBudgetCard({
    required List<CategoryBudgetDto> ungroupedCats,
    required bool isDarkMode,
    required bool isAr,
    required Color borderColor,
  }) {
    if (ungroupedCats.isEmpty) return const SizedBox.shrink();
    final isCollapsed = _collapsedGroupIds.contains('ungrouped');
    final totalSpent = ungroupedCats.fold<double>(0.0, (s, c) => s + c.spent);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF141418) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (isCollapsed) {
                  _collapsedGroupIds.remove('ungrouped');
                } else {
                  _collapsedGroupIds.add('ungrouped');
                }
              });
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(20),
              bottom: isCollapsed ? const Radius.circular(20) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: (isDarkMode ? Colors.white : Colors.black)
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.square_stack_3d_down_dottedline,
                        size: 18,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'فئات غير مصنفة' : 'Ungrouped',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF09090B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${ungroupedCats.length} ${isAr ? 'فئات' : 'categories'}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              '  ·  ',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDarkMode
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                              ),
                            ),
                            Text(
                              _formatAmount(totalSpent),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isCollapsed ? (isAr ? 0.25 : -0.25) : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      size: 13,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDarkMode
                      ? const Color(0xFF222228)
                      : const Color(0xFFF4F4F5),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ungroupedCats.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: isDarkMode
                        ? const Color(0xFF222228)
                        : const Color(0xFFF4F4F5),
                  ),
                  itemBuilder: (context, index) => _buildCategoryBudgetRow(
                    cat: ungroupedCats[index],
                    isDarkMode: isDarkMode,
                    isAr: isAr,
                    isFirst: false,
                    isLast: index == ungroupedCats.length - 1,
                  ),
                ),
              ],
            ),
            crossFadeState: isCollapsed
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetRow({
    required CategoryBudgetDto cat,
    required bool isDarkMode,
    required bool isAr,
    required bool isFirst,
    required bool isLast,
  }) {
    final name = isAr ? cat.categoryNameAr : cat.categoryNameEn;
    final catBudget = cat.budget;
    final spent = cat.spent;
    final catRatio = catBudget > 0 ? (spent / catBudget).clamp(0.0, 1.0) : 0.0;
    final catPercent = (catRatio * 100).toInt();
    final isCatOver = catBudget > 0 && spent > catBudget;
    final hasBudget = catBudget > 0;
    final isIOS =
        Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final icon = _getCategoryIcon(cat.categoryId, name);

    Color progressColor;
    if (isCatOver) {
      progressColor = Colors.redAccent;
    } else if (catRatio > 0.85) {
      progressColor = Colors.amber;
    } else {
      progressColor = isDarkMode ? Colors.white : const Color(0xFF09090B);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _showSetCategoryBudgetDialog(cat, isDarkMode);
        },
        borderRadius: isFirst
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Category Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isDarkMode ? Colors.white : Colors.black).withValues(
                    alpha: 0.07,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 12),

              // Title + Progress + Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatAmount(spent),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isCatOver
                                ? Colors.redAccent
                                : (isDarkMode ? Colors.white : Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    if (hasBudget) ...[
                      // Micro progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 3.5,
                          child: LinearProgressIndicator(
                            value: catRatio,
                            backgroundColor: isDarkMode
                                ? const Color(0xFF27272A)
                                : const Color(0xFFE4E4E7),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              isCatOver
                                  ? context.l10n.overBudgetExclamation
                                  : '${context.l10n.limitAmount(_formatAmount(catBudget))}  ·  $catPercent%',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isCatOver
                                    ? Colors.redAccent
                                    : (isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCatOver
                                ? '+${_formatAmount(spent - catBudget)}'
                                : '${context.l10n.remainingBudget} ${_formatAmount(catBudget - spent)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isCatOver
                                  ? Colors.redAccent
                                  : (isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        context.l10n.noLimitSet,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action / 3-dots
              Container(
                width: 28,
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
                                  ? context.l10n.editBudget
                                  : context.l10n.setBudget,
                              iconSystemName: 'pencil',
                            ),
                            IosContextMenuAction(
                              id: 'delete',
                              title: context.l10n.deleteCategory,
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
                                size: 14.0,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
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
                          size: 15,
                          color: isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
