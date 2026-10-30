import 'package:flutter/material.dart';

enum TransactionType { all, income, expense, transfer }

class TransactionFilter {
  final TransactionType type;
  final String label;

  TransactionFilter({
    required this.type,
    required this.label,
  });
}

class AccountItem {
  final String id;
  final String name;
  final String type; // 'all', 'cash', 'bank', 'ewallet', 'savings', 'credit_card', 'investment', 'gold', 'silver', 'certificate'
  final double balance;
  final double income;
  final double expense;
  final IconData icon;
  final bool isAll;
  final bool isMain;
  final String? accountNumber;
  final String currency;
  final String? bankName;
  final String? provider;
  final String? notificationMethod; // 'sms' or 'notification'
  final List<String>? cardNumbers;
  final double? creditLimit;
  final int? billingDay;
  final int? dueDay;
  final double? minPaymentPercentage;
  final double? availableBalance;
  final bool excludeFromTotal;
  final bool receiveAtmWithdrawals;
  final bool autoAddInstapayFee;
  final String? metalKarat;
  final double? metalWeightGrams;
  final double? metalPurchasePricePerGram;
  final DateTime? metalPurchaseDate;
  final double? metalCurrentPricePerGram;
  final bool autoUpdateMetalPrice;
  final String? propertyCategory; // 'fund', 'apartment', 'car', 'business', 'other'
  final double? annualYieldRate; // e.g. 22.5% for money market funds
  final bool autoEstimateValue; // true if auto-adjusting value
  final double? estimateRateYearly; // e.g. 10.0%
  final String? estimateDirection; // 'up' or 'down'
  final String? reminderFrequency; // 'monthly', '3_months', '6_months', 'never'
  final String? note;
  final double? totalInvestedAmount; // Cost basis for stocks/crypto to compute P&L
  final String? investmentPlatform; // e.g. 'egx', 'us_stocks', 'crypto', 'other'

  const AccountItem({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.income = 0.0,
    this.expense = 0.0,
    required this.icon,
    this.isAll = false,
    this.isMain = false,
    this.accountNumber,
    this.currency = 'EGP',
    this.bankName,
    this.provider,
    this.notificationMethod,
    this.cardNumbers,
    this.creditLimit,
    this.billingDay,
    this.dueDay,
    this.minPaymentPercentage,
    this.availableBalance,
    this.excludeFromTotal = false,
    this.receiveAtmWithdrawals = false,
    this.autoAddInstapayFee = false,
    this.metalKarat,
    this.metalWeightGrams,
    this.metalPurchasePricePerGram,
    this.metalPurchaseDate,
    this.metalCurrentPricePerGram,
    this.autoUpdateMetalPrice = true,
    this.propertyCategory,
    this.annualYieldRate,
    this.autoEstimateValue = false,
    this.estimateRateYearly,
    this.estimateDirection,
    this.reminderFrequency,
    this.note,
    this.totalInvestedAmount,
    this.investmentPlatform,
  });

  AccountItem copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    double? income,
    double? expense,
    IconData? icon,
    bool? isAll,
    bool? isMain,
    String? accountNumber,
    String? currency,
    String? bankName,
    String? provider,
    String? notificationMethod,
    List<String>? cardNumbers,
    double? creditLimit,
    int? billingDay,
    int? dueDay,
    double? minPaymentPercentage,
    double? availableBalance,
    bool? excludeFromTotal,
    bool? receiveAtmWithdrawals,
    bool? autoAddInstapayFee,
    String? metalKarat,
    double? metalWeightGrams,
    double? metalPurchasePricePerGram,
    DateTime? metalPurchaseDate,
    double? metalCurrentPricePerGram,
    bool? autoUpdateMetalPrice,
    String? propertyCategory,
    double? annualYieldRate,
    bool? autoEstimateValue,
    double? estimateRateYearly,
    String? estimateDirection,
    String? reminderFrequency,
    String? note,
    double? totalInvestedAmount,
    String? investmentPlatform,
  }) {
    return AccountItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      icon: icon ?? this.icon,
      isAll: isAll ?? this.isAll,
      isMain: isMain ?? this.isMain,
      accountNumber: accountNumber ?? this.accountNumber,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      provider: provider ?? this.provider,
      notificationMethod: notificationMethod ?? this.notificationMethod,
      cardNumbers: cardNumbers ?? this.cardNumbers,
      creditLimit: creditLimit ?? this.creditLimit,
      billingDay: billingDay ?? this.billingDay,
      dueDay: dueDay ?? this.dueDay,
      minPaymentPercentage: minPaymentPercentage ?? this.minPaymentPercentage,
      availableBalance: availableBalance ?? this.availableBalance,
      excludeFromTotal: excludeFromTotal ?? this.excludeFromTotal,
      receiveAtmWithdrawals: receiveAtmWithdrawals ?? this.receiveAtmWithdrawals,
      autoAddInstapayFee: autoAddInstapayFee ?? this.autoAddInstapayFee,
      metalKarat: metalKarat ?? this.metalKarat,
      metalWeightGrams: metalWeightGrams ?? this.metalWeightGrams,
      metalPurchasePricePerGram: metalPurchasePricePerGram ?? this.metalPurchasePricePerGram,
      metalPurchaseDate: metalPurchaseDate ?? this.metalPurchaseDate,
      metalCurrentPricePerGram: metalCurrentPricePerGram ?? this.metalCurrentPricePerGram,
      autoUpdateMetalPrice: autoUpdateMetalPrice ?? this.autoUpdateMetalPrice,
      propertyCategory: propertyCategory ?? this.propertyCategory,
      annualYieldRate: annualYieldRate ?? this.annualYieldRate,
      autoEstimateValue: autoEstimateValue ?? this.autoEstimateValue,
      estimateRateYearly: estimateRateYearly ?? this.estimateRateYearly,
      estimateDirection: estimateDirection ?? this.estimateDirection,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      note: note ?? this.note,
      totalInvestedAmount: totalInvestedAmount ?? this.totalInvestedAmount,
      investmentPlatform: investmentPlatform ?? this.investmentPlatform,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'balance': balance,
    'income': income,
    'expense': expense,
    'icon': icon.codePoint,
    'isAll': isAll,
    'isMain': isMain,
    'accountNumber': accountNumber,
    'currency': currency,
    if (bankName != null) 'bankName': bankName,
    if (provider != null) 'provider': provider,
    if (notificationMethod != null) 'notificationMethod': notificationMethod,
    if (cardNumbers != null) 'cardNumbers': cardNumbers,
    if (creditLimit != null) 'creditLimit': creditLimit,
    if (billingDay != null) 'billingDay': billingDay,
    if (dueDay != null) 'dueDay': dueDay,
    if (minPaymentPercentage != null) 'minPaymentPercentage': minPaymentPercentage,
    if (availableBalance != null) 'availableBalance': availableBalance,
    if (excludeFromTotal) 'excludeFromTotal': excludeFromTotal,
    if (receiveAtmWithdrawals) 'receiveAtmWithdrawals': receiveAtmWithdrawals,
    if (autoAddInstapayFee) 'autoAddInstapayFee': autoAddInstapayFee,
    if (metalKarat != null) 'metalKarat': metalKarat,
    if (metalWeightGrams != null) 'metalWeightGrams': metalWeightGrams,
    if (metalPurchasePricePerGram != null) 'metalPurchasePricePerGram': metalPurchasePricePerGram,
    if (metalPurchaseDate != null) 'metalPurchaseDate': metalPurchaseDate!.toIso8601String(),
    if (metalCurrentPricePerGram != null) 'metalCurrentPricePerGram': metalCurrentPricePerGram,
    if (!autoUpdateMetalPrice) 'autoUpdateMetalPrice': autoUpdateMetalPrice,
    if (propertyCategory != null) 'propertyCategory': propertyCategory,
    if (annualYieldRate != null) 'annualYieldRate': annualYieldRate,
    if (autoEstimateValue) 'autoEstimateValue': autoEstimateValue,
    if (estimateRateYearly != null) 'estimateRateYearly': estimateRateYearly,
    if (estimateDirection != null) 'estimateDirection': estimateDirection,
    if (reminderFrequency != null) 'reminderFrequency': reminderFrequency,
    if (note != null) 'note': note,
    if (totalInvestedAmount != null) 'totalInvestedAmount': totalInvestedAmount,
    if (investmentPlatform != null) 'investmentPlatform': investmentPlatform,
  };

  factory AccountItem.fromJson(Map<String, dynamic> json) {
    final codePoint = json['icon'] as int? ?? Icons.account_balance_rounded.codePoint;
    IconData resolvedIcon = Icons.account_balance_rounded;
    for (final icon in kAvailableAccountIcons) {
      if (icon.codePoint == codePoint) {
        resolvedIcon = icon;
        break;
      }
    }
    return AccountItem(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'bank',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
      icon: resolvedIcon,
      isAll: json['isAll'] as bool? ?? false,
      isMain: json['isMain'] as bool? ?? false,
      accountNumber: json['accountNumber'] as String?,
      currency: json['currency'] as String? ?? 'EGP',
      bankName: json['bankName'] as String?,
      provider: json['provider'] as String?,
      notificationMethod: json['notificationMethod'] as String?,
      cardNumbers: (json['cardNumbers'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      billingDay: json['billingDay'] as int?,
      dueDay: json['dueDay'] as int?,
      minPaymentPercentage: (json['minPaymentPercentage'] as num?)?.toDouble(),
      availableBalance: (json['availableBalance'] as num?)?.toDouble(),
      excludeFromTotal: json['excludeFromTotal'] as bool? ?? false,
      receiveAtmWithdrawals: json['receiveAtmWithdrawals'] as bool? ?? false,
      autoAddInstapayFee: json['autoAddInstapayFee'] as bool? ?? false,
      metalKarat: json['metalKarat'] as String?,
      metalWeightGrams: (json['metalWeightGrams'] as num?)?.toDouble(),
      metalPurchasePricePerGram: (json['metalPurchasePricePerGram'] as num?)?.toDouble(),
      metalPurchaseDate: json['metalPurchaseDate'] != null ? DateTime.tryParse(json['metalPurchaseDate'] as String) : null,
      metalCurrentPricePerGram: (json['metalCurrentPricePerGram'] as num?)?.toDouble(),
      autoUpdateMetalPrice: json['autoUpdateMetalPrice'] as bool? ?? true,
      propertyCategory: json['propertyCategory'] as String?,
      annualYieldRate: (json['annualYieldRate'] as num?)?.toDouble(),
      autoEstimateValue: json['autoEstimateValue'] as bool? ?? false,
      estimateRateYearly: (json['estimateRateYearly'] as num?)?.toDouble(),
      estimateDirection: json['estimateDirection'] as String?,
      reminderFrequency: json['reminderFrequency'] as String?,
      note: json['note'] as String?,
      totalInvestedAmount: (json['totalInvestedAmount'] as num?)?.toDouble(),
      investmentPlatform: json['investmentPlatform'] as String?,
    );
  }
}

const List<IconData> kAvailableAccountIcons = [
  // Banks & Cards
  Icons.account_balance_rounded,
  Icons.account_balance_outlined,
  Icons.credit_card_rounded,
  Icons.credit_card_outlined,
  Icons.wallet_outlined,
  Icons.wallet_rounded,
  Icons.shield_outlined,
  Icons.shield_rounded,
  Icons.lock_outline_rounded,
  Icons.lock_rounded,

  // Cash & Money
  Icons.payments_rounded,
  Icons.payments_outlined,
  Icons.account_balance_wallet_rounded,
  Icons.account_balance_wallet_outlined,
  Icons.savings_rounded,
  Icons.savings_outlined,
  Icons.monetization_on_rounded,
  Icons.attach_money_rounded,
  Icons.currency_exchange_rounded,
  Icons.receipt_long_rounded,

  // Wallets & Tech
  Icons.smartphone_rounded,
  Icons.smartphone_outlined,
  Icons.send_to_mobile_rounded,
  Icons.phone_iphone_rounded,
  Icons.phone_android_rounded,
  Icons.cell_tower_rounded,
  Icons.payment_rounded,
  Icons.qr_code_rounded,
  Icons.contactless_rounded,
  Icons.wifi_rounded,
  Icons.devices_rounded,

  // Investments & Assets
  Icons.diamond_rounded,
  Icons.diamond_outlined,
  Icons.circle_outlined,
  Icons.verified_outlined,
  Icons.card_membership_rounded,
  Icons.trending_up_rounded,
  Icons.view_in_ar_outlined,
  Icons.pie_chart_outline_rounded,
  Icons.pie_chart_rounded,
  Icons.show_chart_rounded,
  Icons.storefront_rounded,
  Icons.business_center_rounded,
  Icons.work_rounded,
  Icons.handshake_rounded,

  // Lifestyle & Goals
  Icons.home_rounded,
  Icons.apartment_rounded,
  Icons.directions_car_rounded,
  Icons.two_wheeler_rounded,
  Icons.flight_takeoff_rounded,
  Icons.shopping_bag_outlined,
  Icons.shopping_bag_rounded,
  Icons.shopping_cart_rounded,
  Icons.restaurant_rounded,
  Icons.local_cafe_rounded,
  Icons.fitness_center_rounded,
  Icons.medical_services_rounded,
  Icons.school_outlined,
  Icons.school_rounded,
  Icons.card_giftcard_rounded,
  Icons.celebration_rounded,
  Icons.sports_esports_rounded,
  Icons.movie_rounded,
  Icons.pets_rounded,
  Icons.child_care_rounded,
  Icons.lightbulb_rounded,
  Icons.local_shipping_rounded,
  Icons.spa_rounded,
  Icons.construction_rounded,
  Icons.volunteer_activism_rounded,
  Icons.family_restroom_rounded,
  Icons.stars_rounded,
  Icons.auto_awesome_rounded,
];

