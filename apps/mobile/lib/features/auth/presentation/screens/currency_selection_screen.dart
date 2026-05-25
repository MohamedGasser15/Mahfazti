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
    with TickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  String? _selectedCurrency;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

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
    _loadCurrentCurrency();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );

    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );

    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    _fadeController.forward();
  }

  Future<void> _loadCurrentCurrency() async {
    final code = await SharedPrefs.getCurrency();
    setState(() {
      _selectedCurrency = code;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrency() async {
    if (_selectedCurrency == null) {
      MessageService.showWarning(context: context, message: context.l10n.selectCurrencyWarning);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = SharedPrefs.authToken;
      if (token == null) throw Exception('No token found');

      await _authRepository.setUserCurrency(_selectedCurrency!);
      await SharedPrefs.setCurrency(_selectedCurrency!);

      if (mounted) {
        MessageService.showSuccess(context: context, message: context.l10n.currencySavedSuccess);
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
      if (!mounted) return;
      MessageService.showError(context: context, message: '${context.l10n.failedToSaveCurrency}: ${e.toString()}');
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
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
            Navigator.pop(context);
          },
        ),
        title: null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Logo
              SlideTransition(
                position: _logoSlide,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title & Subtitle
              SlideTransition(
                position: _titleSlide,
                child: FadeTransition(
                  opacity: _titleFade,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          context.l10n.selectCurrency,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          context.l10n.selectCurrencyDescription,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Currency list
              SlideTransition(
                position: _formSlide,
                child: FadeTransition(
                  opacity: _formFade,
                  child: SizedBox(
                    height: 380,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
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
                                ? theme.colorScheme.primary.withValues(alpha: 0.05)
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
                                        : theme.colorScheme.outline.withValues(alpha: 0.2),
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
                                            color: Colors.black.withValues(alpha: 0.05),
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
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
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
                ),
              ),

              const SizedBox(height: 24),

              // Button
              SlideTransition(
                position: _buttonSlide,
                child: FadeTransition(
                  opacity: _buttonFade,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCurrency,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                        disabledForegroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.4),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black26,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(context.l10n.continueText, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
