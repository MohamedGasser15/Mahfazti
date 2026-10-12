import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/utils/navigation_service.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/wallet/data/models/category_model.dart';
import 'package:my_wallet/features/wallet/presentation/utils/category_icon_helper.dart';

class CategoriesManagementScreen extends StatefulWidget {
  const CategoriesManagementScreen({super.key});

  static const availableCategoryIcons = <IconData>[
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

  static Future<void> showAddCategoryModal({
    required BuildContext context,
    required bool isDarkMode,
    required void Function(String name, int iconIndex, BuildContext sheetContext) onSave,
  }) async {
    final focusNode = FocusNode();

    NavigationService.isModalOpenNotifier.value = true;
    try {
      if (Platform.isIOS) {
        final sheetController = GlassModalSheetController();
        final glassSettings = isDarkMode
            ? const LiquidGlassSettings(
                thickness: 20,
                blur: 28,
                glassColor: Color(0x661E1E26),
                refractiveIndex: 1.18,
                lightIntensity: 0.90,
                whitenStrength: 0.08,
              )
            : const LiquidGlassSettings(
                thickness: 18,
                blur: 24,
                glassColor: Color(0xCCFFFFFF),
                refractiveIndex: 1.12,
                whitenStrength: 0.15,
              );

        await GlassModalSheet.show(
          context: context,
          useRootNavigator: true,
          platformViewBackdrop: true,
          controller: sheetController,
          initialState: GlassSheetState.half,
          halfSize: 0.69,
          fullSize: 0.87,
          detents: const {GlassSheetDetent.medium, GlassSheetDetent.large},
          horizontalMargin: 5.0,
          bottomMargin: 6.0,
          topBorderRadius: 38.0,
          bottomBorderRadius: 38.0,
          fullTopBorderRadius: 24.0,
          fullBottomBorderRadius: 0.0,
          showDragIndicator: true,
          dragIndicatorColor: isDarkMode
              ? Colors.white.withValues(alpha: 0.35)
              : const Color(0x33000000),
          barrierColor: isDarkMode
              ? const Color(0x80000000)
              : const Color(0x33000000),
          enableInteractionGlow: false,
          enableSaturationGlow: false,
          fillThreshold: 1.0,
          expandedColor: Colors.transparent,
          expandedDarkColor: Colors.transparent,
          settings: glassSettings,
          halfSettings: glassSettings,
          fullSettings: glassSettings,
          onStateChanged: (state) {
            if (state == GlassSheetState.half) {
              focusNode.unfocus();
            }
          },
          builder: (sheetContext) {
            return Material(
              type: MaterialType.transparency,
              child: _CategoryModalContent(
                isDarkMode: isDarkMode,
                controller: sheetController,
                focusNode: focusNode,
                isGlass: true,
                initialName: '',
                initialIconIndex: 0,
                onSave: (name, iconIndex) {
                  onSave(name, iconIndex, sheetContext);
                },
              ),
            );
          },
        );
      } else {
        await showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return _CategoryModalContent(
              isDarkMode: isDarkMode,
              controller: null,
              focusNode: focusNode,
              isGlass: false,
              initialName: '',
              initialIconIndex: 0,
              onSave: (name, iconIndex) {
                onSave(name, iconIndex, sheetContext);
              },
            );
          },
        );
      }
    } finally {
      NavigationService.isModalOpenNotifier.value = false;
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        1: 8, // 8 expenses
        2: 5, // 5 expenses
        3: 12, // 12 expenses
        4: 3, // 3 expenses
        5: 6, // 6 expenses
        6: 9, // 9 expenses
        7: 2, // 2 expenses
        8: 1, // 1 expense
        9: 4, // 4 expenses
        10: 0, // 0 -> hidden!
        11: 1, // 1 expense
        12: 3, // 3 expenses
        13: 0, // 0 -> hidden!
        14: 2, // 2 expenses
        15: 0, // 0 -> hidden!
        16: 2, // 2 expenses
        17: 1, // 1 expense
        18: 0, // 0 -> hidden!
        19: 0, // 0 -> hidden!
        20: 0, // 0 -> hidden!
      };

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Simulate slight instant load for smooth UX
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() {
      _categories = _defaultSeedCategories;
      _categoryExpenseCounts = Map.from(_defaultSeedCounts);
      _isLoading = false;
    });
  }

  List<Category> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) {
      return _categories;
    }
    final q = _searchQuery.trim().toLowerCase();
    return _categories.where((cat) {
      return cat.nameAr.toLowerCase().contains(q) ||
          cat.nameEn.toLowerCase().contains(q);
    }).toList();
  }

  static List<IconData> get _availableCategoryIcons =>
      CategoriesManagementScreen.availableCategoryIcons;

  void _showAddCategorySheet(bool isDarkMode) => _showCategorySheet(isDarkMode);

  Future<void> _showCategorySheet(bool isDarkMode, {Category? categoryToEdit}) async {
    final focusNode = FocusNode();

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

    NavigationService.isModalOpenNotifier.value = true;
    try {
      if (Platform.isIOS) {
        final sheetController = GlassModalSheetController();
        final glassSettings = isDarkMode
            ? const LiquidGlassSettings(
                thickness: 20,
                blur: 28,
                glassColor: Color(0x661E1E26),
                refractiveIndex: 1.18,
                lightIntensity: 0.90,
                whitenStrength: 0.08,
              )
            : const LiquidGlassSettings(
                thickness: 18,
                blur: 24,
                glassColor: Color(0xCCFFFFFF),
                refractiveIndex: 1.12,
                whitenStrength: 0.15,
              );

        await GlassModalSheet.show(
          context: context,
          useRootNavigator: true,
          platformViewBackdrop: true,
          controller: sheetController,
          initialState: GlassSheetState.half,
          halfSize: 0.69,
          fullSize: 0.87,
          detents: const {GlassSheetDetent.medium, GlassSheetDetent.large},
          horizontalMargin: 5.0,
          bottomMargin: 6.0,
          topBorderRadius: 38.0,
          bottomBorderRadius: 38.0,
          fullTopBorderRadius: 24.0,
          fullBottomBorderRadius: 0.0,
          showDragIndicator: true,
          dragIndicatorColor: isDarkMode
              ? Colors.white.withValues(alpha: 0.35)
              : const Color(0x33000000),
          barrierColor: isDarkMode
              ? const Color(0x80000000)
              : const Color(0x33000000),
          enableInteractionGlow: false,
          enableSaturationGlow: false,
          fillThreshold: 1.0,
          expandedColor: Colors.transparent,
          expandedDarkColor: Colors.transparent,
          settings: glassSettings,
          halfSettings: glassSettings,
          fullSettings: glassSettings,
          onStateChanged: (state) {
            if (state == GlassSheetState.half) {
              focusNode.unfocus();
            }
          },
          builder: (sheetContext) {
            return Material(
              type: MaterialType.transparency,
              child: _CategoryModalContent(
                isDarkMode: isDarkMode,
                controller: sheetController,
                focusNode: focusNode,
                isGlass: true,
                categoryToEdit: categoryToEdit,
                initialName: initialName,
                initialIconIndex: initialIconIndex >= 0 ? initialIconIndex : 0,
                expenseCount: expenseCount,
                onSave: (name, iconIndex) {
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
                    ? () {
                        _submitDeleteCategory(
                          category: categoryToEdit,
                          bottomSheetContext: sheetContext,
                        );
                      }
                    : null,
              ),
            );
          },
        );
      } else {
        await showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return _CategoryModalContent(
              isDarkMode: isDarkMode,
              controller: null,
              focusNode: focusNode,
              isGlass: false,
              categoryToEdit: categoryToEdit,
              initialName: initialName,
              initialIconIndex: initialIconIndex >= 0 ? initialIconIndex : 0,
              expenseCount: expenseCount,
              onSave: (name, iconIndex) {
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
                  ? () {
                      _submitDeleteCategory(
                        category: categoryToEdit,
                        bottomSheetContext: sheetContext,
                      );
                    }
                  : null,
            );
          },
        );
      }
    } finally {
      NavigationService.isModalOpenNotifier.value = false;
    }
  }

  void _submitNewCategory({
    required String name,
    required int iconIndex,
    required BuildContext bottomSheetContext,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      MessageService.showWarning(
        context: context,
        message: context.l10n.pleaseEnterCategoryName,
      );
      return;
    }

    final maxId = _categories.fold<int>(0, (m, c) => c.id > m ? c.id : m);
    final newId = maxId + 1;
    final newCat = Category(
      id: newId,
      nameAr: trimmedName,
      nameEn: trimmedName,
      createdAt: DateTime.now(),
    );

    setState(() {
      _categories = [newCat, ..._categories];
      _categoryExpenseCounts[newId] = 0;
      if (iconIndex >= 0 && iconIndex < _availableCategoryIcons.length) {
        _categoryCustomIcons[newId] = _availableCategoryIcons[iconIndex];
      }
    });
    if (bottomSheetContext.mounted) {
      Navigator.pop(bottomSheetContext);
    }
    MessageService.showSuccess(
      context: context,
      message: context.l10n.categoryAddedSuccess,
    );
  }

  void _submitEditCategory({
    required Category category,
    required String name,
    required int iconIndex,
    required BuildContext bottomSheetContext,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      MessageService.showWarning(
        context: context,
        message: context.l10n.pleaseEnterCategoryName,
      );
      return;
    }

    setState(() {
      _categories = _categories.map((c) {
        if (c.id == category.id) {
          return Category(
            id: c.id,
            nameAr: trimmedName,
            nameEn: trimmedName,
            createdAt: c.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return c;
      }).toList();

      if (iconIndex >= 0 && iconIndex < _availableCategoryIcons.length) {
        _categoryCustomIcons[category.id] = _availableCategoryIcons[iconIndex];
      }
    });

    if (bottomSheetContext.mounted) {
      Navigator.pop(bottomSheetContext);
    }
    final isAr = Directionality.of(context) == TextDirection.rtl;
    MessageService.showSuccess(
      context: context,
      message: isAr ? 'تم تعديل التصنيف بنجاح' : 'Category updated successfully',
    );
  }

  void _submitDeleteCategory({
    required Category category,
    required BuildContext bottomSheetContext,
  }) {
    setState(() {
      _categories = _categories.where((c) => c.id != category.id).toList();
      _categoryExpenseCounts.remove(category.id);
      _categoryCustomIcons.remove(category.id);
    });

    if (bottomSheetContext.mounted) {
      Navigator.pop(bottomSheetContext);
    }
    final isAr = Directionality.of(context) == TextDirection.rtl;
    MessageService.showSuccess(
      context: context,
      message: isAr
          ? 'تم حذف التصنيف بنجاح'
          : 'Category deleted successfully',
    );
  }

  void _confirmDeleteCategoryFromList(Category category) {
    HapticFeedback.mediumImpact();
    final count = _categoryExpenseCounts[category.id] ?? 0;
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final catName = isAr ? category.nameAr : category.nameEn;

    showCupertinoDialog<void>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text(
          isAr ? 'حذف التصنيف' : 'Delete Category',
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            count > 0
                ? (isAr
                    ? 'هل أنت متأكد من حذف "$catName"؟ هذا التصنيف مرتبط بـ $count ${count == 1 ? 'معاملة' : 'معاملات'} وستصبح هذه المعاملات بدون تصنيف.'
                    : 'Are you sure you want to delete "$catName"? This category has $count linked ${count == 1 ? 'expense' : 'expenses'} that will become uncategorized.')
                : (isAr
                    ? 'هل أنت متأكد من حذف "$catName"؟'
                    : 'Are you sure you want to delete "$catName"?'),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(context.l10n.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              setState(() {
                _categories =
                    _categories.where((c) => c.id != category.id).toList();
                _categoryExpenseCounts.remove(category.id);
                _categoryCustomIcons.remove(category.id);
              });
              MessageService.showSuccess(
                context: context,
                message: isAr
                    ? 'تم حذف التصنيف بنجاح'
                    : 'Category deleted successfully',
              );
            },
            child: Text(
              isAr ? 'حذف' : 'Delete',
            ),
          ),
        ],
      ),
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          context.l10n.manageCategories,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: isDarkMode ? Colors.white : const Color(0xFF09090B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const AppGlassBackButton(),
        actions: [
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
                ListView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: Platform.isIOS
                        ? MediaQuery.of(context).padding.bottom + 84
                        : MediaQuery.of(context).padding.bottom + 24,
                  ),
                  children: [
                    // Top Search Bar (Android only)
                    if (!Platform.isIOS) ...[
                      _buildAndroidSearchBar(
                        isDarkMode: isDarkMode,
                        cardBg: cardBg,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Categories Card Group
                    if (categories.isEmpty)
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
                            context.l10n.noCategoriesFound,
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
                  else
                    Builder(
                      builder: (context) {
                        const double cardRadius = 18.0;
                        return Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(cardRadius),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(cardRadius - 0.5),
                            child: SlidableAutoCloseBehavior(
                              closeWhenOpened: true,
                              closeWhenTapped: true,
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
                                Slidable(
                                  key: ValueKey('category_${cat.id}'),
                                  groupTag: 'categories_list',
                                  startActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    extentRatio: 0.28,
                                    dismissible: Builder(
                                      builder: (paneContext) => DismissiblePane(
                                        motion: const _SlidableSeamlessStretchMotion(),
                                        dismissThreshold: 0.90,
                                        closeOnCancel: false,
                                        confirmDismiss: () async {
                                          HapticFeedback.lightImpact();
                                          Slidable.of(paneContext)?.openCurrentActionPane();
                                          return false;
                                        },
                                        onDismissed: () {},
                                      ),
                                    ),
                                    children: [
                                      CustomSlidableAction(
                                        onPressed: (_) {
                                          HapticFeedback.selectionClick();
                                          _showCategorySheet(isDarkMode,
                                              categoryToEdit: cat);
                                        },
                                        backgroundColor: const Color(0xFF3B82F6),
                                        foregroundColor: Colors.white,
                                        borderRadius: itemRadius,
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
                                    motion: const StretchMotion(),
                                    extentRatio: 0.28,
                                    dismissible: Builder(
                                      builder: (paneContext) => DismissiblePane(
                                        motion: const _SlidableSeamlessStretchMotion(),
                                        dismissThreshold: 0.90,
                                        closeOnCancel: false,
                                        confirmDismiss: () async {
                                          HapticFeedback.lightImpact();
                                          Slidable.of(paneContext)?.openCurrentActionPane();
                                          return false;
                                        },
                                        onDismissed: () {},
                                      ),
                                    ),
                                    children: [
                                      CustomSlidableAction(
                                        onPressed: (_) {
                                          HapticFeedback.selectionClick();
                                          _confirmDeleteCategoryFromList(cat);
                                        },
                                        backgroundColor: const Color(0xFFEF4444),
                                        foregroundColor: Colors.white,
                                        borderRadius: itemRadius,
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
                                  borderRadius: itemRadius,
                                  child: InkWell(
                                    borderRadius: itemRadius,
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
                                        // Category Icon Box
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: meta.color.withValues(
                                              alpha: isDarkMode ? 0.18 : 0.12,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: meta.color.withValues(
                                                alpha: isDarkMode ? 0.30 : 0.20,
                                              ),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Icon(
                                            catIcon,
                                            size: 20,
                                            color: meta.color,
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Category Name & Expenses Count
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

                                        // Light iOS-style Chevron (>)
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 13,
                                          color: chevronColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                              // <hr> Horizontal divider line under every item (except the last)
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
                );
              },
            ),
                  const SizedBox(height: 32),
                ],
              ),

            // Floating Bottom Search Bar (Only on iOS)
            if (Platform.isIOS)
              Positioned(
                left: 0,
                right: 0,
                bottom: math.max(
                      MediaQuery.of(context).padding.bottom + 12.0,
                      MediaQuery.of(context).viewInsets.bottom + 10.0,
                    ) -
                    MediaQuery.of(context).viewInsets.bottom,
                child: Center(
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 48).clamp(310.0, 335.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDarkMode ? 0.35 : 0.10,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: GlassSearchBar(
                      controller: _searchController,
                      placeholder: context.l10n.searchCategories,
                      useOwnLayer: true,
                      height: 44,
                      settings: LiquidGlassSettings(
                        thickness: 20,
                        blur: 16,
                        glassColor: isDarkMode
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.85),
                      ),
                      textStyle: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF09090B),
                      ),
                      placeholderStyle: TextStyle(
                        fontSize: 13.5,
                        color: isDarkMode
                            ? const Color(0xFF71717A)
                            : const Color(0xFFA1A1AA),
                      ),
                      searchIconColor: isDarkMode
                          ? const Color(0xFFA1A1AA)
                          : const Color(0xFF71717A),
                      clearIconColor: isDarkMode
                          ? const Color(0xFFA1A1AA)
                          : const Color(0xFF71717A),
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                      },
                    ),
                  ),
                ),
              ),
          ],
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
    this.expenseCount = 0,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_CategoryModalContent> createState() =>
      _CategoryModalContentState();
}

class _CategoryModalContentState extends State<_CategoryModalContent>
    with WidgetsBindingObserver {
  late final TextEditingController _nameController;
  late int _selectedIconIndex;
  bool _wasKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedIconIndex = widget.initialIconIndex;
    _nameController = TextEditingController(text: widget.initialName);
    if (widget.initialName.isNotEmpty) {
      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _nameController.text.length),
      );
    }
    WidgetsBinding.instance.addObserver(this);
    widget.focusNode.addListener(_handleFocusChange);
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

  void _confirmDelete(BuildContext context) {
    widget.focusNode.unfocus();
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final catName = isAr
        ? widget.categoryToEdit!.nameAr
        : widget.categoryToEdit!.nameEn;

    showCupertinoDialog<void>(
      context: context,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: Text(
          isAr ? 'حذف التصنيف' : 'Delete Category',
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            widget.expenseCount > 0
                ? (isAr
                    ? 'هل أنت متأكد من حذف "$catName"؟ هذا التصنيف مرتبط بـ ${widget.expenseCount} معاملة وستصبح هذه المعاملات بدون تصنيف.'
                    : 'Are you sure you want to delete "$catName"? This category has ${widget.expenseCount} linked expenses that will become uncategorized.')
                : (isAr
                    ? 'هل أنت متأكد من حذف "$catName"؟'
                    : 'Are you sure you want to delete "$catName"?'),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(context.l10n.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              widget.onDelete?.call();
            },
            child: Text(
              isAr ? 'حذف' : 'Delete',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
        widget.isDarkMode ? Colors.white : const Color(0xFF09090B);
    final fieldBg = widget.isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFF4F4F5);
    final activeIcon =
        _CategoriesManagementScreenState._availableCategoryIcons[_selectedIconIndex];
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;

    final sheetContent = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.focusNode.hasFocus) {
          widget.focusNode.unfocus();
        }
      },
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          20,
          widget.isGlass ? 12 : 8,
          20,
          viewInsetsBottom > 0 ? viewInsetsBottom + 16 : 24,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle for Android
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

            // Header Bar with Cancel, Centered Title, and Save Checkmark
            SizedBox(
              height: 42,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Perfectly Centered Title
                  Text(
                    widget.categoryToEdit != null
                        ? (Directionality.of(context) == TextDirection.rtl
                            ? 'تعديل التصنيف'
                            : 'Edit Category')
                        : context.l10n.newCategory,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: widget.isDarkMode
                          ? Colors.white
                          : const Color(0xFF09090B),
                    ),
                  ),

                  // Left & Right Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Cancel Button (Glass on iOS, Material on Android)
                      widget.isGlass
                          ? GlassButton.custom(
                              height: 42,
                              shape: const LiquidRoundedRectangle(borderRadius: 21),
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
                                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          : Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  Navigator.of(context).pop();
                                },
                                borderRadius: BorderRadius.circular(21),
                                child: Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: widget.isDarkMode
                                        ? const Color(0xFF1E1E24)
                                        : const Color(0xFFF4F4F5),
                                    borderRadius: BorderRadius.circular(21),
                                    border: Border.all(
                                      color: widget.isDarkMode
                                          ? const Color(0xFF2E2E38)
                                          : const Color(0xFFE4E4E7),
                                    ),
                                  ),
                                  alignment: Alignment.center,
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
                            ),

                      // Right: Checkmark (Save) Button (Glass on iOS, Material on Android)
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
                                widget.onSave(_nameController.text, _selectedIconIndex);
                              },
                              child: Icon(
                                CupertinoIcons.checkmark,
                                size: 20,
                                color: themeColor,
                              ),
                            )
                          : Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  widget.onSave(_nameController.text, _selectedIconIndex);
                                },
                                borderRadius: BorderRadius.circular(21),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: widget.isDarkMode
                                        ? const Color(0xFF1E1E24)
                                        : const Color(0xFFF4F4F5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: widget.isDarkMode
                                          ? const Color(0xFF2E2E38)
                                          : const Color(0xFFE4E4E7),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    CupertinoIcons.checkmark,
                                    size: 19,
                                    color: themeColor,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 18),

          // Interactive Icon Preview Pill
          Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFF09090B).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isDarkMode
                    ? Colors.white.withValues(alpha: 0.22)
                    : const Color(0xFF09090B).withValues(alpha: 0.14),
                  width: 1.5,
                ),
              ),
              child: Icon(
                activeIcon,
                color: themeColor,
                size: 28,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Label above Name Field
          Text(
            Directionality.of(context) == TextDirection.rtl
                ? 'اسم التصنيف'
                : 'Category Name',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode
                  ? const Color(0xFFD4D4D8)
                  : const Color(0xFF71717A),
            ),
          ),
          const SizedBox(height: 6),

          // Single Category Name Field
          TextField(
            controller: _nameController,
            focusNode: widget.focusNode,
            autofocus: true,
            cursorColor: themeColor,
            style: TextStyle(
              color: widget.isDarkMode
                  ? Colors.white
                  : const Color(0xFF09090B),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: Directionality.of(context) == TextDirection.rtl
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

          const SizedBox(height: 14),

          // Icon Grid Selector
          Text(
            Directionality.of(context) == TextDirection.rtl
                ? 'أيقونة التصنيف'
                : 'Category Icon',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode
                  ? const Color(0xFFD4D4D8)
                  : const Color(0xFF71717A),
            ),
          ),
          const SizedBox(height: 8),

          // Icon Grid Selector (Row of Expanded items for 100% fluid, glitch-free responsiveness)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int rowIndex = 0; rowIndex < 3; rowIndex++) ...[
                if (rowIndex > 0) const SizedBox(height: 10),
                Row(
                  children: [
                    for (int colIndex = 0; colIndex < 6; colIndex++) ...[
                      if (colIndex > 0) const SizedBox(width: 10),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Builder(
                            builder: (context) {
                              final idx = rowIndex * 6 + colIndex;
                              final icon = _CategoriesManagementScreenState
                                  ._availableCategoryIcons[idx];
                              final isSelected = idx == _selectedIconIndex;

                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedIconIndex = idx);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (widget.isDarkMode
                                            ? Colors.white.withValues(alpha: 0.22)
                                            : const Color(0xFF09090B)
                                                .withValues(alpha: 0.08))
                                        : (widget.isDarkMode
                                            ? Colors.white.withValues(alpha: 0.06)
                                            : fieldBg),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? themeColor
                                          : (widget.isDarkMode
                                              ? Colors.white.withValues(alpha: 0.10)
                                              : Colors.black.withValues(alpha: 0.05)),
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      icon,
                                      size: 22,
                                      color: isSelected
                                          ? themeColor
                                          : (widget.isDarkMode
                                              ? const Color(0xFFD4D4D8)
                                              : const Color(0xFF71717A)),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),

          // Edit Mode: Linked Expenses Warning & Delete Category Button
          if (widget.categoryToEdit != null) ...[
            const SizedBox(height: 18),

            // Warning Banner if category has linked expenses
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
                        Directionality.of(context) == TextDirection.rtl
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
                      Directionality.of(context) == TextDirection.rtl
                          ? 'حذف التصنيف'
                          : 'Delete Category',
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
        color: widget.isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
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

//#region Slidable Seamless Stretch Motion
class _SlidableSeamlessStretchMotion extends StatelessWidget {
  const _SlidableSeamlessStretchMotion();

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context);
    final controller = Slidable.of(context);

    if (paneData == null || controller == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: controller.animation,
      builder: (BuildContext context, Widget? child) {
        final value = controller.animation.value.clamp(0.0, 1.0);
        return FractionallySizedBox(
          alignment: paneData.alignment,
          widthFactor: paneData.direction == Axis.horizontal ? value : 1.0,
          heightFactor: paneData.direction == Axis.horizontal ? 1.0 : value,
          child: child,
        );
      },
      child: const ClipRect(
        child: BehindMotion(),
      ),
    );
  }
}
//#endregion

