import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/wallet_cache_service.dart';
import 'package:my_wallet/core/themes/app_surfaces.dart';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/navigation_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/core/widgets/app_shimmer.dart';
import 'package:my_wallet/core/widgets/app_states.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/inferred_wallet_label.dart';

/// Full-screen Transactions View for Mahfazti.
///
/// Features authentic iOS 26 Liquid Glass styling on Apple platforms and
/// clean Material 3 styling on Android, complete with pagination, search,
/// type tabs, date range filter, and swipe-to-delete.
class TransactionsPage extends StatefulWidget {
  final List<WalletTransaction>? initialTransactions;

  /// Opens the transaction editor (same sheet as "Add Transaction").
  /// Provided by the caller — typically the Home tab state.
  final Future<void> Function(WalletTransaction transaction)? onEditTransaction;

  const TransactionsPage({
    super.key,
    this.initialTransactions,
    this.onEditTransaction,
  });

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

/// Backward compatibility alias
typedef TransactionsTab = TransactionsPage;

class _CategoryFilterItem {
  final int? id;
  final String nameEn;
  final String nameAr;
  final IconData icon;

  const _CategoryFilterItem({
    this.id,
    required this.nameEn,
    required this.nameAr,
    required this.icon,
  });
}

class _GroupedListItem {
  final bool isHeader;
  final String? headerTitle;
  final int count;
  final WalletTransaction? transaction;

  const _GroupedListItem.header({
    required this.headerTitle,
    this.count = 0,
  })  : isHeader = true,
        transaction = null;

  const _GroupedListItem.transaction(this.transaction)
      : isHeader = false,
        headerTitle = null,
        count = 0;
}

/// One date bucket (Today / Yesterday / This Week …) with its transactions.
class _DateSection {
  final String title;
  final List<WalletTransaction> transactions;

  const _DateSection(this.title, this.transactions);
}

class _TransactionsPageState extends State<TransactionsPage> {
  final WalletRepository _walletRepository = WalletRepository();
  StreamSubscription<void>? _syncSubscription;
  List<WalletTransaction> _transactions = [];
  List<WalletTransaction> _filteredTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  // Filters
  String? _selectedType; // null = all, "Deposit", "Withdrawal"
  String _selectedAccountId = 'all';
  String _selectedAccountName = '';
  String? _selectedCategory; // null = all
  String _searchQuery = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  String _sortBy = 'newest'; // 'newest', 'oldest', 'highest'

  String? _currencyCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialTransactions != null &&
        widget.initialTransactions!.isNotEmpty) {
      _transactions = List.from(widget.initialTransactions!);
      _filteredTransactions = List.from(widget.initialTransactions!);
      _isLoading = false;
    }

    _loadCurrency();
    _loadTransactions(
      page: 1,
      forceRefresh: widget.initialTransactions == null,
    );
    _syncSubscription = WalletDataSyncService.onDataChanged.listen((_) {
      if (mounted) {
        _loadTransactions(page: 1, forceRefresh: true);
      }
    });
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ================== Helper Methods ==================

  Future<void> _loadCurrency() async {
    final code = await SharedPrefs.getCurrency();
    if (mounted) {
      setState(() {
        _currencyCode = code ?? 'EGP';
      });
    }
  }

  String _formatAmount(double amount) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final symbol = getCurrencySymbol(_currencyCode ?? 'EGP', isAr: isAr);
    // Trailing zeros trimmed: 500.00 → 500, 500.50 → 500.5
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return '$symbol ${formatter.format(amount)}';
  }

  String _getCacheKey() {
    final typeKey = _selectedType ?? 'all';
    final fromKey = _fromDate != null ? _fromDate!.toIso8601String() : 'none';
    final toKey = _toDate != null ? _toDate!.toIso8601String() : 'none';
    return 'type_${typeKey}_from_${fromKey}_to_${toKey}_page1';
  }

  // ================== Data Loading ==================

  Future<void> _loadTransactions(
      {int page = 1, bool forceRefresh = false}) async {
    if (!mounted) return;

    if (page > 1) {
      await _fetchMoreTransactions(page);
      return;
    }

    if (!forceRefresh && !AppConstants.useMockBackend) {
      final cacheKey = _getCacheKey();
      final cached =
          await WalletCacheService.getTransactions(filterKey: cacheKey);
      if (cached != null) {
        try {
          final transactionsJson = cached['transactions'] as List;
          final transactions = transactionsJson
              .map((t) => WalletTransaction.fromJson(t))
              .toList();
          final totalPages = cached['totalPages'] as int;
          final currentPage = cached['currentPage'] as int;

          setState(() {
            _transactions = transactions;
            _applySearchFilter();
            _currentPage = currentPage;
            _totalPages = totalPages;
            _isLoading = false;
            _errorMessage = null;
          });
          _refreshInBackground();
          return;
        } catch (e) {
          debugPrint('Error parsing cached transactions: $e');
        }
      }
    }

    if (_transactions.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    if (mounted) {
      await _fetchFromApi(page: page);
    }
  }

  Future<void> _fetchFromApi({int page = 1, bool silent = false}) async {
    try {
      final response = await _walletRepository.getTransactions(
        page: page,
        pageSize: 20,
        type: _selectedType,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      if (!mounted) return;

      if (page == 1) {
        final cacheKey = _getCacheKey();
        final cacheData = {
          'transactions': response.transactions.map((t) => t.toJson()).toList(),
          'totalPages': response.totalPages,
          'currentPage': response.page,
        };
        await WalletCacheService.saveTransactions(cacheData,
            filterKey: cacheKey);
      }

      setState(() {
        if (page == 1) {
          _transactions = response.transactions;
          _applySearchFilter();
          _currentPage = response.page;
          _totalPages = response.totalPages;
          _isLoading = false;
          _errorMessage = null;
        } else {
          _transactions.addAll(response.transactions);
          _applySearchFilter();
          _isLoadingMore = false;
        }
      });
    } catch (e) {
      if (mounted && !silent && _transactions.isEmpty) {
        setState(() {
          _errorMessage = context.l10n.failedToLoadTransactions(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMoreTransactions(int page) async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final response = await _walletRepository.getTransactions(
        page: page,
        pageSize: 20,
        type: _selectedType,
        fromDate: _fromDate,
        toDate: _toDate,
      );
      if (!mounted) return;
      setState(() {
        _transactions.addAll(response.transactions);
        _applySearchFilter();
        _currentPage = response.page;
        _totalPages = response.totalPages;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        MessageService.showError(
            context: context,
            message: context.l10n.failedToLoadMore(e.toString()));
      }
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      await _fetchFromApi(page: 1, silent: true);
    } catch (_) {}
  }

  Future<void> _refreshData() async {
    await _loadTransactions(page: 1, forceRefresh: true);
  }

  // ================== Search & Filters ==================

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {
      _searchQuery = _searchController.text.trim();
      _applySearchFilter();
    });
  }

  void _applySort() {
    if (_sortBy == 'newest') {
      _filteredTransactions
          .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    } else if (_sortBy == 'oldest') {
      _filteredTransactions
          .sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
    } else if (_sortBy == 'highest') {
      _filteredTransactions.sort((a, b) => b.amount.compareTo(a.amount));
    }
  }

  void _applySearchFilter() {
    _applyFilters();
  }

  void _applyFilters() {
    List<WalletTransaction> list = List.from(_transactions);

    // 1. Account Filter
    if (_selectedAccountId != 'all') {
      if (_selectedAccountId == 'bank') {
        list = list.where((t) {
          final title = t.title.toLowerCase();
          final desc = (t.description ?? '').toLowerCase();
          final cat = (t.categoryNameEn ?? '').toLowerCase();
          return cat.contains('salary') ||
              cat.contains('invest') ||
              cat.contains('bill') ||
              title.contains('راتب') ||
              title.contains('بنك') ||
              desc.contains('بنك');
        }).toList();
      } else if (_selectedAccountId == 'cash') {
        list = list.where((t) {
          final cat = (t.categoryNameEn ?? '').toLowerCase();
          return cat.contains('grocer') ||
              cat.contains('food') ||
              cat.contains('trans') ||
              cat.contains('shop');
        }).toList();
      } else if (_selectedAccountId == 'ewallet') {
        list = list.where((t) {
          final title = t.title.toLowerCase();
          final desc = (t.description ?? '').toLowerCase();
          final cat = (t.categoryNameEn ?? '').toLowerCase();
          return cat.contains('freelance') ||
              cat.contains('bill') ||
              title.contains('إنترنت') ||
              desc.contains('فايبر') ||
              desc.contains('فودافون');
        }).toList();
      }
    }

    // 2. Category Filter
    if (_selectedCategory != null) {
      final selectedLower = _selectedCategory!.toLowerCase();
      list = list.where((t) {
        final en = (t.categoryNameEn ?? '').toLowerCase();
        final ar = (t.categoryNameAr ?? '').toLowerCase();
        return en == selectedLower ||
            ar == selectedLower ||
            en.contains(selectedLower) ||
            ar.contains(selectedLower);
      }).toList();
    }

    // 3. Search Query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((t) {
        return t.title.toLowerCase().contains(query) ||
            (t.description?.toLowerCase().contains(query) ?? false) ||
            (t.categoryNameAr?.toLowerCase().contains(query) ?? false) ||
            (t.categoryNameEn?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _filteredTransactions = list;
    _applySort();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchQuery = '';
      _applySearchFilter();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _totalPages) {
      _fetchMoreTransactions(_currentPage + 1);
    }
  }

  void _showFilterDialog() {
    if (Platform.isIOS) {
      showGlassModalSheet(
        context: context,
        halfSize: 0.58,
        fullSize: 0.78,
        builder: (context) => _buildFilterSheet(isGlass: true),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildFilterSheet(isGlass: false),
      );
    }
  }

  Widget _buildFilterSheet({bool isGlass = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    DateTime? tempFromDate = _fromDate;
    DateTime? tempToDate = _toDate;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        final content = Padding(
          padding: EdgeInsets.fromLTRB(20, isGlass ? 8 : 24, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isGlass) ...[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                context.l10n.filterTransactions,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  CupertinoIcons.calendar,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                title: Text(
                  context.l10n.from,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Text(
                  tempFromDate == null
                      ? context.l10n.any
                      : '${tempFromDate!.day}/${tempFromDate!.month}/${tempFromDate!.year}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                onTap: () async {
                  DateTime? date;
                  if (Platform.isIOS) {
                    date = await showCupertinoCalendarPicker(
                      context,
                      widgetRenderBox: null,
                      initialDate: tempFromDate ?? DateTime.now(),
                      minimumDate: DateTime(2000),
                      maximumDate: DateTime.now(),
                    );
                  } else {
                    date = await showDatePicker(
                      context: context,
                      initialDate: tempFromDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                  }
                  if (date != null) {
                    setSheetState(() => tempFromDate = date);
                  }
                },
              ),
              Divider(
                height: 1,
                color: isDarkMode ? Colors.white12 : Colors.black12,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  CupertinoIcons.calendar,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                title: Text(
                  context.l10n.to,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Text(
                  tempToDate == null
                      ? context.l10n.any
                      : '${tempToDate!.day}/${tempToDate!.month}/${tempToDate!.year}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                onTap: () async {
                  DateTime? date;
                  if (Platform.isIOS) {
                    date = await showCupertinoCalendarPicker(
                      context,
                      widgetRenderBox: null,
                      initialDate: tempToDate ?? DateTime.now(),
                      minimumDate: DateTime(2000),
                      maximumDate: DateTime.now(),
                    );
                  } else {
                    date = await showDatePicker(
                      context: context,
                      initialDate: tempToDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                  }
                  if (date != null) {
                    setSheetState(() => tempToDate = date);
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setSheetState(() {
                          tempFromDate = null;
                          tempToDate = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: isDarkMode ? Colors.white24 : Colors.black26,
                        ),
                      ),
                      child: Text(
                        context.l10n.reset,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _fromDate = tempFromDate;
                          _toDate = tempToDate;
                        });
                        _loadTransactions(page: 1, forceRefresh: true);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor:
                            isDarkMode ? Colors.white : Colors.black,
                        foregroundColor:
                            isDarkMode ? Colors.black : Colors.white,
                      ),
                      child: Text(
                        context.l10n.apply,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        if (isGlass) {
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: content,
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF18181B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(child: content),
        );
      },
    );
  }

  // ================== Build UI ==================

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Platform.isIOS;
    final bgColor =
        isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final hasActiveDateFilter = _fromDate != null || _toDate != null;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: !isIOS,
      appBar: AppBar(
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 52,
        leadingWidth: 58,
        leading: const AppGlassBackButton(),
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final offset =
                _scrollController.hasClients ? _scrollController.offset : 0.0;
            final isAr = Localizations.localeOf(context).languageCode == 'ar';
            final progress = ((offset - 16.0) / 38.0).clamp(0.0, 1.0);
            if (progress <= 0.0) return const SizedBox.shrink();
            final curve = Curves.easeOutCubic.transform(progress);

            // Travels in from the left along the continuous diagonal trajectory
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
                    context.l10n.transactions,
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
        flexibleSpace: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final offset =
                _scrollController.hasClients ? _scrollController.offset : 0.0;
            final progress = ((offset - 10.0) / 35.0).clamp(0.0, 1.0);
            if (progress <= 0.0) return const SizedBox.shrink();
            return ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 20.0 * progress,
                  sigmaY: 20.0 * progress,
                ),
                child: Container(
                  color: (isDarkMode
                          ? const Color(0xFF09090B)
                          : const Color(0xFFF8F8FA))
                      .withValues(alpha: 0.82 * progress),
                ),
              ),
            );
          },
        ),
        actions: [
          isIOS
              ? _buildIosTopActions(isDarkMode, hasActiveDateFilter)
              : _buildAndroidTopActions(isDarkMode, hasActiveDateFilter),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ResponsiveWrapper(
          child: Stack(
            children: [
              isIOS
                  ? _buildIosList(isDarkMode, hasActiveDateFilter)
                  : _buildAndroidList(isDarkMode, hasActiveDateFilter),

              // Floating Bottom Search Bar (iOS Authentic Liquid Glass)
              // Automatically hides when modal sheet opens to prevent show-through
              if (isIOS)
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
                    placeholder: context.l10n.searchTransactions,
                    onCancel: _clearSearch,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                      _applySearchFilter();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== Scrollable Content Header ==================

  Widget _buildScrollableHeader({
    required bool isDarkMode,
    required bool isIOS,
    required bool hasActiveDateFilter,
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // iOS Authentic Large Title with smooth fade and upward drift on scroll
        AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final offset =
                _scrollController.hasClients ? _scrollController.offset : 0.0;
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
                child: Opacity(
                  opacity: opacity,
                  child: child,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
            child: Text(
              context.l10n.transactions,
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

        // 1. Account Selector ("All Accounts ⌵") & Date (soft/light color)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAccountSelector(isDarkMode, isAr),
              _buildDateSelector(isDarkMode, isAr, hasActiveDateFilter),
            ],
          ),
        ),

        // Top Search Bar (Android only)
        if (!isIOS)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: _buildAndroidSearchBar(isDarkMode),
          ),

        // 2. Categories Horizontal Scroll List (replaces old TypeFilter tabs)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCategoriesFilterList(isDarkMode, isAr),
        ),

        // 3. Spent & Received Summary Cards
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: _buildSpentReceivedSummary(isDarkMode, isAr),
        ),

        const SizedBox(height: 2),
      ],
    );
  }

  // ================== Account & Category Header Widgets ==================

  List<IosContextMenuItem> _getDateActions(
      bool isAr, bool hasActiveDateFilter) {
    return [
      IosContextMenuAction(
        id: 'date_today',
        title: isAr ? 'اليوم' : 'Today',
        iconSystemName: 'sun.max',
        icon: CupertinoIcons.sun_max,
        showTrailingCheckmark: _isTodayActive,
      ),
      IosContextMenuAction(
        id: 'date_this_week',
        title: isAr ? 'هذا الأسبوع' : 'This Week',
        iconSystemName: 'calendar.badge.clock',
        icon: CupertinoIcons.calendar_badge_plus,
        showTrailingCheckmark: _isThisWeekActive,
      ),
      IosContextMenuAction(
        id: 'date_this_month',
        title: context.l10n.thisMonth,
        iconSystemName: 'calendar',
        icon: CupertinoIcons.calendar,
        showTrailingCheckmark: _isThisMonthActive,
      ),
      IosContextMenuAction(
        id: 'date_last_month',
        title: context.l10n.lastMonth,
        iconSystemName: 'clock.arrow.circlepath',
        icon: CupertinoIcons.clock,
        showTrailingCheckmark: _isLastMonthActive,
      ),
      const IosContextMenuDivider(),
      IosContextMenuAction(
        id: 'date_picker',
        title: context.l10n.customRangeDots,
        iconSystemName: 'calendar.badge.plus',
        icon: CupertinoIcons.calendar_badge_plus,
      ),
      if (hasActiveDateFilter) ...[
        const IosContextMenuDivider(),
        IosContextMenuAction(
          id: 'date_reset',
          title: context.l10n.reset,
          iconSystemName: 'arrow.counterclockwise',
          icon: CupertinoIcons.arrow_counterclockwise,
          destructive: true,
        ),
      ],
    ];
  }

  IconData _getAccountIconData(String accountId) {
    switch (accountId) {
      case 'bank':
        return CupertinoIcons.building_2_fill;
      case 'cash':
        return CupertinoIcons.money_dollar;
      case 'ewallet':
        return CupertinoIcons.device_phone_portrait;
      default:
        return CupertinoIcons.creditcard;
    }
  }

  Widget _buildAccountSelector(bool isDarkMode, bool isAr) {
    final accountActions = <IosContextMenuItem>[
      IosContextMenuAction(
        id: 'acc_all',
        title: isAr ? 'جميع الحسابات' : 'All Accounts',
        iconSystemName: 'creditcard',
        icon: CupertinoIcons.creditcard,
        showTrailingCheckmark: _selectedAccountId == 'all',
      ),
      IosContextMenuAction(
        id: 'acc_bank',
        title: isAr ? 'بنك مصر (Banque Misr)' : 'Banque Misr',
        iconSystemName: 'building.columns',
        icon: CupertinoIcons.building_2_fill,
        showTrailingCheckmark: _selectedAccountId == 'bank',
      ),
      IosContextMenuAction(
        id: 'acc_cash',
        title: isAr ? 'محفظة كاش (Cash)' : 'Cash Wallet',
        iconSystemName: 'banknote',
        icon: CupertinoIcons.money_dollar,
        showTrailingCheckmark: _selectedAccountId == 'cash',
      ),
      IosContextMenuAction(
        id: 'acc_ewallet',
        title: isAr ? 'فودافون كاش (Vodafone Cash)' : 'Vodafone Cash',
        iconSystemName: 'iphone',
        icon: CupertinoIcons.device_phone_portrait,
        showTrailingCheckmark: _selectedAccountId == 'ewallet',
      ),
    ];

    final displayName = _selectedAccountName.isNotEmpty
        ? _selectedAccountName
        : (isAr ? 'جميع الحسابات' : 'All Accounts');

    return IosSingleTapContextMenu(
      actions: accountActions,
      onSelected: (id) => _handleAccountSelection(id, isAr),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getAccountIconData(_selectedAccountId),
              size: 14,
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.7)
                  : const Color(0xFF71717A),
            ),
            const SizedBox(width: 6),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: isDarkMode ? Colors.white : const Color(0xFF09090B),
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              CupertinoIcons.chevron_down,
              size: 11,
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.5)
                  : const Color(0xFF71717A),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAccountSelection(String id, bool isAr) {
    setState(() {
      _selectedAccountId = id;
      if (id == 'acc_all') {
        _selectedAccountName = isAr ? 'جميع الحسابات' : 'All Accounts';
      } else if (id == 'acc_bank') {
        _selectedAccountName = isAr ? 'بنك مصر' : 'Banque Misr';
      } else if (id == 'acc_cash') {
        _selectedAccountName = isAr ? 'محفظة كاش' : 'Cash Wallet';
      } else if (id == 'acc_ewallet') {
        _selectedAccountName = isAr ? 'فودافون كاش' : 'Vodafone Cash';
      }
      _applyFilters();
    });
  }

  Widget _buildDateSelector(
      bool isDarkMode, bool isAr, bool hasActiveDateFilter) {
    final now = DateTime.now();
    String dateText;
    if (hasActiveDateFilter && _fromDate != null && _toDate != null) {
      if (_isTodayActive) {
        dateText = isAr ? 'اليوم' : 'Today';
      } else if (_isThisWeekActive) {
        dateText = isAr ? 'هذا الأسبوع' : 'This Week';
      } else if (_isThisMonthActive) {
        dateText = isAr ? 'هذا الشهر' : 'This Month';
      } else if (_isLastMonthActive) {
        dateText = isAr ? 'الشهر الماضي' : 'Last Month';
      } else {
        dateText =
            '${DateFormat('d MMM', isAr ? 'ar' : 'en_US').format(_fromDate!)} - ${DateFormat('d MMM', isAr ? 'ar' : 'en_US').format(_toDate!)}';
      }
    } else {
      dateText = DateFormat('MMMM yyyy', isAr ? 'ar' : 'en_US').format(now);
    }

    final dateActions = _getDateActions(isAr, hasActiveDateFilter);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IosSingleTapContextMenu(
          actions: dateActions,
          onSelected: _handleMenuAction,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 13,
                  color: hasActiveDateFilter
                      ? const Color(0xFF3B82F6)
                      : (isDarkMode
                          ? Colors.white.withValues(alpha: 0.45)
                          : const Color(0xFF8E8E93)),
                ),
                const SizedBox(width: 5),
                Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    color: hasActiveDateFilter
                        ? const Color(0xFF3B82F6)
                        : (isDarkMode
                            ? Colors.white.withValues(alpha: 0.5)
                            : const Color(0xFF71717A)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasActiveDateFilter)
          GestureDetector(
            onTap: () {
              setState(() {
                _fromDate = null;
                _toDate = null;
              });
              _loadTransactions(page: 1, forceRefresh: true);
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                CupertinoIcons.clear_circled_solid,
                size: 14,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
      ],
    );
  }

  IconData _getCategoryIcon(String? nameEn, String? nameAr, int? categoryId) {
    final lower = (nameEn ?? nameAr ?? '').toLowerCase();
    if (lower.contains('grocer') ||
        lower.contains('سوبرماركت') ||
        lower.contains('بقالة') ||
        lower.contains('مستلزمات')) {
      return CupertinoIcons.cart_fill;
    }
    if (lower.contains('food') ||
        lower.contains('dining') ||
        lower.contains('مطاعم') ||
        lower.contains('كافيه') ||
        lower.contains('طعام')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('salary') ||
        lower.contains('راتب') ||
        lower.contains('دخل')) {
      return CupertinoIcons.money_dollar_circle_fill;
    }
    if (lower.contains('freelance') ||
        lower.contains('عمل حر') ||
        lower.contains('استشارات')) {
      return CupertinoIcons.briefcase_fill;
    }
    if (lower.contains('bill') ||
        lower.contains('فواتير') ||
        lower.contains('إنترنت') ||
        lower.contains('كهرباء') ||
        lower.contains('خدمات')) {
      return CupertinoIcons.doc_text_fill;
    }
    if (lower.contains('shop') ||
        lower.contains('تسوق') ||
        lower.contains('ملابس')) {
      return CupertinoIcons.bag_fill;
    }
    if (lower.contains('entertain') ||
        lower.contains('ترفيه') ||
        lower.contains('سينما') ||
        lower.contains('خروج')) {
      return Icons.movie_rounded;
    }
    if (lower.contains('education') ||
        lower.contains('learning') ||
        lower.contains('تعليم') ||
        lower.contains('دراسة') ||
        lower.contains('كتب')) {
      return CupertinoIcons.book_fill;
    }
    if (lower.contains('bonus') ||
        lower.contains('reward') ||
        lower.contains('gift') ||
        lower.contains('مكافآت') ||
        lower.contains('حوافز') ||
        lower.contains('هدايا')) {
      return CupertinoIcons.gift_fill;
    }
    if (lower.contains('health') ||
        lower.contains('fitness') ||
        lower.contains('صحة') ||
        lower.contains('رياضة') ||
        lower.contains('طبي')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('trans') ||
        lower.contains('مواصلات') ||
        lower.contains('بنزين') ||
        lower.contains('سيارة')) {
      return CupertinoIcons.car_detailed;
    }
    if (lower.contains('invest') ||
        lower.contains('استثمار') ||
        lower.contains('أرباح')) {
      return Icons.trending_up_rounded;
    }
    if (lower.contains('subscript') || lower.contains('اشتراك')) {
      return CupertinoIcons.repeat;
    }
    return CupertinoIcons.tag_fill;
  }

  List<_CategoryFilterItem> _getDistinctCategories() {
    final Map<String, _CategoryFilterItem> map = {};
    for (final t in _transactions) {
      final en = t.categoryNameEn;
      final ar = t.categoryNameAr;
      final key = en ?? ar;
      if (key != null && key.isNotEmpty && !map.containsKey(key)) {
        map[key] = _CategoryFilterItem(
          id: t.categoryId,
          nameEn: en ?? key,
          nameAr: ar ?? key,
          icon: _getCategoryIcon(en, ar, t.categoryId),
        );
      }
    }
    return map.values.toList();
  }

  Widget _buildCategoriesFilterList(bool isDarkMode, bool isAr) {
    final categories = _getDistinctCategories();

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedCategory == null;
            return _buildCategoryChip(
              title: isAr ? 'الكل' : 'All',
              icon: Icons.grid_view_rounded,
              isSelected: isSelected,
              isDarkMode: isDarkMode,
              onTap: () {
                setState(() {
                  _selectedCategory = null;
                  _applyFilters();
                });
              },
            );
          }

          final cat = categories[index - 1];
          final title = isAr ? cat.nameAr : cat.nameEn;
          final isSelected = _selectedCategory == cat.nameEn ||
              _selectedCategory == cat.nameAr;

          return _buildCategoryChip(
            title: title,
            icon: cat.icon,
            isSelected: isSelected,
            isDarkMode: isDarkMode,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedCategory = null;
                } else {
                  _selectedCategory = cat.nameEn;
                }
                _applyFilters();
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String title,
    required IconData icon,
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
            // Smoothly animated icon: 0 width + 0 opacity + 0.3 scale when unselected,
            // expanding gracefully with a bouncy spring curve when selected
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
          ],
        ),
      ),
    );
  }

  Widget _buildSpentReceivedSummary(bool isDarkMode, bool isAr) {
    double totalSpent = 0.0;
    double totalReceived = 0.0;

    for (final tx in _filteredTransactions) {
      final t = tx.type.toLowerCase();
      if (t == 'withdrawal' || t == 'expense') {
        totalSpent += tx.amount;
      } else if (t == 'deposit' || t == 'income') {
        totalReceived += tx.amount;
      }
    }

    return Row(
      children: [
        // Spent Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE4E4E7),
                width: 0.8,
              ),
              boxShadow: isDarkMode
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrow_up_right,
                      size: 13,
                      color: isDarkMode
                          ? const Color(0xFFA1A1AA)
                          : const Color(0xFF71717A),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isAr ? 'المصروفات' : 'Spent',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '-${_formatAmount(totalSpent)}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Received Card (Green money as requested!)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE4E4E7),
                width: 0.8,
              ),
              boxShadow: isDarkMode
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrow_down_left,
                      size: 13,
                      color: isDarkMode
                          ? const Color(0xFF10B981)
                          : const Color(0xFF059669),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isAr ? 'المستلم' : 'Received',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '+${_formatAmount(totalReceived)}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    // Same emerald as the Home "Recent Transactions" rows.
                    color: isDarkMode
                        ? const Color(0xFF10B981)
                        : const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool get _isTodayActive {
    if (_fromDate == null || _toDate == null) return false;
    final now = DateTime.now();
    return _fromDate!.year == now.year &&
        _fromDate!.month == now.month &&
        _fromDate!.day == now.day &&
        _toDate!.year == now.year &&
        _toDate!.month == now.month &&
        _toDate!.day == now.day;
  }

  bool get _isThisWeekActive {
    if (_fromDate == null || _toDate == null) return false;
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return _fromDate!.year == startOfWeek.year &&
        _fromDate!.month == startOfWeek.month &&
        _fromDate!.day == startOfWeek.day;
  }

  bool get _isThisMonthActive {
    if (_fromDate == null || _toDate == null) return false;
    final now = DateTime.now();
    return _fromDate!.year == now.year &&
        _fromDate!.month == now.month &&
        _fromDate!.day == 1 &&
        _toDate!.year == now.year &&
        _toDate!.month == now.month;
  }

  bool get _isLastMonthActive {
    if (_fromDate == null || _toDate == null) return false;
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    return _fromDate!.year == lastMonth.year &&
        _fromDate!.month == lastMonth.month &&
        _fromDate!.day == 1 &&
        _toDate!.year == lastMonth.year &&
        _toDate!.month == lastMonth.month;
  }

  // ================== Top Actions (iOS & Android) ==================

  IconData _getTransactionCupertinoIcon(
      WalletTransaction transaction, bool isIOS) {
    if (!isIOS) return transaction.icon;

    final cat = (transaction.categoryNameEn ?? '').toLowerCase();
    final catAr = (transaction.categoryNameAr ?? '');
    final title = transaction.title.toLowerCase();
    final isIncome = transaction.isDeposit;

    if (cat.contains('food') ||
        cat.contains('dining') ||
        cat.contains('restaurant') ||
        catAr.contains('مطاعم') ||
        catAr.contains('كافيه') ||
        title.contains('starbucks') ||
        title.contains('ستاربكس')) {
      return CupertinoIcons.bag_fill;
    }
    if (cat.contains('grocer') ||
        cat.contains('supermarket') ||
        catAr.contains('سوبرماركت') ||
        catAr.contains('بقالة') ||
        title.contains('كارفور') ||
        title.contains('carrefour')) {
      return CupertinoIcons.cart_fill;
    }
    if (cat.contains('salary') ||
        cat.contains('income') ||
        catAr.contains('راتب') ||
        catAr.contains('دخل')) {
      return CupertinoIcons.money_dollar_circle_fill;
    }
    if (cat.contains('freelance') ||
        cat.contains('consult') ||
        catAr.contains('حر') ||
        catAr.contains('مشروع')) {
      return CupertinoIcons.briefcase_fill;
    }
    if (cat.contains('shop') ||
        cat.contains('retail') ||
        cat.contains('cloth') ||
        catAr.contains('تسوق') ||
        catAr.contains('ملابس') ||
        title.contains('zara')) {
      return CupertinoIcons.bag_fill;
    }
    if (cat.contains('transport') ||
        cat.contains('car') ||
        cat.contains('fuel') ||
        cat.contains('gas') ||
        catAr.contains('مواصلات') ||
        catAr.contains('سيار') ||
        catAr.contains('بنزين')) {
      return CupertinoIcons.car_detailed;
    }
    if (cat.contains('bill') ||
        cat.contains('utilit') ||
        cat.contains('internet') ||
        catAr.contains('فواتير') ||
        catAr.contains('إنترنت')) {
      return CupertinoIcons.doc_text_fill;
    }
    if (cat.contains('entertain') ||
        cat.contains('subscript') ||
        cat.contains('stream') ||
        catAr.contains('ترفيه') ||
        catAr.contains('اشتراك') ||
        title.contains('netflix')) {
      return CupertinoIcons.film_fill;
    }
    if (cat.contains('health') ||
        cat.contains('medic') ||
        cat.contains('pharm') ||
        catAr.contains('صحة') ||
        catAr.contains('صيدلية')) {
      return CupertinoIcons.heart_fill;
    }
    if (cat.contains('educat') ||
        cat.contains('school') ||
        cat.contains('course') ||
        catAr.contains('تعليم') ||
        catAr.contains('دراسة')) {
      return CupertinoIcons.book_fill;
    }

    return isIncome
        ? CupertinoIcons.arrow_down_left
        : CupertinoIcons.arrow_up_right;
  }

  Widget _buildIosTopActions(bool isDarkMode, bool hasActiveDateFilter) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final iconColor = isDarkMode ? Colors.white : const Color(0xFF09090B);

    final dateActions = <IosContextMenuItem>[
      IosContextMenuAction(
        id: 'date_today',
        title: isAr ? 'اليوم' : 'Today',
        iconSystemName: 'sun.max',
        icon: CupertinoIcons.sun_max,
        showTrailingCheckmark: _isTodayActive,
      ),
      IosContextMenuAction(
        id: 'date_this_week',
        title: isAr ? 'هذا الأسبوع' : 'This Week',
        iconSystemName: 'calendar.badge.clock',
        icon: CupertinoIcons.calendar_badge_plus,
        showTrailingCheckmark: _isThisWeekActive,
      ),
      IosContextMenuAction(
        id: 'date_this_month',
        title: context.l10n.thisMonth,
        iconSystemName: 'calendar',
        icon: CupertinoIcons.calendar,
        showTrailingCheckmark: _isThisMonthActive,
      ),
      IosContextMenuAction(
        id: 'date_last_month',
        title: context.l10n.lastMonth,
        iconSystemName: 'clock.arrow.circlepath',
        icon: CupertinoIcons.clock,
        showTrailingCheckmark: _isLastMonthActive,
      ),
      const IosContextMenuDivider(),
      IosContextMenuAction(
        id: 'date_picker',
        title: context.l10n.customRangeDots,
        iconSystemName: 'calendar.badge.plus',
        icon: CupertinoIcons.calendar_badge_plus,
      ),
      if (hasActiveDateFilter) ...[
        const IosContextMenuDivider(),
        IosContextMenuAction(
          id: 'date_reset',
          title: context.l10n.reset,
          iconSystemName: 'arrow.counterclockwise',
          icon: CupertinoIcons.arrow_counterclockwise,
          destructive: true,
        ),
      ],
    ];

    final moreActions = <IosContextMenuItem>[
      // Transaction Type Filters
      IosContextMenuAction(
        id: 'filter_all',
        title: context.l10n.all,
        iconSystemName: 'tray.2',
        icon: CupertinoIcons.tray_2,
        showTrailingCheckmark: _selectedType == null,
      ),
      IosContextMenuAction(
        id: 'filter_income',
        title: context.l10n.income,
        iconSystemName: 'arrow.down.left',
        icon: CupertinoIcons.arrow_down_left,
        showTrailingCheckmark: _selectedType == 'Deposit',
      ),
      IosContextMenuAction(
        id: 'filter_expense',
        title: context.l10n.expense,
        iconSystemName: 'arrow.up.right',
        icon: CupertinoIcons.arrow_up_right,
        showTrailingCheckmark: _selectedType == 'Withdrawal',
      ),
      const IosContextMenuDivider(),

      // Sort Options
      IosContextMenuAction(
        id: 'sort_newest',
        title: isAr ? 'الأحدث أولاً' : 'Newest First',
        iconSystemName: 'arrow.down',
        icon: CupertinoIcons.arrow_down,
        showTrailingCheckmark: _sortBy == 'newest',
      ),
      IosContextMenuAction(
        id: 'sort_oldest',
        title: isAr ? 'الأقدم أولاً' : 'Oldest First',
        iconSystemName: 'arrow.up',
        icon: CupertinoIcons.arrow_up,
        showTrailingCheckmark: _sortBy == 'oldest',
      ),
      IosContextMenuAction(
        id: 'sort_highest',
        title: isAr ? 'الأعلى قيمة' : 'Highest Amount',
        iconSystemName: 'chart.line.uptrend.xyaxis',
        icon: CupertinoIcons.graph_square,
        showTrailingCheckmark: _sortBy == 'highest',
      ),
      const IosContextMenuDivider(),

      // Refresh
      IosContextMenuAction(
        id: 'refresh',
        title: isAr ? 'تحديث' : 'Refresh',
        iconSystemName: 'arrow.clockwise',
        icon: CupertinoIcons.arrow_clockwise,
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
              // Date Button with Context Menu (Icon only)
              IosSingleTapContextMenu(
                actions: dateActions,
                onSelected: _handleMenuAction,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  color: Colors.transparent,
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 22,
                          color: hasActiveDateFilter
                              ? const Color(0xFF3B82F6)
                              : iconColor,
                        ),
                        if (hasActiveDateFilter)
                          Positioned(
                            top: -2,
                            right: -3,
                            child: Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3-dots with iOS Native Menu (ellipsis_circle matching reference)
              IosSingleTapContextMenu(
                actions: moreActions,
                onSelected: _handleMenuAction,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.only(left: 12, right: 16),
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(
                      CupertinoIcons.ellipsis_circle,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidTopActions(bool isDarkMode, bool hasActiveDateFilter) {
    final borderColor = AppSurfaces.border(isDarkMode);
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final iconColor = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

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
              // Date button with popup menu (icon only)
              PopupMenuButton<String>(
                padding: const EdgeInsets.only(left: 14, right: 10),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                tooltip: isAr ? 'تصفية بالتاريخ' : 'Filter by date',
                icon: Stack(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: hasActiveDateFilter
                          ? const Color(0xFF3B82F6)
                          : iconColor,
                    ),
                    if (hasActiveDateFilter)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 6.5,
                          height: 6.5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: cardBg,
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'date_today',
                    child: Text(isAr ? 'اليوم' : 'Today'),
                  ),
                  PopupMenuItem(
                    value: 'date_this_week',
                    child: Text(isAr ? 'هذا الأسبوع' : 'This Week'),
                  ),
                  PopupMenuItem(
                    value: 'date_this_month',
                    child: Text(context.l10n.thisMonth),
                  ),
                  PopupMenuItem(
                    value: 'date_last_month',
                    child: Text(context.l10n.lastMonth),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'date_picker',
                    child: Text(context.l10n.customRangeDots),
                  ),
                  if (hasActiveDateFilter) ...[
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'date_reset',
                      child: Text(
                        context.l10n.reset,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
              // 3-dots popup menu
              PopupMenuButton<String>(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
                icon: Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: iconColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: cardBg,
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'filter_all',
                    child: Text(context.l10n.all),
                  ),
                  PopupMenuItem(
                    value: 'filter_income',
                    child: Text(context.l10n.income),
                  ),
                  PopupMenuItem(
                    value: 'filter_expense',
                    child: Text(context.l10n.expense),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'sort_newest',
                    child: Text(isAr ? 'الأحدث أولاً' : 'Newest First'),
                  ),
                  PopupMenuItem(
                    value: 'sort_oldest',
                    child: Text(isAr ? 'الأقدم أولاً' : 'Oldest First'),
                  ),
                  PopupMenuItem(
                    value: 'sort_highest',
                    child: Text(isAr ? 'الأعلى قيمة' : 'Highest Amount'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'refresh',
                    child: Text(isAr ? 'تحديث' : 'Refresh'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String id) {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    switch (id) {
      case 'filter_all':
        _setType(null);
        break;
      case 'filter_income':
        _setType('Deposit');
        break;
      case 'filter_expense':
        _setType('Withdrawal');
        break;
      case 'date_today':
        setState(() {
          _fromDate = DateTime(now.year, now.month, now.day);
          _toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        });
        _loadTransactions(page: 1, forceRefresh: true);
        break;
      case 'date_this_week':
        final startOfWeek =
            DateTime(now.year, now.month, now.day - (now.weekday - 1));
        setState(() {
          _fromDate = startOfWeek;
          _toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        });
        _loadTransactions(page: 1, forceRefresh: true);
        break;
      case 'date_this_month':
        setState(() {
          _fromDate = DateTime(now.year, now.month, 1);
          _toDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        });
        _loadTransactions(page: 1, forceRefresh: true);
        break;
      case 'date_last_month':
        setState(() {
          _fromDate = DateTime(now.year, now.month - 1, 1);
          _toDate = DateTime(now.year, now.month, 0, 23, 59, 59);
        });
        _loadTransactions(page: 1, forceRefresh: true);
        break;
      case 'date_picker':
        _showFilterDialog();
        break;
      case 'date_reset':
        setState(() {
          _fromDate = null;
          _toDate = null;
        });
        _loadTransactions(page: 1, forceRefresh: true);
        break;
      case 'sort_newest':
        setState(() {
          _sortBy = 'newest';
          _applySort();
        });
        break;
      case 'sort_oldest':
        setState(() {
          _sortBy = 'oldest';
          _applySort();
        });
        break;
      case 'sort_highest':
        setState(() {
          _sortBy = 'highest';
          _applySort();
        });
        break;
      case 'refresh':
        _refreshData();
        break;
    }
  }

  // ================== Search Bar (Android) ==================

  Widget _buildAndroidSearchBar(bool isDarkMode) {
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

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
              focusNode: _searchFocusNode,
              keyboardAppearance: isDarkMode ? Brightness.dark : Brightness.light,
              decoration: InputDecoration(
                hintText: context.l10n.searchTransactions,
                hintStyle: TextStyle(
                  color: isDarkMode
                      ? const Color(0xFFA1A1AA)
                      : const Color(0xFF71717A),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
                _applySearchFilter();
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_rounded,
                size: 18,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              onPressed: _clearSearch,
            ),
        ],
      ),
    );
  }

  // ================== Type Filter Helpers ==================

  void _setType(String? value) {
    if (_selectedType == value) return;
    setState(() {
      _selectedType = value;
      _currentPage = 1;
    });
    _loadTransactions(page: 1, forceRefresh: true);
  }

  // ================== Lists (iOS vs Android) ==================

  String _getDateGroupTitle(DateTime txDate, DateTime now, bool isAr) {
    final today = DateTime(now.year, now.month, now.day);
    final txMidnight = DateTime(txDate.year, txDate.month, txDate.day);
    final diffDays = today.difference(txMidnight).inDays;

    if (diffDays < 0) {
      return isAr ? 'قريباً' : 'Upcoming';
    } else if (diffDays == 0) {
      return isAr ? 'اليوم' : 'Today';
    } else if (diffDays == 1) {
      return isAr ? 'أمس' : 'Yesterday';
    } else if (diffDays > 1 && diffDays < 7) {
      return isAr ? 'هذا الأسبوع' : 'This Week';
    } else if (diffDays >= 7 && diffDays < 14) {
      return isAr ? 'الأسبوع الماضي' : 'Last Week';
    } else if (txDate.year == now.year && txDate.month == now.month) {
      return isAr ? 'هذا الشهر' : 'Earlier This Month';
    } else if (txDate.year == now.year) {
      return DateFormat('MMMM', isAr ? 'ar' : 'en_US').format(txDate);
    } else {
      return DateFormat('MMMM yyyy', isAr ? 'ar' : 'en_US').format(txDate);
    }
  }

  /// Same grouping rules as [_buildGroupedItems], but keeps each date bucket
  /// together so iOS can render it as one inset-grouped card.
  List<_DateSection> _buildSections(bool isAr) {
    if (_filteredTransactions.isEmpty) return const [];

    final now = DateTime.now();
    final sorted = List<WalletTransaction>.from(_filteredTransactions)
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    final sections = <_DateSection>[];
    for (final tx in sorted) {
      final title = _getDateGroupTitle(tx.transactionDate, now, isAr);
      if (sections.isEmpty || sections.last.title != title) {
        sections.add(_DateSection(title, [tx]));
      } else {
        sections.last.transactions.add(tx);
      }
    }
    return sections;
  }

  Widget _buildSectionBlock(
    _DateSection section,
    bool isDarkMode, {
    required bool isFirst,
  }) {
    final borderColor =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDateSectionHeader(
          section.title,
          section.transactions.length,
          isDarkMode,
          isFirst: isFirst,
        ),
        Container(
          decoration: AppSurfaces.cardDecoration(
            isDarkMode: isDarkMode,
            radius: 20,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < section.transactions.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 72,
                    endIndent: 16,
                    color: borderColor,
                  ),
                _buildTransactionCard(
                  section.transactions[i],
                  isDarkMode,
                  isGlass: true,
                  grouped: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<_GroupedListItem> _buildGroupedItems(bool isAr) {
    if (_filteredTransactions.isEmpty) return const [];

    final now = DateTime.now();
    // Sort descending by date to ensure proper chronological order of groups
    final sortedList = List<WalletTransaction>.from(_filteredTransactions)
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    final map = <String, List<WalletTransaction>>{};
    for (final tx in sortedList) {
      final group = _getDateGroupTitle(tx.transactionDate, now, isAr);
      (map[group] ??= []).add(tx);
    }

    final items = <_GroupedListItem>[];
    map.forEach((title, txList) {
      items.add(_GroupedListItem.header(
        headerTitle: title,
        count: txList.length,
      ));
      for (final tx in txList) {
        items.add(_GroupedListItem.transaction(tx));
      }
    });

    return items;
  }

  Widget _buildDateSectionHeader(
    String title,
    int count,
    bool isDarkMode, {
    bool isFirst = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, isFirst ? 6 : 20, 4, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.85)
                      : const Color(0xFF27272A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIosList(bool isDarkMode, bool hasActiveDateFilter) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final listBottom =
        (bottomPadding > 0 ? bottomPadding + 70 : 80) + bottomInset;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    // iOS renders each date bucket as one grouped card.
    final sections = _buildSections(isAr);

    return SlidableAutoCloseBehavior(
      closeWhenOpened: true,
      closeWhenTapped: true,
      child: CustomScrollView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: _refreshData,
          ),
          SliverToBoxAdapter(
            child: _buildScrollableHeader(
              isDarkMode: isDarkMode,
              isIOS: true,
              hasActiveDateFilter: hasActiveDateFilter,
            ),
          ),
          if (_isLoading)
            SliverToBoxAdapter(child: _buildShimmerLoading())
          else if (_errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildErrorState(),
            )
          else if (_filteredTransactions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _searchQuery.isNotEmpty
                  ? Center(
                      child: GlassContentUnavailableView.search(
                        query: _searchQuery,
                        onClear: _clearSearch,
                      ),
                    )
                  : _buildEmptyState(isDarkMode),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, listBottom),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < sections.length) {
                      return _buildSectionBlock(
                        sections[index],
                        isDarkMode,
                        isFirst: index == 0,
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                    }
                  },
                  childCount: sections.length + (_isLoadingMore ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAndroidList(bool isDarkMode, bool hasActiveDateFilter) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final listBottom =
        (bottomPadding > 0 ? bottomPadding + 24 : 32) + bottomInset;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final groupedItems = _buildGroupedItems(isAr);

    return SlidableAutoCloseBehavior(
      closeWhenOpened: true,
      closeWhenTapped: true,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: isDarkMode ? Colors.white : Colors.black,
        child: CustomScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildScrollableHeader(
                isDarkMode: isDarkMode,
                isIOS: false,
                hasActiveDateFilter: hasActiveDateFilter,
              ),
            ),
            if (_isLoading)
              SliverToBoxAdapter(child: _buildShimmerLoading())
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(),
              )
            else if (_filteredTransactions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _searchQuery.isNotEmpty
                    ? Center(
                        child: GlassContentUnavailableView.search(
                          query: _searchQuery,
                          onClear: _clearSearch,
                        ),
                      )
                    : _buildEmptyState(isDarkMode),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, listBottom),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < groupedItems.length) {
                        final item = groupedItems[index];
                        if (item.isHeader) {
                          return _buildDateSectionHeader(
                            item.headerTitle ?? '',
                            item.count,
                            isDarkMode,
                            isFirst: index == 0,
                          );
                        }
                        return _buildTransactionCard(
                          item.transaction!,
                          isDarkMode,
                          isGlass: false,
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                    childCount: groupedItems.length +
                        (_isLoadingMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================== Transaction Card ==================

  Widget _buildTransactionCard(
    WalletTransaction transaction,
    bool isDarkMode, {
    required bool isGlass,
    bool grouped = false,
  }) {
    final isIOS = Platform.isIOS;
    final isIncome = transaction.isDeposit;
    final locale = Localizations.localeOf(context).languageCode;
    final categoryName = locale == 'ar'
        ? (transaction.categoryNameAr ?? transaction.categoryNameEn ?? '')
        : (transaction.categoryNameEn ?? transaction.categoryNameAr ?? '');

    return Padding(
      // Grouped rows sit flush inside the shared card.
      padding: EdgeInsets.only(bottom: grouped ? 0 : 10),
      child: Slidable(
        key: Key('trans_page_${transaction.id}'),
        groupTag: 'trans_page_list',
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.28,
          children: [
            CustomSlidableAction(
              onPressed: (_) {
                HapticFeedback.mediumImpact();
                _showDeleteDialog(transaction);
              },
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              borderRadius: grouped ? BorderRadius.zero : BorderRadius.circular(18),
              padding: EdgeInsets.zero,
              child: const Icon(
                CupertinoIcons.trash_fill,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
        child: Container(
          // Grouped rows inherit the shared card from the date section.
          decoration: grouped
              ? null
              : isGlass
                  ? BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.85),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDarkMode ? 0.25 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    )
                  : AppSurfaces.cardDecoration(
                      isDarkMode: isDarkMode,
                      radius: 18,
                    ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: grouped ? BorderRadius.zero : BorderRadius.circular(18),
              onTap: () async {
                HapticFeedback.selectionClick();
                final edit = widget.onEditTransaction;
                if (edit == null) return;
                await edit(transaction);
                if (!mounted) return;
                await _refreshData();
              },
              onLongPress: () {
                _showDeleteDialog(transaction);
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Category Mono Icon Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF27272A)
                            : const Color(0xFFE4E4E7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getTransactionCupertinoIcon(transaction, isIOS),
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & Category/Date info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (categoryName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              categoryName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 3),
                          InferredWalletLabel(
                            transaction: transaction,
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Amount · Date (date sits under the price)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${isIncome ? '+' : '-'}${_formatAmount(transaction.amount)}',
                          textDirection: ui.TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: isIncome
                                ? (isDarkMode
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF059669))
                                : (isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF18181B)),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatDate(transaction.transactionDate, context),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================== States & Dialogs ==================

  Widget _buildErrorState() {
    return AppErrorState(
      message: _errorMessage ?? 'Failed to load transactions',
      onRetry: _refreshData,
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.search,
                size: 48,
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
              const SizedBox(height: 16),
              Text(
                'No results for "$_searchQuery"',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                onPressed: _clearSearch,
                child: const Text('Clear search'),
              ),
            ],
          ),
        ),
      );
    }

    return AppEmptyState(
      message: context.l10n.noTransactions,
    );
  }

  void _showDeleteDialog(WalletTransaction transaction) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (Platform.isIOS) {
      NeoAlertDialog.show(
        context: context,
        title: context.l10n.deleteTransaction,
        message: context.l10n.confirmDeleteTransaction(transaction.title),
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
              try {
                await _walletRepository.deleteTransaction(transaction.id);
                await _refreshData();
                if (mounted) {
                  MessageService.showSuccess(
                    context: context,
                    message: context.l10n.transactionDeletedSuccess,
                  );
                }
              } catch (e) {
                if (mounted) {
                  MessageService.showError(
                    context: context,
                    message:
                        context.l10n.failedToDeleteWithError(e.toString()),
                  );
                }
              }
            },
          ),
        ],
      );
      return;
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDarkMode ? const Color(0xFF18181B) : Colors.white,
        title: Text(
          context.l10n.deleteTransaction,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          context.l10n.confirmDeleteTransaction(transaction.title),
          style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _walletRepository.deleteTransaction(transaction.id);
                await _refreshData();
                if (context.mounted) {
                  MessageService.showSuccess(
                    context: context,
                    message: context.l10n.transactionDeletedSuccess,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  MessageService.showError(
                    context: context,
                    message:
                        context.l10n.failedToDeleteWithError(e.toString()),
                  );
                }
              }
            },
            child: Text(
              context.l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final locale = isAr ? 'ar' : 'en_US';

    final isToday = transactionDate == today;
    final isYesterday = transactionDate == today.subtract(const Duration(days: 1));

    // Rows under the "Today" / "Yesterday" section headers only need the time.
    if (isToday || isYesterday) {
      return DateFormat('h:mm a', locale).format(date);
    }

    // Older: "Tue 3:40 AM"
    return DateFormat('EEE, h:mm a', locale).format(date);
  }

  // ================== Shimmer Loading ==================

  Widget _buildShimmerLoading() {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: const [
            _ShimmerTransactionCard(),
            _ShimmerTransactionCard(),
            _ShimmerTransactionCard(),
            _ShimmerTransactionCard(),
            _ShimmerTransactionCard(),
            _ShimmerTransactionCard(),
            _ShimmerTransactionCard(),
          ],
        ),
      ),
    );
  }
}

class _ShimmerTransactionCard extends StatelessWidget {
  const _ShimmerTransactionCard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SkeletonBox(width: 44, height: 44, borderRadius: 14),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 130, height: 16, borderRadius: 6),
                SizedBox(height: 8),
                SkeletonBox(width: 80, height: 12, borderRadius: 4),
              ],
            ),
          ),
          SkeletonBox(width: 65, height: 18, borderRadius: 6),
        ],
      ),
    );
  }
}
