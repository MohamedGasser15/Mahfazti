import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_adaptive_context_menu/ios_adaptive_context_menu.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/hide_balance_service.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/utils/api_error_handler.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/navigation_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:my_wallet/features/settings/presentation/screens/categories_management_screen.dart';
import 'package:my_wallet/features/settings/presentation/screens/settings_screen.dart';
import 'package:my_wallet/features/wallet/data/models/budget_models.dart';
import 'package:my_wallet/features/wallet/data/models/category_model.dart';
import 'package:my_wallet/features/wallet/data/models/voice_expense_model.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';
import 'package:my_wallet/features/wallet/data/repositories/category_repository.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/presentation/screens/analytics_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/subscriptions_tab.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/home_tab_models.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/voice_expense_button.dart';
import 'package:my_wallet/features/wallet/presentation/utils/category_icon_helper.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

part '../widgets/home_tab_dialogs.dart';
part '../widgets/home_tab_widgets.dart';

class HomeTab extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const HomeTab({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<HomeTab> createState() => _HomeTabConcrete();
}

abstract class _HomeTabState extends State<HomeTab> {
  //#region Private Fields
  final WalletRepository _walletRepository = WalletRepository();
  bool _isLoading = true;
  WalletHomeData? _homeData;
  BudgetDto? _budgetData;
  SubscriptionItem? _upcomingSubscription;
  List<SubscriptionItem> _subscriptions = [];
  String? _errorMessage;

  List<Category> _categories = [];
  String? _currencyCode;

  String _selectedAccountId = 'bank';
  String _mainAccountId = 'bank';
  final List<AccountItem> _customAccounts = [];
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  bool _showAutoTrackingBanner = true;
  int _getStartedCardIndex = 0;
  final Set<String> _dismissedGetStartedCards = <String>{};
  String? _animatingDismissCardId;
  bool _isDismissingCard = false;
  PageController _getStartedPageController = PageController(viewportFraction: 0.90);
  final ScrollController _walletsScrollController = ScrollController();
  //#endregion

  //#region Lifecycle
  @override
  void initState() {
    super.initState();
    _loadCurrency().then((_) {
      _loadHomeData();
    });
    _loadCategories();
  }

  @override
  void dispose() {
    _getStartedPageController.dispose();
    _walletsScrollController.dispose();
    super.dispose();
  }
  //#endregion

  //#region Accounts Data Getter
  List<AccountItem> get _accounts {
    final balance = _homeData?.balance.totalBalance ?? 0.0;
    final income = _homeData?.balance.totalDeposits ?? 0.0;
    final expense = _homeData?.balance.totalWithdrawals ?? 0.0;

    return [
      AccountItem(
        id: 'all',
        name: context.l10n.allAccounts,
        type: 'all',
        balance: balance,
        income: income,
        expense: expense,
        icon: Icons.account_balance_wallet_rounded,
        isAll: true,
        isMain: _mainAccountId == 'all',
        currency: _currencyCode ?? 'EGP',
      ),
      AccountItem(
        id: 'bank',
        name: context.l10n.banqueMisr,
        type: 'bank',
        balance: balance * 0.62,
        income: income * 0.8,
        expense: expense * 0.45,
        icon: Icons.account_balance_rounded,
        isMain: _mainAccountId == 'bank',
        accountNumber: '•••• 8920',
        currency: 'EGP',
      ),
      AccountItem(
        id: 'cash',
        name: context.l10n.cashWallet,
        type: 'cash',
        balance: balance * 0.18,
        income: income * 0.1,
        expense: expense * 0.35,
        icon: Icons.payments_rounded,
        isMain: _mainAccountId == 'cash',
        accountNumber: context.l10n.cash,
        currency: 'USD',
      ),
      AccountItem(
        id: 'ewallet',
        name: context.l10n.vodafoneCash,
        type: 'ewallet',
        balance: balance * 0.20,
        income: income * 0.1,
        expense: expense * 0.2,
        icon: Icons.phone_iphone_rounded,
        isMain: _mainAccountId == 'ewallet',
        accountNumber: '010 •••• 567',
        currency: 'EGP',
      ),
      ..._customAccounts,
    ];
  }

  List<AccountItem> get _walletsCarouselList {
    final list = _accounts.where((a) => !a.isAll).toList();
    list.sort((a, b) {
      if (a.isMain && !b.isMain) return -1;
      if (!a.isMain && b.isMain) return 1;
      return 0;
    });
    return list;
  }

  void _syncWalletsCarouselToSelected() {
    if (!_walletsScrollController.hasClients) return;
    final wallets = _walletsCarouselList;
    final targetIndex = wallets.indexWhere((a) => a.id == _selectedAccountId);
    if (targetIndex != -1) {
      final targetOffset = (targetIndex * (168.0 + 10.0)).clamp(
        0.0,
        _walletsScrollController.position.maxScrollExtent,
      );
      _walletsScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  AccountItem get _selectedAccount {
    final accounts = _accounts;
    return accounts.firstWhere(
      (a) => a.id == _selectedAccountId,
      orElse: () => accounts.first,
    );
  }

  double _heroDragDistance = 0.0;
  bool _heroSlideFromLeft = false;

  void _switchToNextAccount({bool isRtl = false}) {
    final accounts = _accounts;
    if (accounts.length <= 1) return;
    final currentIndex = accounts.indexWhere((a) => a.id == _selectedAccountId);
    if (currentIndex == -1) return;
    final nextIndex = (currentIndex + 1) % accounts.length;
    HapticFeedback.selectionClick();
    setState(() {
      _heroSlideFromLeft = isRtl;
      _selectedAccountId = accounts[nextIndex].id;
    });
    _syncWalletsCarouselToSelected();
  }

  void _switchToPreviousAccount({bool isRtl = false}) {
    final accounts = _accounts;
    if (accounts.length <= 1) return;
    final currentIndex = accounts.indexWhere((a) => a.id == _selectedAccountId);
    if (currentIndex == -1) return;
    final prevIndex = (currentIndex - 1 + accounts.length) % accounts.length;
    HapticFeedback.selectionClick();
    setState(() {
      _heroSlideFromLeft = !isRtl;
      _selectedAccountId = accounts[prevIndex].id;
    });
    _syncWalletsCarouselToSelected();
  }
  //#endregion

  //#region Data Loading
  Future<void> _loadCurrency() async {
    final code = await SharedPrefs.getCurrency();
    setState(() {
      _currencyCode = code ?? 'USD';
    });
  }

  Future<void> _loadCategories() async {
    try {
      final repo = CategoryRepository();
      _categories = await repo.getAllCategories();
    } catch (e) {
      final errorMsg = ApiErrorHandler.getErrorMessage(e);
      debugPrint('Error loading categories: $errorMsg');
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: '${context.l10n.failedToLoadCategories}: $errorMsg',
      );
    }
  }

  Future<List<WalletTransaction>> _loadAllTransactions() async {
    try {
      final response = await _walletRepository.getTransactions(pageSize: 100);
      return response.transactions;
    } catch (e) {
      final errorMsg = ApiErrorHandler.getErrorMessage(e);
      if (!mounted) return [];
      MessageService.showError(
        context: context,
        message: '${context.l10n.failedToLoadTransactions}: $errorMsg',
      );
      return [];
    }
  }

  Future<void> _loadHomeData({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await WalletCacheService.getHome();
      final cachedBudget = await WalletCacheService.getBudget();
      await _loadUpcomingSubscription();
      if (cached != null) {
        try {
          final cachedData = WalletHomeData.fromJson(cached);
          final parsedBudget = cachedBudget != null
              ? BudgetDto.fromJson(cachedBudget)
              : null;
          setState(() {
            _homeData = cachedData;
            _budgetData = (parsedBudget != null && parsedBudget.monthlyBudget > 0) ? parsedBudget : null;
            _isLoading = false;
            _errorMessage = null;
          });
          _refreshInBackground();
          return;
        } catch (e) {
          debugPrint('Error parsing cached home data: $e');
        }
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _fetchHomeFromApi();
  }

  Future<void> _loadUpcomingSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user_subscriptions_list');
      List<SubscriptionItem> list = [];
      if (raw != null) {
        final decoded = jsonDecode(raw) as List;
        list = decoded.map((e) => SubscriptionItem.fromJson(e)).toList();
      }
      if (list.isEmpty) {
        list = List.from(SubscriptionItem.defaultSeed());
        await prefs.setString(
          'user_subscriptions_list',
          jsonEncode(list.map((e) => e.toJson()).toList()),
        );
      }
      final now = DateTime.now();
      list.sort((a, b) {
        int daysA = a.renewalDay - now.day;
        if (daysA < 0) daysA += 30;
        int daysB = b.renewalDay - now.day;
        if (daysB < 0) daysB += 30;
        return daysA.compareTo(daysB);
      });
      if (mounted) {
        setState(() {
          _subscriptions = list;
          _upcomingSubscription = list.isNotEmpty ? list.first : null;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchHomeFromApi({bool silent = false}) async {
    try {
      final data = await _walletRepository.getHomeData();
      final cacheMap = data.toJson();
      await WalletCacheService.saveHome(cacheMap);

      BudgetDto? fetchedBudget;
      try {
        fetchedBudget = await _walletRepository.getBudget();
      } catch (_) {}
      await _loadUpcomingSubscription();

      if (mounted) {
        setState(() {
          _homeData = data;
          _budgetData = (fetchedBudget != null && fetchedBudget.monthlyBudget > 0)
              ? fetchedBudget
              : null;
          if (!silent) _isLoading = false;
        });
      }
    } catch (e) {
      final errorMsg = ApiErrorHandler.getErrorMessage(e);
      if (mounted && !silent) {
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
      }
      if (!ApiErrorHandler.isNetworkError(e)) {
        if (!mounted) return;
        MessageService.showError(context: context, message: errorMsg);
      }
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      await _fetchHomeFromApi(silent: true);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _refreshData() async {
    await _loadHomeData(forceRefresh: true);
  }
  //#endregion

  //#region Filter Helpers
  List<WalletTransaction> get _filteredTransactions {
    final all = _homeData?.recentTransactions ?? [];
    if (_selectedAccountId == 'all') return all;

    final accountsList = _accounts.where((a) => !a.isAll).map((a) => a.id).toList();
    final index = accountsList.indexOf(_selectedAccountId);
    if (index == -1) return all;

    final total = accountsList.length;
    final filtered = all.where((t) => (t.id % total) == index).toList();
    return filtered;
  }


  String get _formattedDateRange {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final startStr = DateFormat('d MMM', isAr ? 'ar' : 'en').format(_startDate);
    final endStr = DateFormat('d MMM', isAr ? 'ar' : 'en').format(_endDate);
    return '$startStr - $endStr';
  }

  //#endregion

  //#region Transaction Actions
  Future<void> _deleteTransaction(WalletTransaction transaction) async {
    try {
      final success = await _walletRepository.deleteTransaction(transaction.id);

      if (success) {
        await _loadHomeData();
        if (!mounted) return;
        MessageService.showSuccess(
          context: context,
          message: context.l10n.transactionDeletedSuccess,
        );
      } else {
        if (!mounted) return;
        MessageService.showError(
          context: context,
          message: context.l10n.failedToDeleteTransaction,
        );
      }
    } catch (e) {
      if (!mounted) return;
      MessageService.showError(
        context: context,
        message: context.l10n.errorDeletingTransaction(e.toString()),
      );
    }
  }
  //#endregion

  //#region Cross-Mixin Abstract Declarations
  Widget _buildSayHeroSection(bool isDarkMode, HideBalanceService hideService);
  Widget _buildWalletsCarousel(bool isDarkMode, HideBalanceService hideService);
  Widget _buildAutoTrackingBanner(bool isDarkMode);
  Widget _buildRecentTransactionsSection(bool isDarkMode);
  Widget _buildInsightsGridSection(bool isDarkMode, HideBalanceService hideService);
  Widget _buildEmptyState(bool isDarkMode);
  Widget _buildTransactionCard(WalletTransaction transaction, bool isDarkMode);
  void _showEditTransactionDialog(WalletTransaction transaction);
  void _showDeleteConfirmationDialog(WalletTransaction transaction);
  Widget _buildSkeletonLoading(bool isDarkMode);
  Widget _buildErrorWidget(bool isDarkMode);
  void _showUnifiedAddModal({VoiceExpenseResult? prefillFromVoice});
  void _showAddAccountModal();
  void _showManageAccountsModal();
  void _showAccountSwitcherModal();
  void _showAllTransactionsModal(List<WalletTransaction> transactions);
  //#endregion

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hideService = Provider.of<HideBalanceService>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Container(
        color: isDarkMode ? const Color(0xFF09090B) : Colors.white,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.white,
          backgroundColor: isDarkMode ? const Color(0xFF26262E) : const Color(0xFF202026),
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Top overscroll extension: matches top of hero gradient seamlessly
                Positioned(
                  top: -1000,
                  left: -1000,
                  right: -1000,
                  height: 1000,
                  child: Container(
                    color: isDarkMode
                        ? const Color(0xFF16161B)
                        : const Color(0xFF141418),
                  ),
                ),
                ResponsiveWrapper(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Say-Style Hero Section with Atmospheric Black Gradient / Shadow (Status bar down to actions)
                      _buildSayHeroSection(isDarkMode, hideService),

                      if (_homeData == null) ...[
                        if (_isLoading)
                          _buildSkeletonLoading(isDarkMode)
                        else if (_errorMessage != null)
                          _buildErrorWidget(isDarkMode)
                        else
                          const SizedBox.shrink(),
                      ] else ...[
                        // "Get Started / Auto-Tracking" Banner Card
                        AnimatedSize(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeInOutCubic,
                          child: (_showAutoTrackingBanner && _dismissedGetStartedCards.length < 4)
                              ? Column(
                                  children: [
                                    _buildAutoTrackingBanner(isDarkMode),
                                    const SizedBox(height: 20),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Wallets Carousel (Displayed if user has multiple accounts/wallets)
                        if (_accounts.where((a) => !a.isAll).length > 1) ...[
                          _buildWalletsCarousel(isDarkMode, hideService),
                          const SizedBox(height: 20),
                        ],

                        // Recent Transactions Section
                        _buildRecentTransactionsSection(isDarkMode),

                        const SizedBox(height: 24),

                        // Insights Grid Widgets Section
                        _buildInsightsGridSection(isDarkMode, hideService),

                        const SizedBox(height: 120),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //#region Formatting Helpers
  String _formatAmount(
    double amount, {
    String? currencyCode,
    String prefix = '',
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final targetCode = currencyCode ?? _currencyCode ?? 'USD';
    final symbol = getCurrencySymbol(targetCode, isAr: isAr);
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedNum = formatter.format(amount.abs());

    String sign = prefix.trim();
    if (sign.isEmpty && amount < 0) {
      sign = '-';
    }

    final signPart = sign.isNotEmpty ? '$sign ' : '';

    if (isAr) {
      return '$signPart$formattedNum $symbol';
    } else {
      return '$signPart$symbol $formattedNum';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = context.l10n;

    if (difference.isNegative || difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgoPlural(difference.inMinutes);
    } else if (difference.inHours < 24 && date.day == now.day) {
      return l10n.hoursAgoPlural(difference.inHours);
    } else if (difference.inDays <= 1 || (now.day - date.day == 1 && difference.inHours < 48)) {
      return l10n.yesterday;
    } else if (difference.inDays < 30) {
      return l10n.daysAgoPlural(difference.inDays);
    } else if (difference.inDays < 60) {
      return l10n.oneMonthAgo;
    } else {
      return DateFormat('d MMM', isAr ? 'ar' : 'en').format(date);
    }
  }

  Future<T?> _showAdaptiveBottomSheet<T>({
    required Widget Function(BuildContext context, bool isGlass, GlassModalSheetController? controller) builder,
    bool isScrollControlled = true,
    bool showDragHandle = true,
    bool dismissible = true,
    bool enableDrag = true,
    double topBorderRadius = 38,
    double bottomBorderRadius = 0,
    double fullTopBorderRadius = 24,
    double fullBottomBorderRadius = 0,
    double horizontalMargin = 0.0,
    double bottomMargin = 0.0,
    double halfSize = 0.69,
    double fullSize = 0.88,
    GlassSheetState initialState = GlassSheetState.half,
    Set<GlassSheetDetent> detents = const {GlassSheetDetent.medium, GlassSheetDetent.large},
    GlassModalSheetController? controller,
    List<FocusNode>? focusNodes,
    ValueChanged<GlassSheetState>? onStateChanged,
  }) async {
    final isIOS = Platform.isIOS;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    NavigationService.isModalOpenNotifier.value = true;
    try {
      if (isIOS) {
        final sheetController = controller ?? GlassModalSheetController();
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

        return await GlassModalSheet.show<T>(
          context: context,
          useRootNavigator: true,
          platformViewBackdrop: true,
          controller: sheetController,
          initialState: initialState,
          halfSize: halfSize,
          fullSize: fullSize,
          detents: detents,
          dismissible: dismissible,
          horizontalMargin: horizontalMargin,
          bottomMargin: bottomMargin,
          topBorderRadius: topBorderRadius,
          bottomBorderRadius: bottomBorderRadius,
          fullTopBorderRadius: fullTopBorderRadius,
          fullBottomBorderRadius: fullBottomBorderRadius,
          showDragIndicator: showDragHandle,
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
            if (state == GlassSheetState.half && focusNodes != null) {
              for (final node in focusNodes) {
                node.unfocus();
              }
            }
            onStateChanged?.call(state);
          },
          builder: (ctx) => Material(
            type: MaterialType.transparency,
            child: builder(ctx, true, sheetController),
          ),
        );
      } else {
        return await showModalBottomSheet<T>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: isScrollControlled,
          enableDrag: enableDrag,
          backgroundColor: Colors.transparent,
          builder: (ctx) => builder(ctx, false, null),
        );
      }
    } finally {
      NavigationService.isModalOpenNotifier.value = false;
    }
  }
  //#endregion
}

class AdaptiveSheetFocusScope extends StatefulWidget {
  final Widget child;
  final GlassModalSheetController? controller;
  final List<FocusNode> focusNodes;

  const AdaptiveSheetFocusScope({
    super.key,
    required this.child,
    this.controller,
    required this.focusNodes,
  });

  @override
  State<AdaptiveSheetFocusScope> createState() => _AdaptiveSheetFocusScopeState();
}

class _AdaptiveSheetFocusScopeState extends State<AdaptiveSheetFocusScope>
    with WidgetsBindingObserver {
  bool _wasKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    for (final node in widget.focusNodes) {
      node.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    final anyHasFocus = widget.focusNodes.any((n) => n.hasFocus);
    if (widget.controller == null) return;
    if (anyHasFocus) {
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
      for (final node in widget.focusNodes) {
        node.unfocus();
      }
    }
    _wasKeyboardOpen = isKeyboardOpen;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final node in widget.focusNodes) {
      node.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        for (final node in widget.focusNodes) {
          if (node.hasFocus) node.unfocus();
        }
      },
      child: widget.child,
    );
  }
}

class _HomeTabConcrete extends _HomeTabState with _HomeTabDialogs, _HomeTabWidgets {}
