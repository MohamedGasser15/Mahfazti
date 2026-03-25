import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';

class CurrencySelectionScreen extends StatefulWidget {
  const CurrencySelectionScreen({super.key});

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen>
    with SingleTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  String? _selectedCurrency;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, String>> currencies = const [
    {'code': 'USD', 'nameKey': 'currencyUSD', 'flag': '🇺🇸'},
    {'code': 'EUR', 'nameKey': 'currencyEUR', 'flag': '🇪🇺'},
    {'code': 'EGP', 'nameKey': 'currencyEGP', 'flag': '🇪🇬'},
    {'code': 'SAR', 'nameKey': 'currencySAR', 'flag': '🇸🇦'},
    {'code': 'AED', 'nameKey': 'currencyAED', 'flag': '🇦🇪'},
    {'code': 'KWD', 'nameKey': 'currencyKWD', 'flag': '🇰🇼'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentCurrency(); // تحميل العملة الحالية إذا وجدت
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  Future<void> _loadCurrentCurrency() async {
    final code = await SharedPrefs.getCurrency();
    setState(() {
      _selectedCurrency = code;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrency() async {
    if (_selectedCurrency == null) {
      MessageService.showWarning(context.l10n.selectCurrencyWarning);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = SharedPrefs.authToken;
      if (token == null) throw Exception('No token found');

      await _authRepository.setUserCurrency(_selectedCurrency!);
      await SharedPrefs.setCurrency(_selectedCurrency!);

      if (mounted) {
        MessageService.showSuccess(context.l10n.currencySavedSuccess);
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      MessageService.showError('${context.l10n.failedToSaveCurrency}: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getCurrencyName(String? nameKey) {
    switch (nameKey) {
      case 'currencyUSD': return context.l10n.currencyUSD;
      case 'currencyEUR': return context.l10n.currencyEUR;
      case 'currencyEGP': return context.l10n.currencyEGP;
      case 'currencySAR': return context.l10n.currencySAR;
      case 'currencyAED': return context.l10n.currencyAED;
      case 'currencyKWD': return context.l10n.currencyKWD;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () {
            // ✅ ببساطة نعود للشاشة السابقة
            Navigator.pop(context);
          },
        ),
        title: null,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.selectCurrency,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.selectCurrencyDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Expanded(
                    child: ListView.builder(
                      itemCount: currencies.length,
                      itemBuilder: (context, index) {
                        final currency = currencies[index];
                        final isSelected = _selectedCurrency == currency['code'];
                        final currencyName = _getCurrencyName(currency['nameKey']);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                setState(() {
                                  _selectedCurrency = currency['code'];
                                });
                                HapticFeedback.selectionClick();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline.withOpacity(0.2),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          currency['flag']!,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currencyName,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            currency['code']!,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onBackground
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: isDark ? Colors.black : Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCurrency,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(context.l10n.continueText),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}