import 'dart:io';
import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/constants/app_routes.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/app_lock_service.dart';
import 'package:my_wallet/core/services/biometric_service.dart';
import 'package:my_wallet/core/services/hide_balance_service.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/services/theme_service.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/language_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:my_wallet/features/profile/data/models/user_profile.dart';
import 'package:my_wallet/features/profile/data/repositories/profile_repository.dart';
import 'package:my_wallet/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsContent extends StatefulWidget {
  final Function(Locale) onLocaleChanged;

  const SettingsContent({
    super.key,
    required this.onLocaleChanged,
  });

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  bool _isEnglish = true;
  String _currentTheme = 'system';
  String _currencyCode = 'USD';
  UserProfile? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCurrency();
    _loadProfile();

    ThemeService.themeNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) {
      _loadCurrentTheme();
    }
  }

  @override
  void dispose() {
    ThemeService.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  // Load Currency
  Future<void> _loadCurrency() async {
    final code = await SharedPrefs.getCurrency();
    if (mounted) {
      setState(() {
        _currencyCode = code ?? 'USD';
      });
    }
  }

  // Load Profile with fast cache-first approach
  Future<void> _loadProfile({bool forceRefresh = false}) async {
    if (_profile != null && !forceRefresh) return;

    final cached = await ProfileRepository().getCachedProfile();
    if (cached != null && !forceRefresh) {
      if (mounted) {
        setState(() {
          _profile = cached;
          _isLoadingProfile = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingProfile = true);
      }
    }

    try {
      final fresh = await ProfileRepository().getProfile();
      if (mounted && fresh != _profile) {
        setState(() => _profile = fresh);
      }
    } catch (_) {
      // Keep cached data if API fails
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  void _onProfileUpdated() {
    _loadProfile(forceRefresh: true);
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // Currency Selection Modal
  void _openCurrencySelection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final itemBorder = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final selectedBg = const Color(0xFF3B82F6).withValues(alpha: isDarkMode ? 0.14 : 0.08);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? tempSelected = _currencyCode;

        final List<Map<String, String>> currencies = [
          {'code': 'USD', 'flag': '🇺🇸', 'name': 'US Dollar'},
          {'code': 'EUR', 'flag': '🇪🇺', 'name': 'Euro'},
          {'code': 'EGP', 'flag': '🇪🇬', 'name': 'Egyptian Pound'},
          {'code': 'SAR', 'flag': '🇸🇦', 'name': 'Saudi Riyal'},
          {'code': 'AED', 'flag': '🇦🇪', 'name': 'UAE Dirham'},
          {'code': 'KWD', 'flag': '🇰🇼', 'name': 'Kuwaiti Dinar'},
        ];
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                border: Border(
                  top: BorderSide(
                    color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    height: 4,
                    width: 36,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 6, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.selectCurrency,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Currency List
                  ...currencies.map((currency) {
                    final isSelected = tempSelected == currency['code'];
                    return GestureDetector(
                      onTap: () => setModalState(() => tempSelected = currency['code']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedBg
                              : (isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF9F9FB)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF3B82F6) : itemBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Flag
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF1F1F5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  currency['flag']!,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Name & Code
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currency['name']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currency['code']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Check
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: isSelected
                                  ? Container(
                                      key: const ValueKey('check'),
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF3B82F6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const SizedBox(key: ValueKey('empty'), width: 24),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Save Button
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      16,
                      18,
                      MediaQuery.of(context).padding.bottom + 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final currentContext = context;
                                if (tempSelected == null) return;
                                setModalState(() => isSubmitting = true);
                                try {
                                  await AuthRepository().setUserCurrency(tempSelected!);
                                  await SharedPrefs.setCurrency(tempSelected!);
                                  setState(() => _currencyCode = tempSelected!);
                                  if (!currentContext.mounted) return;
                                  Navigator.pop(currentContext);
                                  MessageService.showSuccess(
                                    context: currentContext,
                                    message: currentContext.l10n.currencySavedSuccess,
                                  );
                                } catch (e) {
                                  if (!currentContext.mounted) return;
                                  MessageService.showError(
                                    context: currentContext,
                                    message: e.toString(),
                                  );
                                  setModalState(() => isSubmitting = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.white : const Color(0xFF09090B),
                          foregroundColor: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                context.l10n.save,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadSettings() async {
    final locale = await LanguageService.getSavedLocale();
    await _loadCurrentTheme();
    if (mounted) {
      setState(() {
        _isEnglish = LanguageService.isEnglish(locale);
      });
    }
  }

  Future<void> _loadCurrentTheme() async {
    final theme = await ThemeService.getSavedTheme();
    if (mounted) {
      setState(() {
        _currentTheme = theme;
      });
    }
  }

  Future<void> _switchToArabic() async {
    await LanguageService.switchToArabic();
    if (mounted) {
      setState(() {
        _isEnglish = false;
      });
    }
    widget.onLocaleChanged(LanguageService.arabic);
  }

  Future<void> _switchToEnglish() async {
    await LanguageService.switchToEnglish();
    if (mounted) {
      setState(() {
        _isEnglish = true;
      });
    }
    widget.onLocaleChanged(LanguageService.english);
  }

  Future<void> _setTheme(String theme) async {
    await ThemeService.saveTheme(theme);
  }

  // External Links
  Future<void> _openStore() async {
    const appStoreUrl = 'https://apps.apple.com/app/idYOUR_APP_ID';
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME';

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
          await launchUrl(Uri.parse(appStoreUrl));
        }
      } else {
        if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
          await launchUrl(Uri.parse(playStoreUrl));
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('${context.l10n.cannotOpenStore}: $e');
    }
  }

  Future<void> _openFacebook() async {
    const url = 'https://facebook.com/YOUR_PAGE';
    await _launchUrl(url);
  }

  Future<void> _openTwitter() async {
    const url = 'https://twitter.com/YOUR_PAGE';
    await _launchUrl(url);
  }

  Future<void> _openInstagram() async {
    const url = 'https://instagram.com/YOUR_PAGE';
    await _launchUrl(url);
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://yourwebsite.com/privacy';
    await _launchUrl(url);
  }

  Future<void> _openTerms() async {
    const url = 'https://yourwebsite.com/terms';
    await _launchUrl(url);
  }

  Future<void> _launchUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (!mounted) return;
        _showErrorSnackbar(context.l10n.cannotOpenUrl);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('${context.l10n.error}: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    MessageService.showError(context: context, message: message);
  }

  void _showComingSoonSnackbar() {
    MessageService.showInfo(context: context, message: context.l10n.featureComingSoon);
  }

  // Theme Toggle (Native CupertinoSwitch)
  Widget _buildThemeToggle(bool isDarkMode) {
    final isDark = _currentTheme == ThemeService.dark || (_currentTheme == ThemeService.system && isDarkMode);
    return CupertinoSwitch(
      value: isDark,
      activeTrackColor: const Color(0xFF3B82F6),
      onChanged: (value) {
        HapticFeedback.selectionClick();
        final newTheme = value ? ThemeService.dark : ThemeService.light;
        setState(() => _currentTheme = newTheme);
        _setTheme(newTheme);
      },
    );
  }

  // Language Button (Native iOS UIMenu on iOS / Material PopupMenuButton on Android)
  Widget _buildLanguageButton() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Platform.isIOS;
    String currentLanguageLabel = _isEnglish ? context.l10n.english : context.l10n.arabic;

    if (isIOS) {
      return Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CNPopupMenuButton(
              buttonLabel: currentLanguageLabel,
              height: 28,
              tint: isDarkMode ? Colors.white : const Color(0xFF09090B),
              shrinkWrap: true,
              buttonStyle: CNButtonStyle.plain,
              items: [
                CNPopupMenuItem(
                  label: 'العربية',
                  icon: const CNSymbol('globe', size: 16.0),
                  checked: !_isEnglish,
                ),
                CNPopupMenuItem(
                  label: 'English',
                  icon: const CNSymbol('globe', size: 16.0),
                  checked: _isEnglish,
                ),
              ],
              onSelected: (index) {
                HapticFeedback.selectionClick();
                if (index == 0) {
                  _switchToArabic();
                } else if (index == 1) {
                  _switchToEnglish();
                }
              },
            ),
            const SizedBox(width: 2),
            IgnorePointer(
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
              ),
            ),
          ],
        ),
      );
    }

    // Android / Other Platforms: Styled Material PopupMenuButton
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          shadowColor: Colors.black.withValues(alpha: 0.25),
        ),
      ),
      child: PopupMenuButton<bool>(
        tooltip: context.l10n.selectLanguage,
        offset: const Offset(0, 36),
        position: PopupMenuPosition.under,
        elevation: 8,
        color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFE4E4E7),
            width: 1,
          ),
        ),
        splashRadius: 18,
        padding: EdgeInsets.zero,
        onSelected: (isEnglish) {
          HapticFeedback.selectionClick();
          if (isEnglish) {
            _switchToEnglish();
          } else {
            _switchToArabic();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<bool>(
            value: false,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.arabic,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: !_isEnglish ? FontWeight.w700 : FontWeight.w500,
                      color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                    ),
                  ),
                ),
                if (!_isEnglish) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                  ),
                ],
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<bool>(
            value: true,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.english,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _isEnglish ? FontWeight.w700 : FontWeight.w500,
                      color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                    ),
                  ),
                ),
                if (_isEnglish) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                  ),
                ],
              ],
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentLanguageLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD':
        return context.l10n.currencyUSD;
      case 'EUR':
        return context.l10n.currencyEUR;
      case 'EGP':
        return context.l10n.currencyEGP;
      case 'SAR':
        return context.l10n.currencySAR;
      case 'AED':
        return context.l10n.currencyAED;
      case 'KWD':
        return context.l10n.currencyKWD;
      default:
        return code;
    }
  }

  // Section Container Helper
  Widget _buildSectionContainer({
    required bool isDarkMode,
    required String title,
    required List<Widget> children,
  }) {
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final headerColor = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: headerColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
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
            children: children,
          ),
        ),
      ],
    );
  }

  // Setting Item Helper
  Widget _buildSettingTile({
    required bool isDarkMode,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDanger = false,
    bool showDivider = true,
  }) {
    final titleColor = isDanger
        ? const Color(0xFFEF4444)
        : (isDarkMode ? Colors.white : const Color(0xFF09090B));
    final subColor = isDanger
        ? const Color(0xFFEF4444).withValues(alpha: 0.75)
        : (isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A));
    final dividerColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF1F1F5);
    final chevronColor = isDanger
        ? const Color(0xFFEF4444)
        : (isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA));

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: iconColor.withValues(alpha: 0.08),
            highlightColor: iconColor.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isDarkMode ? 0.16 : 0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 19,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: subColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (trailing != null)
                    trailing
                  else if (onTap != null)
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
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 68, right: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: dividerColor,
            ),
          ),
      ],
    );
  }

  // Profile Header Card
  Widget _buildProfileHeader(bool isDarkMode) {
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final subtitleColor = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final pillBg = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final pillBorder = isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7);
    final pillText = isDarkMode ? Colors.white : const Color(0xFF09090B);

    final initials = _getInitials(_profile?.fullName);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Avatar with gradient ring
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                image: _profile?.profileImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(_profile!.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profile?.profileImageUrl == null
                  ? Center(
                      child: initials.isNotEmpty
                          ? Text(
                              initials,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            )
                          : Icon(
                              Icons.person_rounded,
                              size: 34,
                              color: titleColor,
                            ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Name, Email & Edit Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isLoadingProfile
                      ? context.l10n.loading
                      : (_profile?.fullName.isNotEmpty == true
                          ? _profile!.fullName
                          : context.l10n.user),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _profile?.email ?? context.l10n.emailPlaceholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                // Manage / Edit pill button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileEditScreen(
                            onProfileUpdated: _onProfileUpdated,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: pillBorder, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 13,
                            color: pillText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.l10n.manage,
                            style: TextStyle(
                              color: pillText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // App Settings Section
  Widget _buildAppSettings(bool isDarkMode) {
    return _buildSectionContainer(
      isDarkMode: isDarkMode,
      title: context.l10n.app,
      children: [
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          iconColor: isDarkMode ? const Color(0xFF8B5CF6) : const Color(0xFFF59E0B),
          title: context.l10n.darkMode,
          subtitle: isDarkMode ? context.l10n.dark : context.l10n.light,
          trailing: _buildThemeToggle(isDarkMode),
          onTap: () {
            HapticFeedback.selectionClick();
            final newTheme = isDarkMode ? ThemeService.light : ThemeService.dark;
            setState(() => _currentTheme = newTheme);
            _setTheme(newTheme);
          },
        ),
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.payments_outlined,
          iconColor: const Color(0xFF10B981),
          title: context.l10n.currency,
          subtitle: _getCurrencyName(_currencyCode),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currencyCode,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                ),
              ],
            ),
          ),
          onTap: _openCurrencySelection,
          showDivider: false,
        ),
      ],
    );
  }

  // Profile Settings Section
  Widget _buildProfileSettings(bool isDarkMode) {
    return _buildSectionContainer(
      isDarkMode: isDarkMode,
      title: context.l10n.profileSettings,
      children: [
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF3B82F6),
          title: context.l10n.personalDetails,
          subtitle: context.l10n.updateYourPersonalInformation,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileEditScreen(
                  onProfileUpdated: _onProfileUpdated,
                ),
              ),
            );
          },
        ),
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF06B6D4),
          title: context.l10n.appLanguage,
          subtitle: context.l10n.changeAppLanguage,
          trailing: _buildLanguageButton(),
          showDivider: false,
        ),
      ],
    );
  }

  // Security Settings Section
  Widget _buildSecuritySettings(bool isDarkMode) {
    final hideService = Provider.of<HideBalanceService>(context);
    final appLockService = Provider.of<AppLockService>(context);

    return _buildSectionContainer(
      isDarkMode: isDarkMode,
      title: context.l10n.security,
      children: [
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.visibility_off_outlined,
          iconColor: const Color(0xFFF59E0B),
          title: context.l10n.hideBalances,
          subtitle: context.l10n.hideYourBalancesForPrivacy,
          trailing: CupertinoSwitch(
            value: hideService.isHidden,
            activeTrackColor: const Color(0xFF3B82F6),
            onChanged: (value) => hideService.setHidden(value),
          ),
          showDivider: true,
        ),
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.lock_outline_rounded,
          iconColor: const Color(0xFF6366F1),
          title: context.l10n.appLock,
          subtitle: context.l10n.appLockSubtitle,
          trailing: CupertinoSwitch(
            value: appLockService.isEnabled,
            activeTrackColor: const Color(0xFF3B82F6),
            onChanged: (value) async {
              final success = await appLockService.setAppLock(
                value,
                localizedReason: context.l10n.appLockPrompt,
              );
              if (!success && mounted) {
                final isAvailable = await BiometricService.isDeviceLockAvailable();
                if (!isAvailable && mounted) {
                  MessageService.showWarning(
                    context: context,
                    message: context.l10n.appLockDeviceNotSupported,
                  );
                } else if (mounted) {
                  MessageService.showError(
                    context: context,
                    message: context.l10n.biometricAuthenticationFailed,
                  );
                }
              }
            },
          ),
          showDivider: false,
        ),
      ],
    );
  }

  // About Us Section
  Widget _buildAboutUsSection(bool isDarkMode) {
    return _buildSectionContainer(
      isDarkMode: isDarkMode,
      title: context.l10n.aboutUs,
      children: [
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFF59E0B),
          title: context.l10n.rateUsOnAppStorePlayStore,
          onTap: _openStore,
        ),
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.thumb_up_alt_rounded,
          iconColor: const Color(0xFF2563EB),
          title: context.l10n.likeUsOnFacebook,
          onTap: _openFacebook,
        ),
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.public_rounded,
          iconColor: const Color(0xFF0EA5E9),
          title: context.l10n.followUsOnTwitter,
          onTap: _openTwitter,
        ),
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.camera_alt_rounded,
          iconColor: const Color(0xFFE1306C),
          title: context.l10n.followUsOnInstagram,
          onTap: _openInstagram,
        ),
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.privacy_tip_outlined,
          iconColor: const Color(0xFF64748B),
          title: context.l10n.privacyPolicy,
          onTap: _openPrivacyPolicy,
        ),
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF64748B),
          title: context.l10n.termsConditions,
          onTap: _openTerms,
          showDivider: false,
        ),
      ],
    );
  }

  // Close Account Section
  Widget _buildCloseAccountSection(bool isDarkMode) {
    return _buildSectionContainer(
      isDarkMode: isDarkMode,
      title: context.l10n.account,
      children: [
        _buildSettingTile(
          isDarkMode: isDarkMode,
          icon: Icons.delete_outline_rounded,
          iconColor: const Color(0xFFEF4444),
          title: context.l10n.closeAccount,
          subtitle: context.l10n.permanentlyDeleteYourAccount,
          isDanger: true,
          onTap: () => _showCloseAccountDialog(isDarkMode),
          showDivider: false,
        ),
      ],
    );
  }

  void _showCloseAccountDialog(bool isDarkMode) {
    final dialogBg = isDarkMode ? const Color(0xFF141418) : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            width: 1,
          ),
        ),
        title: Text(
          context.l10n.closeAccount,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : const Color(0xFF09090B),
          ),
        ),
        content: Text(
          context.l10n.closeAccountConfirmation,
          style: TextStyle(
            color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(
                color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonSnackbar();
            },
            child: Text(
              context.l10n.closeAccount,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logout Button
  Widget _buildLogoutButton(bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: isDarkMode ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: isDarkMode ? 0.25 : 0.20),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.logout,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(bool isDarkMode) {
    final sheetBg = isDarkMode ? const Color(0xFF141418) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          14,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 30,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 18),

            Text(
              context.l10n.logout,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: isDarkMode ? Colors.white : const Color(0xFF09090B),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              context.l10n.logoutConfirmation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Confirm Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.l10n.logout,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  context.l10n.cancel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    try {
      await AuthRepository().logout();
    } catch (_) {
      await SharedPrefs.removeAuthToken();
      await SharedPrefs.removeUserData();
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.onboarding,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ResponsiveWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card Header
            _buildProfileHeader(isDarkMode),
            const SizedBox(height: 24),

            // App Section
            _buildAppSettings(isDarkMode),
            const SizedBox(height: 24),

            // Profile Settings Section
            _buildProfileSettings(isDarkMode),
            const SizedBox(height: 24),

            // Security Section
            _buildSecuritySettings(isDarkMode),
            const SizedBox(height: 24),

            // About Us Section
            _buildAboutUsSection(isDarkMode),
            const SizedBox(height: 24),

            // Close Account Section
            _buildCloseAccountSection(isDarkMode),
            const SizedBox(height: 28),

            // Logout Button
            _buildLogoutButton(isDarkMode),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}