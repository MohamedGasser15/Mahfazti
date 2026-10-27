import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:neo_cupertino/neo_cupertino.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:my_wallet/core/utils/navigation_service.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/core/widgets/app_icon_picker_modal.dart';
import 'package:my_wallet/features/wallet/data/models/category_model.dart';
import 'package:my_wallet/features/wallet/data/repositories/category_repository.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/presentation/utils/category_icon_helper.dart';

class CategoriesManagementScreen extends StatefulWidget {
  const CategoriesManagementScreen({super.key});

  /// Complete list of category icons.
  /// Original 18 icons are preserved at indices 0..17 for full backward compatibility,
  /// followed by all other icons available in the app icon catalog.
  static final List<IconData> _allCategoryIcons = () {
    final list = <IconData>[
      Icons.restaurant_rounded,
      Icons.shopping_bag_rounded,
      Icons.local_gas_station_rounded,
      Icons.directions_car_rounded,
      Icons.receipt_long_rounded,
      Icons.local_cafe_rounded,
      Icons.local_hospital_rounded,
      Icons.fitness_center_rounded,
      Icons.sports_esports_rounded,
      Icons.flight_takeoff_rounded,
      Icons.school_rounded,
      Icons.card_giftcard_rounded,
      Icons.subscriptions_rounded,
      Icons.trending_up_rounded,
      Icons.home_rounded,
      Icons.pets_rounded,
      Icons.movie_rounded,
      Icons.work_rounded,
    ];
    for (final item in kAppIconItems) {
      if (!list.contains(item.icon)) {
        list.add(item.icon);
      }
    }
    return List<IconData>.unmodifiable(list);
  }();

  static List<IconData> get availableCategoryIcons => _allCategoryIcons;

  /// Public helper method called across the app (e.g. home_tab_dialogs) to show
  /// the Add Category modal sheet with native iOS Liquid Glass styling.
  static Future<void> showAddCategoryModal({
    required BuildContext context,
    required bool isDarkMode,
    required void Function(String name, int iconIndex, BuildContext sheetContext) onSave,
  }) async {
    await _presentCategoryModal(
      context: context,
      isDarkMode: isDarkMode,
      onSave: onSave,
    );
  }

  /// Unified modal presentation using neo_cupertino's showGlassModalSheet on iOS
  /// and standard bottom sheet on Android.
  static Future<void> _presentCategoryModal({
    required BuildContext context,
    required bool isDarkMode,
    Category? categoryToEdit,
    String initialName = '',
    int initialIconIndex = 0,
    IconData? initialIcon,
    int expenseCount = 0,
    required void Function(String name, int iconIndex, BuildContext sheetContext) onSave,
    void Function(BuildContext sheetContext)? onDelete,
  }) async {
    final focusNode = FocusNode();

    if (Platform.isIOS) {
      final sheetController = GlassModalSheetController();
      final isNewCategory = categoryToEdit == null;
      await GlassModalSheet.present(
        context: context,
        controller: sheetController,
        halfSize: 0.69,
        fullSize: 0.87,
        initialState: isNewCategory ? GlassSheetState.full : GlassSheetState.half,
        onStateChanged: (state) {
          if (state == GlassSheetState.half) {
            focusNode.unfocus();
          }
        },
        builder: (sheetContext) => Material(
          type: MaterialType.transparency,
          child: _CategoryModalContent(
            isDarkMode: isDarkMode,
            controller: sheetController,
            focusNode: focusNode,
            isGlass: true,
            categoryToEdit: categoryToEdit,
            initialName: initialName,
            initialIconIndex: initialIconIndex >= 0 ? initialIconIndex : 0,
            initialIcon: initialIcon,
            expenseCount: expenseCount,
            onSave: (name, iconIndex) => onSave(name, iconIndex, sheetContext),
            onDelete: onDelete != null ? () => onDelete(sheetContext) : null,
          ),
        ),
      );
    } else {
      await showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => _CategoryModalContent(
          isDarkMode: isDarkMode,
          controller: null,
          focusNode: focusNode,
          isGlass: false,
          categoryToEdit: categoryToEdit,
          initialName: initialName,
          initialIconIndex: initialIconIndex >= 0 ? initialIconIndex : 0,
          initialIcon: initialIcon,
          expenseCount: expenseCount,
          onSave: (name, iconIndex) => onSave(name, iconIndex, sheetContext),
          onDelete: onDelete != null ? () => onDelete(sheetContext) : null,
        ),
      );
    }
  }

  @override
  State<CategoriesManagementScreen> createState() =>
      _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState
    extends State<CategoriesManagementScreen> {
  bool _isLoading = true;
  List<Category> _categories = [];
  Map<int, int> _categoryExpenseCounts = {};
  final Map<int, IconData> _categoryCustomIcons = {};
  String _searchQuery = '';
  // 'all' | 'unused' | 'noBudget' | 'overBudget'
  String _usageFilter = 'all';
  // 'default' | 'mostUsed' | 'leastUsed' | 'az'
  String _sortMode = 'default';

  // Demo budget data for the seeded categories.
  // TODO: replace with `WalletRepository.getBudget()` once this screen is
  // wired to the backend instead of the local seed list.
  static const Map<int, double> _categoryBudgets = {
    1: 150,
    2: 200,
    3: 250,
    4: 300,
    5: 120,
    6: 80,
    7: 60,
    9: 100,
    11: 90,
    12: 70,
  };
  static const Map<int, double> _categorySpent = {
    1: 220,
    2: 90,
    3: 310,
    4: 120,
    5: 60,
    6: 95,
    7: 20,
    9: 40,
    11: 30,
    12: 15,
  };
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _listScrollController = ScrollController();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final WalletRepository _walletRepository = WalletRepository();
  StreamSubscription<void>? _syncSubscription;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _loadData();
    _syncSubscription = WalletDataSyncService.onDataChanged.listen((_) {
      if (mounted) {
        _loadData(silent: true);
      }
    });
  }

  void _onSearchFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  static List<Category> get _defaultSeedCategories => [
        Category(id: 1, nameAr: 'طعام ومطاعم', nameEn: 'Food & Dining'),
        Category(id: 2, nameAr: 'تسوق ومستلزمات', nameEn: 'Shopping & Retail'),
        Category(id: 3, nameAr: 'بقالة وسوبرماركت', nameEn: 'Groceries & Supermarket'),
        Category(id: 4, nameAr: 'فواتير وخدمات', nameEn: 'Bills & Utilities'),
        Category(id: 5, nameAr: 'مواصلات وبنزين', nameEn: 'Transportation & Gas'),
        Category(id: 6, nameAr: 'قهوة وكافيهات', nameEn: 'Coffee & Cafes'),
        Category(id: 7, nameAr: 'الصحة والأدوية', nameEn: 'Health & Pharmacy'),
        Category(id: 8, nameAr: 'الراتب والدخل', nameEn: 'Salary & Income'),
        Category(id: 9, nameAr: 'اشتراكات وباقات', nameEn: 'Subscriptions & Internet'),
        Category(id: 10, nameAr: 'سفر وطيران ورحلات', nameEn: 'Travel & Flights'),
        Category(id: 11, nameAr: 'جيم ورياضة', nameEn: 'Gym & Fitness'),
        Category(id: 12, nameAr: 'ترفيه وسينما', nameEn: 'Entertainment & Movies'),
        Category(id: 13, nameAr: 'التعليم والكورسات', nameEn: 'Education & Courses'),
        Category(id: 14, nameAr: 'عمل حر ومشاريع', nameEn: 'Freelance & Projects'),
        Category(id: 15, nameAr: 'استثمار وادخار', nameEn: 'Investments & Savings'),
        Category(id: 16, nameAr: 'هدايا وتبرعات', nameEn: 'Gifts & Charity'),
        Category(id: 17, nameAr: 'المنزل والإيجار', nameEn: 'Home & Rent'),
        Category(id: 18, nameAr: 'إلكترونيات وأجهزة', nameEn: 'Electronics & Tech'),
        Category(id: 19, nameAr: 'حيوانات أليفة', nameEn: 'Pets & Vet'),
        Category(id: 20, nameAr: 'مصاريف أخرى', nameEn: 'Other Miscellaneous'),
      ];

  static Map<int, int> get _defaultSeedCounts => {
        1: 8,
        2: 5,
        3: 12,
        4: 3,
        5: 6,
        6: 9,
        7: 2,
        8: 1,
        9: 4,
        10: 0,
        11: 1,
        12: 3,
        13: 0,
        14: 2,
        15: 0,
        16: 2,
        17: 1,
        18: 0,
        19: 0,
        20: 0,
      };

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final categories = await _categoryRepository.getAllCategories();
      final summary = await _walletRepository.getSummary(
        fromDate: DateTime(2026, 1, 1),
        toDate: DateTime(2026, 12, 31, 23, 59, 59),
      );
      final counts = <int, int>{};
      for (final cat in summary.expensesByCategory) {
        counts[cat.categoryId] = cat.count;
      }
      for (final cat in summary.incomeByCategory) {
        counts[cat.categoryId] = (counts[cat.categoryId] ?? 0) + cat.count;
      }
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _categoryExpenseCounts = counts;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (_categories.isEmpty) {
          _categories = _defaultSeedCategories;
          _categoryExpenseCounts = Map.from(_defaultSeedCounts);
        }
        _isLoading = false;
      });
    }
  }

  /// Pull-to-refresh entry point (keeps the current list on screen).
  Future<void> _refreshCategories() => _loadData(silent: true);

  bool _isOverBudget(Category cat) {
    final budget = _categoryBudgets[cat.id];
    if (budget == null || budget <= 0) return false;
    return (_categorySpent[cat.id] ?? 0) > budget;
  }

  int _countForFilter(String filterId) {
    switch (filterId) {
      case 'unused':
        return _categories
            .where((cat) => (_categoryExpenseCounts[cat.id] ?? 0) == 0)
            .length;
      case 'noBudget':
        return _categories
            .where((cat) => !_categoryBudgets.containsKey(cat.id))
            .length;
      case 'overBudget':
        return _categories.where(_isOverBudget).length;
      default:
        return _categories.length;
    }
  }

  List<Category> get _filteredCategories {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    Iterable<Category> list = _categories;

    // Usage / budget filter
    switch (_usageFilter) {
      case 'unused':
        list = list.where((cat) => (_categoryExpenseCounts[cat.id] ?? 0) == 0);
        break;
      case 'noBudget':
        list = list.where((cat) => !_categoryBudgets.containsKey(cat.id));
        break;
      case 'overBudget':
        list = list.where(_isOverBudget);
        break;
    }

    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((cat) =>
          cat.nameAr.toLowerCase().contains(q) ||
          cat.nameEn.toLowerCase().contains(q));
    }

    final result = list.toList();
    switch (_sortMode) {
      case 'mostUsed':
        result.sort((a, b) => (_categoryExpenseCounts[b.id] ?? 0)
            .compareTo(_categoryExpenseCounts[a.id] ?? 0));
        break;
      case 'leastUsed':
        result.sort((a, b) => (_categoryExpenseCounts[a.id] ?? 0)
            .compareTo(_categoryExpenseCounts[b.id] ?? 0));
        break;
      case 'az':
        result.sort((a, b) => (isAr ? a.nameAr : a.nameEn)
            .toLowerCase()
            .compareTo((isAr ? b.nameAr : b.nameEn).toLowerCase()));
        break;
    }
    return result;
  }

  static List<IconData> get _availableCategoryIcons =>
      CategoriesManagementScreen.availableCategoryIcons;

  void _showAddCategorySheet(bool isDarkMode) => _showCategorySheet(isDarkMode);

  Future<void> _showCategorySheet(bool isDarkMode, {Category? categoryToEdit}) async {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final initialName = categoryToEdit != null
        ? (isAr ? categoryToEdit.nameAr : categoryToEdit.nameEn)
        : '';
    final initialIcon = categoryToEdit != null
        ? (_categoryCustomIcons[categoryToEdit.id] ??
            CategoryIconHelper.getMeta(categoryToEdit.id, initialName).icon)
        : null;
    final initialIconIndex = initialIcon != null
        ? _availableCategoryIcons.indexOf(initialIcon)
        : 0;
    final expenseCount = categoryToEdit != null
        ? (_categoryExpenseCounts[categoryToEdit.id] ?? 0)
        : 0;

    await CategoriesManagementScreen._presentCategoryModal(
      context: context,
      isDarkMode: isDarkMode,
      categoryToEdit: categoryToEdit,
      initialName: initialName,
      initialIconIndex: initialIconIndex,
      initialIcon: initialIcon,
      expenseCount: expenseCount,
      onSave: (name, iconIndex, sheetContext) {
        if (categoryToEdit != null) {
          _submitEditCategory(
            category: categoryToEdit,
            name: name,
            iconIndex: iconIndex,
            bottomSheetContext: sheetContext,
          );
        } else {
          _submitNewCategory(
            name: name,
            iconIndex: iconIndex,
            bottomSheetContext: sheetContext,
          );
        }
      },
      onDelete: categoryToEdit != null
          ? (sheetContext) {
              _submitDeleteCategory(
                category: categoryToEdit,
                bottomSheetContext: sheetContext,
              );
            }
          : null,
    );
  }

  Future<void> _submitNewCategory({
    required String name,
    required int iconIndex,
    required BuildContext bottomSheetContext,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      MessageService.showWarning(
        context: context,
        message: context.l10n.pleaseEnterCategoryName,
      );
      return;
    }

    try {
      final created = await _categoryRepository.createCategory(trimmedName, trimmedName);
      if (iconIndex >= 0 && iconIndex < _availableCategoryIcons.length) {
        final icon = _availableCategoryIcons[iconIndex];
        _categoryCustomIcons[created.id] = icon;
        CategoryIconHelper.setCustomIcon(created.id, icon);
      }
      await _loadData(silent: true);
      if (bottomSheetContext.mounted) {
        Navigator.pop(bottomSheetContext);
      }
      if (!mounted) return;
      MessageService.showSuccess(
        context: context,
        message: context.l10n.categoryAddedSuccess,
      );
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString(),
      );
    }
  }

  Future<void> _submitEditCategory({
    required Category category,
    required String name,
    required int iconIndex,
    required BuildContext bottomSheetContext,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      MessageService.showWarning(
        context: context,
        message: context.l10n.pleaseEnterCategoryName,
      );
      return;
    }

    try {
      await _categoryRepository.updateCategory(category.id, trimmedName, trimmedName);
      if (iconIndex >= 0 && iconIndex < _availableCategoryIcons.length) {
        final icon = _availableCategoryIcons[iconIndex];
        _categoryCustomIcons[category.id] = icon;
        CategoryIconHelper.setCustomIcon(category.id, icon);
      }
      await _loadData(silent: true);
      if (bottomSheetContext.mounted) {
        Navigator.pop(bottomSheetContext);
      }
      if (!mounted) return;
      final isAr = Directionality.of(context) == TextDirection.rtl;
      MessageService.showSuccess(
        context: context,
        message: isAr ? 'تم تعديل التصنيف بنجاح' : 'Category updated successfully',
      );
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString(),
      );
    }
  }

  Future<void> _submitDeleteCategory({
    required Category category,
    required BuildContext bottomSheetContext,
  }) async {
    try {
      await _categoryRepository.deleteCategory(category.id);
      _categoryExpenseCounts.remove(category.id);
      _categoryCustomIcons.remove(category.id);
      await _loadData(silent: true);
      if (bottomSheetContext.mounted) {
        Navigator.pop(bottomSheetContext);
      }
      if (!mounted) return;
      final isAr = Directionality.of(context) == TextDirection.rtl;
      MessageService.showSuccess(
        context: context,
        message: isAr
            ? 'تم حذف التصنيف بنجاح'
            : 'Category deleted successfully',
      );
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: e.toString(),
      );
    }
  }

  void _confirmDeleteCategoryFromList(Category category) {
    HapticFeedback.mediumImpact();
    final count = _categoryExpenseCounts[category.id] ?? 0;
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final catName = isAr ? category.nameAr : category.nameEn;

    NeoAlertDialog.show(
      context: context,
      title: isAr ? 'حذف التصنيف' : 'Delete Category',
      message: count > 0
          ? (isAr
              ? 'هل أنت متأكد من حذف "$catName"؟ هذا التصنيف مرتبط بـ $count ${count == 1 ? 'معاملة' : 'معاملات'} وستصبح هذه المعاملات بدون تصنيف.'
              : 'Are you sure you want to delete "$catName"? This category has $count linked ${count == 1 ? 'expense' : 'expenses'} that will become uncategorized.')
          : (isAr
              ? 'هل أنت متأكد من حذف "$catName"؟'
              : 'Are you sure you want to delete "$catName"?'),
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
            try {
              await _categoryRepository.deleteCategory(category.id);
              _categoryExpenseCounts.remove(category.id);
              _categoryCustomIcons.remove(category.id);
              await _loadData(silent: true);
              if (!mounted) return;
              MessageService.showSuccess(
                context: context,
                message: isAr
                    ? 'تم حذف التصنيف بنجاح'
                    : 'Category deleted successfully',
              );
            } catch (e) {
              if (!mounted) return;
              MessageService.showError(
                context: context,
                message: e.toString(),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final bgColor =
        isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final dividerColor =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF1F1F5);
    final chevronColor =
        isDarkMode ? const Color(0xFF52525B) : const Color(0xFFD4D4D8);

    final categories = _filteredCategories;

    final listPadding = EdgeInsets.only(
      left: 16,
      right: 16,
      top: 12,
      bottom: Platform.isIOS
          ? (MediaQuery.of(context).viewPadding.bottom > 0
                  ? MediaQuery.of(context).viewPadding.bottom + 80
                  : 90) +
              MediaQuery.of(context).viewInsets.bottom
          : (MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 70
                  : 80),
    );

    final categoryListChildren = <Widget>[
      // Large title that collapses into the AppBar while scrolling
      AnimatedBuilder(
        animation: _listScrollController,
        builder: (context, child) {
          final offset = _listScrollController.hasClients
              ? _listScrollController.offset
              : 0.0;
          final isAr = Directionality.of(context) == TextDirection.rtl;
          final t = (offset / 55.0).clamp(0.0, 1.0);
          final curve = Curves.easeOutCubic.transform(t);
          final deltaX = isAr ? -curve * 90.0 : curve * 90.0;
          final deltaY = offset > 0 ? -offset * 0.35 : 0.0;
          final scale = 1.0 - curve * 0.35;
          final opacity = (1.0 - (offset - 15.0) / 40.0).clamp(0.0, 1.0);

          return Transform.translate(
            offset: Offset(deltaX, deltaY),
            child: Transform.scale(
              scale: scale,
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: Opacity(opacity: opacity, child: child),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 4,
            end: 4,
            top: 4,
            bottom: 12,
          ),
          child: Text(
            context.l10n.manageCategories,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.15,
              color: isDarkMode ? Colors.white : const Color(0xFF09090B),
            ),
          ),
        ),
      ),

      // Usage filters (All / Used / Unused) — same pill style as Transactions
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 4, end: 4, bottom: 14),
        child: _buildUsageFilters(isDarkMode),
      ),

      // Top Search Bar (Android only)
      if (!Platform.isIOS) ...[
        _buildAndroidSearchBar(
          isDarkMode: isDarkMode,
          cardBg: cardBg,
          borderColor: borderColor,
        ),
        const SizedBox(height: 12),
      ],

      // Categories Card Group or Authentic Empty State
      if (categories.isEmpty)
        _searchQuery.isNotEmpty
            ? GlassContentUnavailableView.search(
                query: _searchQuery,
                onClear: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : GlassContentUnavailableView(
                icon: CupertinoIcons.folder_badge_minus,
                title: context.l10n.noCategoriesFound,
                actionLabel: context.l10n.newCategory,
                onAction: () => _showAddCategorySheet(isDarkMode),
              )
      else
        SlidableAutoCloseBehavior(
          closeWhenOpened: true,
          closeWhenTapped: true,
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1),
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
            child: Column(
              children: List.generate(categories.length, (index) {
                final cat = categories[index];
                final isLast = index == categories.length - 1;
                final catName = isRtl ? cat.nameAr : cat.nameEn;
                final meta =
                    CategoryIconHelper.getMeta(cat.id, catName);
                final catIcon = _categoryCustomIcons[cat.id] ?? meta.icon;
                final count = _categoryExpenseCounts[cat.id] ?? 0;
                final countLabel =
                    context.l10n.categoryExpensesCount(count);

                return Column(
                  children: [
                    Slidable(
                      key: ValueKey('cat_${cat.id}'),
                      groupTag: 'categories_group',
                      startActionPane: ActionPane(
                        motion: const BehindMotion(),
                        extentRatio: 0.25,
                        children: [
                          CustomSlidableAction(
                            onPressed: (_) {
                              HapticFeedback.selectionClick();
                              _showCategorySheet(isDarkMode,
                                  categoryToEdit: cat);
                            },
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const BehindMotion(),
                        extentRatio: 0.25,
                        children: [
                          CustomSlidableAction(
                            onPressed: (_) {
                              HapticFeedback.selectionClick();
                              _confirmDeleteCategoryFromList(cat);
                            },
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              CupertinoIcons.trash_fill,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      child: Material(
                        color: cardBg,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _showCategorySheet(isDarkMode,
                                categoryToEdit: cat);
                          },
                          splashColor: (isDarkMode
                                  ? Colors.white
                                  : Colors.black)
                              .withValues(alpha: 0.04),
                          highlightColor: (isDarkMode
                                  ? Colors.white
                                  : Colors.black)
                              .withValues(alpha: 0.02),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Icon Box (Monochrome)
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? const Color(0xFF27272A)
                                        : const Color(0xFFE4E4E7),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode
                                          ? const Color(0xFF3F3F46)
                                          : const Color(0xFFD4D4D8),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Icon(
                                    catIcon,
                                    size: 20,
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF09090B),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Name & Counts
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        catName,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white
                                              : const Color(0xFF09090B),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                      if (count > 0) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          countLabel,
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? const Color(0xFFA1A1AA)
                                                : const Color(0xFF71717A),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Chevron
                                Icon(
                                  appForwardIconOf(context),
                                  size: 13,
                                  color: chevronColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 70,
                          end: 16,
                        ),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: dividerColor,
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      const SizedBox(height: 32),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: !Platform.isIOS,
      appBar: AppBar(
        // Title stays hidden until the large title scrolls away, then it
        // travels into the header bar (same behaviour as the Transactions page).
        title: AnimatedBuilder(
          animation: _listScrollController,
          builder: (context, child) {
            final offset = _listScrollController.hasClients
                ? _listScrollController.offset
                : 0.0;
            final isAr = Directionality.of(context) == TextDirection.rtl;
            final progress = ((offset - 16.0) / 38.0).clamp(0.0, 1.0);
            if (progress <= 0.0) return const SizedBox.shrink();
            final curve = Curves.easeOutCubic.transform(progress);

            // Travels in from the leading side along the diagonal trajectory
            final incomingX =
                isAr ? (1.0 - curve) * 60.0 : -(1.0 - curve) * 60.0;
            final incomingY = (1.0 - curve) * 12.0;
            final incomingScale = 0.85 + 0.15 * curve;

            return Transform.translate(
              offset: Offset(incomingX, incomingY),
              child: Transform.scale(
                scale: incomingScale,
                child: Opacity(
                  opacity: progress,
                  child: Text(
                    context.l10n.manageCategories,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const AppGlassBackButton(),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: _buildSortButton(isDarkMode),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Platform.isIOS
                ? GlassButton(
                    width: 38,
                    height: 38,
                    shape: const LiquidOval(),
                    useOwnLayer: true,
                    settings: LiquidGlassSettings(
                      thickness: 14,
                      blur: 10,
                      glassColor: isDarkMode
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.85),
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _showAddCategorySheet(isDarkMode);
                    },
                    icon: Icon(
                      Icons.add_rounded,
                      size: 20,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF09090B),
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _showAddCategorySheet(isDarkMode);
                    },
                    icon: Container(
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
                        size: 20,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF09090B),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Stack(
              children: [
                Platform.isIOS
                    ? CustomScrollView(
                        controller: _listScrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: _refreshCategories,
                          ),
                          SliverPadding(
                            padding: listPadding,
                            sliver: SliverList(
                              delegate: SliverChildListDelegate(
                                categoryListChildren,
                              ),
                            ),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshCategories,
                        color: isDarkMode ? Colors.white : Colors.black,
                        child: ListView(
                          controller: _listScrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: listPadding,
                          children: categoryListChildren,
                        ),
                      ),

                // Floating Bottom Search Bar (iOS Authentic Liquid Glass)
                // Automatically hides when modal sheet opens to prevent show-through
                if (Platform.isIOS)
                  ValueListenableBuilder<bool>(
                    valueListenable: NavigationService.isModalOpenNotifier,
                    builder: (context, isModalOpen, child) {
                      final bottomPadding = math.max(
                        MediaQuery.of(context).viewPadding.bottom > 0
                            ? MediaQuery.of(context).viewPadding.bottom - 2.0
                            : 14.0,
                        MediaQuery.of(context).viewInsets.bottom + 10.0,
                      );

                      return Positioned(
                        left: 20,
                        right: 20,
                        bottom: isModalOpen ? -120.0 : bottomPadding,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isModalOpen ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: isModalOpen,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: GlassSearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      placeholder: context.l10n.searchCategories,
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSortButton(bool isDarkMode) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final iconColor = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final borderColor =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    final options = <_SortOption>[
      _SortOption(
        id: 'default',
        title: isAr ? 'الترتيب الافتراضي' : 'Default order',
        icon: CupertinoIcons.list_bullet,
      ),
      _SortOption(
        id: 'mostUsed',
        title: isAr ? 'الأكثر استخدامًا' : 'Most used',
        icon: CupertinoIcons.arrow_down,
      ),
      _SortOption(
        id: 'leastUsed',
        title: isAr ? 'الأقل استخدامًا' : 'Least used',
        icon: CupertinoIcons.arrow_up,
      ),
      _SortOption(
        id: 'az',
        title: isAr ? 'أبجديًا' : 'A → Z',
        icon: CupertinoIcons.textformat,
      ),
    ];

    void onSelected(String id) {
      HapticFeedback.selectionClick();
      setState(() => _sortMode = id);
    }

    if (Platform.isIOS) {
      return GlassButton.custom(
        width: 38,
        height: 38,
        shape: const LiquidOval(),
        useOwnLayer: true,
        onTap: () {},
        settings: LiquidGlassSettings(
          thickness: 14,
          blur: 10,
          glassColor: isDarkMode
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.85),
        ),
        child: IosSingleTapContextMenu(
          actions: [
            for (final option in options)
              IosContextMenuAction(
                id: option.id,
                title: option.title,
                iconSystemName: 'arrow.up.arrow.down',
                icon: option.icon,
                showTrailingCheckmark: _sortMode == option.id,
              ),
          ],
          onSelected: onSelected,
          child: Center(
            child: Icon(Icons.swap_vert_rounded, size: 20, color: iconColor),
          ),
        ),
      );
    }

    return PopupMenuButton<String>(
      tooltip: isAr ? 'ترتيب' : 'Sort',
      onSelected: onSelected,
      color: isDarkMode ? const Color(0xFF141418) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<String>(
            value: option.id,
            child: Row(
              children: [
                Icon(option.icon, size: 18, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  option.title,
                  style: TextStyle(color: iconColor, fontSize: 14),
                ),
                const Spacer(),
                if (_sortMode == option.id)
                  Icon(Icons.check_rounded, size: 18, color: iconColor),
              ],
            ),
          ),
      ],
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF141418) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Icon(Icons.swap_vert_rounded, size: 20, color: iconColor),
      ),
    );
  }

  Widget _buildUsageFilters(bool isDarkMode) {
    final isAr = Directionality.of(context) == TextDirection.rtl;

    final filters = <_UsageFilterItem>[
      _UsageFilterItem(
        id: 'all',
        title: isAr ? 'الكل' : 'All',
        icon: Icons.grid_view_rounded,
      ),
      _UsageFilterItem(
        id: 'unused',
        title: isAr ? 'غير مستخدمة' : 'Unused',
        icon: Icons.remove_circle_outline_rounded,
      ),
      _UsageFilterItem(
        id: 'noBudget',
        title: isAr ? 'بدون ميزانية' : 'No budget',
        icon: Icons.savings_outlined,
      ),
      _UsageFilterItem(
        id: 'overBudget',
        title: isAr ? 'تجاوزت الميزانية' : 'Over budget',
        icon: Icons.trending_up_rounded,
      ),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return _buildFilterChip(
            title: filter.title,
            icon: filter.icon,
            count: _countForFilter(filter.id),
            isSelected: _usageFilter == filter.id,
            isDarkMode: isDarkMode,
            onTap: () {
              if (_usageFilter == filter.id) return;
              setState(() => _usageFilter = filter.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String title,
    required IconData icon,
    required int count,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.white : const Color(0xFF09090B))
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.06)),
            width: 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon expands smoothly only when the chip is selected
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: AlignmentDirectional.centerStart,
                widthFactor: isSelected ? 1.0 : 0.0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  opacity: isSelected ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    scale: isSelected ? 1.0 : 0.3,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: Icon(
                        icon,
                        size: 14.5,
                        color: isSelected
                            ? (isDarkMode
                                ? const Color(0xFF09090B)
                                : Colors.white)
                            : (isDarkMode
                                ? Colors.white.withValues(alpha: 0.75)
                                : const Color(0xFF52525B)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.2,
                color: isSelected
                    ? (isDarkMode ? const Color(0xFF09090B) : Colors.white)
                    : (isDarkMode
                        ? Colors.white.withValues(alpha: 0.85)
                        : const Color(0xFF27272A)),
              ),
            ),
            const SizedBox(width: 5),
            // Live count so the filter row reads like real information
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDarkMode
                        ? Colors.black.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.20))
                    : (isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (isDarkMode ? const Color(0xFF09090B) : Colors.white)
                      : (isDarkMode
                          ? Colors.white.withValues(alpha: 0.55)
                          : Colors.black.withValues(alpha: 0.45)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidSearchBar({
    required bool isDarkMode,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDarkMode ? 0.35 : 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: isDarkMode
                ? const Color(0xFFA1A1AA)
                : const Color(0xFF71717A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              keyboardAppearance: isDarkMode ? Brightness.dark : Brightness.light,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode
                    ? Colors.white
                    : const Color(0xFF09090B),
              ),
              decoration: InputDecoration(
                hintText: context.l10n.searchCategories,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDarkMode
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA1A1AA),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: isDarkMode
                    ? const Color(0xFFA1A1AA)
                    : const Color(0xFF71717A),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryModalContent extends StatefulWidget {
  final bool isDarkMode;
  final GlassModalSheetController? controller;
  final FocusNode focusNode;
  final bool isGlass;
  final Category? categoryToEdit;
  final String initialName;
  final int initialIconIndex;
  final IconData? initialIcon;
  final int expenseCount;
  final void Function(String name, int iconIndex) onSave;
  final VoidCallback? onDelete;

  const _CategoryModalContent({
    required this.isDarkMode,
    this.controller,
    required this.focusNode,
    this.isGlass = false,
    this.categoryToEdit,
    required this.initialName,
    required this.initialIconIndex,
    this.initialIcon,
    this.expenseCount = 0,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_CategoryModalContent> createState() => _CategoryModalContentState();
}

class _CategoryModalContentState extends State<_CategoryModalContent>
    with WidgetsBindingObserver {
  late final TextEditingController _nameController;
  late int _selectedIconIndex;
  late IconData _selectedIcon;
  bool _wasKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    final icons = CategoriesManagementScreen.availableCategoryIcons;
    _selectedIconIndex = (widget.initialIconIndex >= 0 &&
            widget.initialIconIndex < icons.length)
        ? widget.initialIconIndex
        : 0;
    _selectedIcon = widget.initialIcon ??
        (icons.isNotEmpty ? icons[_selectedIconIndex] : Icons.category_rounded);
    _nameController = TextEditingController(text: widget.initialName);
    if (widget.initialName.isNotEmpty) {
      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _nameController.text.length),
      );
    }
    WidgetsBinding.instance.addObserver(this);
    widget.focusNode.addListener(_handleFocusChange);

    // Autofocus keyboard immediately when adding a new category
    if (widget.categoryToEdit == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.focusNode.requestFocus();
        }
      });
    }
  }

  void _handleFocusChange() {
    if (widget.controller == null) return;
    if (widget.focusNode.hasFocus) {
      if (widget.controller!.currentState != GlassSheetState.full) {
        widget.controller!.snapToState(GlassSheetState.full);
      }
    } else {
      if (widget.controller!.currentState == GlassSheetState.full) {
        widget.controller!.snapToState(GlassSheetState.half);
      }
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = View.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;
    if (_wasKeyboardOpen && !isKeyboardOpen) {
      if (widget.controller?.currentState == GlassSheetState.full) {
        widget.controller?.snapToState(GlassSheetState.half);
      }
      widget.focusNode.unfocus();
    }
    _wasKeyboardOpen = isKeyboardOpen;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.focusNode.removeListener(_handleFocusChange);
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickIcon(BuildContext btnContext) async {
    widget.focusNode.unfocus();
    HapticFeedback.selectionClick();
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final RenderBox? renderBox =
        btnContext.findRenderObject() as RenderBox?;
    final picked = await showAppIconPicker(
      context,
      widgetRenderBox: renderBox,
      selectedIcon: _selectedIcon,
      isDarkMode: widget.isDarkMode,
      isAr: isAr,
      title: isAr ? 'أيقونة التصنيف' : 'Category Icon',
    );
    if (picked != null) {
      setState(() {
        _selectedIcon = picked;
        final icons = CategoriesManagementScreen.availableCategoryIcons;
        final idx = icons.indexOf(picked);
        _selectedIconIndex = idx >= 0 ? idx : 0;
      });
    }
  }

  void _confirmDelete(BuildContext context) {
    widget.focusNode.unfocus();
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final catName = isAr
        ? widget.categoryToEdit!.nameAr
        : widget.categoryToEdit!.nameEn;

    NeoAlertDialog.show(
      context: context,
      title: isAr ? 'حذف التصنيف' : 'Delete Category',
      message: widget.expenseCount > 0
          ? (isAr
              ? 'هل أنت متأكد من حذف "$catName"؟ هذا التصنيف مرتبط بـ ${widget.expenseCount} معاملة وستصبح هذه المعاملات بدون تصنيف.'
              : 'Are you sure you want to delete "$catName"? This category has ${widget.expenseCount} linked expenses that will become uncategorized.')
          : (isAr
              ? 'هل أنت متأكد من حذف "$catName"؟'
              : 'Are you sure you want to delete "$catName"?'),
      actions: [
        NeoDialogAction(
          title: context.l10n.cancel,
          role: NeoDialogActionRole.cancel,
          onPressed: () {},
        ),
        NeoDialogAction(
          title: isAr ? 'حذف' : 'Delete',
          role: NeoDialogActionRole.destructive,
          onPressed: () {
            widget.onDelete?.call();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
        widget.isDarkMode ? Colors.white : const Color(0xFF09090B);
    final fieldBg = widget.isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF4F4F5);
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final isAr = Directionality.of(context) == TextDirection.rtl;

    final sheetScrollController = widget.isGlass
        ? ScrollControllerProvider.of(context)?.controller
        : null;

    final sheetContent = SingleChildScrollView(
      controller: sheetScrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        widget.isGlass ? 12 : 8,
        20,
        viewInsetsBottom > 0
            ? viewInsetsBottom + 36
            : safeAreaBottom + 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Android top drag handle
          if (!widget.isGlass)
            Center(
              child: Container(
                height: 4,
                width: 38,
                margin: const EdgeInsets.only(top: 4, bottom: 12),
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // Header Bar: Cancel on Left, Centered Title, Save Checkmark on Right
          SizedBox(
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  widget.categoryToEdit != null
                      ? (isAr ? 'تعديل التصنيف' : 'Edit Category')
                      : context.l10n.newCategory,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: themeColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Cancel Button
                    widget.isGlass
                        ? GlassButton.custom(
                            height: 42,
                            shape: const LiquidRoundedRectangle(
                                borderRadius: 21),
                            useOwnLayer: true,
                            settings: widget.isDarkMode
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
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Center(
                                child: Text(
                                  context.l10n.cancel,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isDarkMode
                                        ? const Color(0xFFE4E4E7)
                                        : const Color(0xFF71717A),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              context.l10n.cancel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: widget.isDarkMode
                                    ? const Color(0xFFE4E4E7)
                                    : const Color(0xFF71717A),
                              ),
                            ),
                          ),

                    // Save Checkmark Button
                    widget.isGlass
                        ? GlassButton.custom(
                            width: 42,
                            height: 42,
                            shape: const LiquidOval(),
                            useOwnLayer: true,
                            settings: widget.isDarkMode
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
                              HapticFeedback.selectionClick();
                              widget.onSave(
                                  _nameController.text, _selectedIconIndex);
                            },
                            child: Icon(
                              CupertinoIcons.checkmark,
                              size: 20,
                              color: themeColor,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              widget.onSave(
                                  _nameController.text, _selectedIconIndex);
                            },
                            icon: Icon(
                              CupertinoIcons.checkmark,
                              size: 20,
                              color: themeColor,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Hero Icon Squircle Avatar (tap directly to open icon picker)
          Builder(
            builder: (btnContext) {
              final avatarBgColor = widget.isDarkMode
                  ? Colors.white.withValues(alpha: 0.10)
                  : const Color(0xFF09090B).withValues(alpha: 0.05);
              final avatarBorder = widget.isDarkMode
                  ? Colors.white.withValues(alpha: 0.18)
                  : const Color(0xFFE4E4E7);

              return Center(
                child: GestureDetector(
                  onTap: () => _pickIcon(btnContext),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: avatarBgColor,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: avatarBorder,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: widget.isDarkMode ? 0.35 : 0.06,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(
                              scale: anim,
                              child: child,
                            ),
                            child: Icon(
                              _selectedIcon,
                              key: ValueKey(_selectedIcon.codePoint),
                              size: 38,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ),

                      // Edit Badge on Corner
                      PositionedDirectional(
                        bottom: -3,
                        end: -3,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: widget.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 13,
                            color: widget.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 28),

          // Category Name Label
          Text(
            isAr ? 'اسم التصنيف' : 'Category Name',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode
                  ? const Color(0xFFD4D4D8)
                  : const Color(0xFF71717A),
            ),
          ),
          const SizedBox(height: 6),

          // Name Field
          TextField(
            controller: _nameController,
            focusNode: widget.focusNode,
            autofocus: widget.categoryToEdit == null,
            keyboardAppearance:
                widget.isDarkMode ? Brightness.dark : Brightness.light,
            cursorColor: themeColor,
            style: TextStyle(
              color: widget.isDarkMode
                  ? Colors.white
                  : const Color(0xFF09090B),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: isAr
                  ? 'مثال: مشتريات، مواصلات...'
                  : 'e.g. Shopping, Transport...',
              hintStyle: TextStyle(
                color: widget.isDarkMode
                    ? const Color(0xFF71717A)
                    : const Color(0xFFA1A1AA),
                fontSize: 14,
              ),
              filled: true,
              fillColor: fieldBg,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: widget.isDarkMode
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE4E4E7),
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: widget.isDarkMode
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE4E4E7),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: widget.isDarkMode
                      ? Colors.white.withValues(alpha: 0.40)
                      : const Color(0xFF09090B),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Edit Mode: Warning & Delete Button
          if (widget.categoryToEdit != null) ...[
            const SizedBox(height: 18),
            if (widget.expenseCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.32)
                        : const Color(0xFFFDE68A),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: widget.isDarkMode
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'هذا التصنيف مرتبط بـ ${widget.expenseCount} ${widget.expenseCount == 1 ? 'معاملة' : 'معاملات'}. حذفه سيترك هذه المعاملات بدون تصنيف.'
                            : 'This category has ${widget.expenseCount} linked ${widget.expenseCount == 1 ? 'expense' : 'expenses'}. Deleting it will leave these expenses uncategorized.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: widget.isDarkMode
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Delete Category Button
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                _confirmDelete(context);
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? const Color(0xFFEF4444).withValues(alpha: 0.14)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? const Color(0xFFEF4444).withValues(alpha: 0.30)
                        : const Color(0xFFFECACA),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.trash,
                      size: 17,
                      color: widget.isDarkMode
                          ? const Color(0xFFF87171)
                          : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'حذف التصنيف' : 'Delete Category',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode
                            ? const Color(0xFFF87171)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );

    if (widget.isGlass) {
      return sheetContent;
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF141417) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: widget.isDarkMode
              ? const Color(0xFF27272A)
              : const Color(0xFFE4E4E7),
          width: 1,
        ),
      ),
      child: SafeArea(
        top: false,
        child: sheetContent,
      ),
    );
  }
}

/// Item model for the usage filter pills shown under the page title.
class _UsageFilterItem {
  const _UsageFilterItem({
    required this.id,
    required this.title,
    required this.icon,
  });

  final String id;
  final String title;
  final IconData icon;
}

/// Item model for the sort menu shown in the app bar.
class _SortOption {
  const _SortOption({required this.id, required this.title, required this.icon});

  final String id;
  final String title;
  final IconData icon;
}
