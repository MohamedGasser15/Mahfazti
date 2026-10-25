import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';

/// Full-page currency picker screen with real-time bilingual search,
/// country flags, full currency names, currency codes, and symbols.
class CurrencyPickerScreen extends StatefulWidget {
  final String? initialCurrency;

  const CurrencyPickerScreen({
    super.key,
    this.initialCurrency,
  });

  /// Convenient helper to push this screen with native platform transitions.
  static Future<String?> open(
    BuildContext context, {
    String? initialCurrency,
  }) {
    if (Platform.isIOS) {
      return Navigator.push<String>(
        context,
        CupertinoPageRoute(
          builder: (_) => CurrencyPickerScreen(
            initialCurrency: initialCurrency,
          ),
        ),
      );
    } else {
      return Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => CurrencyPickerScreen(
            initialCurrency: initialCurrency,
          ),
        ),
      );
    }
  }

  @override
  State<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends State<CurrencyPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.initialCurrency?.toUpperCase() ?? 'EGP';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onCurrencySelected(String code) {
    HapticFeedback.selectionClick();
    setState(() => _selectedCode = code);
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;

    final bgColor = isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final secondaryTextColor =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    final filteredCurrencies = kAllCurrencies
        .where((c) => c.matches(_searchQuery))
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 52,
        leadingWidth: 58,
        leading: const AppGlassBackButton(),
        centerTitle: true,
        title: Text(
          isAr ? 'اختيار العملة' : 'Select Currency',
          style: TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: primaryTextColor,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 4),

            // Search Bar
            _buildSearchBar(isDarkMode, isAr, cardBg, borderColor, secondaryTextColor),

            const SizedBox(height: 12),

            // Currencies List
            Expanded(
              child: filteredCurrencies.isEmpty
                  ? _buildEmptyState(isDarkMode, isAr, primaryTextColor, secondaryTextColor)
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        16,
                        4,
                        16,
                        safeAreaBottom > 0 ? safeAreaBottom + 40 : 50,
                      ),
                      itemCount: filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = filteredCurrencies[index];
                        final isSelected = currency.code == _selectedCode;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildCurrencyTile(
                            currency: currency,
                            isSelected: isSelected,
                            isDarkMode: isDarkMode,
                            isAr: isAr,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
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

  // ==========================================
  // SEARCH BAR
  // ==========================================
  Widget _buildSearchBar(
    bool isDarkMode,
    bool isAr,
    Color cardBg,
    Color borderColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          keyboardAppearance: isDarkMode ? Brightness.dark : Brightness.light,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          cursorColor: isDarkMode ? Colors.white : Colors.black,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: secondaryTextColor,
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: secondaryTextColor,
                    ),
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 36, minHeight: 40),
            hintText: isAr
                ? 'بحث بالاسم، الكود، أو الرمز (مثال: EGP, دولار)...'
                : 'Search by name, code, or symbol (e.g. EGP, USD)...',
            hintStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: secondaryTextColor,
            ),
          ),
          onChanged: (val) {
            setState(() => _searchQuery = val.trim());
          },
        ),
      ),
    );
  }

  // ==========================================
  // CURRENCY LIST TILE
  // ==========================================
  Widget _buildCurrencyTile({
    required AppCurrency currency,
    required bool isSelected,
    required bool isDarkMode,
    required bool isAr,
    required Color cardBg,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final symbol = isAr ? currency.symbolAr : currency.symbol;
    final fullName = isAr ? currency.nameAr : currency.nameEn;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onCurrencySelected(currency.code),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.05))
                : cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDarkMode ? Colors.white : Colors.black)
                  : borderColor,
              width: isSelected ? 1.5 : 1.0,
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
          child: Row(
            children: [
              // 1. Flag Avatar Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    currency.flag,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // 2. Code & Full Name Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currency.code,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // 3. Currency Symbol Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFF4F4F6),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                ),
              ),

              // 4. Selection Checkmark
              if (isSelected) ...[
                const SizedBox(width: 10),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // EMPTY SEARCH STATE
  // ==========================================
  Widget _buildEmptyState(
    bool isDarkMode,
    bool isAr,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 42,
              color: secondaryTextColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              isAr ? 'لم يتم العثور على عملة مطابقة' : 'No matching currencies found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAr
                  ? 'جرب البحث بكود مختلف (مثال: EGP, USD, SAR)'
                  : 'Try searching with another code or name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isAr ? 'مسح البحث' : 'Clear Search',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
