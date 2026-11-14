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
import 'package:my_wallet/core/widgets/app_progress_indicator.dart';
import 'package:my_wallet/features/wallet/data/models/category_group_model.dart';
import 'package:my_wallet/features/wallet/data/models/category_model.dart';
import 'package:my_wallet/features/wallet/data/repositories/category_group_service.dart';
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

  /// Returns the corresponding SF Symbol string for a given IconData on iOS.
  static String sfSymbolForIcon(IconData icon) {
    if (icon == Icons.restaurant_rounded || icon == Icons.restaurant)
      return 'fork.knife';
    if (icon == Icons.shopping_bag_rounded || icon == Icons.shopping_bag)
      return 'bag.fill';
    if (icon == Icons.shopping_cart_rounded || icon == Icons.shopping_cart)
      return 'cart.fill';
    if (icon == Icons.local_gas_station_rounded ||
        icon == Icons.local_gas_station)
      return 'fuelpump.fill';
    if (icon == Icons.directions_car_rounded || icon == Icons.directions_car)
      return 'car.fill';
    if (icon == Icons.receipt_long_rounded ||
        icon == Icons.receipt_long ||
        icon == Icons.receipt)
      return 'doc.text.fill';
    if (icon == Icons.local_cafe_rounded || icon == Icons.local_cafe)
      return 'cup.and.saucer.fill';
    if (icon == Icons.local_hospital_rounded ||
        icon == Icons.local_hospital ||
        icon == Icons.medical_services_rounded ||
        icon == Icons.medical_services)
      return 'cross.case.fill';
    if (icon == Icons.fitness_center_rounded || icon == Icons.fitness_center)
      return 'dumbbell.fill';
    if (icon == Icons.sports_esports_rounded || icon == Icons.sports_esports)
      return 'gamecontroller.fill';
    if (icon == Icons.flight_takeoff_rounded ||
        icon == Icons.flight_takeoff ||
        icon == Icons.flight)
      return 'airplane.departure';
    if (icon == Icons.school_rounded || icon == Icons.school)
      return 'graduationcap.fill';
    if (icon == Icons.card_giftcard_rounded || icon == Icons.card_giftcard)
      return 'gift.fill';
    if (icon == Icons.celebration_rounded || icon == Icons.celebration)
      return 'party.popper.fill';
    if (icon == Icons.subscriptions_rounded || icon == Icons.subscriptions)
      return 'play.tv.fill';
    if (icon == Icons.trending_up_rounded || icon == Icons.trending_up)
      return 'chart.line.uptrend.xyaxis';
    if (icon == Icons.home_rounded || icon == Icons.home) return 'house.fill';
    if (icon == Icons.apartment_rounded || icon == Icons.apartment)
      return 'building.2.fill';
    if (icon == Icons.pets_rounded || icon == Icons.pets)
      return 'pawprint.fill';
    if (icon == Icons.movie_rounded || icon == Icons.movie) return 'film.fill';
    if (icon == Icons.work_rounded || icon == Icons.work)
      return 'briefcase.fill';
    if (icon == Icons.account_balance_wallet_rounded ||
        icon == Icons.account_balance_wallet)
      return 'wallet.bifold';
    if (icon == Icons.payments_rounded || icon == Icons.payments)
      return 'banknote';
    if (icon == Icons.savings_rounded || icon == Icons.savings)
      return 'archivebox.fill';
    if (icon == Icons.account_balance_rounded || icon == Icons.account_balance)
      return 'building.columns';
    if (icon == Icons.credit_card_rounded ||
        icon == Icons.credit_card ||
        icon == Icons.payment_rounded ||
        icon == Icons.payment)
      return 'creditcard';
    if (icon == Icons.phone_iphone_rounded || icon == Icons.phone_iphone)
      return 'iphone';
    if (icon == Icons.diamond_rounded || icon == Icons.diamond)
      return 'sparkles';
    if (icon == Icons.currency_exchange_rounded ||
        icon == Icons.currency_exchange)
      return 'arrow.left.arrow.right';
    if (icon == Icons.monetization_on_rounded || icon == Icons.monetization_on)
      return 'dollarsign.circle.fill';
    if (icon == Icons.two_wheeler_rounded || icon == Icons.two_wheeler)
      return 'bicycle';
    if (icon == Icons.child_care_rounded || icon == Icons.child_care)
      return 'figure.and.child.holdinghands';
    if (icon == Icons.lightbulb_rounded || icon == Icons.lightbulb)
      return 'lightbulb.fill';
    if (icon == Icons.wifi_rounded || icon == Icons.wifi) return 'wifi';
    if (icon == Icons.devices_rounded || icon == Icons.devices)
      return 'laptopcomputer.and.iphone';
    if (icon == Icons.shield_rounded || icon == Icons.shield)
      return 'shield.fill';
    if (icon == Icons.lock_rounded || icon == Icons.lock) return 'lock.fill';
    if (icon == Icons.storefront_rounded || icon == Icons.storefront)
      return 'storefront.fill';
    if (icon == CupertinoIcons.folder_fill ||
        icon == Icons.folder_rounded ||
        icon == Icons.folder)
      return 'folder.fill';
    return 'folder.fill';
  }

  /// Public helper method called across the app (e.g. home_tab_dialogs) to show
  /// the Add Category modal sheet with native iOS Liquid Glass styling.
  static Future<void> showAddCategoryModal({
    required BuildContext context,
    required bool isDarkMode,
    required void Function(
      String name,
      int iconIndex,
      BuildContext sheetContext,
    )
    onSave,
    String? initialGroupId,
  }) async {
    final groups = await CategoryGroupService.getGroups();
    if (!context.mounted) return;
    await _presentCategoryModal(
      context: context,
      isDarkMode: isDarkMode,
      availableGroups: groups,
      initialGroupId: initialGroupId,
      onSave: (name, iconIndex, groupId, sheetContext) {
        onSave(name, iconIndex, sheetContext);
      },
    );
  }

  /// Public helper method to show the Add Group modal sheet.
  static Future<void> showAddGroupModal({
    required BuildContext context,
    required bool isDarkMode,
    required void Function(
      String name,
      int colorValue,
      int iconIndex,
      BuildContext sheetContext,
    )
    onSave,
  }) async {
    await _presentGroupModal(
      context: context,
      isDarkMode: isDarkMode,
      onSave: onSave,
    );
  }

  /// Public helper method to show the Edit Group modal sheet.
  static Future<void> showEditGroupModal({
    required BuildContext context,
    required bool isDarkMode,
    required CategoryGroup groupToEdit,
    required void Function(
      String name,
      int colorValue,
      int iconIndex,
      BuildContext sheetContext,
    )
    onSave,
    void Function(BuildContext sheetContext)? onDelete,
  }) async {
    await _presentGroupModal(
      context: context,
      isDarkMode: isDarkMode,
      groupToEdit: groupToEdit,
      onSave: onSave,
      onDelete: onDelete,
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
    List<CategoryGroup> availableGroups = const [],
    String? initialGroupId,
    required void Function(
      String name,
      int iconIndex,
      String? groupId,
      BuildContext sheetContext,
    )
    onSave,
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
        initialState: isNewCategory
            ? GlassSheetState.full
            : GlassSheetState.half,
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
            availableGroups: availableGroups,
            initialGroupId: initialGroupId,
            onSave: (name, iconIndex, groupId) =>
                onSave(name, iconIndex, groupId, sheetContext),
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
          availableGroups: availableGroups,
          initialGroupId: initialGroupId,
          onSave: (name, iconIndex, groupId) =>
              onSave(name, iconIndex, groupId, sheetContext),
          onDelete: onDelete != null ? () => onDelete(sheetContext) : null,
        ),
      );
    }
  }

  /// Unified modal presentation for Add / Edit Group.
  static Future<void> _presentGroupModal({
    required BuildContext context,
    required bool isDarkMode,
    CategoryGroup? groupToEdit,
    required void Function(
      String name,
      int colorValue,
      int iconIndex,
      BuildContext sheetContext,
    )
    onSave,
    void Function(BuildContext sheetContext)? onDelete,
  }) async {
    final focusNode = FocusNode();
    final initialName = groupToEdit?.name ?? '';
    final initialColorValue = groupToEdit?.colorValue ?? 0xFF3B82F6;
    final initialIconIndex = (groupToEdit != null && groupToEdit.iconIndex >= 0)
        ? groupToEdit.iconIndex
        : 0;

    if (Platform.isIOS) {
      final sheetController = GlassModalSheetController();
      final isNewGroup = groupToEdit == null;
      await GlassModalSheet.present(
        context: context,
        controller: sheetController,
        halfSize: 0.72,
        fullSize: 0.90,
        initialState: isNewGroup ? GlassSheetState.full : GlassSheetState.half,
        onStateChanged: (state) {
          if (state == GlassSheetState.half) {
            focusNode.unfocus();
          }
        },
        builder: (sheetContext) => Material(
          type: MaterialType.transparency,
          child: _GroupModalContent(
            isDarkMode: isDarkMode,
            controller: sheetController,
            focusNode: focusNode,
            isGlass: true,
            groupToEdit: groupToEdit,
            initialName: initialName,
            initialColorValue: initialColorValue,
            initialIconIndex: initialIconIndex,
            onSave: (name, colorValue, iconIndex) =>
                onSave(name, colorValue, iconIndex, sheetContext),
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
        builder: (sheetContext) => _GroupModalContent(
          isDarkMode: isDarkMode,
          controller: null,
          focusNode: focusNode,
          isGlass: false,
          groupToEdit: groupToEdit,
          initialName: initialName,
          initialColorValue: initialColorValue,
          initialIconIndex: initialIconIndex,
          onSave: (name, colorValue, iconIndex) =>
              onSave(name, colorValue, iconIndex, sheetContext),
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

  // Real budget data loaded from WalletRepository / Cache
  Map<int, double> _categoryBudgets = {};
  Map<int, double> _categorySpent = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _listScrollController = ScrollController();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final WalletRepository _walletRepository = WalletRepository();
  StreamSubscription<void>? _syncSubscription;
  StreamSubscription<void>? _groupsSubscription;
  List<CategoryGroup> _groups = [];
  final Set<String> _collapsedGroupIds = {};
  Map<int, String> _categoryGroupMap = {};

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
    _groupsSubscription = CategoryGroupService.onGroupsChanged.listen((_) {
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
    _groupsSubscription?.cancel();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  static List<Category> get _defaultSeedCategories => [
    Category(id: 1, nameAr: 'طعام ومطاعم', nameEn: 'Food & Dining'),
    Category(id: 2, nameAr: 'تسوق ومستلزمات', nameEn: 'Shopping & Retail'),
    Category(
      id: 3,
      nameAr: 'بقالة وسوبرماركت',
      nameEn: 'Groceries & Supermarket',
    ),
    Category(id: 4, nameAr: 'فواتير وخدمات', nameEn: 'Bills & Utilities'),
    Category(id: 5, nameAr: 'مواصلات وبنزين', nameEn: 'Transportation & Gas'),
    Category(id: 6, nameAr: 'قهوة وكافيهات', nameEn: 'Coffee & Cafes'),
    Category(id: 7, nameAr: 'الصحة والأدوية', nameEn: 'Health & Pharmacy'),
    Category(id: 8, nameAr: 'الراتب والدخل', nameEn: 'Salary & Income'),
    Category(
      id: 9,
      nameAr: 'اشتراكات وباقات',
      nameEn: 'Subscriptions & Internet',
    ),
    Category(id: 10, nameAr: 'سفر وطيران ورحلات', nameEn: 'Travel & Flights'),
    Category(id: 11, nameAr: 'جيم ورياضة', nameEn: 'Gym & Fitness'),
    Category(id: 12, nameAr: 'ترفيه وسينما', nameEn: 'Entertainment & Movies'),
    Category(
      id: 13,
      nameAr: 'التعليم والكورسات',
      nameEn: 'Education & Courses',
    ),
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
      final groups = await CategoryGroupService.getGroups();
      final groupMap = await CategoryGroupService.getCategoryGroupMappings();
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

      final budgets = <int, double>{};
      final spent = <int, double>{};
      try {
        final budgetData = await _walletRepository.getBudget();
        for (final cb in budgetData.categoryBudgets) {
          if (cb.budget > 0) {
            budgets[cb.categoryId] = cb.budget;
          }
          spent[cb.categoryId] = cb.spent;
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _groups = groups;
        _categoryGroupMap = groupMap;
        _categoryExpenseCounts = counts;
        _categoryBudgets = budgets;
        _categorySpent = spent;
        _isLoading = false;
      });
    } catch (_) {
      final groups = await CategoryGroupService.getGroups();
      final groupMap = await CategoryGroupService.getCategoryGroupMappings();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _categoryGroupMap = groupMap;
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
      list = list.where(
        (cat) =>
            cat.nameAr.toLowerCase().contains(q) ||
            cat.nameEn.toLowerCase().contains(q),
      );
    }

    final result = list.toList();
    switch (_sortMode) {
      case 'mostUsed':
        result.sort(
          (a, b) => (_categoryExpenseCounts[b.id] ?? 0).compareTo(
            _categoryExpenseCounts[a.id] ?? 0,
          ),
        );
        break;
      case 'leastUsed':
        result.sort(
          (a, b) => (_categoryExpenseCounts[a.id] ?? 0).compareTo(
            _categoryExpenseCounts[b.id] ?? 0,
          ),
        );
        break;
      case 'az':
        result.sort(
          (a, b) => (isAr ? a.nameAr : a.nameEn).toLowerCase().compareTo(
            (isAr ? b.nameAr : b.nameEn).toLowerCase(),
          ),
        );
        break;
    }
    return result;
  }

  static List<IconData> get _availableCategoryIcons =>
      CategoriesManagementScreen.availableCategoryIcons;

  void _showAddCategorySheet(bool isDarkMode) => _showCategorySheet(isDarkMode);

  Future<void> _showAddGroupSheet(bool isDarkMode) async {
    await CategoriesManagementScreen._presentGroupModal(
      context: context,
      isDarkMode: isDarkMode,
      onSave: (name, colorValue, iconIndex, sheetContext) async {
        final trimmed = name.trim();
        if (trimmed.isEmpty) {
          MessageService.showWarning(
            context: context,
            message: Directionality.of(context) == TextDirection.rtl
                ? 'يرجى إدخال اسم المجموعة'
                : 'Please enter a group name',
          );
          return;
        }
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
        await _loadData(silent: true);
        if (sheetContext.mounted) {
          Navigator.pop(sheetContext);
        }
        if (!mounted) return;
        final isAr = Directionality.of(context) == TextDirection.rtl;
        MessageService.showSuccess(
          context: context,
          message: isAr
              ? 'تم إضافة المجموعة "$trimmed" بنجاح'
              : 'Group "$trimmed" added successfully',
        );
      },
    );
  }

  Future<void> _showEditGroupSheet(bool isDarkMode, CategoryGroup group) async {
    await CategoriesManagementScreen._presentGroupModal(
      context: context,
      isDarkMode: isDarkMode,
      groupToEdit: group,
      onSave: (name, colorValue, iconIndex, sheetContext) async {
        final trimmed = name.trim();
        if (trimmed.isEmpty) {
          MessageService.showWarning(
            context: context,
            message: Directionality.of(context) == TextDirection.rtl
                ? 'يرجى إدخال اسم المجموعة'
                : 'Please enter a group name',
          );
          return;
        }
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
        await _loadData(silent: true);
        if (sheetContext.mounted) {
          Navigator.pop(sheetContext);
        }
        if (!mounted) return;
        final isAr = Directionality.of(context) == TextDirection.rtl;
        MessageService.showSuccess(
          context: context,
          message: isAr
              ? 'تم تعديل المجموعة بنجاح'
              : 'Group updated successfully',
        );
      },
      onDelete: (sheetContext) async {
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
        await _loadData(silent: true);
        if (sheetContext.mounted) {
          Navigator.pop(sheetContext);
        }
        if (!mounted) return;
        final isAr = Directionality.of(context) == TextDirection.rtl;
        MessageService.showSuccess(
          context: context,
          message: isAr ? 'تم حذف المجموعة' : 'Group deleted',
        );
      },
    );
  }

  void _showGroupOptionsMenu(
    BuildContext context,
    CategoryGroup group,
    bool isDarkMode,
  ) {
    HapticFeedback.selectionClick();
    final isAr = Directionality.of(context) == TextDirection.rtl;

    NeoAlertDialog.show(
      context: context,
      title: group.name,
      message: isAr
          ? 'اختر إجراءً لهذه المجموعة'
          : 'Choose an action for this group',
      isDark: isDarkMode,
      actions: [
        NeoDialogAction(
          title: isAr ? 'تعديل المجموعة' : 'Edit Group',
          role: NeoDialogActionRole.standard,
          onPressed: () {
            _showEditGroupSheet(isDarkMode, group);
          },
        ),
        NeoDialogAction(
          title: isAr ? 'حذف المجموعة' : 'Delete Group',
          role: NeoDialogActionRole.destructive,
          onPressed: () {
            _confirmDeleteGroup(group);
          },
        ),
        NeoDialogAction(
          title: isAr ? 'إلغاء' : 'Cancel',
          role: NeoDialogActionRole.cancel,
          onPressed: () {},
        ),
      ],
    );
  }

  void _confirmDeleteGroup(CategoryGroup group) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    NeoAlertDialog.show(
      context: context,
      title: isAr ? 'حذف المجموعة' : 'Delete Group',
      message: isAr
          ? 'هل أنت متأكد من حذف "${group.name}"؟ الفئات التابعة لها لن تُحذف وستصبح غير مصنفة.'
          : 'Are you sure you want to delete "${group.name}"? Its categories will not be deleted and will become ungrouped.',
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
            await _loadData(silent: true);
            if (!mounted) return;
            MessageService.showSuccess(
              context: context,
              message: isAr ? 'تم حذف المجموعة' : 'Group deleted',
            );
          },
        ),
      ],
    );
  }

  Future<void> _showCategorySheet(
    bool isDarkMode, {
    Category? categoryToEdit,
  }) async {
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
    final initialGroupId = categoryToEdit != null
        ? _categoryGroupMap[categoryToEdit.id]
        : null;

    await CategoriesManagementScreen._presentCategoryModal(
      context: context,
      isDarkMode: isDarkMode,
      categoryToEdit: categoryToEdit,
      initialName: initialName,
      initialIconIndex: initialIconIndex,
      initialIcon: initialIcon,
      expenseCount: expenseCount,
      availableGroups: _groups,
      initialGroupId: initialGroupId,
      onSave: (name, iconIndex, selectedGroupId, sheetContext) {
        if (categoryToEdit != null) {
          _submitEditCategory(
            category: categoryToEdit,
            name: name,
            iconIndex: iconIndex,
            groupId: selectedGroupId,
            bottomSheetContext: sheetContext,
          );
        } else {
          _submitNewCategory(
            name: name,
            iconIndex: iconIndex,
            groupId: selectedGroupId,
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
    String? groupId,
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
      final created = await _categoryRepository.createCategory(
        trimmedName,
        trimmedName,
      );
      if (iconIndex >= 0 && iconIndex < _availableCategoryIcons.length) {
        final icon = _availableCategoryIcons[iconIndex];
        _categoryCustomIcons[created.id] = icon;
        CategoryIconHelper.setCustomIcon(created.id, icon);
      }
      if (groupId != null) {
        await CategoryGroupService.assignCategoryToGroup(created.id, groupId);
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
      MessageService.showError(context: context, message: e.toString());
    }
  }

  Future<void> _submitEditCategory({
    required Category category,
    required String name,
    required int iconIndex,
    required BuildContext bottomSheetContext,
    String? groupId,
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
      await _categoryRepository.updateCategory(
        category.id,
        trimmedName,
        trimmedName,
      );
      if (iconIndex >= 0 && iconIndex < _availableCategoryIcons.length) {
        final icon = _availableCategoryIcons[iconIndex];
        _categoryCustomIcons[category.id] = icon;
        CategoryIconHelper.setCustomIcon(category.id, icon);
      }
      await CategoryGroupService.assignCategoryToGroup(category.id, groupId);
      await _loadData(silent: true);
      if (bottomSheetContext.mounted) {
        Navigator.pop(bottomSheetContext);
      }
      if (!mounted) return;
      final isAr = Directionality.of(context) == TextDirection.rtl;
      MessageService.showSuccess(
        context: context,
        message: isAr
            ? 'تم تعديل التصنيف بنجاح'
            : 'Category updated successfully',
      );
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(context: context, message: e.toString());
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
      await CategoryGroupService.deleteCategoryAssignment(category.id);
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
      MessageService.showError(context: context, message: e.toString());
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
              await CategoryGroupService.deleteCategoryAssignment(category.id);
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
              MessageService.showError(context: context, message: e.toString());
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
    final bgColor = isDarkMode
        ? const Color(0xFF09090B)
        : const Color(0xFFF8F8FA);
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? const Color(0xFF27272A)
        : const Color(0xFFE4E4E7);
    final dividerColor = isDarkMode
        ? const Color(0xFF27272A)
        : const Color(0xFFF1F1F5);
    final chevronColor = isDarkMode
        ? const Color(0xFF52525B)
        : const Color(0xFFD4D4D8);

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

      if (_groups.isEmpty) ...[
        // Categories Card Group or Authentic Empty State (When user has no groups)
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
          _buildCategoriesCard(
            categories,
            isDarkMode: isDarkMode,
            cardBg: cardBg,
            borderColor: borderColor,
            chevronColor: chevronColor,
            dividerColor: dividerColor,
            isRtl: isRtl,
          ),
      ] else ...[
        // Grouped mode (When user has created one or more groups)
        for (final group in _groups) ...[
          Builder(
            builder: (context) {
              final groupCats = categories
                  .where((c) => _categoryGroupMap[c.id] == group.id)
                  .toList();
              final icon =
                  (group.iconIndex >= 0 &&
                      group.iconIndex < _availableCategoryIcons.length)
                  ? _availableCategoryIcons[group.iconIndex]
                  : Icons.folder_rounded;
              final isCollapsed = _collapsedGroupIds.contains(group.id);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Header
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 6,
                      end: 4,
                      top: 14,
                      bottom: 8,
                    ),
                    child: Row(
                      children: [
                        // Leading: Icon + Group Name + Collapse Indicator (tappable to collapse/expand)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
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
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: group.color.withValues(
                                      alpha: isDarkMode ? 0.22 : 0.14,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: group.color.withValues(
                                        alpha: 0.50,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      icon,
                                      size: 15,
                                      color: group.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    group.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      color: isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF09090B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AnimatedRotation(
                                  turns: isCollapsed
                                      ? (isRtl ? 0.25 : -0.25)
                                      : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: Icon(
                                    CupertinoIcons.chevron_down,
                                    size: 13,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Far right: Count badge
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(
                                      0xFF09090B,
                                    ).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isRtl
                                  ? '${groupCats.length} ${groupCats.length == 1 ? 'فئة' : 'فئات'}'
                                  : '${groupCats.length} ${groupCats.length == 1 ? 'category' : 'categories'}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // 3-dots button on far right
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              _showGroupOptionsMenu(context, group, isDarkMode),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : const Color(
                                      0xFF09090B,
                                    ).withValues(alpha: 0.04),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.more_horiz_rounded,
                                size: 18,
                                color: isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Collapsible Categories Card
                  AnimatedCrossFade(
                    firstChild: const SizedBox(
                      width: double.infinity,
                      height: 0,
                    ),
                    secondChild: _buildCategoriesCard(
                      groupCats,
                      isDarkMode: isDarkMode,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      chevronColor: chevronColor,
                      dividerColor: dividerColor,
                      isRtl: isRtl,
                      emptyMessage: isRtl
                          ? 'لا توجد فئات في هذه المجموعة بعد'
                          : 'No categories in this group yet',
                    ),
                    crossFadeState: isCollapsed
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 220),
                    sizeCurve: Curves.easeInOutCubic,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
        ],

        // Ungrouped Section
        Builder(
          builder: (context) {
            final ungroupedCats = categories
                .where((c) => _categoryGroupMap[c.id] == null)
                .toList();
            final isUngroupedCollapsed = _collapsedGroupIds.contains(
              'ungrouped',
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 6,
                    end: 4,
                    top: 10,
                    bottom: 8,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isUngroupedCollapsed) {
                          _collapsedGroupIds.remove('ungrouped');
                        } else {
                          _collapsedGroupIds.add('ungrouped');
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: (isDarkMode ? Colors.white : Colors.black)
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.square_stack_3d_down_dottedline,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            isRtl ? 'غير مصنفة' : 'Ungrouped',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF09090B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: isUngroupedCollapsed
                              ? (isRtl ? 0.25 : -0.25)
                              : 0.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: Icon(
                            CupertinoIcons.chevron_down,
                            size: 13,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(
                                    0xFF09090B,
                                  ).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isRtl
                                ? '${ungroupedCats.length} ${ungroupedCats.length == 1 ? 'فئة' : 'فئات'}'
                                : '${ungroupedCats.length} ${ungroupedCats.length == 1 ? 'category' : 'categories'}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: _buildCategoriesCard(
                    ungroupedCats,
                    isDarkMode: isDarkMode,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    chevronColor: chevronColor,
                    dividerColor: dividerColor,
                    isRtl: isRtl,
                    emptyMessage: isRtl
                        ? 'جميع الفئات مصنفة ضمن مجموعات'
                        : 'All categories are organized in groups',
                  ),
                  crossFadeState: isUngroupedCollapsed
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 220),
                  sizeCurve: Curves.easeInOutCubic,
                ),
              ],
            );
          },
        ),
      ],
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
            final incomingX = isAr
                ? (1.0 - curve) * 60.0
                : -(1.0 - curve) * 60.0;
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
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF09090B),
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
          Platform.isIOS
              ? _buildIosTopActions(isDarkMode, isRtl)
              : _buildAndroidTopActions(isDarkMode, isRtl, borderColor),
        ],
      ),
      body: _isLoading
          ? const Center(child: AppProgressIndicator())
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

  Widget _buildIosTopActions(bool isDarkMode, bool isRtl) {
    final iconColor = isDarkMode ? Colors.white : const Color(0xFF09090B);

    final sortOptions = <_SortOption>[
      _SortOption(
        id: 'default',
        title: isRtl ? 'الترتيب الافتراضي' : 'Default order',
        icon: CupertinoIcons.list_bullet,
        iconSystemName: 'list.bullet',
      ),
      _SortOption(
        id: 'mostUsed',
        title: isRtl ? 'الأكثر استخدامًا' : 'Most used',
        icon: CupertinoIcons.arrow_down,
        iconSystemName: 'arrow.down',
      ),
      _SortOption(
        id: 'leastUsed',
        title: isRtl ? 'الأقل استخدامًا' : 'Least used',
        icon: CupertinoIcons.arrow_up,
        iconSystemName: 'arrow.up',
      ),
      _SortOption(
        id: 'az',
        title: isRtl ? 'أبجديًا' : 'A → Z',
        icon: CupertinoIcons.textformat,
        iconSystemName: 'textformat',
      ),
    ];

    final sortActions = <IosContextMenuItem>[
      for (final option in sortOptions)
        IosContextMenuAction(
          id: option.id,
          title: option.title,
          iconSystemName: option.iconSystemName,
          icon: option.icon,
          showTrailingCheckmark: _sortMode == option.id,
        ),
    ];

    final addActions = <IosContextMenuItem>[
      IosContextMenuAction(
        id: 'new_category',
        title: isRtl ? 'تصنيف جديد' : 'New Category',
        iconSystemName: 'folder.badge.plus',
        icon: CupertinoIcons.folder_badge_plus,
      ),
      IosContextMenuAction(
        id: 'new_group',
        title: isRtl ? 'مجموعة جديدة' : 'New Group',
        iconSystemName: 'rectangle.stack.badge.plus',
        icon: CupertinoIcons.rectangle_stack_badge_plus,
      ),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: GlassButton.custom(
          height: 44,
          shape: const LiquidRoundedRectangle(borderRadius: 22),
          useOwnLayer: true,
          quality: GlassQuality.premium,
          canRequestFocus: false,
          excludeFromSemantics: true,
          stretch: 0.35,
          settings: isDarkMode
              ? LiquidGlassSettings.ios27Dark
              : LiquidGlassSettings.ios27Light,
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sort Button with Context Menu
              IosSingleTapContextMenu(
                actions: sortActions,
                onSelected: (id) {
                  HapticFeedback.selectionClick();
                  setState(() => _sortMode = id);
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(
                      Icons.swap_vert_rounded,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                ),
              ),

              // Add Button with Context Menu
              IosSingleTapContextMenu(
                actions: addActions,
                onSelected: (id) {
                  HapticFeedback.selectionClick();
                  if (id == 'new_category') {
                    _showAddCategorySheet(isDarkMode);
                  } else if (id == 'new_group') {
                    _showAddGroupSheet(isDarkMode);
                  }
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.only(left: 12, right: 16),
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(Icons.add_rounded, size: 22, color: iconColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidTopActions(
    bool isDarkMode,
    bool isRtl,
    Color borderColor,
  ) {
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final iconColor = isDarkMode ? Colors.white : const Color(0xFF09090B);

    final sortOptions = <_SortOption>[
      _SortOption(
        id: 'default',
        title: isRtl ? 'الترتيب الافتراضي' : 'Default order',
        icon: CupertinoIcons.list_bullet,
      ),
      _SortOption(
        id: 'mostUsed',
        title: isRtl ? 'الأكثر استخدامًا' : 'Most used',
        icon: CupertinoIcons.arrow_down,
      ),
      _SortOption(
        id: 'leastUsed',
        title: isRtl ? 'الأقل استخدامًا' : 'Least used',
        icon: CupertinoIcons.arrow_up,
      ),
      _SortOption(
        id: 'az',
        title: isRtl ? 'أبجديًا' : 'A → Z',
        icon: CupertinoIcons.textformat,
      ),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sort Button with popup menu
              PopupMenuButton<String>(
                tooltip: isRtl ? 'ترتيب' : 'Sort',
                onSelected: (id) {
                  HapticFeedback.selectionClick();
                  setState(() => _sortMode = id);
                },
                color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                itemBuilder: (context) => [
                  for (final option in sortOptions)
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
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: iconColor,
                            ),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Center(
                    child: Icon(
                      Icons.swap_vert_rounded,
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                ),
              ),

              // Add Button with popup menu
              PopupMenuButton<String>(
                tooltip: isRtl ? 'إضافة' : 'Add',
                onSelected: (id) {
                  HapticFeedback.selectionClick();
                  if (id == 'new_category') {
                    _showAddCategorySheet(isDarkMode);
                  } else if (id == 'new_group') {
                    _showAddGroupSheet(isDarkMode);
                  }
                },
                color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'new_category',
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 18,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF09090B),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isRtl ? 'تصنيف جديد' : 'New Category',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF09090B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'new_group',
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_copy_rounded,
                          size: 18,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF09090B),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isRtl ? 'مجموعة جديدة' : 'New Group',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF09090B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.only(left: 10, right: 14),
                  child: Center(
                    child: Icon(Icons.add_rounded, size: 20, color: iconColor),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.06),
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
              keyboardAppearance: isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white : const Color(0xFF09090B),
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

  Widget _buildCategoriesCard(
    List<Category> categoriesList, {
    required bool isDarkMode,
    required Color cardBg,
    required Color borderColor,
    required Color chevronColor,
    required Color dividerColor,
    required bool isRtl,
    String? emptyMessage,
  }) {
    if (categoriesList.isEmpty) {
      if (emptyMessage == null) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? const Color(0xFF71717A)
                  : const Color(0xFFA1A1AA),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (int i = 0; i < categoriesList.length; i++) ...[
              _buildCategoryRow(
                categoriesList[i],
                isDarkMode: isDarkMode,
                cardBg: cardBg,
                chevronColor: chevronColor,
                isRtl: isRtl,
              ),
              if (i < categoriesList.length - 1)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 70, end: 16),
                  child: Divider(height: 1, thickness: 1, color: dividerColor),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    Category cat, {
    required bool isDarkMode,
    required Color cardBg,
    required Color chevronColor,
    required bool isRtl,
  }) {
    final catName = isRtl ? cat.nameAr : cat.nameEn;
    final meta = CategoryIconHelper.getMeta(cat.id, catName);
    final catIcon = _categoryCustomIcons[cat.id] ?? meta.icon;
    final count = _categoryExpenseCounts[cat.id] ?? 0;
    final countLabel = context.l10n.categoryExpensesCount(count);

    return Slidable(
      key: ValueKey('cat_${cat.id}'),
      groupTag: 'categories_group',
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) {
              HapticFeedback.selectionClick();
              _showCategorySheet(isDarkMode, categoryToEdit: cat);
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
            _showCategorySheet(isDarkMode, categoryToEdit: cat);
          },
          splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
          splashColor: Platform.isIOS
              ? Colors.transparent
              : (isDarkMode ? Colors.white : Colors.black).withValues(
                  alpha: 0.04,
                ),
          highlightColor: (isDarkMode ? Colors.white : Colors.black).withValues(
            alpha: 0.02,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    borderRadius: BorderRadius.circular(12),
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
                    color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Counts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                Icon(appForwardIconOf(context), size: 13, color: chevronColor),
              ],
            ),
          ),
        ),
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
  final List<CategoryGroup> availableGroups;
  final String? initialGroupId;
  final void Function(String name, int iconIndex, String? groupId) onSave;
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
    this.availableGroups = const [],
    this.initialGroupId,
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
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    final icons = CategoriesManagementScreen.availableCategoryIcons;
    _selectedIconIndex =
        (widget.initialIconIndex >= 0 && widget.initialIconIndex < icons.length)
        ? widget.initialIconIndex
        : 0;
    _selectedIcon =
        widget.initialIcon ??
        (icons.isNotEmpty ? icons[_selectedIconIndex] : Icons.category_rounded);
    _selectedGroupId = widget.initialGroupId;
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
    final RenderBox? renderBox = btnContext.findRenderObject() as RenderBox?;
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
    final themeColor = widget.isDarkMode
        ? Colors.white
        : const Color(0xFF09090B);
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
        viewInsetsBottom > 0 ? viewInsetsBottom + 36 : safeAreaBottom + 36,
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
                  color: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[300],
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
                              borderRadius: 21,
                            ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                _nameController.text,
                                _selectedIconIndex,
                                _selectedGroupId,
                              );
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
                                _nameController.text,
                                _selectedIconIndex,
                                _selectedGroupId,
                              );
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
                          border: Border.all(color: avatarBorder, width: 1.2),
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
                                ScaleTransition(scale: anim, child: child),
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
            keyboardAppearance: widget.isDarkMode
                ? Brightness.dark
                : Brightness.light,
            cursorColor: themeColor,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : const Color(0xFF09090B),
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
                horizontal: 16,
                vertical: 14,
              ),
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

          // Group Selector (Only visible if the user has created at least one group)
          if (widget.availableGroups.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              isAr ? 'المجموعة' : 'Group',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode
                    ? const Color(0xFFD4D4D8)
                    : const Color(0xFF71717A),
              ),
            ),
            const SizedBox(height: 6),
            _buildGroupPicker(context, isAr, fieldBg, themeColor),
          ],

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
      child: SafeArea(top: false, child: sheetContent),
    );
  }

  IconData _iconForGroup(CategoryGroup group) {
    final icons = CategoriesManagementScreen.availableCategoryIcons;
    if (group.iconIndex >= 0 && group.iconIndex < icons.length) {
      return icons[group.iconIndex];
    }
    return CupertinoIcons.folder_fill;
  }

  String _sfSymbolForGroup(CategoryGroup group) {
    final icon = _iconForGroup(group);
    return CategoriesManagementScreen.sfSymbolForIcon(icon);
  }

  Widget _buildGroupPicker(
    BuildContext context,
    bool isAr,
    Color fieldBg,
    Color themeColor,
  ) {
    CategoryGroup? currentGroup;
    if (_selectedGroupId != null) {
      for (final g in widget.availableGroups) {
        if (g.id == _selectedGroupId) {
          currentGroup = g;
          break;
        }
      }
    }

    final displayText = currentGroup != null
        ? currentGroup.name
        : (isAr ? 'بدون مجموعة' : 'No group');

    if (Platform.isIOS) {
      final menuActions = <IosContextMenuItem>[
        IosContextMenuAction(
          id: 'none',
          title: isAr ? 'بدون مجموعة' : 'No group',
          iconSystemName: null,
          icon: null,
          showTrailingCheckmark: _selectedGroupId == null,
        ),
        for (final g in widget.availableGroups)
          IosContextMenuAction(
            id: g.id,
            title: g.name,
            iconSystemName: _sfSymbolForGroup(g),
            icon: _iconForGroup(g),
            showTrailingCheckmark: _selectedGroupId == g.id,
          ),
      ];

      return IosSingleTapContextMenu(
        actions: menuActions,
        onSelected: (id) {
          widget.focusNode.unfocus();
          HapticFeedback.selectionClick();
          setState(() {
            _selectedGroupId = id == 'none' ? null : id;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isDarkMode
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFE4E4E7),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_up_chevron_down,
                size: 15,
                color: widget.isDarkMode
                    ? const Color(0xFF71717A)
                    : const Color(0xFFA1A1AA),
              ),
            ],
          ),
        ),
      );
    }

    // Android Dropdown
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFE4E4E7),
          width: 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: widget.availableGroups.any((g) => g.id == _selectedGroupId)
              ? _selectedGroupId
              : null,
          isExpanded: true,
          dropdownColor: widget.isDarkMode
              ? const Color(0xFF1E1E22)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          icon: Icon(Icons.arrow_drop_down_rounded, color: themeColor),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                isAr ? 'بدون مجموعة' : 'No group',
                style: TextStyle(
                  color: themeColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final g in widget.availableGroups)
              DropdownMenuItem<String?>(
                value: g.id,
                child: Row(
                  children: [
                    Icon(
                      _iconForGroup(g),
                      size: 18,
                      color: Color(g.colorValue),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      g.name,
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: (val) {
            setState(() => _selectedGroupId = val);
          },
        ),
      ),
    );
  }
}

class _GroupModalContent extends StatefulWidget {
  final bool isDarkMode;
  final GlassModalSheetController? controller;
  final FocusNode focusNode;
  final bool isGlass;
  final CategoryGroup? groupToEdit;
  final String initialName;
  final int initialColorValue;
  final int initialIconIndex;
  final void Function(String name, int colorValue, int iconIndex) onSave;
  final VoidCallback? onDelete;

  const _GroupModalContent({
    required this.isDarkMode,
    this.controller,
    required this.focusNode,
    this.isGlass = false,
    this.groupToEdit,
    required this.initialName,
    required this.initialColorValue,
    required this.initialIconIndex,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_GroupModalContent> createState() => _GroupModalContentState();
}

class _GroupModalContentState extends State<_GroupModalContent>
    with WidgetsBindingObserver {
  late final TextEditingController _nameController;
  late int _selectedColorValue;
  late int _selectedIconIndex;
  late IconData _selectedIcon;
  bool _wasKeyboardOpen = false;

  static const List<int> _paletteColors = [
    0xFF3B82F6, // Blue
    0xFF10B981, // Emerald
    0xFFF59E0B, // Amber
    0xFFEF4444, // Red
    0xFF8B5CF6, // Purple
    0xFFEC4899, // Pink
    0xFF06B6D4, // Cyan
    0xFF14B8A6, // Teal
    0xFF6366F1, // Indigo
    0xFFF97316, // Orange
    0xFF84CC16, // Lime
    0xFF64748B, // Slate
  ];

  @override
  void initState() {
    super.initState();
    final icons = CategoriesManagementScreen.availableCategoryIcons;
    _selectedIconIndex =
        (widget.initialIconIndex >= 0 && widget.initialIconIndex < icons.length)
        ? widget.initialIconIndex
        : 0;
    _selectedIcon = (icons.isNotEmpty)
        ? icons[_selectedIconIndex]
        : CupertinoIcons.folder_fill;
    _selectedColorValue = widget.initialColorValue;
    _nameController = TextEditingController(text: widget.initialName);
    if (widget.initialName.isNotEmpty) {
      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _nameController.text.length),
      );
    }
    WidgetsBinding.instance.addObserver(this);
    widget.focusNode.addListener(_handleFocusChange);

    if (widget.groupToEdit == null) {
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
    final RenderBox? renderBox = btnContext.findRenderObject() as RenderBox?;
    final picked = await showAppIconPicker(
      context,
      widgetRenderBox: renderBox,
      selectedIcon: _selectedIcon,
      isDarkMode: widget.isDarkMode,
      isAr: isAr,
      title: isAr ? 'أيقونة المجموعة' : 'Group Icon',
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
    final groupName = widget.groupToEdit?.name ?? '';

    NeoAlertDialog.show(
      context: context,
      title: isAr ? 'حذف المجموعة' : 'Delete Group',
      message: isAr
          ? 'هل أنت متأكد من حذف "$groupName"؟ الفئات التابعة لها لن تُحذف وستصبح غير مصنفة.'
          : 'Are you sure you want to delete "$groupName"? Its categories will not be deleted and will become ungrouped.',
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
    final themeColor = widget.isDarkMode
        ? Colors.white
        : const Color(0xFF09090B);
    final fieldBg = widget.isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF4F4F5);
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final currentColor = Color(_selectedColorValue);

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
        viewInsetsBottom > 0 ? viewInsetsBottom + 36 : safeAreaBottom + 36,
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
                  color: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // Header Bar
          SizedBox(
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  widget.groupToEdit != null
                      ? (isAr ? 'تعديل المجموعة' : 'Edit Group')
                      : (isAr ? 'مجموعة جديدة' : 'New Group'),
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
                              borderRadius: 21,
                            ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                _nameController.text,
                                _selectedColorValue,
                                _selectedIconIndex,
                              );
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
                                _nameController.text,
                                _selectedColorValue,
                                _selectedIconIndex,
                              );
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

          // Hero Icon Squircle Avatar with Color Accent
          Builder(
            builder: (btnContext) {
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
                          color: currentColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: currentColor.withValues(alpha: 0.40),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: currentColor.withValues(alpha: 0.20),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              _selectedIcon,
                              key: ValueKey(_selectedIcon.codePoint),
                              size: 38,
                              color: currentColor,
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

          const SizedBox(height: 24),

          // Group Name Label
          Text(
            isAr ? 'اسم المجموعة' : 'Group Name',
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
            autofocus: widget.groupToEdit == null,
            keyboardAppearance: widget.isDarkMode
                ? Brightness.dark
                : Brightness.light,
            cursorColor: themeColor,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : const Color(0xFF09090B),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: isAr
                  ? 'مثال: الاحتياجات اليومية، التزامات شهرية...'
                  : 'e.g. Daily Essentials, Fixed Bills...',
              hintStyle: TextStyle(
                color: widget.isDarkMode
                    ? const Color(0xFF71717A)
                    : const Color(0xFFA1A1AA),
                fontSize: 14,
              ),
              filled: true,
              fillColor: fieldBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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

          const SizedBox(height: 20),

          // Color Palette Label (Under the Name input)
          Text(
            isAr ? 'لون المجموعة' : 'Group Color',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode
                  ? const Color(0xFFD4D4D8)
                  : const Color(0xFF71717A),
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal Color Palette
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _paletteColors.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final colorVal = _paletteColors[index];
                final isSelected = colorVal == _selectedColorValue;
                final col = Color(colorVal);

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedColorValue = colorVal);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: col,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF09090B),
                              width: 2.5,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: col.withValues(alpha: 0.40),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Explanatory Note Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: (widget.isDarkMode ? Colors.white : Colors.black)
                  .withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (widget.isDarkMode ? Colors.white : Colors.black)
                    .withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.info_circle_fill,
                  size: 18,
                  color: currentColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isAr
                        ? 'المجموعة تجمع عدة فئات معاً، وفي شاشة الميزانيات تظهر إجمالي كل شيء لتسهيل متابعة مصاريفك.'
                        : 'A group holds categories together. On the budgets screen, it shows the total of everything to give you a clear overview.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: widget.isDarkMode
                          ? const Color(0xFFA1A1AA)
                          : const Color(0xFF71717A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit Mode: Delete Group Button
          if (widget.groupToEdit != null) ...[
            const SizedBox(height: 22),
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
                      isAr ? 'حذف المجموعة' : 'Delete Group',
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
      child: SafeArea(top: false, child: sheetContent),
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
  const _SortOption({
    required this.id,
    required this.title,
    required this.icon,
    this.iconSystemName,
  });

  final String id;
  final String title;
  final IconData icon;
  final String? iconSystemName;
}
