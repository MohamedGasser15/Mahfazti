import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:neo_cupertino/neo_cupertino.dart';

import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/core/widgets/app_icon_picker_modal.dart';
import 'package:my_wallet/features/wallet/data/repositories/bank_repository.dart';
import 'package:my_wallet/features/wallet/presentation/screens/bank_picker_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/currency_picker_screen.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/home_tab_models.dart';

/// Navigation steps for the Add Account wizard
enum AddAccountStep {
  selectType,             // Step 1: Type selection
  selectPropertyCategory, // If Investment/Property: pick MMF, Apartment, Car, etc.
  fundAnnualYield,        // For MMF: what does it pay a year
  assetValueChange,       // For Apartment/Car/Business/Other: does value change on its own
  selectStocksCryptoPlatform, // For Stocks & Crypto: pick EGX, US, Crypto, Other
  selectEWallet,          // If E-Wallet: pick Vodafone, Orange, Etisalat, WE, Other
  selectNotifyMethod,     // If Debit/Credit: SMS vs Notification
  enterSmsCardNumbers,    // If SMS: enter card digits + examples + skip
  details,                // Final details form
}

/// Property and investment categories
enum PropertyCategory {
  moneyMarketFund,
  apartment,
  car,
  business,
  stocksCrypto,
  somethingElse,
}

/// Configuration definition for each account / wallet type in monochrome style.
class AccountTypeDefinition {
  final String id;
  final String section; // 'spend' or 'own'
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final IconData icon;
  final String namePlaceholderAr;
  final String namePlaceholderEn;
  final String? extraFieldLabelAr;
  final String? extraFieldLabelEn;
  final String? extraFieldPlaceholderAr;
  final String? extraFieldPlaceholderEn;
  final TextInputType extraFieldKeyboardType;

  const AccountTypeDefinition({
    required this.id,
    required this.section,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.icon,
    required this.namePlaceholderAr,
    required this.namePlaceholderEn,
    this.extraFieldLabelAr,
    this.extraFieldLabelEn,
    this.extraFieldPlaceholderAr,
    this.extraFieldPlaceholderEn,
    this.extraFieldKeyboardType = TextInputType.text,
  });
}

const List<AccountTypeDefinition> kAccountTypeDefinitions = [
  // SECTION 1: MONEY YOU CAN SPEND
  AccountTypeDefinition(
    id: 'bank',
    section: 'spend',
    titleAr: 'كارت خصم مباشر أو حساب بنكي',
    titleEn: 'Debit Card',
    subtitleAr: 'حساب بنكي جاري أو توفير، أو كارت خصم للسحب والمشتريات.',
    subtitleEn: 'A debit card or bank transfer account.',
    icon: Icons.wallet_outlined,
    namePlaceholderAr: 'مثال: CIB، البنك الأهلي، بنك مصر',
    namePlaceholderEn: 'e.g. CIB, NBE, HSBC',
  ),
  AccountTypeDefinition(
    id: 'credit_card',
    section: 'spend',
    titleAr: 'كارت مشتريات (ائتمان)',
    titleEn: 'Credit Card',
    subtitleAr: 'تتبع المصاريف والمديونية مقابل الحد الائتماني (Limit).',
    subtitleEn: 'Tracks spending against a credit limit.',
    icon: Icons.credit_card_outlined,
    namePlaceholderAr: 'مثال: CIB تيتانيوم، مشتريات الأهلي',
    namePlaceholderEn: 'e.g. CIB Titanium, NBE Platinum',
  ),
  AccountTypeDefinition(
    id: 'cash',
    section: 'spend',
    titleAr: 'كاش ونقدي',
    titleEn: 'Cash',
    subtitleAr: 'بدون بنك أو رسائل — تسجله بنفسك في أي وقت.',
    subtitleEn: 'No bank, no texts — you log it yourself.',
    icon: Icons.payments_outlined,
    namePlaceholderAr: 'مثال: فلوس الجيب، محفظة العربية، درج البيت',
    namePlaceholderEn: 'e.g. Pocket Cash, Home Drawer',
  ),
  AccountTypeDefinition(
    id: 'ewallet',
    section: 'spend',
    titleAr: 'محفظة إلكترونية',
    titleEn: 'E-wallet',
    subtitleAr: 'فودافون كاش، أورانج كاش، إنستاباي وما شابه.',
    subtitleEn: 'Vodafone Cash, Orange Cash, and similar.',
    icon: Icons.smartphone_outlined,
    namePlaceholderAr: 'مثال: فودافون كاش الأساسي، محفظة إنستاباي',
    namePlaceholderEn: 'e.g. Vodafone Cash, InstaPay',
  ),
  AccountTypeDefinition(
    id: 'savings',
    section: 'spend',
    titleAr: 'خزنة ادخار أو جمعية',
    titleEn: 'Savings or Gam\'eya',
    subtitleAr: 'فلوس مجمدة لهدف معين، تحويشة سفر أو جمعية شهرية.',
    subtitleEn: 'Locked funds for a goal, emergency, or Gam\'eya.',
    icon: Icons.savings_outlined,
    namePlaceholderAr: 'مثال: حصالة الطوارئ، جمعية البيت',
    namePlaceholderEn: 'e.g. Emergency Fund, Home Gam\'eya',
    extraFieldLabelAr: 'المبلغ المستهدف توفيره (اختياري)',
    extraFieldLabelEn: 'Target Savings Goal (optional)',
    extraFieldPlaceholderAr: 'مثال: 100,000',
    extraFieldPlaceholderEn: 'e.g. 100,000',
    extraFieldKeyboardType: TextInputType.number,
  ),

  // SECTION 2: THINGS YOU OWN
  AccountTypeDefinition(
    id: 'investment',
    section: 'own',
    titleAr: 'أصول واستثمار',
    titleEn: 'Property or investment',
    subtitleAr: 'شقة، عربية، بيزنس، أسهم أو صندوق استثماري.',
    subtitleEn: 'An apartment, a car, a business, a fund.',
    icon: Icons.view_in_ar_outlined,
    namePlaceholderAr: 'مثال: محفظة ثندر (Thndr)، صندوق استثماري',
    namePlaceholderEn: 'e.g. Thndr Portfolio, Mutual Fund',
    extraFieldLabelAr: 'نوع الأصل أو الملاحظة (اختياري)',
    extraFieldLabelEn: 'Asset Type / Note (optional)',
    extraFieldPlaceholderAr: 'مثال: محفظة أسهم البورصة',
    extraFieldPlaceholderEn: 'e.g. Stock Market Portfolio',
    extraFieldKeyboardType: TextInputType.text,
  ),
  AccountTypeDefinition(
    id: 'certificate',
    section: 'own',
    titleAr: 'شهادة بنكية أو وديعة',
    titleEn: 'Bank Certificate (CD)',
    subtitleAr: 'شهادات ادخار وودائع بعائد شهري أو سنوي.',
    subtitleEn: 'Certificates of deposit or fixed-term bank deposits.',
    icon: Icons.verified_outlined,
    namePlaceholderAr: 'مثال: شهادة البنك الأهلي 27%، شهادة بنك مصر',
    namePlaceholderEn: 'e.g. NBE 27% Certificate, Banque Misr CD',
    extraFieldLabelAr: 'نسبة العائد أو تاريخ الاستحقاق (اختياري)',
    extraFieldLabelEn: 'Yield % or Maturity Date (optional)',
    extraFieldPlaceholderAr: 'مثال: عائد 27% سنوي - يستحق 2027',
    extraFieldPlaceholderEn: 'e.g. 27% Annual Yield - Matures 2027',
    extraFieldKeyboardType: TextInputType.text,
  ),
  AccountTypeDefinition(
    id: 'gold',
    section: 'own',
    titleAr: 'ذهب وملاذ آمن',
    titleEn: 'Gold',
    subtitleAr: 'سبائك أو جنيهات ذهب، مقيمة بسعر اليوم.',
    subtitleEn: 'Bars or jewellery, valued at today\'s price.',
    icon: Icons.diamond_outlined,
    namePlaceholderAr: 'مثال: ذهب العائلة، ذهب الادخار',
    namePlaceholderEn: 'e.g. Family Gold, Savings Bullion',
  ),
  AccountTypeDefinition(
    id: 'silver',
    section: 'own',
    titleAr: 'فضة وسبائك',
    titleEn: 'Silver',
    subtitleAr: 'سبائك أو جنيهات وعملات فضة، مقيمة بسعر اليوم.',
    subtitleEn: 'Bars or coins, valued at today\'s price.',
    icon: Icons.circle_outlined,
    namePlaceholderAr: 'مثال: سبائك فضة، فضة الادخار',
    namePlaceholderEn: 'e.g. Silver Bars, Silver Savings',
  ),
];

class EWalletProvider {
  final String id;
  final String titleAr;
  final String titleEn;
  final String prefix;
  final IconData icon;

  const EWalletProvider({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.prefix,
    required this.icon,
  });
}

const List<EWalletProvider> kEWalletProviders = [
  EWalletProvider(
    id: 'vodafone',
    titleAr: 'فودافون كاش',
    titleEn: 'Vodafone Cash',
    prefix: '010',
    icon: Icons.phone_iphone_rounded,
  ),
  EWalletProvider(
    id: 'instapay',
    titleAr: 'إنستاباي (InstaPay)',
    titleEn: 'InstaPay',
    prefix: 'IP',
    icon: Icons.send_to_mobile_rounded,
  ),
  EWalletProvider(
    id: 'orange',
    titleAr: 'أورانج كاش',
    titleEn: 'Orange Cash',
    prefix: '012',
    icon: Icons.phone_android_rounded,
  ),
  EWalletProvider(
    id: 'etisalat',
    titleAr: 'اتصالات كاش (e&)',
    titleEn: 'Etisalat Cash (e&)',
    prefix: '011',
    icon: Icons.cell_tower_rounded,
  ),
  EWalletProvider(
    id: 'wepay',
    titleAr: 'وي باي (WE Pay)',
    titleEn: 'WE Pay',
    prefix: '015',
    icon: Icons.payment_rounded,
  ),
  EWalletProvider(
    id: 'telda',
    titleAr: 'تيلدا (Telda)',
    titleEn: 'Telda',
    prefix: 'Telda',
    icon: Icons.credit_card_rounded,
  ),
  EWalletProvider(
    id: 'fawry',
    titleAr: 'ماي فوري (myfawry)',
    titleEn: 'myfawry',
    prefix: 'Fawry',
    icon: Icons.account_balance_wallet_rounded,
  ),
  EWalletProvider(
    id: 'other',
    titleAr: 'محفظة أخرى',
    titleEn: 'Other E-Wallet',
    prefix: 'أخرى',
    icon: Icons.account_balance_wallet_outlined,
  ),
];

const List<String> kSupportedCurrenciesList = [
  'EGP',
  'USD',
  'EUR',
  'SAR',
  'AED',
  'KWD',
];

/// AddAccountScreen in clean monochrome (black & white) styling.
class AddAccountScreen extends StatefulWidget {
  final String currencyCode;
  final bool thingsYouOwnFirst;

  const AddAccountScreen({
    super.key,
    this.currencyCode = 'EGP',
    this.thingsYouOwnFirst = false,
  });

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final List<AddAccountStep> _stepHistory = [AddAccountStep.selectType];
  AddAccountStep get _currentStep => _stepHistory.last;

  String _selectedTypeId = 'bank';
  late IconData _selectedIcon;
  late String _selectedCurrency;
  bool _hasUserManuallySelectedIcon = false;
  String? _autoGuessReason;

  IconData? _guessIconFromName(String text) {
    final clean = text.trim().toLowerCase();
    if (clean.isEmpty) return null;

    // Gold / Jewelry
    if (clean.contains('ذهب') || clean.contains('gold') || clean.contains('سبيك') || clean.contains('عيار')) {
      return Icons.diamond_outlined;
    }
    // Silver / Bullion
    if (clean.contains('فضة') || clean.contains('فضه') || clean.contains('silver')) {
      return Icons.circle_outlined;
    }
    // Bank Certificate / Deposit
    if (clean.contains('شهادة') || clean.contains('شهاده') || clean.contains('وديعة') || clean.contains('وديعه') || clean.contains('certificate') || clean.contains('cd')) {
      return Icons.verified_outlined;
    }
    // Car / Vehicle / Fuel
    if (clean.contains('عرب') || clean.contains('سيار') || clean.contains('car') || clean.contains('بنزين') || clean.contains('أوبر') || clean.contains('uber')) {
      return Icons.directions_car_rounded;
    }
    // Home / Apartment / Rent / Real Estate
    if (clean.contains('بيت') || clean.contains('شقة') || clean.contains('منزل') || clean.contains('home') || clean.contains('إيجار') || clean.contains('عقار')) {
      return Icons.home_rounded;
    }
    // Travel / Flight / Vacation
    if (clean.contains('سفر') || clean.contains('رحل') || clean.contains('طيران') || clean.contains('travel') || clean.contains('flight') || clean.contains('مصيف') || clean.contains('تذاكر')) {
      return Icons.flight_takeoff_rounded;
    }
    // Savings / Gam'eya / Emergency
    if (clean.contains('جمعية') || clean.contains('حصالة') || clean.contains('تحويش') || clean.contains('توفير') || clean.contains('savings')) {
      return Icons.savings_rounded;
    }
    // Emergency / Safety / Protection
    if (clean.contains('طوارئ') || clean.contains('أمان') || clean.contains('حماية') || clean.contains('emergency') || clean.contains('تأمين')) {
      return Icons.shield_outlined;
    }
    // Stocks / Trading / Crypto / Funds / Thndr
    if (clean.contains('أسهم') || clean.contains('بورصة') || clean.contains('ثندر') || clean.contains('thndr') || clean.contains('تداول') || clean.contains('صندوق') || clean.contains('crypto') || clean.contains('بيتكوين') || clean.contains('استثمار') || clean.contains('أرباح')) {
      return Icons.trending_up_rounded;
    }
    // Cash / Pocket / Wallet
    if (clean.contains('كاش') || clean.contains('نقدي') || clean.contains('جيب') || clean.contains('cash') || clean.contains('درج') || clean.contains('فكة')) {
      return Icons.payments_outlined;
    }
    // Mobile Wallets / InstaPay / Telda
    if (clean.contains('فودافون') || clean.contains('vodafone') || clean.contains('أورانج') || clean.contains('orange') || clean.contains('اتصالات') || clean.contains('etisalat') || clean.contains('we pay') || clean.contains('وي باي') || clean.contains('إنستاباي') || clean.contains('instapay') || clean.contains('تيلدا') || clean.contains('telda') || clean.contains('كلافر')) {
      return Icons.smartphone_outlined;
    }
    // Credit Card / Shopping Card
    if (clean.contains('كريدت') || clean.contains('credit') || clean.contains('مشتريات') || clean.contains('فيزا') || clean.contains('تيتانيوم') || clean.contains('بلاتينيوم') || clean.contains('gold card')) {
      return Icons.credit_card_rounded;
    }
    // Bank Account / Debit
    if (clean.contains('بنك') || clean.contains('bank') || clean.contains('cib') || clean.contains('أهلي') || clean.contains('nbe') || clean.contains('مصر') || clean.contains('qnb') || clean.contains('hsbc') || clean.contains('إسكندرية') || clean.contains('حساب جاري') || clean.contains('حساب توفير')) {
      return Icons.account_balance_rounded;
    }
    // Shopping / Grocery
    if (clean.contains('شراء') || clean.contains('تسوق') || clean.contains('shop') || clean.contains('سوق') || clean.contains('كارفور') || clean.contains('هايبر')) {
      return Icons.shopping_bag_outlined;
    }
    // Gift
    if (clean.contains('هدية') || clean.contains('gift')) {
      return Icons.card_giftcard_rounded;
    }
    // Gym / Sports
    if (clean.contains('جيم') || clean.contains('gym') || clean.contains('رياضة') || clean.contains('تمرين')) {
      return Icons.fitness_center_rounded;
    }
    // Food / Restaurant / Cafe
    if (clean.contains('مطعم') || clean.contains('أكل') || clean.contains('طعام') || clean.contains('food') || clean.contains('كافيه') || clean.contains('قهوة') || clean.contains('cafe') || clean.contains('coffee')) {
      return Icons.restaurant_rounded;
    }
    // Medical / Pharmacy / Health
    if (clean.contains('صيدلية') || clean.contains('دواء') || clean.contains('دكتور') || clean.contains('علاج') || clean.contains('مستشفى') || clean.contains('health') || clean.contains('medical')) {
      return Icons.medical_services_rounded;
    }
    // School / Education
    if (clean.contains('مدرسة') || clean.contains('جامعة') || clean.contains('كورس') || clean.contains('تعليم') || clean.contains('دراسة') || clean.contains('school')) {
      return Icons.school_rounded;
    }
    // Salary / Work
    if (clean.contains('راتب') || clean.contains('مرتب') || clean.contains('شغل') || clean.contains('عمل') || clean.contains('وظيفة') || clean.contains('salary')) {
      return Icons.work_rounded;
    }
    // Bills / Electricity / Utilities
    if (clean.contains('كهرباء') || clean.contains('غاز') || clean.contains('مياه') || clean.contains('فاتورة') || clean.contains('نور') || clean.contains('bills')) {
      return Icons.lightbulb_rounded;
    }

    return null;
  }

  void _handleNameChanged(String val) {
    if (!_hasUserManuallySelectedIcon) {
      final guessed = _guessIconFromName(val);
      if (guessed != null) {
        _selectedIcon = guessed;
        _autoGuessReason = val.trim();
      } else if (val.trim().isEmpty) {
        _selectedIcon = _selectedType.icon;
        _autoGuessReason = null;
      }
    }
    setState(() {});
  }

  // E-Wallet state
  String? _selectedEWallet;

  // Debit & Credit notification & SMS state
  String? _selectedNotifyMethod; // 'sms' or 'notification'
  final List<String> _smsCardNumbers = [];
  final TextEditingController _smsNumberInputController = TextEditingController();
  final FocusNode _smsNumberFocusNode = FocusNode();
  bool _showSmsExamples = false;

  // Bank & Credit Card fields
  String? _selectedBank;
  static const int _defaultBillingDay = 25;
  static const int _defaultDueDay = 15;

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _creditLimitController = TextEditingController();
  final TextEditingController _billingDayController = TextEditingController();
  final TextEditingController _dueDayController = TextEditingController();
  final TextEditingController _availableBalanceController = TextEditingController();
  final TextEditingController _minPaymentController = TextEditingController();
  final TextEditingController _extraFieldController = TextEditingController();

  // Precious Metals (Gold & Silver)
  final TextEditingController _metalWeightController = TextEditingController();
  final TextEditingController _metalPurchasePriceController = TextEditingController();
  final FocusNode _metalWeightFocusNode = FocusNode();
  final FocusNode _metalPurchasePriceFocusNode = FocusNode();
  String _selectedMetalKarat = '21';
  DateTime? _metalPurchaseDate;
  bool _autoUpdateMetalPrice = true;

  // Property & Investment wizard state
  PropertyCategory? _selectedPropertyCategory;
  String? _selectedStocksPlatform;
  final TextEditingController _investedAmountController = TextEditingController();
  final FocusNode _investedAmountFocusNode = FocusNode();
  final TextEditingController _fundYieldController = TextEditingController();
  final FocusNode _fundYieldFocusNode = FocusNode();
  bool _autoEstimateValue = false; // false = update myself, true = yes about X%
  String _reminderPeriod = 'monthly'; // 'monthly', '3_months', '6_months', 'never'
  final TextEditingController _estimateRateController = TextEditingController();
  final FocusNode _estimateRateFocusNode = FocusNode();
  String _estimateDirection = 'up'; // 'up' or 'down'
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  // Focus Nodes
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _balanceFocusNode = FocusNode();
  final FocusNode _creditLimitFocusNode = FocusNode();
  final FocusNode _billingDayFocusNode = FocusNode();
  final FocusNode _dueDayFocusNode = FocusNode();
  final FocusNode _availableBalanceFocusNode = FocusNode();
  final FocusNode _minPaymentFocusNode = FocusNode();
  final FocusNode _extraFieldFocusNode = FocusNode();

  // Additional Account Options (Toggles)
  bool _excludeFromTotal = false;
  bool _receiveAtmWithdrawals = false;
  bool _autoAddInstapayFee = false;

  bool _isSubmitting = false;

  AccountTypeDefinition get _selectedType =>
      kAccountTypeDefinitions.firstWhere(
        (t) => t.id == _selectedTypeId,
        orElse: () => kAccountTypeDefinitions.first,
      );

  @override
  void initState() {
    super.initState();
    _selectedIcon = kAccountTypeDefinitions.first.icon;
    _selectedCurrency = widget.currencyCode.isNotEmpty ? widget.currencyCode : 'EGP';

    _nameFocusNode.addListener(_onFocusChange);
    _balanceFocusNode.addListener(_onFocusChange);
    _creditLimitFocusNode.addListener(_onFocusChange);
    _billingDayFocusNode.addListener(_onFocusChange);
    _dueDayFocusNode.addListener(_onFocusChange);
    _availableBalanceFocusNode.addListener(_onFocusChange);
    _minPaymentFocusNode.addListener(_onFocusChange);
    _extraFieldFocusNode.addListener(_onFocusChange);
    _smsNumberFocusNode.addListener(_onFocusChange);
    _metalWeightFocusNode.addListener(_onFocusChange);
    _metalPurchasePriceFocusNode.addListener(_onFocusChange);
    _fundYieldFocusNode.addListener(_onFocusChange);
    _estimateRateFocusNode.addListener(_onFocusChange);
    _noteFocusNode.addListener(_onFocusChange);
    _investedAmountFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameFocusNode.removeListener(_onFocusChange);
    _balanceFocusNode.removeListener(_onFocusChange);
    _creditLimitFocusNode.removeListener(_onFocusChange);
    _billingDayFocusNode.removeListener(_onFocusChange);
    _dueDayFocusNode.removeListener(_onFocusChange);
    _availableBalanceFocusNode.removeListener(_onFocusChange);
    _minPaymentFocusNode.removeListener(_onFocusChange);
    _extraFieldFocusNode.removeListener(_onFocusChange);
    _smsNumberFocusNode.removeListener(_onFocusChange);
    _metalWeightFocusNode.removeListener(_onFocusChange);
    _metalPurchasePriceFocusNode.removeListener(_onFocusChange);
    _fundYieldFocusNode.removeListener(_onFocusChange);
    _estimateRateFocusNode.removeListener(_onFocusChange);
    _noteFocusNode.removeListener(_onFocusChange);
    _investedAmountFocusNode.removeListener(_onFocusChange);

    _smsNumberInputController.dispose();
    _smsNumberFocusNode.dispose();
    _nameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    _billingDayController.dispose();
    _dueDayController.dispose();
    _availableBalanceController.dispose();
    _minPaymentController.dispose();
    _extraFieldController.dispose();
    _metalWeightController.dispose();
    _metalPurchasePriceController.dispose();
    _fundYieldController.dispose();
    _estimateRateController.dispose();
    _noteController.dispose();
    _investedAmountController.dispose();

    _nameFocusNode.dispose();
    _balanceFocusNode.dispose();
    _creditLimitFocusNode.dispose();
    _billingDayFocusNode.dispose();
    _dueDayFocusNode.dispose();
    _availableBalanceFocusNode.dispose();
    _minPaymentFocusNode.dispose();
    _investedAmountFocusNode.dispose();
    _extraFieldFocusNode.dispose();
    _metalWeightFocusNode.dispose();
    _metalPurchasePriceFocusNode.dispose();
    _fundYieldFocusNode.dispose();
    _estimateRateFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _pushStep(AddAccountStep step) {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    setState(() {
      _stepHistory.add(step);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (step == AddAccountStep.fundAnnualYield) {
        _fundYieldFocusNode.requestFocus();
      } else if (step == AddAccountStep.assetValueChange) {
        if (_autoEstimateValue) {
          _estimateRateFocusNode.requestFocus();
        }
      } else if (step == AddAccountStep.details) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _onBackTapped() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    if (_stepHistory.length > 1) {
      setState(() {
        _stepHistory.removeLast();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onTypeSelected(AccountTypeDefinition typeDef) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTypeId = typeDef.id;
      _selectedIcon = typeDef.icon;
      _hasUserManuallySelectedIcon = false;
      _autoGuessReason = null;
      _selectedBank = null;
      _selectedEWallet = null;
      _selectedNotifyMethod = null;
      _nameController.clear();
      _balanceController.clear();
      _creditLimitController.clear();
      _availableBalanceController.clear();
      _minPaymentController.clear();
      _extraFieldController.clear();
      _metalWeightController.clear();
      _metalPurchasePriceController.clear();
      _metalPurchaseDate = null;
      _autoUpdateMetalPrice = true;
      _selectedMetalKarat = (typeDef.id == 'silver') ? '925' : '21';
      _excludeFromTotal = false;
      _receiveAtmWithdrawals = false;
      _autoAddInstapayFee = false;
      _selectedPropertyCategory = null;
      _fundYieldController.clear();
      _autoEstimateValue = false;
      _reminderPeriod = 'monthly';
      _estimateRateController.clear();
      _estimateDirection = 'up';
      _noteController.clear();
    });

    if (typeDef.id == 'cash') {
      _pushStep(AddAccountStep.details);
    } else if (typeDef.id == 'ewallet') {
      _pushStep(AddAccountStep.selectEWallet);
    } else if (typeDef.id == 'bank' || typeDef.id == 'credit_card') {
      _pushStep(AddAccountStep.selectNotifyMethod);
    } else if (typeDef.id == 'investment') {
      _pushStep(AddAccountStep.selectPropertyCategory);
    } else {
      _pushStep(AddAccountStep.details);
    }
  }

  void _onPropertyCategorySelected(PropertyCategory cat, bool isAr) {
    HapticFeedback.selectionClick();

    setState(() {
      _selectedPropertyCategory = cat;
      _hasUserManuallySelectedIcon = false;
    });

    switch (cat) {
      case PropertyCategory.stocksCrypto:
        setState(() {
          _selectedIcon = CupertinoIcons.graph_circle_fill;
          _autoGuessReason = isAr ? 'أسهم وعملات رقمية' : 'Stocks & Crypto';
          _nameController.text = isAr ? 'محفظة استثمارية' : 'Investment Portfolio';
        });
        _pushStep(AddAccountStep.selectStocksCryptoPlatform);
        break;
      case PropertyCategory.moneyMarketFund:
        setState(() {
          _selectedIcon = CupertinoIcons.chart_pie_fill;
          _autoGuessReason = isAr ? 'صندوق استثماري' : 'Money Market Fund';
          _nameController.text = isAr ? 'صندوق استثماري' : 'Money Market Fund';
        });
        _pushStep(AddAccountStep.fundAnnualYield);
        break;
      case PropertyCategory.apartment:
        setState(() {
          _selectedIcon = CupertinoIcons.building_2_fill;
          _autoGuessReason = isAr ? 'شقة' : 'Apartment';
          _nameController.text = isAr ? 'شقة' : 'Apartment';
          _estimateDirection = 'up';
        });
        _pushStep(AddAccountStep.assetValueChange);
        break;
      case PropertyCategory.car:
        setState(() {
          _selectedIcon = CupertinoIcons.car_detailed;
          _autoGuessReason = isAr ? 'سيارة' : 'Car';
          _nameController.text = isAr ? 'سيارة' : 'Car';
          _estimateDirection = 'down';
        });
        _pushStep(AddAccountStep.assetValueChange);
        break;
      case PropertyCategory.business:
        setState(() {
          _selectedIcon = CupertinoIcons.briefcase_fill;
          _autoGuessReason = isAr ? 'مشروع' : 'Business';
          _nameController.text = isAr ? 'مشروع' : 'Business';
          _estimateDirection = 'up';
        });
        _pushStep(AddAccountStep.assetValueChange);
        break;
      case PropertyCategory.somethingElse:
        setState(() {
          _selectedIcon = CupertinoIcons.cube_box_fill;
          _autoGuessReason = isAr ? 'مقتنيات' : 'Personal Asset';
          _nameController.text = isAr ? 'مقتنيات' : 'Personal Asset';
          _estimateDirection = 'up';
        });
        _pushStep(AddAccountStep.assetValueChange);
        break;
    }
  }

  void _onEWalletSelected(EWalletProvider wallet) {
    HapticFeedback.selectionClick();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    setState(() {
      _selectedEWallet = wallet.id;
      _selectedIcon = wallet.icon;
      _hasUserManuallySelectedIcon = false;
      _autoGuessReason = wallet.titleAr;
      _nameController.text = isAr ? wallet.titleAr : wallet.titleEn;
    });
    _pushStep(AddAccountStep.details);
  }

  void _onNotifyMethodSelected(String method) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedNotifyMethod = method;
    });

    if (method == 'sms') {
      _pushStep(AddAccountStep.enterSmsCardNumbers);
    } else {
      // In notification method: skip the last 4 digits screen and go directly to details
      _pushStep(AddAccountStep.details);
    }
  }

  void _addSmsCardNumber() {
    final text = _smsNumberInputController.text.trim();
    if (text.isEmpty) return;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    final cardNumber = digits.length > 4 ? digits.substring(digits.length - 4) : digits;
    if (cardNumber.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      if (!_smsCardNumbers.contains(cardNumber)) {
        _smsCardNumbers.add(cardNumber);
      }
      _smsNumberInputController.clear();
    });
  }

  void _removeSmsCardNumber(String number) {
    HapticFeedback.lightImpact();
    setState(() {
      _smsCardNumbers.remove(number);
    });
  }

  void _proceedFromSmsStep() {
    // If user has written something in the field but didn't press '+', add it
    final remaining = _smsNumberInputController.text.trim();
    if (remaining.isNotEmpty) {
      final digits = remaining.replaceAll(RegExp(r'\D'), '');
      final cardNumber = digits.length > 4 ? digits.substring(digits.length - 4) : digits;
      if (cardNumber.isNotEmpty && !_smsCardNumbers.contains(cardNumber)) {
        _smsCardNumbers.add(cardNumber);
        _smsNumberInputController.clear();
      }
    }
    _pushStep(AddAccountStep.details);
  }

  int _calculateTotalSteps() {
    if (_selectedTypeId == 'investment') {
      return 3;
    }
    if (_selectedTypeId == 'cash' ||
        _selectedTypeId == 'savings' ||
        _selectedTypeId == 'gold' ||
        _selectedTypeId == 'silver' ||
        _selectedTypeId == 'certificate') {
      return 2;
    }
    if (_selectedTypeId == 'ewallet') {
      return 3;
    }
    if (_selectedTypeId == 'bank' || _selectedTypeId == 'credit_card') {
      if (_selectedNotifyMethod == 'notification') {
        return 3;
      }
      return 4;
    }
    return 3;
  }

  String _getStepTitle(bool isAr) {
    switch (_currentStep) {
      case AddAccountStep.selectType:
        return isAr ? 'ما الذي تريد إضافته؟' : 'What are you adding?';
      case AddAccountStep.selectPropertyCategory:
        return isAr ? 'تصنيف الأصل' : 'Asset Category';
      case AddAccountStep.fundAnnualYield:
        return isAr ? 'العائد السنوي' : 'Annual Yield';
      case AddAccountStep.assetValueChange:
        return isAr ? 'تغير قيمة الأصل' : 'Asset Value Change';
      case AddAccountStep.selectStocksCryptoPlatform:
        return isAr ? 'سوق الاستثمار' : 'Investment Market';
      case AddAccountStep.selectEWallet:
        return isAr ? 'اختر المحفظة الإلكترونية' : 'Select E-Wallet';
      case AddAccountStep.selectNotifyMethod:
        return isAr ? 'طريقة تتبع المعاملات' : 'Tracking Method';
      case AddAccountStep.enterSmsCardNumbers:
        return isAr ? 'أرقام كارت الرسائل' : 'Card SMS Numbers';
      case AddAccountStep.details:
        return isAr ? 'بيانات الحساب' : 'Account Details';
    }
  }

  String _getStepSubtitle(bool isAr) {
    switch (_currentStep) {
      case AddAccountStep.selectType:
        return isAr
            ? 'اختر نوع الحساب لتخصيص طريقة التتبع بدقة'
            : 'Choose an account type to customize tracking';
      case AddAccountStep.selectPropertyCategory:
        return isAr
            ? 'حدد نوع الاستثمار أو الأصل لمتابعة قيمته وعوائده'
            : 'Choose investment or asset type to track value and yields';
      case AddAccountStep.fundAnnualYield:
        return isAr
            ? 'حساب وتوزيع العائد يومياً'
            : 'Calculate and add daily returns';
      case AddAccountStep.assetValueChange:
        return isAr
            ? 'تقدير تلقائي أو تحديث يدوي'
            : 'Automatic estimate or manual update';
      case AddAccountStep.selectStocksCryptoPlatform:
        return isAr
            ? 'اختر السوق أو المنصة التي تدير فيها استثمارك'
            : 'Choose market or platform managing your portfolio';
      case AddAccountStep.selectEWallet:
        return isAr
            ? 'حدد نوع محفظتك الذكية لإعدادها بسهولة'
            : 'Select your mobile wallet to configure it';
      case AddAccountStep.selectNotifyMethod:
        return isAr
            ? 'البنك ده بيبلغك إزاي لما تشتري؟'
            : 'How does your bank notify you of purchases?';
      case AddAccountStep.enterSmsCardNumbers:
        return isAr
            ? 'الرقم اللي بيظهر في رسائل بنكك للربط التلقائي'
            : 'The number that appears in bank SMS';
      case AddAccountStep.details:
        return isAr
            ? 'أدخل بيانات الحساب لتأكيد الإضافة فوراً'
            : 'Enter account details to save immediately';
    }
  }

  Future<void> _submitAccount() async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      HapticFeedback.heavyImpact();
      MessageService.showError(
        context: context,
        message: isAr
            ? 'يرجى إدخال اسم الحساب أو المحفظة'
            : 'Please enter account or wallet name',
      );
      _nameFocusNode.requestFocus();
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    final initialBalance =
        double.tryParse(_balanceController.text.trim().replaceAll(',', '')) ??
            0.0;
    final creditLimit =
        double.tryParse(_creditLimitController.text.trim().replaceAll(',', ''));
    final availableBalance =
        double.tryParse(_availableBalanceController.text.trim().replaceAll(',', ''));
    final minPayment =
        double.tryParse(_minPaymentController.text.trim().replaceAll('%', '').trim());

    final billingDayParsed = int.tryParse(_billingDayController.text.trim());
    final dueDayParsed = int.tryParse(_dueDayController.text.trim());
    final billingDay = (billingDayParsed != null && billingDayParsed > 0)
        ? billingDayParsed.clamp(1, 31)
        : _defaultBillingDay;
    final dueDay = (dueDayParsed != null && dueDayParsed > 0)
        ? dueDayParsed.clamp(1, 31)
        : _defaultDueDay;

    final extraText = _extraFieldController.text.trim();
    final newId = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final isMetal = _selectedTypeId == 'gold' || _selectedTypeId == 'silver';
    final metalWeight = double.tryParse(_metalWeightController.text.trim().replaceAll(',', ''));
    final metalPurchasePrice = double.tryParse(_metalPurchasePriceController.text.trim().replaceAll(',', ''));
    final metalTodayPrice = isMetal
        ? _getTodayMetalPrice(_selectedTypeId, _selectedMetalKarat, _selectedCurrency)
        : null;
    final metalEstimatedValue = (metalWeight != null && metalWeight > 0 && metalTodayPrice != null)
        ? (metalWeight * metalTodayPrice)
        : ((metalWeight != null && metalPurchasePrice != null) ? (metalWeight * metalPurchasePrice) : 0.0);

    final finalBalance = _selectedTypeId == 'credit_card'
        ? (availableBalance ?? initialBalance)
        : (isMetal ? metalEstimatedValue : initialBalance);

    final propertyCatStr = _selectedPropertyCategory == PropertyCategory.stocksCrypto
        ? 'stocks_crypto'
        : (_selectedPropertyCategory == PropertyCategory.moneyMarketFund
            ? 'fund'
            : (_selectedPropertyCategory == PropertyCategory.apartment
                ? 'apartment'
                : (_selectedPropertyCategory == PropertyCategory.car
                    ? 'car'
                    : (_selectedPropertyCategory == PropertyCategory.business
                        ? 'business'
                        : (_selectedPropertyCategory == PropertyCategory.somethingElse
                            ? 'other'
                            : null)))));

    final double? fundYield = double.tryParse(_fundYieldController.text.trim().replaceAll(',', ''));
    final double? estimateRate = double.tryParse(_estimateRateController.text.trim().replaceAll(',', ''));
    final double? totalInvested = double.tryParse(_investedAmountController.text.trim().replaceAll(',', ''));
    final String? noteText = _noteController.text.trim().isNotEmpty
        ? _noteController.text.trim()
        : null;

    final newAccount = AccountItem(
      id: newId,
      name: name,
      type: _selectedTypeId,
      balance: finalBalance,
      icon: _selectedIcon,
      accountNumber: extraText.isNotEmpty ? extraText : null,
      currency: _selectedCurrency,
      bankName: _selectedBank,
      provider: _selectedEWallet,
      notificationMethod: _selectedNotifyMethod,
      cardNumbers: _smsCardNumbers.isNotEmpty ? List.from(_smsCardNumbers) : null,
      creditLimit: creditLimit,
      billingDay: _selectedTypeId == 'credit_card' ? billingDay : null,
      dueDay: _selectedTypeId == 'credit_card' ? dueDay : null,
      minPaymentPercentage: minPayment,
      availableBalance: availableBalance,
      excludeFromTotal: _excludeFromTotal,
      receiveAtmWithdrawals: _selectedTypeId == 'cash' && _receiveAtmWithdrawals,
      autoAddInstapayFee: _selectedTypeId == 'bank' && _autoAddInstapayFee,
      metalKarat: isMetal ? _selectedMetalKarat : null,
      metalWeightGrams: isMetal ? metalWeight : null,
      metalPurchasePricePerGram: isMetal ? metalPurchasePrice : null,
      metalPurchaseDate: isMetal ? _metalPurchaseDate : null,
      metalCurrentPricePerGram: isMetal ? metalTodayPrice : null,
      autoUpdateMetalPrice: isMetal ? _autoUpdateMetalPrice : true,
      propertyCategory: propertyCatStr,
      annualYieldRate: fundYield,
      autoEstimateValue: _autoEstimateValue,
      estimateRateYearly: estimateRate,
      estimateDirection: _estimateDirection,
      reminderFrequency: _reminderPeriod,
      note: noteText,
      totalInvestedAmount: _selectedPropertyCategory == PropertyCategory.stocksCrypto ? totalInvested : null,
      investmentPlatform: _selectedPropertyCategory == PropertyCategory.stocksCrypto ? _selectedStocksPlatform : null,
    );

    Navigator.of(context).pop(newAccount);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isIOS = Platform.isIOS || Theme.of(context).platform == TargetPlatform.iOS;
    final bgColor = isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);

    final stepCounter = '${_stepHistory.length}/${_calculateTotalSteps()}';

    return PopScope(
      canPop: _stepHistory.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _stepHistory.length > 1) {
          _onBackTapped();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: bgColor,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            clipBehavior: Clip.none,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 68,
            leadingWidth: 62,
            leading: AppGlassBackButton(
              onPressed: _onBackTapped,
            ),
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _getStepTitle(isAr),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stepCounter,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _getStepSubtitle(isAr),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: const [
              SizedBox(width: 62),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentStep),
              child: _buildCurrentStepView(isDarkMode, isAr, isIOS),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepView(bool isDarkMode, bool isAr, bool isIOS) {
    switch (_currentStep) {
      case AddAccountStep.selectType:
        return _buildTypeSelectionView(isDarkMode, isAr);
      case AddAccountStep.selectPropertyCategory:
        return _buildPropertyCategorySelectionView(isDarkMode, isAr);
      case AddAccountStep.fundAnnualYield:
        return _buildFundAnnualYieldView(isDarkMode, isAr, isIOS);
      case AddAccountStep.assetValueChange:
        return _buildAssetValueChangeView(isDarkMode, isAr, isIOS);
      case AddAccountStep.selectStocksCryptoPlatform:
        return _buildStocksCryptoPlatformView(isDarkMode, isAr);
      case AddAccountStep.selectEWallet:
        return _buildEWalletSelectionView(isDarkMode, isAr);
      case AddAccountStep.selectNotifyMethod:
        return _buildNotifyMethodSelectionView(isDarkMode, isAr);
      case AddAccountStep.enterSmsCardNumbers:
        return _buildSmsCardNumbersView(isDarkMode, isAr, isIOS);
      case AddAccountStep.details:
        return _buildAccountDetailsView(isDarkMode, isAr, isIOS);
    }
  }

  // ==========================================
  // STEP 1: ACCOUNT TYPE SELECTION VIEW
  // ==========================================
  Widget _buildTypeSelectionView(bool isDarkMode, bool isAr) {
    final spendTypes =
        kAccountTypeDefinitions.where((t) => t.section == 'spend').toList();
    final ownTypes =
        kAccountTypeDefinitions.where((t) => t.section == 'own').toList();

    final spendSection = [
      Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 8, left: 2, right: 2),
        child: Text(
          isAr ? 'أموال يمكنك إنفاقها' : 'MONEY YOU CAN SPEND',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
            letterSpacing: 0.6,
          ),
        ),
      ),
      ...spendTypes.map((t) => _buildCompactCard(t, isDarkMode, isAr)),
    ];

    final ownSection = [
      Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 8, left: 2, right: 2),
        child: Text(
          isAr ? 'أصول واستثمارات تملكها' : 'THINGS YOU OWN',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
            letterSpacing: 0.6,
          ),
        ),
      ),
      ...ownTypes.map((t) => _buildCompactCard(t, isDarkMode, isAr)),
    ];

    final children = widget.thingsYouOwnFirst
        ? [
            ...ownSection,
            const SizedBox(height: 12),
            ...spendSection,
          ]
        : [
            ...spendSection,
            const SizedBox(height: 12),
            ...ownSection,
          ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      children: children,
    );
  }

  Widget _buildCompactCard(
    AccountTypeDefinition typeDef,
    bool isDarkMode,
    bool isAr,
  ) {
    final title = isAr ? typeDef.titleAr : typeDef.titleEn;
    final subtitle = isAr ? typeDef.subtitleAr : typeDef.subtitleEn;

    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFF1F1F4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTypeSelected(typeDef),
          borderRadius: BorderRadius.circular(16),
          splashColor: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
          highlightColor: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.03),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.16 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF27272A)
                        : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode
                          ? const Color(0xFF3F3F46).withValues(alpha: 0.5)
                          : const Color(0xFFE4E4E7),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      typeDef.icon,
                      size: 22,
                      color: isDarkMode ? Colors.white : Colors.black,
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
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2.5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isDarkMode
                              ? const Color(0xFFA1A1AA)
                              : const Color(0xFF71717A),
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  appForwardIconOf(context),
                  size: 15,
                  color: isDarkMode
                      ? const Color(0xFF71717A)
                      : const Color(0xFFD4D4D8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PROPERTY & INVESTMENT CATEGORY SELECTION
  // ==========================================
  Widget _buildPropertyCategorySelectionView(bool isDarkMode, bool isAr) {
    final categories = [
      {
        'cat': PropertyCategory.moneyMarketFund,
        'title': isAr ? 'صندوق استثمار نقدي' : 'Money market fund',
        'subtitle': isAr
            ? 'صندوق أسواق نقد يوزع عوائد يومية تراكمية'
            : 'Daily yield fund adding returns each night',
        'icon': CupertinoIcons.chart_pie_fill,
        'badge': null,
      },
      {
        'cat': PropertyCategory.apartment,
        'title': isAr ? 'شقة أو أرض' : 'Apartment or land',
        'subtitle': isAr
            ? 'شقة سكنية، عقار تجاري، قطعة أرض، أو فيلا'
            : 'Residential, commercial apartment, or land',
        'icon': CupertinoIcons.building_2_fill,
        'badge': null,
      },
      {
        'cat': PropertyCategory.car,
        'title': isAr ? 'سيارة' : 'Car',
        'subtitle': isAr
            ? 'سيارة شخصية، دراجة، أو مركبة نقل'
            : 'Personal vehicle, automobile, or ride',
        'icon': CupertinoIcons.car_detailed,
        'badge': null,
      },
      {
        'cat': PropertyCategory.business,
        'title': isAr ? 'مشروع أو شركة' : 'Business',
        'subtitle': isAr
            ? 'شركة، متجر إلكتروني، كافيه، أو نشاط تجاري'
            : 'A startup, company, retail shop, or venture',
        'icon': CupertinoIcons.briefcase_fill,
        'badge': null,
      },
      {
        'cat': PropertyCategory.stocksCrypto,
        'title': isAr ? 'أسهم وعملات رقمية' : 'Stocks and crypto',
        'subtitle': isAr
            ? 'محافظ البورصة، ثندر، وصناديق التداول'
            : 'Stock market portfolios and digital assets',
        'icon': CupertinoIcons.graph_circle_fill,
        'badge': null,
      },
      {
        'cat': PropertyCategory.somethingElse,
        'title': isAr ? 'شيء آخر تملكه' : 'Something else you own',
        'subtitle': isAr
            ? 'ساعات، مقتنيات ثمينة، أجهزة، أو أصول أخرى'
            : 'Valuables, collectibles, art, or other assets',
        'icon': CupertinoIcons.cube_box_fill,
        'badge': null,
      },
    ];

    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFF1F1F4);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      children: categories.map((c) {
        final cat = c['cat'] as PropertyCategory;
        final title = c['title'] as String;
        final subtitle = c['subtitle'] as String;
        final icon = c['icon'] as IconData;
        final badge = c['badge'] as String?;
        final isSoon = badge != null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onPropertyCategorySelected(cat, isAr),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.16 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF27272A)
                            : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF3F3F46).withValues(alpha: 0.5)
                              : const Color(0xFFE4E4E7),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 20,
                          color: isSoon
                              ? (isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA))
                              : (isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isSoon
                                        ? (isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A))
                                        : (isDarkMode ? Colors.white : const Color(0xFF09090B)),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              if (badge != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isDarkMode ? Colors.white : Colors.black)
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    badge,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode
                                          ? const Color(0xFFA1A1AA)
                                          : const Color(0xFF71717A),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2.5),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isDarkMode
                                  ? const Color(0xFFA1A1AA)
                                  : const Color(0xFF71717A),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      appForwardIconOf(context),
                      size: 15,
                      color: isDarkMode
                          ? const Color(0xFF71717A)
                          : const Color(0xFFD4D4D8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================
  // STOCKS & CRYPTO: MARKET / PLATFORM SELECTION
  // ==========================================
  Widget _buildStocksCryptoPlatformView(bool isDarkMode, bool isAr) {
    final platforms = [
      {
        'id': 'egx',
        'title': isAr ? 'البورصة المصرية (EGX)' : 'Egyptian Stocks (EGX)',
        'subtitle': isAr
            ? 'ثندر (Thndr)، هيرميس، مباشر، أسطول'
            : 'Thndr, EFG Hermes, Mubasher, Ostoul',
        'defaultNameAr': 'محفظة ثندر',
        'defaultNameEn': 'Thndr Portfolio',
        'currency': 'EGP',
        'icon': CupertinoIcons.chart_bar_alt_fill,
      },
      {
        'id': 'us_stocks',
        'title': isAr ? 'الأسهم الأمريكية والعالمية' : 'US & Global Stocks',
        'subtitle': isAr
            ? 'Interactive Brokers, Baraka, Trading212'
            : 'Interactive Brokers, Baraka, Trading212',
        'defaultNameAr': 'محفظة الأسهم الأمريكية',
        'defaultNameEn': 'US Stocks Portfolio',
        'currency': 'USD',
        'icon': CupertinoIcons.globe,
      },
      {
        'id': 'crypto',
        'title': isAr ? 'العملات الرقمية (Crypto)' : 'Cryptocurrency',
        'subtitle': isAr
            ? 'Binance, Bybit, Cold Wallet, Metamask'
            : 'Binance, Bybit, Cold Wallet, Metamask',
        'defaultNameAr': 'محفظة بينانس',
        'defaultNameEn': 'Binance Portfolio',
        'currency': 'USD',
        'icon': CupertinoIcons.bitcoin,
      },
      {
        'id': 'other',
        'title': isAr ? 'محفظة استثمارية أخرى' : 'Other Portfolio',
        'subtitle': isAr
            ? 'صناديق استثمارية، محافظ مدارة، أصول متنوعة'
            : 'Managed funds, diverse investment portfolio',
        'defaultNameAr': 'محفظة استثمارية',
        'defaultNameEn': 'Investment Portfolio',
        'currency': 'EGP',
        'icon': CupertinoIcons.briefcase_fill,
      },
    ];

    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFF1F1F4);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      children: platforms.map((p) {
        final id = p['id'] as String;
        final title = p['title'] as String;
        final subtitle = p['subtitle'] as String;
        final defaultNameAr = p['defaultNameAr'] as String;
        final defaultNameEn = p['defaultNameEn'] as String;
        final currency = p['currency'] as String;
        final icon = p['icon'] as IconData;

        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedStocksPlatform = id;
                  _selectedIcon = icon;
                  _hasUserManuallySelectedIcon = false;
                  _selectedCurrency = currency;
                  _nameController.text = isAr ? defaultNameAr : defaultNameEn;
                });
                _pushStep(AddAccountStep.details);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.16 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF27272A)
                            : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF3F3F46).withValues(alpha: 0.5)
                              : const Color(0xFFE4E4E7),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 20,
                          color: isDarkMode ? Colors.white : Colors.black,
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
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2.5),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isDarkMode
                                  ? const Color(0xFFA1A1AA)
                                  : const Color(0xFF71717A),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      appForwardIconOf(context),
                      size: 15,
                      color: isDarkMode
                          ? const Color(0xFF71717A)
                          : const Color(0xFFD4D4D8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================
  // RADIO BUTTON CIRCLE (AUTHENTIC IOS STYLE)
  // ==========================================
  Widget _buildRadioCircle(bool isSelected, bool isDarkMode) {
    final borderColor = isSelected
        ? (isDarkMode ? Colors.white : Colors.black)
        : (isDarkMode ? const Color(0xFF52525B) : const Color(0xFFD4D4D8));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.0 : 1.5,
        ),
        color: Colors.transparent,
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            )
          : null,
    );
  }

  // ==========================================
  // MONEY MARKET FUND: ANNUAL YIELD RATE VIEW
  // ==========================================
  Widget _buildFundAnnualYieldView(bool isDarkMode, bool isAr, bool isIOS) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final restingBottom = safeAreaBottom > 0 ? safeAreaBottom + 3.0 : 11.0;
    final buttonBottom = math.max(restingBottom, viewInsetsBottom + 7.0);

    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE4E4E7);

    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            (safeAreaBottom > 0 ? safeAreaBottom + 85 : 95) + viewInsetsBottom,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                isAr ? 'كم نسبة العائد السنوي؟' : 'What does it pay a year?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                isAr
                    ? 'النسبة السنوية التي يعلنها الصندوق. محفظتي تضيف حصة كل يوم تلقائياً كل ليلة.'
                    : 'The yearly rate the fund shows. Mahfazti adds a day of it every night.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                  color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _fundYieldController,
                      focusNode: _fundYieldFocusNode,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      cursorColor: isDarkMode ? Colors.white : Colors.black,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: '22',
                        hintStyle: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? const Color(0xFF52525B) : const Color(0xFFC7C7CC),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isAr ? '% سنوياً' : '% a year',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Bottom Continue Button
        Positioned(
          left: 20,
          right: 20,
          bottom: buttonBottom,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _pushStep(AddAccountStep.details);
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: (isDarkMode ? Colors.white : Colors.black)
                          .withValues(alpha: isDarkMode ? 0.18 : 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isAr ? 'متابعة' : 'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.black : Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PROPERTY/CAR/BUSINESS: ASSET VALUE CHANGE
  // ==========================================
  Widget _buildAssetValueChangeView(bool isDarkMode, bool isAr, bool isIOS) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final restingBottom = safeAreaBottom > 0 ? safeAreaBottom + 3.0 : 11.0;
    final buttonBottom = math.max(restingBottom, viewInsetsBottom + 7.0);

    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE4E4E7);

    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            (safeAreaBottom > 0 ? safeAreaBottom + 85 : 95) + viewInsetsBottom,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                isAr ? 'هل تتغير قيمته تلقائياً؟' : 'Does its value change on its own?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.black,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                isAr
                    ? 'يمكن لمحفظتي تعديل القيمة تدريجياً كل ليلة بناءً على تقديرك، وتسجيل القيمة الفعلية في أي وقت يُلغي التقدير.'
                    : 'Mahfazti can move it a little every night by an estimate. Recording the real value any time overrides it.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                ),
              ),
            ),

            // CARD 1: "No, I'll update it myself"
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                FocusScope.of(context).unfocus();
                setState(() => _autoEstimateValue = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildRadioCircle(!_autoEstimateValue, isDarkMode),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'لا، سأقوم بتحديثه بنفسي' : "No, I'll update it myself",
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isAr
                                    ? 'محفظتي تذكرك بتحديث القيمة'
                                    : 'Mahfazti reminds you to update it',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!_autoEstimateValue) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: _buildReminderPeriodTabs(isDarkMode, isAr),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // CARD 2: "Yes, about"
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _autoEstimateValue = true);
                _estimateRateFocusNode.requestFocus();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildRadioCircle(_autoEstimateValue, isDarkMode),
                        const SizedBox(width: 12),
                        Text(
                          isAr ? 'نعم، بنسبة تقريبية' : 'Yes, about',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 58,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _estimateRateController,
                            focusNode: _estimateRateFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            cursorColor: isDarkMode ? Colors.white : Colors.black,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              hintText: '8',
                              hintStyle: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? const Color(0xFF52525B) : const Color(0xFFC7C7CC),
                              ),
                            ),
                            onTap: () {
                              if (!_autoEstimateValue) {
                                setState(() => _autoEstimateValue = true);
                              }
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isAr ? '% سنوياً' : '% a year',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    if (_autoEstimateValue) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: _buildDirectionTabs(isDarkMode, isAr),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // Bottom Continue Button
        Positioned(
          left: 20,
          right: 20,
          bottom: buttonBottom,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _pushStep(AddAccountStep.details);
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: (isDarkMode ? Colors.white : Colors.black)
                          .withValues(alpha: isDarkMode ? 0.18 : 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isAr ? 'متابعة' : 'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.black : Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderPeriodTabs(bool isDarkMode, bool isAr) {
    final periods = [
      {'id': 'monthly', 'label': isAr ? 'شهرياً' : 'Monthly'},
      {'id': '3_months', 'label': isAr ? 'كل 3 شهور' : '3 months'},
      {'id': '6_months', 'label': isAr ? 'كل 6 شهور' : '6 months'},
      {'id': 'never', 'label': isAr ? 'أبداً' : 'Never'},
    ];
    final selectedIdx = periods.indexWhere((p) => p['id'] == _reminderPeriod);
    final activeIdx = selectedIdx < 0 ? 0 : selectedIdx;
    final isGlass = PlatformInfo.isIOS26OrHigher();

    if (isGlass) {
      return GlassSegmentedControl(
        selectedIndex: activeIdx,
        onSegmentSelected: (idx) {
          HapticFeedback.selectionClick();
          setState(() => _reminderPeriod = periods[idx]['id']!);
        },
        segments: periods
            .map((p) => GlassSegment(label: p['label']!))
            .toList(),
        height: 38,
        useOwnLayer: true,
        backgroundColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        indicatorColor: isDarkMode
            ? const Color(0xFF27272A)
            : Colors.white,
        selectedTextStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: isAr ? 'Cairo' : null,
        ),
        unselectedTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.55),
          fontFamily: isAr ? 'Cairo' : null,
        ),
      );
    }

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
          width: 0.8,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / periods.length;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 220),
                curve: Curves.fastOutSlowIn,
                start: activeIdx * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF27272A) : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.08),
                        blurRadius: 5,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: periods.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final p = entry.value;
                  final isSelected = activeIdx == idx;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _reminderPeriod = p['id']!);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : (isDarkMode
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.55)),
                            fontFamily: isAr ? 'Cairo' : null,
                          ),
                          child: Text(p['label']!),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDirectionTabs(bool isDarkMode, bool isAr) {
    final dirs = [
      {'id': 'up', 'label': isAr ? 'زيادة / صعود' : 'Up'},
      {'id': 'down', 'label': isAr ? 'نقصان / هبوط' : 'Down'},
    ];
    final selectedIdx = dirs.indexWhere((d) => d['id'] == _estimateDirection);
    final activeIdx = selectedIdx < 0 ? 0 : selectedIdx;
    final isGlass = PlatformInfo.isIOS26OrHigher();

    if (isGlass) {
      return GlassSegmentedControl(
        selectedIndex: activeIdx,
        onSegmentSelected: (idx) {
          HapticFeedback.selectionClick();
          setState(() => _estimateDirection = dirs[idx]['id']!);
        },
        segments: dirs
            .map((d) => GlassSegment(label: d['label']!))
            .toList(),
        height: 38,
        useOwnLayer: true,
        backgroundColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06),
        indicatorColor: isDarkMode
            ? const Color(0xFF27272A)
            : Colors.white,
        selectedTextStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: isAr ? 'Cairo' : null,
        ),
        unselectedTextStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.55),
          fontFamily: isAr ? 'Cairo' : null,
        ),
      );
    }

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
          width: 0.8,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / dirs.length;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 220),
                curve: Curves.fastOutSlowIn,
                start: activeIdx * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF27272A) : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.08),
                        blurRadius: 5,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: dirs.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final d = entry.value;
                  final isSelected = activeIdx == idx;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _estimateDirection = d['id']!);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : (isDarkMode
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.55)),
                            fontFamily: isAr ? 'Cairo' : null,
                          ),
                          child: Text(d['label']!),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getReminderPeriodLabel(String period, bool isAr) {
    switch (period) {
      case 'monthly':
        return isAr ? 'شهرياً' : 'Monthly';
      case '3_months':
        return isAr ? 'كل 3 شهور' : 'Every 3 months';
      case '6_months':
        return isAr ? 'كل 6 شهور' : 'Every 6 months';
      case 'never':
      default:
        return isAr ? 'أبداً' : 'Never';
    }
  }

  Widget _buildPropertyConfigSummaryBadge(bool isDarkMode, bool isAr) {
    String label;
    IconData icon;

    if (_selectedPropertyCategory == PropertyCategory.stocksCrypto) {
      final platformLabels = {
        'egx': isAr ? 'البورصة المصرية (EGX)' : 'EGX Stocks',
        'us_stocks': isAr ? 'الأسهم الأمريكية' : 'US Stocks',
        'crypto': isAr ? 'العملات الرقمية (Crypto)' : 'Crypto',
        'other': isAr ? 'محفظة استثمارية' : 'Investment Portfolio',
      };
      final pLabel = platformLabels[_selectedStocksPlatform] ?? (isAr ? 'محفظة استثمارية' : 'Portfolio');
      icon = _selectedStocksPlatform == 'crypto'
          ? CupertinoIcons.bitcoin
          : (_selectedStocksPlatform == 'us_stocks'
              ? CupertinoIcons.globe
              : CupertinoIcons.chart_bar_alt_fill);
      label = isAr
          ? '$pLabel · تتبع أرباح وخسائر'
          : '$pLabel · Portfolio P&L';
    } else if (_selectedPropertyCategory == PropertyCategory.moneyMarketFund) {
      icon = CupertinoIcons.chart_pie_fill;
      final rate = _fundYieldController.text.trim();
      label = isAr
          ? 'صندوق استثماري · عائد ${rate.isNotEmpty ? rate : "20"}% سنوياً'
          : 'Money Market Fund · ${rate.isNotEmpty ? rate : "20"}% a year yield';
    } else {
      if (_autoEstimateValue) {
        icon = _estimateDirection == 'up' ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right;
        final rate = _estimateRateController.text.trim();
        final sign = _estimateDirection == 'up' ? '+' : '-';
        label = isAr
            ? 'تحديث تلقائي: $sign${rate.isNotEmpty ? rate : "10"}% سنوياً'
            : 'Auto-estimate: $sign${rate.isNotEmpty ? rate : "10"}% a year';
      } else {
        icon = CupertinoIcons.bell_fill;
        label = isAr
            ? 'تحديث يدوي · تذكير: ${_getReminderPeriodLabel(_reminderPeriod, isAr)}'
            : 'Manual update · Reminder: ${_getReminderPeriodLabel(_reminderPeriod, isAr)}';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF18181F) : const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE4E4E7),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDarkMode ? Colors.white : Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (double diff, double pct)? _calculatePnL() {
    final worthStr = _balanceController.text.trim().replaceAll(',', '');
    final investedStr = _investedAmountController.text.trim().replaceAll(',', '');
    final worth = double.tryParse(worthStr);
    final invested = double.tryParse(investedStr);
    if (worth == null || invested == null || invested <= 0) {
      return null;
    }
    final diff = worth - invested;
    final pct = (diff / invested) * 100;
    return (diff, pct);
  }

  Widget _buildPnLPreviewBadge(bool isDarkMode, bool isAr) {
    final pnl = _calculatePnL();
    if (pnl == null) return const SizedBox.shrink();

    final diff = pnl.$1;
    final pct = pnl.$2;
    final isPositive = diff >= 0;

    final gainColor = isDarkMode ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    final lossColor = isDarkMode ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    final statusColor = isPositive ? gainColor : lossColor;

    final formattedDiff = NumberFormat('#,##0.00').format(diff.abs());
    final sign = isPositive ? '+' : '-';
    final pctStr = '$sign${pct.abs().toStringAsFixed(1)}%';

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isDarkMode ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: isDarkMode ? 0.35 : 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Text(
            isAr
                ? (isPositive ? 'صافي ربح تقديري: ' : 'صافي خسارة تقديرية: ')
                : (isPositive ? 'Est. Profit: ' : 'Est. Loss: '),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
            ),
          ),
          Text(
            '$sign$formattedDiff $_selectedCurrency',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($pctStr)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 2: E-WALLET SELECTION VIEW
  // ==========================================
  Widget _buildEWalletSelectionView(bool isDarkMode, bool isAr) {
    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      children: [
        ...kEWalletProviders.map((w) {
          final isSelected = _selectedEWallet == w.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onEWalletSelected(w),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDarkMode ? const Color(0xFF1E1E24) : const Color(0xFFF4F4F6))
                        : cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (isDarkMode ? Colors.white54 : Colors.black87)
                          : borderColor,
                      width: isSelected ? 1.4 : 1.0,
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
                      // Company Brand Logo
                      _buildEWalletBrandLogo(w.id, isDarkMode, size: 44),
                      const SizedBox(width: 14),

                      // Provider Name Only (No prefix / numbers below)
                      Expanded(
                        child: Text(
                          isAr ? w.titleAr : w.titleEn,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF09090B),
                          ),
                        ),
                      ),

                      // Trailing Chevron
                      Icon(
                        appForwardIconOf(context),
                        size: 15,
                        color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFD4D4D8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // STEP 2: NOTIFICATION METHOD SELECTION VIEW
  // ==========================================
  Widget _buildNotifyMethodSelectionView(bool isDarkMode, bool isAr) {
    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFF1F1F4);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      children: [
        // Question title card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isAr
                          ? 'البنك ده بيبلغك إزاي لما تشتري؟'
                          : 'How does your bank notify you of purchases?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : Colors.black,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isAr
                    ? 'اختر وسيلة الإشعار التي يستخدمها بنكك لربط المصاريف تلقائياً وبدقة'
                    : 'Choose how your bank alerts you so we can track transactions accurately',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // OPTION 1: SMS
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onNotifyMethodSelected('sms'),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.16 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.sms_outlined,
                        size: 24,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isAr ? 'رسائل SMS' : 'SMS Messages',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isAr ? 'الأكثر شيوعاً' : 'Popular',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                              ? 'رسائل الخصم والمشتريات النصية اللي بتوصلك من البنك على الموبايل'
                              : 'Text messages received from your bank upon card purchases',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    appForwardIconOf(context),
                    size: 16,
                    color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFD4D4D8),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // OPTION 2: NOTIFICATION
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onNotifyMethodSelected('notification'),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.16 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.notifications_active_outlined,
                        size: 24,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'إشعار التطبيق (Notification)' : 'App Push Notification',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                              ? 'إشعارات تطبيق البنك أو المحفظة الذكية على الشاشة مباشرة'
                              : 'Push notifications from your mobile banking or wallet app',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    appForwardIconOf(context),
                    size: 16,
                    color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFD4D4D8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 3: SMS CARD NUMBERS VIEW
  // ==========================================
  Widget _buildSmsCardNumbersView(bool isDarkMode, bool isAr, bool isIOS) {
    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFF1F1F4);

    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    final restingBottom = safeAreaBottom > 0 ? math.max(8.0, safeAreaBottom - 7.0) : 4.0;
    final buttonBottom = math.max(restingBottom, viewInsetsBottom + 6.0);

    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            (safeAreaBottom > 0 ? safeAreaBottom + 105 : 113) + viewInsetsBottom,
          ),
          children: [
            // Header Instruction Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'الرقم اللي بيظهر في رسائل بنكك' : 'Number from bank SMS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : Colors.black,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isAr
                        ? 'أدخل آخر 4 أرقام من الكارت أو المعرف اللي بيظهر في نص رسائل البنك لربط المعاملات تلقائياً (يمكنك إضافة أكثر من كارت).'
                        : 'Enter the last 4 digits of your card or identifier shown in bank SMS. You can add multiple cards.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Number Input Row + Add Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildAdaptiveTextField(
                    controller: _smsNumberInputController,
                    focusNode: _smsNumberFocusNode,
                    placeholder: isAr ? 'آخر 4 أرقام (مثال: 8920)' : 'Last 4 digits (e.g. 8920)',
                    isIOS: isIOS,
                    isDarkMode: isDarkMode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: 4,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _addSmsCardNumber(),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addSmsCardNumber,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: isDarkMode ? Colors.black : Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAr ? 'إضافة' : 'Add',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Added Numbers Chips List
            if (_smsCardNumbers.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _smsCardNumbers.map((cardNum) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode ? Colors.white24 : Colors.black26,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '•••• $cardNum',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _removeSmsCardNumber(cardNum),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 13,
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Expandable Bank SMS Examples Section
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showSmsExamples = !_showSmsExamples);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 18,
                        color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isAr
                              ? 'مش متأكد شكله إزاي؟ شوف أمثلة من رسائل البنوك'
                              : 'Not sure? See bank SMS examples',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                          ),
                        ),
                      ),
                      Icon(
                        _showSmsExamples
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Realistic SMS Mockup Examples
            if (_showSmsExamples) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF141418) : const Color(0xFFF4F4F6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSmsExampleItem(
                      bank: 'CIB',
                      sms: 'شراء بمبلغ 350.00 ج.م من بطاقتك المنتهية بـ **8920 لدى Spinneys. الرصيد المتاح...',
                      target: '8920',
                      isDarkMode: isDarkMode,
                      isAr: isAr,
                    ),
                    const Divider(height: 20),
                    _buildSmsExampleItem(
                      bank: isAr ? 'البنك الأهلي المصري' : 'NBE',
                      sms: 'خصم مبلغ 120.00 جم كارت مشتريات رقم ****4311 في 23/10/2026...',
                      target: '4311',
                      isDarkMode: isDarkMode,
                      isAr: isAr,
                    ),
                    const Divider(height: 20),
                    _buildSmsExampleItem(
                      bank: isAr ? 'بنك مصر' : 'Banque Misr',
                      sms: 'تمت عملية خصم بمبلغ EGP 500 كارت رقم **7721 بنجاح...',
                      target: '7721',
                      isDarkMode: isDarkMode,
                      isAr: isAr,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),

        // Floating Action Buttons (متابعة + تخطي دلوقتي)
        Positioned(
          left: 20,
          right: 20,
          bottom: buttonBottom,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _proceedFromSmsStep,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: (isDarkMode ? Colors.white : Colors.black)
                              .withValues(alpha: isDarkMode ? 0.18 : 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isAr ? 'متابعة' : 'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.black : Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _pushStep(AddAccountStep.details);
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                child: Text(
                  isAr ? 'تخطي دلوقتي' : 'Skip for now',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsExampleItem({
    required String bank,
    required String sms,
    required String target,
    required bool isDarkMode,
    required bool isAr,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              bank,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${isAr ? 'الرقم:' : 'Number:'} $target',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          sms,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 4: FINAL ACCOUNT DETAILS VIEW
  // ==========================================
  Widget _buildAccountDetailsView(bool isDarkMode, bool isAr, bool isIOS) {
    final type = _selectedType;
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    final restingBottom = safeAreaBottom > 0 ? safeAreaBottom + 3.0 : 11.0;
    final buttonBottom = math.max(restingBottom, viewInsetsBottom + 7.0);

    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            (safeAreaBottom > 0 ? safeAreaBottom + 77 : 85) + viewInsetsBottom,
          ),
          children: [
            // 1. HERO ACCOUNT ICON AVATAR & DATE-PICKER POPUP TRIGGER
            _buildHeroAccountIconSection(isDarkMode, isAr),
            const SizedBox(height: 20),

            // Investment / Property Configuration Summary Pill
            if (type.id == 'investment' && _selectedPropertyCategory != null) ...[
              _buildPropertyConfigSummaryBadge(isDarkMode, isAr),
              const SizedBox(height: 16),
            ],

            // 2. BANK OR APP SELECTOR (للديبيت كارد أو الكريدت كارد أو الشهادات البنكية)
            if (type.id == 'bank' || type.id == 'credit_card' || type.id == 'certificate') ...[
              _buildBankSelector(isDarkMode, isAr),
              const SizedBox(height: 18),
            ],

            // 3. ACCOUNT NAME (اسم الحساب)
            Text(
              isAr ? 'اسم الحساب أو المحفظة' : 'Account or Wallet Name',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
              ),
            ),
            const SizedBox(height: 8),
            _buildAdaptiveTextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              placeholder: isAr ? type.namePlaceholderAr : type.namePlaceholderEn,
              isIOS: isIOS,
              isDarkMode: isDarkMode,
              textInputAction: TextInputAction.next,
              suffix: _nameController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _nameController.clear();
                        _handleNameChanged('');
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                          ),
                        ),
                      ),
                    )
                  : null,
              onChanged: _handleNameChanged,
            ),
            _buildNameSuggestionChips(isDarkMode, isAr, type),
            const SizedBox(height: 18),

            // 4. CURRENCY SELECTOR (العملة)
            _buildCurrencySelectorRow(isDarkMode, isAr),
            const SizedBox(height: 18),

            // ==========================================
            // CREDIT CARD SPECIFIC FIELDS
            // حد الائتمان + يوم الفاتورة + يوم الاستحقاق + نسبة الحد الأدنى + الرصيد المتاح
            // ==========================================
            if (type.id == 'credit_card') ...[
              // حد الائتمان (Credit Limit)
              Text(
                isAr ? 'الحد الائتماني (Credit Limit)' : 'Credit Limit',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                ),
              ),
              const SizedBox(height: 8),
              _buildAdaptiveTextField(
                controller: _creditLimitController,
                focusNode: _creditLimitFocusNode,
                placeholder: isAr ? 'مثال: 50,000' : 'e.g. 50,000',
                isIOS: isIOS,
                isDarkMode: isDarkMode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                suffix: _buildSuffixPill(_selectedCurrency, isDarkMode),
                onChanged: (_) => setState(() {}),
              ),
              _buildFieldHelpText(
                isAr
                    ? 'إجمالي الحد الائتماني المتاح للبطاقة والمحدد من قِبل البنك.'
                    : 'Total credit limit assigned to this card by the bank.',
                isDarkMode,
              ),
              const SizedBox(height: 18),

              // صف يوم الفاتورة ويوم استحقاق السداد (حقول أرقام مع شرح)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // يوم الفاتورة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'يوم الفاتورة' : 'Billing Day',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildAdaptiveTextField(
                          controller: _billingDayController,
                          focusNode: _billingDayFocusNode,
                          placeholder: isAr ? 'مثال: 25' : 'e.g. 25',
                          isIOS: isIOS,
                          isDarkMode: isDarkMode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLength: 2,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          suffix: _buildSuffixPill(isAr ? 'يوم' : 'Day', isDarkMode),
                          onChanged: (val) {
                            final n = int.tryParse(val);
                            if (n != null && n > 31) {
                              _billingDayController.text = '31';
                              _billingDayController.selection = TextSelection.fromPosition(
                                const TextPosition(offset: 2),
                              );
                            }
                            setState(() {});
                          },
                        ),
                        _buildFieldHelpText(
                          isAr
                              ? 'اليوم من كل شهر اللي بيصدر فيه كشف الحساب وتتحسب فيه معاملاتك.'
                              : 'Monthly date when your statement closes and charges are calculated.',
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // يوم استحقاق السداد
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'يوم استحقاق السداد' : 'Due Day',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildAdaptiveTextField(
                          controller: _dueDayController,
                          focusNode: _dueDayFocusNode,
                          placeholder: isAr ? 'مثال: 15' : 'e.g. 15',
                          isIOS: isIOS,
                          isDarkMode: isDarkMode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLength: 2,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          suffix: _buildSuffixPill(isAr ? 'يوم' : 'Day', isDarkMode),
                          onChanged: (val) {
                            final n = int.tryParse(val);
                            if (n != null && n > 31) {
                              _dueDayController.text = '31';
                              _dueDayController.selection = TextSelection.fromPosition(
                                const TextPosition(offset: 2),
                              );
                            }
                            setState(() {});
                          },
                        ),
                        _buildFieldHelpText(
                          isAr
                              ? 'آخر ميعاد لدفع مستحقات البطاقة لتجنب الفوائد وغرامات التأخير.'
                              : 'Monthly deadline to pay balance and avoid interest or late fees.',
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // نسبة الحد الأدنى للسداد (اختياري)
              Row(
                children: [
                  Text(
                    isAr ? 'نسبة الحد الأدنى للسداد' : 'Min Payment %',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAr ? '(اختياري)' : '(Optional)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAdaptiveTextField(
                controller: _minPaymentController,
                focusNode: _minPaymentFocusNode,
                placeholder: isAr ? 'مثال: 5' : 'e.g. 5',
                isIOS: isIOS,
                isDarkMode: isDarkMode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                suffix: _buildSuffixPill('%', isDarkMode),
                onChanged: (_) => setState(() {}),
              ),
              _buildFieldHelpText(
                isAr
                    ? 'أقل نسبة بيطلبها البنك شهرياً من إجمالي المديونية (غالباً 5%).'
                    : 'Minimum percentage required by the bank monthly (typically 5%).',
                isDarkMode,
              ),
              const SizedBox(height: 18),

              // الرصيد المتاح دلوقتي (Current Available Balance)
              Text(
                isAr ? 'الرصيد المتاح دلوقتي' : 'Current Available Balance',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                ),
              ),
              const SizedBox(height: 8),
              _buildAdaptiveTextField(
                controller: _availableBalanceController,
                focusNode: _availableBalanceFocusNode,
                placeholder: '0.00',
                isIOS: isIOS,
                isDarkMode: isDarkMode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                suffix: _buildSuffixPill(_selectedCurrency, isDarkMode),
                onChanged: (_) => setState(() {}),
              ),
              _buildFieldHelpText(
                isAr
                    ? 'المبلغ الفعلي المتبقي للصرف حالياً بعد خصم المشتريات والمديونية.'
                    : 'Actual remaining balance available to spend right now.',
                isDarkMode,
              ),
            ] else if (type.id == 'gold' || type.id == 'silver') ...[
              // ==========================================
              // PRECIOUS METALS (GOLD & SILVER)
              // الوزن + العيار + سعر الشراء + تاريخ الشراء + سعر الجرام اليوم + تحديث تلقائي + القيمة التقديرية
              // ==========================================
              _buildPreciousMetalsSection(isDarkMode, isAr, isIOS, type),
            ] else ...[
              // ==========================================
              // STANDARD ACCOUNTS & INVESTMENTS
              // رصيد البداية أو القيمة الحالية
              // ==========================================
              Text(
                isAr
                    ? (type.id == 'investment' ? 'ما هي قيمته الآن؟' : 'رصيد البداية')
                    : (type.id == 'investment' ? 'What is it worth now?' : 'Starting Balance'),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                ),
              ),
              const SizedBox(height: 8),
              _buildAdaptiveTextField(
                controller: _balanceController,
                focusNode: _balanceFocusNode,
                placeholder: '0.00',
                isIOS: isIOS,
                isDarkMode: isDarkMode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                suffix: _buildSuffixPill(_selectedCurrency, isDarkMode),
                onChanged: (_) => setState(() {}),
              ),
            ],

            // Stocks & Crypto: Invested Amount, Live P&L Preview, and Update Reminder
            if (type.id == 'investment' && _selectedPropertyCategory == PropertyCategory.stocksCrypto) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    isAr ? 'إجمالي المبلغ المستثمر' : 'Total Amount Invested',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAr ? '(اختياري)' : '(Optional)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAdaptiveTextField(
                controller: _investedAmountController,
                focusNode: _investedAmountFocusNode,
                placeholder: '0.00',
                isIOS: isIOS,
                isDarkMode: isDarkMode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                suffix: _buildSuffixPill(_selectedCurrency, isDarkMode),
                onChanged: (_) => setState(() {}),
              ),
              _buildFieldHelpText(
                isAr
                    ? 'المبلغ الفعلي الذي قمت بإيداعه أو شرائه، لحساب صافي الأرباح والخسائر ونسبتها.'
                    : 'Total principal invested or deposited, used to track profit/loss percentage.',
                isDarkMode,
              ),
              _buildPnLPreviewBadge(isDarkMode, isAr),
              const SizedBox(height: 18),
              Text(
                isAr ? 'كم مرة تريد تحديث قيمة المحفظة؟' : 'How often do you want to update it?',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                ),
              ),
              const SizedBox(height: 8),
              _buildReminderPeriodTabs(isDarkMode, isAr),
            ],

            // Note field (Optional) for Investment / Property or Extra Field for other types
            if (type.id == 'investment') ...[
              const SizedBox(height: 18),
              Text(
                isAr ? 'ملاحظة (اختياري)' : 'Note (optional)',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                ),
              ),
              const SizedBox(height: 8),
              _buildAdaptiveTextField(
                controller: _noteController,
                focusNode: _noteFocusNode,
                placeholder: isAr
                    ? 'مثال: رقم العقد، موقع العقار، تفاصيل إضافية...'
                    : 'e.g. Contract ID, property location, details...',
                isIOS: isIOS,
                isDarkMode: isDarkMode,
                keyboardType: TextInputType.text,
                onChanged: (_) => setState(() {}),
              ),
            ] else if (type.extraFieldLabelAr != null && type.id != 'gold' && type.id != 'silver') ...[
              const SizedBox(height: 18),
              Text(
                isAr ? type.extraFieldLabelAr! : type.extraFieldLabelEn!,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
                ),
              ),
              const SizedBox(height: 8),
              _buildAdaptiveTextField(
                controller: _extraFieldController,
                focusNode: _extraFieldFocusNode,
                placeholder: (isAr ? type.extraFieldPlaceholderAr : type.extraFieldPlaceholderEn) ?? '',
                isIOS: isIOS,
                isDarkMode: isDarkMode,
                keyboardType: type.extraFieldKeyboardType,
                onChanged: (_) => setState(() {}),
              ),
            ],

            // ==========================================
            // ADDITIONAL ACCOUNT OPTIONS (TOGGLES)
            // استبعاد من إجمالي الرصيد + سحوبات الـ ATM بتنزل هنا
            // Omitted for Investment / Property per user specifications
            // ==========================================
            if (type.id != 'investment') ...[
              const SizedBox(height: 20),
              _buildAccountOptionsSection(isDarkMode, isAr, type),
            ],

            const SizedBox(height: 24),
          ],
        ),

        // FLOATING ACTION BUTTON
        Positioned(
          left: 20,
          right: 20,
          bottom: buttonBottom,
          child: _buildFloatingSubmitButton(isDarkMode, isAr),
        ),
      ],
    );
  }

  // ==========================================
  // HERO ACCOUNT ICON AVATAR
  // ==========================================
  Widget _buildHeroAccountIconSection(bool isDarkMode, bool isAr) {
    final avatarBgColor = isDarkMode ? const Color(0xFF18181C) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE4E4E7);

    return Builder(
      builder: (btnContext) {
        Future<void> openPicker() async {
          HapticFeedback.selectionClick();
          final RenderBox? renderBox =
              btnContext.findRenderObject() as RenderBox?;
          final pickedIcon = await showCupertinoIconPicker(
            context,
            widgetRenderBox: renderBox,
            selectedIcon: _selectedIcon,
            isDarkMode: isDarkMode,
            isAr: isAr,
          );
          if (pickedIcon != null) {
            setState(() {
              _selectedIcon = pickedIcon;
              _hasUserManuallySelectedIcon = true;
              _autoGuessReason = null;
            });
          }
        }

        final isAutoGuessed =
            !_hasUserManuallySelectedIcon && _autoGuessReason != null;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: openPicker,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: avatarBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDarkMode ? 0.35 : 0.06,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                          child: _selectedEWallet != null &&
                                  !_hasUserManuallySelectedIcon
                              ? _buildEWalletBrandLogo(
                                  _selectedEWallet!,
                                  isDarkMode,
                                  size: 48,
                                )
                              : Icon(
                                  _selectedIcon,
                                  key: ValueKey(_selectedIcon.codePoint),
                                  size: 40,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                        ),
                      ),
                    ),

                    // Edit / Auto-guess Badge on Corner
                    PositionedDirectional(
                      bottom: -2,
                      end: -2,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white : Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isAutoGuessed
                              ? Icons.auto_awesome
                              : Icons.edit_rounded,
                          size: 13,
                          color: isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Interactive Hint Pill
              GestureDetector(
                onTap: openPicker,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isDarkMode ? Colors.white : Colors.black)
                          .withValues(alpha: 0.06),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAutoGuessed
                            ? Icons.auto_awesome
                            : Icons.touch_app_rounded,
                        size: 12,
                        color: isDarkMode
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF71717A),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isAutoGuessed
                            ? (isAr
                                ? 'تم اقتراح الأيقونة تلقائياً'
                                : 'Auto-selected icon')
                            : (isAr
                                ? 'اضغط لتغيير الأيقونة'
                                : 'Tap to change icon'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? const Color(0xFFA1A1AA)
                              : const Color(0xFF71717A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // E-WALLET BRAND LOGO BUILDER
  // ==========================================
  Widget _buildEWalletBrandLogo(
    String providerId,
    bool isDarkMode, {
    double size = 44,
  }) {
    final radius = size * 0.28;
    final netLogo = 'https://mahfazati.runasp.net/images/wallets/$providerId.png';

    Widget buildWalletFallback() => _buildFallbackWalletIcon(isDarkMode, size, radius);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.08),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          netLogo,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return buildWalletFallback();
          },
          errorBuilder: (context, error, stackTrace) =>
              buildWalletFallback(),
        ),
      ),
    );
  }

  Widget _buildFallbackWalletIcon(bool isDarkMode, double size, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.06),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.account_balance_wallet_rounded,
          size: size * 0.48,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // ==========================================
  // BANK OR APP SELECTOR (اختيار البنك أو التطبيق)
  // ==========================================
  Widget _buildBankSelector(bool isDarkMode, bool isAr) {
    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'البنك أو التطبيق' : 'Bank or App',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openBankPickerScreen,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.0),
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
                  // Bank Squircle Avatar (with real logo if matched)
                  _buildSelectedBankAvatar(isDarkMode),
                  const SizedBox(width: 14),

                  // Title and Subtitle Stack
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedBank ??
                              (isAr ? 'اختر البنك أو المؤسسة' : 'Select Bank or Issuer'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: _selectedBank != null
                                ? FontWeight.w700
                                : FontWeight.w600,
                            letterSpacing: -0.2,
                            color: _selectedBank != null
                                ? (isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF09090B))
                                : (isDarkMode
                                    ? const Color(0xFF71717A)
                                    : const Color(0xFFA1A1AA)),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedBank != null
                              ? (isAr ? 'اضغط لتغيير البنك' : 'Tap to change')
                              : (isAr
                                  ? 'مثل: الأهلي، مصر، CIB، QNB'
                                  : 'e.g. CIB, NBE, Banque Misr'),
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
                  ),
                  const SizedBox(width: 8),

                  // Forward Chevron
                  Icon(
                    appForwardIconOf(context),
                    size: 13,
                    color: isDarkMode
                        ? const Color(0xFFA1A1AA)
                        : const Color(0xFF71717A),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedBankAvatar(bool isDarkMode) {
    EgyptianBank? matchedBank;
    if (_selectedBank != null) {
      final query = _selectedBank!.trim().toLowerCase();
      final allBanks = BankRepository().cachedBanks;
      for (final b in allBanks) {
        if (b.nameAr.toLowerCase() == query ||
            b.nameEn.toLowerCase() == query ||
            b.cleanName(true).toLowerCase() == query ||
            b.cleanName(false).toLowerCase() == query ||
            b.shortName.toLowerCase() == query ||
            query.contains(b.shortName.toLowerCase())) {
          matchedBank = b;
          break;
        }
      }
    }

    return Container(
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
        boxShadow: matchedBank != null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: () {
          final bank = matchedBank;
          if (bank != null) {
            final netLogo = bank.effectiveLogoUrl;
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Image.network(
                netLogo,
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: Icon(
                      Icons.account_balance_rounded,
                      size: 21,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 21,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }
          return Center(
            child: Icon(
              Icons.account_balance_rounded,
              size: 21,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          );
        }(),
      ),
    );
  }

  Future<void> _openBankPickerScreen() async {
    HapticFeedback.selectionClick();
    final selected = await BankPickerScreen.open(
      context,
      initialBank: _selectedBank,
    );
    if (selected != null && mounted) {
      final isAr = Localizations.localeOf(context).languageCode == 'ar';
      final formattedName = _selectedTypeId == 'certificate'
          ? (isAr ? 'شهادة $selected' : '$selected Certificate')
          : selected;
      setState(() {
        _selectedBank = selected;
        _nameController.text = formattedName;
        _handleNameChanged(formattedName);
        if (!_hasUserManuallySelectedIcon) {
          final guessed = _guessIconFromName(formattedName);
          if (guessed != null) {
            _selectedIcon = guessed;
            _autoGuessReason = selected;
          }
        }
      });
    }
  }

  // ==========================================
  // CURRENCY SELECTOR ROW (العملة)
  // ==========================================
  Widget _buildCurrencySelectorRow(bool isDarkMode, bool isAr) {
    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'العملة' : 'Currency',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
          ),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            final currency = kAllCurrencies.firstWhere(
              (c) => c.code == _selectedCurrency,
              orElse: () => AppCurrency(
                code: _selectedCurrency,
                nameEn: _selectedCurrency,
                nameAr: _selectedCurrency,
                flag: '🌐',
                symbol: getCurrencySymbol(_selectedCurrency),
                symbolAr: getCurrencySymbol(_selectedCurrency, isAr: true),
              ),
            );

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final picked = await CurrencyPickerScreen.open(
                    context,
                    initialCurrency: _selectedCurrency,
                  );
                  if (picked != null && mounted) {
                    setState(() => _selectedCurrency = picked);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.0),
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
                      // Flag Avatar Squircle
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

                      // Code & Full Name Stacked Column
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
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF09090B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAr ? currency.nameAr : currency.nameEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? const Color(0xFFA1A1AA)
                                    : const Color(0xFF71717A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Currency Symbol Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          isAr ? currency.symbolAr : currency.symbol,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF09090B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Forward Arrow
                      Icon(
                        appForwardIconOf(context),
                        size: 13,
                        color: isDarkMode
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF71717A),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // PRECIOUS METALS (GOLD & SILVER) HELPERS & SECTIONS
  // ==========================================
  static const Map<String, double> _goldBasePricesEgp = {
    '24': 4320.0,
    '22': 3960.0,
    '21': 3780.0,
    '18': 3240.0,
  };

  static const Map<String, double> _silverBasePricesEgp = {
    '999': 56.0,
    '925': 51.8,
    '900': 50.4,
    '800': 44.8,
  };

  static const Map<String, double> _currencyToEgpRates = {
    'EGP': 1.0,
    'USD': 49.0,
    'EUR': 53.0,
    'GBP': 62.0,
    'SAR': 13.06,
    'AED': 13.34,
    'KWD': 159.5,
    'QAR': 13.45,
    'BHD': 130.0,
    'OMR': 127.3,
    'JOD': 69.1,
    'CAD': 35.5,
    'AUD': 31.8,
    'CHF': 56.5,
    'JPY': 0.32,
    'TRY': 1.42,
  };

  double _getTodayMetalPrice(String typeId, String karat, String currency) {
    final rate = _currencyToEgpRates[currency.toUpperCase()] ?? 1.0;
    final double baseEgp;
    if (typeId == 'silver') {
      baseEgp = _silverBasePricesEgp[karat] ?? 51.8;
    } else {
      baseEgp = _goldBasePricesEgp[karat] ?? 3780.0;
    }
    return baseEgp / rate;
  }

  String _formatPriceNumber(double value, {int maxDecimals = 2}) {
    if (value == value.roundToDouble() && maxDecimals == 0) {
      return value.toInt().toString();
    }
    final parts = value.toStringAsFixed(maxDecimals).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    if (parts.length > 1) {
      final decimals = parts[1].replaceFirst(RegExp(r'0+$'), '');
      return decimals.isEmpty ? integerPart : '$integerPart.$decimals';
    }
    return integerPart;
  }

  String _formatMetalDate(DateTime date, bool isAr) {
    const arMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    const enMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = isAr ? arMonths[date.month - 1] : enMonths[date.month - 1];
    return '${date.day} $month ${date.year}';
  }

  Future<void> _selectPurchaseDate(BuildContext context, bool isDarkMode, bool isAr) async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final initial = _metalPurchaseDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(2000, 1, 1),
      lastDate: now,
      locale: Locale(isAr ? 'ar' : 'en'),
      builder: (context, child) {
        return Theme(
          data: (isDarkMode ? ThemeData.dark() : ThemeData.light()).copyWith(
            colorScheme: ColorScheme(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
              primary: isDarkMode ? Colors.white : Colors.black,
              onPrimary: isDarkMode ? Colors.black : Colors.white,
              surface: isDarkMode ? const Color(0xFF18181B) : Colors.white,
              onSurface: isDarkMode ? Colors.white : Colors.black,
              secondary: isDarkMode ? Colors.white : Colors.black,
              onSecondary: isDarkMode ? Colors.black : Colors.white,
              error: const Color(0xFFEF4444),
              onError: Colors.white,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _metalPurchaseDate = picked;
      });
    }
  }

  Widget _buildPreciousMetalsSection(
    bool isDarkMode,
    bool isAr,
    bool isIOS,
    AccountTypeDefinition type,
  ) {
    final isGold = type.id == 'gold';
    final karats = isGold ? ['18', '21', '22', '24'] : ['800', '900', '925', '999'];
    if (!karats.contains(_selectedMetalKarat)) {
      _selectedMetalKarat = isGold ? '21' : '925';
    }

    final todayPrice = _getTodayMetalPrice(type.id, _selectedMetalKarat, _selectedCurrency);
    final weight = double.tryParse(_metalWeightController.text.trim().replaceAll(',', '')) ?? 0.0;
    final purchasePrice = double.tryParse(_metalPurchasePriceController.text.trim().replaceAll(',', ''));
    final estimatedTotal = weight * todayPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. الوزن بالجرام (Weight in Grams)
        Text(
          isAr ? 'الوزن بالجرام' : 'Weight in Grams',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
          ),
        ),
        const SizedBox(height: 8),
        _buildAdaptiveTextField(
          controller: _metalWeightController,
          focusNode: _metalWeightFocusNode,
          placeholder: isAr ? 'مثال: 50' : 'e.g. 50',
          isIOS: isIOS,
          isDarkMode: isDarkMode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          suffix: _buildSuffixPill(isAr ? 'جرام' : 'g', isDarkMode),
          onChanged: (_) => setState(() {}),
        ),
        _buildFieldHelpText(
          isAr
              ? 'أدخل الوزن الإجمالي بالجرامات لحساب القيمة التقديرية بدقة.'
              : 'Enter total weight in grams to calculate estimated value accurately.',
          isDarkMode,
        ),
        const SizedBox(height: 18),

        // 2. العيار (Karat Tabs)
        _buildKaratSegmentedTabs(isDarkMode, isAr, isGold, karats),
        const SizedBox(height: 18),

        // 3. سعر الشراء للجرام (Purchase Price per Gram - Optional)
        Row(
          children: [
            Text(
              isAr ? 'سعر الشراء للجرام' : 'Purchase Price per Gram',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isAr ? '(اختياري)' : '(Optional)',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAdaptiveTextField(
          controller: _metalPurchasePriceController,
          focusNode: _metalPurchasePriceFocusNode,
          placeholder: isAr ? 'مثال: 3,500' : 'e.g. 3,500',
          isIOS: isIOS,
          isDarkMode: isDarkMode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          suffix: _buildSuffixPill(_selectedCurrency, isDarkMode),
          onChanged: (_) => setState(() {}),
        ),
        _buildFieldHelpText(
          isAr
              ? 'سعر الجرام وقت ما اشتريت لحساب الأرباح أو الخسائر التقديرية.'
              : 'Price per gram when purchased to calculate your estimated return.',
          isDarkMode,
        ),
        const SizedBox(height: 18),

        // 4. تاريخ الشراء (Purchase Date Card)
        _buildPurchaseDateCard(isDarkMode, isAr),
        const SizedBox(height: 18),

        // 5. سعر الجرام النهارده (Today's Live Market Price Card)
        _buildTodayMarketPriceCard(isDarkMode, isAr, isGold, todayPrice),
        const SizedBox(height: 12),

        // 6. تحديث السعر تلقائياً (Auto-update Live Price Toggle)
        _buildAutoUpdatePriceTile(isDarkMode, isAr),
        const SizedBox(height: 18),

        // 7. عرض القيمة التقديرية (Estimated Total Value Card)
        _buildMetalEstimatedValueCard(
          isDarkMode,
          isAr,
          weight,
          todayPrice,
          estimatedTotal,
          purchasePrice,
        ),
      ],
    );
  }

  Widget _buildKaratSegmentedTabs(
    bool isDarkMode,
    bool isAr,
    bool isGold,
    List<String> karats,
  ) {
    final activeBg = isDarkMode ? Colors.white : Colors.black;
    final activeFg = isDarkMode ? Colors.black : Colors.white;
    final inactiveBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final inactiveBorder = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);
    final inactiveFg = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF52525B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? 'العيار' : 'Karat / Purity',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isGold
                    ? (isAr ? 'عيار $_selectedMetalKarat' : '$_selectedMetalKarat Karat')
                    : (isAr ? 'فضة عيار $_selectedMetalKarat' : 'Silver $_selectedMetalKarat'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: karats.map((k) {
            final isSelected = _selectedMetalKarat == k;
            String subtitle = '';
            if (isGold) {
              subtitle = isAr ? 'عيار' : 'k';
            } else {
              if (k == '999') {
                subtitle = isAr ? 'نقي' : 'Pure';
              } else if (k == '925') {
                subtitle = isAr ? 'استرليني' : 'Sterling';
              } else if (k == '900') {
                subtitle = isAr ? 'عملات' : 'Coins';
              } else {
                subtitle = isAr ? 'شائع' : 'Common';
              }
            }

            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: k != karats.last ? 8 : 0,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMetalKarat = k);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? activeBg : inactiveBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? activeBg : inactiveBorder,
                          width: isSelected ? 1.4 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDarkMode ? 0.35 : 0.12,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            k,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? activeFg : (isDarkMode ? Colors.white : Colors.black),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? activeFg.withValues(alpha: 0.85)
                                  : inactiveFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPurchaseDateCard(bool isDarkMode, bool isAr) {
    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isAr ? 'تاريخ الشراء' : 'Purchase Date',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isAr ? '(اختياري)' : '(Optional)',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectPurchaseDate(context, isDarkMode, isAr),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _metalPurchaseDate != null
                              ? _formatMetalDate(_metalPurchaseDate!, isAr)
                              : (isAr ? 'اضغط لاختيار تاريخ الشراء' : 'Tap to select purchase date'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _metalPurchaseDate != null
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: _metalPurchaseDate != null
                                ? (isDarkMode ? Colors.white : const Color(0xFF09090B))
                                : (isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_metalPurchaseDate != null)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _metalPurchaseDate = null);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                        ),
                      ),
                    )
                  else
                    Icon(
                      appForwardIconOf(context),
                      size: 13,
                      color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
                    ),
                ],
              ),
            ),
          ),
        ),
        _buildFieldHelpText(
          isAr
              ? 'تاريخ شرائك هيتعلم تلقائياً على الرسم البياني لمتابعة حركة السعر من وقتها.'
              : 'Your purchase date will be marked on the chart to track performance since that day.',
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildTodayMarketPriceCard(
    bool isDarkMode,
    bool isAr,
    bool isGold,
    double todayPrice,
  ) {
    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? 'سعر الجرام اليوم (السوق)' : 'Today\'s Market Price / g',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
              ),
            ),
            // Live Indicator badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isAr ? 'مباشر الآن' : 'Live Benchmark',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatPriceNumber(todayPrice, maxDecimals: 2),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_selectedCurrency / ${isAr ? 'جرام' : 'g'}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isGold
                    ? (isAr
                        ? 'محدث تلقائياً لذهب عيار $_selectedMetalKarat بالـ $_selectedCurrency'
                        : 'Updated for $_selectedMetalKarat Karat Gold in $_selectedCurrency')
                    : (isAr
                        ? 'محدث تلقائياً لفضة عيار $_selectedMetalKarat بالـ $_selectedCurrency'
                        : 'Updated for $_selectedMetalKarat Silver in $_selectedCurrency'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAutoUpdatePriceTile(bool isDarkMode, bool isAr) {
    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: _buildToggleOptionTile(
        icon: Icons.sync_rounded,
        title: isAr ? 'تحديث السعر تلقائياً' : 'Auto-update Market Price',
        subtitle: isAr
            ? 'متابعة تغيرات أسعار السوق اليومية وتحديث قيمة رصيدك تلقائياً'
            : 'Track daily market movements and keep your balance up to date',
        value: _autoUpdateMetalPrice,
        isDarkMode: isDarkMode,
        onChanged: (val) => setState(() => _autoUpdateMetalPrice = val),
      ),
    );
  }

  Widget _buildMetalEstimatedValueCard(
    bool isDarkMode,
    bool isAr,
    double weight,
    double todayPrice,
    double estimatedTotal,
    double? purchasePrice,
  ) {
    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);

    final bool hasPurchasePrice = purchasePrice != null && purchasePrice > 0;
    final double? totalCost = hasPurchasePrice && weight > 0 ? (weight * purchasePrice) : null;
    final double? pnl = totalCost != null ? (estimatedTotal - totalCost) : null;
    final double? pnlPct = totalCost != null && totalCost > 0 ? (pnl! / totalCost) * 100 : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'عرض القيمة التقديرية' : 'Estimated Total Value',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: isDarkMode
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAr ? 'صافي القيمة الحالية' : 'Net Current Value',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                        ),
                      ),
                    ],
                  ),
                  if (weight > 0)
                    Text(
                      '${_formatPriceNumber(weight, maxDecimals: 3)} ${isAr ? 'جرام' : 'g'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatPriceNumber(estimatedTotal, maxDecimals: 2),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedCurrency,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
              if (weight > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${_formatPriceNumber(weight, maxDecimals: 3)} ${isAr ? 'جرام' : 'g'} × ${_formatPriceNumber(todayPrice, maxDecimals: 2)} $_selectedCurrency',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 4),
                Text(
                  isAr ? 'أدخل الوزن بالجرام لحساب القيمة التقديرية' : 'Enter weight in grams to calculate value',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
                  ),
                ),
              ],

              // Profit/Loss & Cost Breakdown if purchase price is present
              if (hasPurchasePrice && totalCost != null && pnl != null && pnlPct != null) ...[
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'إجمالي تكلفة الشراء' : 'Total Purchase Cost',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatPriceNumber(totalCost, maxDecimals: 2)} $_selectedCurrency',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (pnl >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (pnl >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            pnl >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            size: 14,
                            color: pnl >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pnl >= 0 ? '+' : ''}${_formatPriceNumber(pnl, maxDecimals: 2)} (${pnl >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: pnl >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // FIELD HELP TEXT (Description under fields)
  // ==========================================
  Widget _buildFieldHelpText(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 6, start: 2, end: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1.5),
            child: Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.35,
                fontWeight: FontWeight.w400,
                color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FIELD SUFFIX PILL (Currency, %, etc.)
  // ==========================================
  Widget _buildSuffixPill(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : const Color(0xFF09090B),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // QUICK NAME SUGGESTION CHIPS
  // ==========================================
  Widget _buildNameSuggestionChips(
    bool isDarkMode,
    bool isAr,
    AccountTypeDefinition type,
  ) {
    final suggestions = _getSuggestionsForType(type.id, isAr);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: suggestions.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, idx) {
            final text = suggestions[idx];
            final isSelected = _nameController.text.trim() == text;

            final selectedBg = isDarkMode ? Colors.white : Colors.black;
            final selectedFg = isDarkMode ? Colors.black : Colors.white;

            final unselectedBg = isDarkMode
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04);
            final unselectedFg = isDarkMode
                ? const Color(0xFFA1A1AA)
                : const Color(0xFF71717A);
            final unselectedBorder = isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _nameController.text = text;
                  _handleNameChanged(text);
                },
                borderRadius: BorderRadius.circular(15),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedBg : unselectedBg,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : unselectedBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? selectedFg : unselectedFg,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<String> _getSuggestionsForType(String typeId, bool isAr) {
    switch (typeId) {
      case 'cash':
        return isAr
            ? ['محفظة الجيب', 'كاش البيت', 'خزنة الطوارئ', 'فكة العربية']
            : ['Pocket Wallet', 'Home Cash', 'Emergency Safe', 'Car Cash'];
      case 'ewallet':
        return isAr
            ? ['فودافون كاش', 'إنستاباي', 'تيلدا', 'أورانج كاش']
            : ['Vodafone Cash', 'InstaPay', 'Telda', 'Orange Cash'];
      case 'bank':
        return isAr
            ? ['حساب المرتب', 'حساب جاري', 'حساب توفير']
            : ['Salary Account', 'Checking Account', 'Savings Account'];
      case 'credit_card':
        return isAr
            ? ['مشتريات رئيسي', 'كارت السفر', 'كارت الأونلاين']
            : ['Main Purchases', 'Travel Card', 'Online Shopping'];
      case 'savings':
        return isAr
            ? ['صندوق الطوارئ', 'تحويش السفر', 'صندوق الاستثمار']
            : ['Emergency Fund', 'Travel Savings', 'Future Fund'];
      case 'gold':
        return isAr
            ? ['ذهب العائلة', 'ذهب الادخار', 'سبائك ذهب', 'جنيهات ذهب']
            : ['Family Gold', 'Savings Bullion', 'Gold Bars', 'Gold Coins'];
      case 'silver':
        return isAr
            ? ['فضة الادخار', 'سبائك فضة', 'جنيهات فضة', 'مشغولات فضة']
            : ['Silver Savings', 'Silver Bars', 'Silver Coins', 'Silver Jewelry'];
      case 'certificate':
        return isAr
            ? ['شهادة 27%', 'شهادة ثلاثية', 'وديعة بنكية', 'شهادة استثمار']
            : ['27% Certificate', '3-Year CD', 'Bank Deposit', 'Investment Certificate'];
      case 'investment':
        return isAr
            ? ['محفظة ثندر', 'صناديق استثمار', 'أسهم البورصة']
            : ['Thndr Portfolio', 'Mutual Funds', 'Stocks'];
      default:
        return [];
    }
  }

  // ==========================================
  // ADAPTIVE TEXT FIELD WIDGET
  // ==========================================
  Widget _buildAdaptiveTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String placeholder,
    required bool isIOS,
    required bool isDarkMode,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextStyle? style,
    EdgeInsetsGeometry? padding,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    if (isIOS) {
      final cupertinoDeco = BoxDecoration(
        color: isDarkMode ? const Color(0xFF141418) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE4E4E7),
          width: 1.0,
        ),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.015),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      );

      return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          primaryColor: isDarkMode ? Colors.white : Colors.black,
        ),
        child: NeoTextField(
          controller: controller,
          focusNode: focusNode,
          placeholder: placeholder,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          cupertinoDecoration: cupertinoDeco,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          style: style ??
              TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
          suffix: suffix,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
        ),
      );
    }

    // Android / Material 3 styling
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      keyboardAppearance: isDarkMode ? Brightness.dark : Brightness.light,
      maxLength: maxLength,
      buildCounter: maxLength != null
          ? (context, {required currentLength, required isFocused, required maxLength}) => null
          : null,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      style: style ??
          TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          fontSize: 14.5,
          color: isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF141418) : Colors.white,
        contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: suffix,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0xFFE4E4E7),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0xFFE4E4E7),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0xFFE4E4E7),
            width: 1,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }

  // ==========================================
  // FLOATING SUBMIT BUTTON
  // ==========================================
  Widget _buildFloatingSubmitButton(bool isDarkMode, bool isAr) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSubmitting ? null : _submitAccount,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? Colors.white : Colors.black)
                    .withValues(alpha: isDarkMode ? 0.18 : 0.22),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: isDarkMode ? Colors.black : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAr ? 'حفظ الحساب' : 'Save Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.black : Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ADDITIONAL ACCOUNT OPTIONS (TOGGLES)
  // ==========================================
  Widget _buildAccountOptionsSection(
    bool isDarkMode,
    bool isAr,
    AccountTypeDefinition type,
  ) {
    final isMetal = type.id == 'gold' || type.id == 'silver';
    final cardBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4E4E7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'خيارات إضافية' : 'Additional Options',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? const Color(0xFFE4E4E7) : const Color(0xFF27272A),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.0),
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
            children: [
              // 1. Exclude from Total / Net Worth
              _buildToggleOptionTile(
                icon: Icons.visibility_off_outlined,
                title: isMetal
                    ? (isAr ? 'استبعاد من صافي الثروة' : 'Exclude from Net Worth')
                    : (isAr ? 'استبعاد من إجمالي الرصيد' : 'Exclude from Total Balance'),
                subtitle: isMetal
                    ? (isAr
                        ? 'إخفاء من الإجمالي، ومش هيتحسب ضمن صافي الثروة في الصفحة الرئيسية'
                        : 'Balance won\'t count toward your net worth on the home screen')
                    : (isAr
                        ? 'رصيده ومعاملاته مش هيتحسبوا في صافي الثروة بالصفحة الرئيسية'
                        : 'Balance & transactions won\'t count toward your net worth'),
                value: _excludeFromTotal,
                isDarkMode: isDarkMode,
                onChanged: (val) => setState(() => _excludeFromTotal = val),
              ),

              // 2. InstaPay Fee Auto-Add (Exclusive for Debit Card / Bank accounts)
              if (type.id == 'bank') ...[
                Divider(
                  height: 1,
                  indent: isAr ? 14 : 62,
                  endIndent: isAr ? 62 : 14,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                _buildToggleOptionTile(
                  icon: Icons.bolt_rounded,
                  title: isAr ? 'إضافة عمولة إنستاباي تلقائياً' : 'Auto-add InstaPay transfer fee',
                  subtitle: isAr
                      ? 'إنستاباي بيخصم عمولة 0.1% بحد أقصى 20 جنيه.\n• لو بنكك بيضيف العمولة دي في مبلغ الرسالة تلقائياً: اقفل ده.\n• لو بنكك بيعرض المبلغ الأصلي بس: سيبه مفعّل عشان نضيف العمولة تلقائياً ويطابق اللي اتخصم فعلياً.'
                      : 'InstaPay deducts a 0.1% fee (max 20 EGP).\n• If your bank includes this fee in the SMS amount, turn this off.\n• If your bank only shows the base transfer amount, leave this on so we auto-add the fee to match your actual deduction.',
                  value: _autoAddInstapayFee,
                  isDarkMode: isDarkMode,
                  onChanged: (val) => setState(() => _autoAddInstapayFee = val),
                ),
              ],

              // 3. ATM Withdrawals (Exclusive for Cash accounts)
              if (type.id == 'cash') ...[
                Divider(
                  height: 1,
                  indent: isAr ? 14 : 62,
                  endIndent: isAr ? 62 : 14,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                _buildToggleOptionTile(
                  icon: Icons.local_atm_rounded,
                  title: isAr ? 'سحوبات الـ ATM بتنزل هنا' : 'Deposit ATM Withdrawals Here',
                  subtitle: isAr
                      ? 'رسائل سحب الكاش من البنك هتتحول تلقائياً للحساب ده لتفادي ازدواج المصاريف'
                      : 'Cash withdrawals from bank will auto-transfer here to prevent double spending',
                  value: _receiveAtmWithdrawals,
                  isDarkMode: isDarkMode,
                  onChanged: (val) => setState(() => _receiveAtmWithdrawals = val),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDarkMode,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Squircle Avatar
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withValues(alpha: value ? 0.12 : 0.05),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: (isDarkMode ? Colors.white : Colors.black)
                          .withValues(alpha: value ? 0.20 : 0.06),
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 19,
                      color: isDarkMode
                          ? (value ? Colors.white : const Color(0xFFA1A1AA))
                          : (value ? Colors.black : const Color(0xFF71717A)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF09090B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Adaptive Glass Switch (iOS 26+ Liquid Glass / Cupertino fallback)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: _buildAdaptiveGlassSwitch(
                  value: value,
                  isDarkMode: isDarkMode,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ADAPTIVE GLASS SWITCH (iOS 26+ Liquid Glass)
  // ==========================================
  Widget _buildAdaptiveGlassSwitch({
    required bool value,
    required bool isDarkMode,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    if (!Platform.isIOS || !PlatformInfo.isIOS26OrHigher()) {
      return CupertinoSwitch(
        value: value,
        activeTrackColor: activeColor ??
            (isDarkMode ? Colors.white : Colors.black),
        thumbColor: value
            ? (isDarkMode ? Colors.black : Colors.white)
            : null,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          onChanged(val);
        },
      );
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Transform.flip(
        flipX: isRtl,
        child: GlassSwitch(
          value: value,
          useOwnLayer: true,
          width: 58.0,
          height: 30.0,
          activeColor: activeColor ??
              (isDarkMode
                  ? Colors.white.withValues(alpha: 0.85)
                  : Colors.black.withValues(alpha: 0.85)),
          inactiveColor: isDarkMode
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.10),
          thumbColor: isDarkMode ? Colors.black : Colors.white,
          settings: LiquidGlassSettings(
            thickness: 24,
            blur: 16,
            glassColor: isDarkMode
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.38),
          ),
          onChanged: (val) {
            HapticFeedback.selectionClick();
            onChanged(val);
          },
        ),
      ),
    );
  }
}
