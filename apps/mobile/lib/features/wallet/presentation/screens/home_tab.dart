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
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return [
      AccountItem(
        id: 'all',
        name: isAr ? 'إجمالي الحسابات' : 'All Accounts',
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
        name: isAr ? 'بنك مصر' : 'Banque Misr',
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
        name: isAr ? 'كاش (الجيب)' : 'Cash Wallet',
        type: 'cash',
        balance: balance * 0.18,
        income: income * 0.1,
        expense: expense * 0.35,
        icon: Icons.payments_rounded,
        isMain: _mainAccountId == 'cash',
        accountNumber: isAr ? 'نقدية' : 'Cash',
        currency: 'USD',
      ),
      AccountItem(
        id: 'ewallet',
        name: isAr ? 'فودافون كاش' : 'Vodafone Cash',
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
  String _formatAmount(double amount, {String? currencyCode}) {
    if (currencyCode != null) {
      final code = currencyCode.toUpperCase();
      final formatter = NumberFormat('#,##0.00', 'en_US');
      final formattedNum = formatter.format(amount.abs());
      final isNegative = amount < 0;
      final sign = isNegative ? '-' : '';
      return '$sign$formattedNum $code';
    }

    final symbol = currencySymbols[_currencyCode ?? 'USD'] ?? '\$';
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$symbol ${formatter.format(amount)}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    if (difference.isNegative || difference.inMinutes < 1) {
      return isAr ? 'الآن' : 'Just now';
    } else if (difference.inMinutes < 60) {
      return isAr ? 'منذ ${difference.inMinutes} دقيقة' : '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && date.day == now.day) {
      if (difference.inHours == 1) {
        return isAr ? 'منذ ساعة' : '1h ago';
      } else if (difference.inHours == 2) {
        return isAr ? 'منذ ساعتين' : '2h ago';
      } else if (difference.inHours >= 3 && difference.inHours <= 10) {
        return isAr ? 'منذ ${difference.inHours} ساعات' : '${difference.inHours}h ago';
      } else {
        return isAr ? 'منذ ${difference.inHours} ساعة' : '${difference.inHours}h ago';
      }
    } else if (difference.inDays <= 1 || (now.day - date.day == 1 && difference.inHours < 48)) {
      return isAr ? 'أمس' : 'Yesterday';
    } else if (difference.inDays == 2) {
      return isAr ? 'منذ يومين' : '2d ago';
    } else if (difference.inDays >= 3 && difference.inDays <= 10) {
      return isAr ? 'منذ ${difference.inDays} أيام' : '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return isAr ? 'منذ ${difference.inDays} يوماً' : '${difference.inDays}d ago';
    } else if (difference.inDays < 60) {
      return isAr ? 'منذ شهر' : '1mo ago';
    } else {
      return DateFormat('d MMM', isAr ? 'ar' : 'en').format(date);
    }
  }
  //#endregion
}

class _HomeTabConcrete extends _HomeTabState with _HomeTabDialogs, _HomeTabWidgets {}
