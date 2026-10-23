import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

/// Categories for organizing and browsing icons intuitively.
enum AppIconCategory {
  all,
  finance,
  food,
  transport,
  home,
  shopping,
  health,
  entertainment,
  education,
  family,
  other,
}

extension AppIconCategoryExtension on AppIconCategory {
  String name(bool isAr) {
    switch (this) {
      case AppIconCategory.all:
        return isAr ? 'الكل' : 'All';
      case AppIconCategory.finance:
        return isAr ? 'مالية وبنوك' : 'Finance';
      case AppIconCategory.food:
        return isAr ? 'طعام ومشروبات' : 'Food';
      case AppIconCategory.transport:
        return isAr ? 'مواصلات وسفر' : 'Transport';
      case AppIconCategory.home:
        return isAr ? 'سكن وفواتير' : 'Home & Bills';
      case AppIconCategory.shopping:
        return isAr ? 'تسوق ومظهر' : 'Shopping';
      case AppIconCategory.health:
        return isAr ? 'صحة ولياقة' : 'Health & Gym';
      case AppIconCategory.entertainment:
        return isAr ? 'ترفيه واشتراكات' : 'Entertainment';
      case AppIconCategory.education:
        return isAr ? 'تعليم وعمل' : 'Education & Work';
      case AppIconCategory.family:
        return isAr ? 'أسرة وحياة' : 'Family & Life';
      case AppIconCategory.other:
        return isAr ? 'أخرى ومتنوعة' : 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case AppIconCategory.all:
        return Icons.grid_view_rounded;
      case AppIconCategory.finance:
        return Icons.account_balance_rounded;
      case AppIconCategory.food:
        return Icons.restaurant_rounded;
      case AppIconCategory.transport:
        return Icons.directions_car_rounded;
      case AppIconCategory.home:
        return Icons.home_rounded;
      case AppIconCategory.shopping:
        return Icons.shopping_bag_rounded;
      case AppIconCategory.health:
        return Icons.favorite_rounded;
      case AppIconCategory.entertainment:
        return Icons.movie_rounded;
      case AppIconCategory.education:
        return Icons.school_rounded;
      case AppIconCategory.family:
        return Icons.diversity_3_rounded;
      case AppIconCategory.other:
        return Icons.auto_awesome_rounded;
    }
  }
}

/// Ordered list of distinct categories (excluding .all)
const List<AppIconCategory> kAppIconCategories = [
  AppIconCategory.finance,
  AppIconCategory.food,
  AppIconCategory.transport,
  AppIconCategory.home,
  AppIconCategory.shopping,
  AppIconCategory.health,
  AppIconCategory.entertainment,
  AppIconCategory.education,
  AppIconCategory.family,
  AppIconCategory.other,
];

/// Ordered list of filter pills for the top scrollable bar (starts with .all)
const List<AppIconCategory> kAppIconFilterCategories = [
  AppIconCategory.all,
  ...kAppIconCategories,
];

/// Model describing an icon with bilingual search keywords and category tagging
class AppIconItem {
  final IconData icon;
  final String nameAr;
  final String nameEn;
  final List<String> keywords;
  final AppIconCategory category;

  const AppIconItem({
    required this.icon,
    required this.nameAr,
    required this.nameEn,
    required this.keywords,
    this.category = AppIconCategory.other,
  });

  bool matches(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return true;
    if (nameAr.toLowerCase().contains(clean)) return true;
    if (nameEn.toLowerCase().contains(clean)) return true;
    for (final kw in keywords) {
      if (kw.toLowerCase().contains(clean)) return true;
    }
    return false;
  }
}

/// Backwards compatibility alias
typedef AccountIconItem = AppIconItem;

/// Complete icon catalog for accounts, categories, and wallets.
final List<AppIconItem> kAppIconItems = [
  const AppIconItem(
    icon: Icons.account_balance_wallet_rounded,
    nameAr: 'محفظة كاش',
    nameEn: 'Cash Wallet',
    category: AppIconCategory.finance,
    keywords: ['محفظة', 'كاش', 'فلوس', 'نقود', 'جيب', 'wallet', 'cash', 'money'],
  ),
  const AppIconItem(
    icon: Icons.payments_rounded,
    nameAr: 'فلوس ونقدية',
    nameEn: 'Banknotes / Cash',
    category: AppIconCategory.finance,
    keywords: ['كاش', 'فلوس', 'مرتب', 'قبض', 'نقدية', 'cash', 'notes', 'bills', 'income'],
  ),
  const AppIconItem(
    icon: Icons.savings_rounded,
    nameAr: 'حصالة وتوفير',
    nameEn: 'Piggy Bank / Savings',
    category: AppIconCategory.finance,
    keywords: ['حصالة', 'توفير', 'تحويش', 'ادخار', 'saving', 'savings', 'safe'],
  ),
  const AppIconItem(
    icon: Icons.account_balance_rounded,
    nameAr: 'حساب بنكي',
    nameEn: 'Bank Account',
    category: AppIconCategory.finance,
    keywords: ['بنك', 'حساب', 'أهلي', 'مصر', 'cib', 'بنكي', 'مصرف', 'bank', 'account'],
  ),
  const AppIconItem(
    icon: Icons.credit_card_rounded,
    nameAr: 'بطاقة وكارت',
    nameEn: 'Card / Debit / Credit',
    category: AppIconCategory.finance,
    keywords: ['كارت', 'فيزا', 'ماستركارد', 'ائتمان', 'مشتريات', 'ديبت', 'كريديت', 'card', 'visa', 'mastercard', 'credit', 'debit'],
  ),
  const AppIconItem(
    icon: Icons.payment_rounded,
    nameAr: 'دفع إلكتروني',
    nameEn: 'Payment / POS',
    category: AppIconCategory.finance,
    keywords: ['دفع', 'سداد', 'ماكينة', 'فوري', 'pos', 'pay', 'payment'],
  ),
  const AppIconItem(
    icon: Icons.phone_iphone_rounded,
    nameAr: 'محفظة موبايل',
    nameEn: 'Mobile Wallet',
    category: AppIconCategory.finance,
    keywords: ['موبايل', 'فودافون كاش', 'أورانج كاش', 'اتصالات كاش', 'وي باي', 'إنستاباي', 'instapay', 'vodafone', 'orange', 'etisalat', 'we'],
  ),
  const AppIconItem(
    icon: Icons.diamond_rounded,
    nameAr: 'ذهب ومجوهرات',
    nameEn: 'Gold & Jewelry',
    category: AppIconCategory.finance,
    keywords: ['ذهب', 'سبيكة', 'عيار', 'مجوهرات', 'ملاذ', 'gold', 'diamond', 'bullion'],
  ),
  const AppIconItem(
    icon: Icons.trending_up_rounded,
    nameAr: 'أسهم واستثمار',
    nameEn: 'Stocks & Invest',
    category: AppIconCategory.finance,
    keywords: ['أسهم', 'بورصة', 'تداول', 'ثندر', 'thndr', 'أرباح', 'صندوق', 'crypto', 'stocks', 'invest'],
  ),
  const AppIconItem(
    icon: Icons.currency_exchange_rounded,
    nameAr: 'صرافة وعملات',
    nameEn: 'Currencies',
    category: AppIconCategory.finance,
    keywords: ['عملة', 'صرافة', 'دولار', 'يورو', 'ريال', 'تحويل', 'forex', 'currency', 'dollar', 'exchange'],
  ),
  const AppIconItem(
    icon: Icons.monetization_on_rounded,
    nameAr: 'كوينز وعملات',
    nameEn: 'Coins & Crypto',
    category: AppIconCategory.finance,
    keywords: ['كوين', 'بيتكوين', 'عملات', 'crypto', 'bitcoin', 'coins'],
  ),
  const AppIconItem(
    icon: Icons.home_rounded,
    nameAr: 'سكن وعقار',
    nameEn: 'Home & House',
    category: AppIconCategory.home,
    keywords: ['بيت', 'شقة', 'منزل', 'عقار', 'إيجار', 'سكن', 'home', 'house', 'rent', 'property'],
  ),
  const AppIconItem(
    icon: Icons.apartment_rounded,
    nameAr: 'عمارة وشقق',
    nameEn: 'Building',
    category: AppIconCategory.home,
    keywords: ['شقة', 'عمارة', 'عقار', 'مكتب', 'apartment', 'building'],
  ),
  const AppIconItem(
    icon: Icons.directions_car_rounded,
    nameAr: 'سيارة وبنزين',
    nameEn: 'Car & Fuel',
    category: AppIconCategory.transport,
    keywords: ['سيارة', 'عربية', 'بنزين', 'صيانة', 'أوبر', 'uber', 'car', 'fuel', 'gas'],
  ),
  const AppIconItem(
    icon: Icons.local_gas_station_rounded,
    nameAr: 'محطة بنزين وقود',
    nameEn: 'Gas Station',
    category: AppIconCategory.transport,
    keywords: ['بنزين', 'سولار', 'غاز', 'محطة', 'وقود', 'gas', 'fuel', 'station'],
  ),
  const AppIconItem(
    icon: Icons.two_wheeler_rounded,
    nameAr: 'موتوسيكل وسكوتر',
    nameEn: 'Motorcycle',
    category: AppIconCategory.transport,
    keywords: ['موتوسيكل', 'سكوتر', 'عجلة', 'دراجة', 'bike', 'motorcycle', 'scooter'],
  ),
  const AppIconItem(
    icon: Icons.flight_takeoff_rounded,
    nameAr: 'سفر ومصيف',
    nameEn: 'Travel & Trips',
    category: AppIconCategory.transport,
    keywords: ['سفر', 'طيران', 'رحلة', 'مصيف', 'تذاكر', 'سياحة', 'travel', 'flight', 'vacation'],
  ),
  const AppIconItem(
    icon: Icons.shopping_bag_rounded,
    nameAr: 'تسوق وشوبينج',
    nameEn: 'Shopping',
    category: AppIconCategory.shopping,
    keywords: ['تسوق', 'شراء', 'شوبينج', 'ملابس', 'كارفور', 'shop', 'shopping', 'store'],
  ),
  const AppIconItem(
    icon: Icons.shopping_cart_rounded,
    nameAr: 'سوبرماركت وطلبات',
    nameEn: 'Groceries',
    category: AppIconCategory.transport,
    keywords: ['سوبرماركت', 'طلبات', 'ماركت', 'بقالة', 'تموين', 'خضار', 'فاكهة', 'groceries', 'market', 'cart'],
  ),
  const AppIconItem(
    icon: Icons.restaurant_rounded,
    nameAr: 'مطاعم وطعام',
    nameEn: 'Food & Dining',
    category: AppIconCategory.food,
    keywords: ['مطعم', 'أكل', 'طعام', 'غداء', 'عشاء', 'وجبات', 'food', 'restaurant', 'dining'],
  ),
  const AppIconItem(
    icon: Icons.local_cafe_rounded,
    nameAr: 'كافيه وقهوة',
    nameEn: 'Cafe & Coffee',
    category: AppIconCategory.food,
    keywords: ['كافيه', 'قهوة', 'شاي', 'مشروبات', 'ستارباكس', 'coffee', 'cafe', 'tea'],
  ),
  const AppIconItem(
    icon: Icons.fitness_center_rounded,
    nameAr: 'جيم ورياضة',
    nameEn: 'Gym & Sports',
    category: AppIconCategory.health,
    keywords: ['جيم', 'رياضة', 'تمرين', 'اشتراك', 'فتنس', 'نادي', 'gym', 'fitness', 'workout'],
  ),
  const AppIconItem(
    icon: Icons.medical_services_rounded,
    nameAr: 'صحة وصيدلية',
    nameEn: 'Health & Pharmacy',
    category: AppIconCategory.health,
    keywords: ['صيدلية', 'دواء', 'دكتور', 'عيادة', 'مستشفى', 'علاج', 'health', 'medical', 'doctor', 'pharmacy'],
  ),
  const AppIconItem(
    icon: Icons.local_hospital_rounded,
    nameAr: 'مستشفى وطوارئ',
    nameEn: 'Hospital',
    category: AppIconCategory.health,
    keywords: ['مستشفى', 'طوارئ', 'إسعاف', 'عيادة', 'طبيب', 'hospital', 'clinic'],
  ),
  const AppIconItem(
    icon: Icons.school_rounded,
    nameAr: 'تعليم ودراسة',
    nameEn: 'Education',
    category: AppIconCategory.education,
    keywords: ['تعليم', 'مدرسة', 'جامعة', 'كورس', 'كتب', 'دراسة', 'school', 'university', 'study'],
  ),
  const AppIconItem(
    icon: Icons.work_rounded,
    nameAr: 'عمل وراتب',
    nameEn: 'Work & Salary',
    category: AppIconCategory.education,
    keywords: ['شغل', 'عمل', 'راتب', 'مرتب', 'وظيفة', 'salary', 'job', 'work'],
  ),
  const AppIconItem(
    icon: Icons.card_giftcard_rounded,
    nameAr: 'هدايا ومناسبات',
    nameEn: 'Gifts',
    category: AppIconCategory.transport,
    keywords: ['هدية', 'مناسبة', 'عيد', 'عيدية', 'gift', 'present'],
  ),
  const AppIconItem(
    icon: Icons.celebration_rounded,
    nameAr: 'احتفال وسهرات',
    nameEn: 'Celebration',
    category: AppIconCategory.entertainment,
    keywords: ['احتفال', 'حفلة', 'خروجة', 'سهرة', 'ترفيه', 'party', 'celebration'],
  ),
  const AppIconItem(
    icon: Icons.sports_esports_rounded,
    nameAr: 'ألعاب وجيمنج',
    nameEn: 'Gaming',
    category: AppIconCategory.food,
    keywords: ['ألعاب', 'بلايستيشن', 'جيمنج', 'steam', 'games', 'gaming'],
  ),
  const AppIconItem(
    icon: Icons.movie_rounded,
    nameAr: 'سينما وترفيه',
    nameEn: 'Entertainment',
    category: AppIconCategory.entertainment,
    keywords: ['سينما', 'أفلام', 'نتفلكس', 'ترفيه', 'movie', 'cinema', 'netflix'],
  ),
  const AppIconItem(
    icon: Icons.subscriptions_rounded,
    nameAr: 'اشتراكات وباقات',
    nameEn: 'Subscriptions',
    category: AppIconCategory.entertainment,
    keywords: ['اشتراك', 'باقة', 'خدمة', 'نتفلكس', 'سبوتيفاي', 'subscriptions', 'streaming'],
  ),
  const AppIconItem(
    icon: Icons.pets_rounded,
    nameAr: 'حيوانات أليفة',
    nameEn: 'Pets',
    category: AppIconCategory.family,
    keywords: ['قطة', 'كلب', 'حيوان', 'بيطري', 'أليف', 'pets', 'dog', 'cat'],
  ),
  const AppIconItem(
    icon: Icons.child_care_rounded,
    nameAr: 'أطفال ورعاية',
    nameEn: 'Child Care',
    category: AppIconCategory.transport,
    keywords: ['أطفال', 'بيبي', 'حضانة', 'لعب', 'baby', 'child', 'kids'],
  ),
  const AppIconItem(
    icon: Icons.lightbulb_rounded,
    nameAr: 'مرافق وفواتير',
    nameEn: 'Utilities',
    category: AppIconCategory.home,
    keywords: ['كهرباء', 'مياه', 'غاز', 'فواتير', 'خدمات', 'utilities', 'bills', 'electricity'],
  ),
  const AppIconItem(
    icon: Icons.wifi_rounded,
    nameAr: 'إنترنت واشتراكات',
    nameEn: 'Internet',
    category: AppIconCategory.home,
    keywords: ['إنترنت', 'واي فاي', 'اشتراك', 'نت', 'راوتر', 'internet', 'wifi'],
  ),
  const AppIconItem(
    icon: Icons.devices_rounded,
    nameAr: 'أجهزة وإلكترونيات',
    nameEn: 'Electronics',
    category: AppIconCategory.education,
    keywords: ['أجهزة', 'لابتوب', 'كمبيوتر', 'إلكترونيات', 'tech', 'laptop', 'devices'],
  ),
  const AppIconItem(
    icon: Icons.receipt_long_rounded,
    nameAr: 'إيصالات وفواتير',
    nameEn: 'Receipts',
    category: AppIconCategory.finance,
    keywords: ['فاتورة', 'إيصال', 'دفع', 'قسط', 'receipt', 'bill'],
  ),
  const AppIconItem(
    icon: Icons.shield_rounded,
    nameAr: 'تأمين وطوارئ',
    nameEn: 'Insurance & Safety',
    category: AppIconCategory.home,
    keywords: ['تأمين', 'طوارئ', 'أمان', 'حماية', 'صندوق', 'insurance', 'safety', 'emergency'],
  ),
  const AppIconItem(
    icon: Icons.lock_rounded,
    nameAr: 'خزنة وسري',
    nameEn: 'Vault',
    category: AppIconCategory.finance,
    keywords: ['خزنة', 'سري', 'أمان', 'قفل', 'vault', 'safe', 'lock'],
  ),
  const AppIconItem(
    icon: Icons.storefront_rounded,
    nameAr: 'محل ومشروع',
    nameEn: 'Store & Shop',
    category: AppIconCategory.transport,
    keywords: ['محل', 'مشروع', 'متجر', 'بيزنس', 'تجارة', 'store', 'business'],
  ),
  const AppIconItem(
    icon: Icons.business_center_rounded,
    nameAr: 'بيزنس وشركات',
    nameEn: 'Business',
    category: AppIconCategory.transport,
    keywords: ['بيزنس', 'شركة', 'مؤسسة', 'عمل', 'business', 'company'],
  ),
  const AppIconItem(
    icon: Icons.qr_code_rounded,
    nameAr: 'كود QR وإنستاباي',
    nameEn: 'QR Code',
    category: AppIconCategory.finance,
    keywords: ['qr', 'كود', 'مسح', 'سريع', 'إنستاباي', 'scan'],
  ),
  const AppIconItem(
    icon: Icons.contactless_rounded,
    nameAr: 'دفع لا تلامسي',
    nameEn: 'Contactless Pay',
    category: AppIconCategory.finance,
    keywords: ['تاتش', 'دفع', 'سريع', 'nfc', 'contactless'],
  ),
  const AppIconItem(
    icon: Icons.send_to_mobile_rounded,
    nameAr: 'تحويل موبايل',
    nameEn: 'Mobile Transfer',
    category: AppIconCategory.finance,
    keywords: ['تحويل', 'رصيد', 'إنستاباي', 'موبايل', 'transfer'],
  ),
  const AppIconItem(
    icon: Icons.handshake_rounded,
    nameAr: 'شراكة وسلف',
    nameEn: 'Partnership',
    category: AppIconCategory.transport,
    keywords: ['شراكة', 'سلف', 'دين', 'قرض', 'اتفاق', 'loan', 'partner'],
  ),
  const AppIconItem(
    icon: Icons.local_shipping_rounded,
    nameAr: 'شحن ودليفري',
    nameEn: 'Delivery',
    category: AppIconCategory.transport,
    keywords: ['شحن', 'توصيل', 'دليفري', 'نقل', 'delivery', 'shipping'],
  ),
  const AppIconItem(
    icon: Icons.spa_rounded,
    nameAr: 'عناية وراحة',
    nameEn: 'Personal Care',
    category: AppIconCategory.transport,
    keywords: ['عناية', 'جمال', 'حلاقة', 'سبا', 'راحة', 'care', 'spa'],
  ),
  const AppIconItem(
    icon: Icons.construction_rounded,
    nameAr: 'صيانة وتشطيبات',
    nameEn: 'Maintenance',
    category: AppIconCategory.home,
    keywords: ['صيانة', 'تصليح', 'تشطيب', 'أدوات', 'repair', 'tools'],
  ),
  const AppIconItem(
    icon: Icons.volunteer_activism_rounded,
    nameAr: 'صدقة وتبرع',
    nameEn: 'Charity & Donation',
    category: AppIconCategory.family,
    keywords: ['صدقة', 'تبرع', 'زكاة', 'خير', 'مساعدة', 'charity', 'zakat', 'donation'],
  ),
  const AppIconItem(
    icon: Icons.family_restroom_rounded,
    nameAr: 'مصاريف عائلية',
    nameEn: 'Family Expenses',
    category: AppIconCategory.home,
    keywords: ['عائلة', 'أسرة', 'بيت', 'مصروف', 'family', 'home'],
  ),
  const AppIconItem(
    icon: Icons.stars_rounded,
    nameAr: 'أهداف ومميز',
    nameEn: 'Special & Goals',
    category: AppIconCategory.other,
    keywords: ['هدف', 'مميز', 'حلم', 'نجاح', 'goal', 'star'],
  ),
  const AppIconItem(
    icon: Icons.fastfood_rounded,
    nameAr: 'وجبات سريعة وبرجر',
    nameEn: 'Fast Food',
    category: AppIconCategory.food,
    keywords: ['برجر', 'وجبات', 'سريعة', 'ماك', 'كنتاكي', 'بيتزا', 'تيك أواي', 'burger', 'fastfood', 'pizza'],
  ),
  const AppIconItem(
    icon: Icons.bakery_dining_rounded,
    nameAr: 'مخبوزات وحلويات',
    nameEn: 'Bakery & Pastry',
    category: AppIconCategory.food,
    keywords: ['مخبز', 'عيش', 'حلويات', 'فطائر', 'كرواسون', 'تورته', 'كيك', 'bakery', 'pastry', 'bread'],
  ),
  const AppIconItem(
    icon: Icons.lunch_dining_rounded,
    nameAr: 'سندوتشات وفطار',
    nameEn: 'Sandwiches & Breakfast',
    category: AppIconCategory.food,
    keywords: ['فطار', 'سندوتش', 'شاورما', 'فول', 'طعمية', 'sandwich', 'breakfast'],
  ),
  const AppIconItem(
    icon: Icons.local_bar_rounded,
    nameAr: 'عصائر ومشروبات',
    nameEn: 'Drinks & Juices',
    category: AppIconCategory.food,
    keywords: ['عصير', 'سموزي', 'فرش', 'مشروبات', 'كوكتيل', 'drinks', 'juice', 'smoothie'],
  ),
  const AppIconItem(
    icon: Icons.icecream_rounded,
    nameAr: 'آيس كريم ومثلجات',
    nameEn: 'Ice Cream',
    category: AppIconCategory.food,
    keywords: ['آيس كريم', 'جيلاتي', 'حلويات', 'مثلجات', 'icecream', 'gelato', 'dessert'],
  ),
  const AppIconItem(
    icon: Icons.local_taxi_rounded,
    nameAr: 'تاكسي وأوبر',
    nameEn: 'Taxi & Rideshare',
    category: AppIconCategory.finance,
    keywords: ['تاكسي', 'أوبر', 'كريم', 'ديدي', 'مشوار', 'توصيل', 'taxi', 'uber', 'careem', 'ride'],
  ),
  const AppIconItem(
    icon: Icons.directions_bus_rounded,
    nameAr: 'أتوبيس وباص',
    nameEn: 'Bus & Transit',
    category: AppIconCategory.transport,
    keywords: ['أتوبيس', 'باص', 'مواصلات', 'سوبرجيت', 'ميني باص', 'bus', 'transit'],
  ),
  const AppIconItem(
    icon: Icons.directions_subway_rounded,
    nameAr: 'مترو وقطار',
    nameEn: 'Metro & Train',
    category: AppIconCategory.transport,
    keywords: ['مترو', 'قطار', 'سكة حديد', 'محطة', 'metro', 'train', 'subway'],
  ),
  const AppIconItem(
    icon: Icons.pedal_bike_rounded,
    nameAr: 'دراجة وعجلة',
    nameEn: 'Bicycle',
    category: AppIconCategory.transport,
    keywords: ['عجلة', 'دراجة', 'سيكل', 'رياضة', 'bike', 'bicycle', 'cycling'],
  ),
  const AppIconItem(
    icon: Icons.car_repair_rounded,
    nameAr: 'ميكانيكي وصيانة سيارات',
    nameEn: 'Car Repair',
    category: AppIconCategory.transport,
    keywords: ['ميكانيكي', 'تصليح', 'صيانة', 'كاوتش', 'زيت', 'ورشه', 'car', 'repair', 'mechanic'],
  ),
  const AppIconItem(
    icon: Icons.checkroom_rounded,
    nameAr: 'ملابس وأزياء',
    nameEn: 'Clothing & Fashion',
    category: AppIconCategory.shopping,
    keywords: ['ملابس', 'لبس', 'قميص', 'بنطلون', 'فستان', 'زارا', 'clothes', 'clothing', 'fashion', 'zara'],
  ),
  const AppIconItem(
    icon: Icons.content_cut_rounded,
    nameAr: 'صالون وحلاقة',
    nameEn: 'Barber & Salon',
    category: AppIconCategory.food,
    keywords: ['حلاقة', 'صالون', 'كوافير', 'شعر', 'دقن', 'barber', 'haircut', 'salon'],
  ),
  const AppIconItem(
    icon: Icons.watch_rounded,
    nameAr: 'ساعات وإكسسوارات',
    nameEn: 'Watches & Accessories',
    category: AppIconCategory.shopping,
    keywords: ['ساعة', 'ساعات', 'إكسسوارات', 'نظارات', 'watch', 'accessories'],
  ),
  const AppIconItem(
    icon: Icons.face_retouching_natural_rounded,
    nameAr: 'تجميل وعناية بالبشرة',
    nameEn: 'Beauty & Skincare',
    category: AppIconCategory.transport,
    keywords: ['تجميل', 'ميك اب', 'بشرة', 'مستحضرات', 'عناية', 'beauty', 'makeup', 'skincare'],
  ),
  const AppIconItem(
    icon: Icons.dry_cleaning_rounded,
    nameAr: 'مكواة ومغسلة',
    nameEn: 'Laundry & Dry Clean',
    category: AppIconCategory.home,
    keywords: ['غسيل', 'مغسلة', 'مكواة', 'دراي كلين', 'laundry', 'dry clean', 'cleaning'],
  ),
  const AppIconItem(
    icon: Icons.chair_rounded,
    nameAr: 'أثاث وديكور',
    nameEn: 'Furniture & Decor',
    category: AppIconCategory.home,
    keywords: ['أثاث', 'عفش', 'ديكور', 'كنبة', 'ايكيا', 'ikea', 'furniture', 'decor'],
  ),
  const AppIconItem(
    icon: Icons.cleaning_services_rounded,
    nameAr: 'نظافة وخدمات منزل',
    nameEn: 'Cleaning Services',
    category: AppIconCategory.home,
    keywords: ['نظافة', 'تنظيف', 'شغالة', 'مساعدين', 'منزل', 'cleaning', 'housekeeping'],
  ),
  const AppIconItem(
    icon: Icons.water_drop_rounded,
    nameAr: 'فاتورة مياه',
    nameEn: 'Water Utility',
    category: AppIconCategory.home,
    keywords: ['مياه', 'فاتورة مياه', 'شرب', 'نور', 'water', 'utility', 'bills'],
  ),
  const AppIconItem(
    icon: Icons.yard_rounded,
    nameAr: 'حديقة ونباتات',
    nameEn: 'Garden & Plants',
    category: AppIconCategory.home,
    keywords: ['حديقة', 'نباتات', 'زرع', 'ورد', 'بستان', 'garden', 'plants', 'flowers'],
  ),
  const AppIconItem(
    icon: Icons.plumbing_rounded,
    nameAr: 'سباكة وتصليحات',
    nameEn: 'Plumbing',
    category: AppIconCategory.home,
    keywords: ['سباكة', 'مواسير', 'حنفية', 'تسريب', 'تصليح', 'plumber', 'plumbing'],
  ),
  const AppIconItem(
    icon: Icons.sports_soccer_rounded,
    nameAr: 'كرة قدم وملاعب',
    nameEn: 'Football / Soccer',
    category: AppIconCategory.health,
    keywords: ['كورة', 'كرة قدم', 'ملعب', 'ماتش', 'حجز', 'soccer', 'football'],
  ),
  const AppIconItem(
    icon: Icons.sports_tennis_rounded,
    nameAr: 'بادل وتنس',
    nameEn: 'Tennis & Padel',
    category: AppIconCategory.health,
    keywords: ['بادل', 'تنس', 'راكيت', 'مضرب', 'حجز بادل', 'padel', 'tennis'],
  ),
  const AppIconItem(
    icon: Icons.pool_rounded,
    nameAr: 'سباحة وأكوا',
    nameEn: 'Swimming & Pool',
    category: AppIconCategory.health,
    keywords: ['سباحة', 'بسين', 'حمام سباحة', 'بحر', 'swimming', 'pool'],
  ),
  const AppIconItem(
    icon: Icons.self_improvement_rounded,
    nameAr: 'يوجا وتأمل',
    nameEn: 'Yoga & Meditation',
    category: AppIconCategory.health,
    keywords: ['يوجا', 'تأمل', 'هدوء', 'استرخاء', 'نفسية', 'yoga', 'meditation'],
  ),
  const AppIconItem(
    icon: Icons.computer_rounded,
    nameAr: 'كمبيوتر ولابتوب',
    nameEn: 'PC & Computer',
    category: AppIconCategory.education,
    keywords: ['كمبيوتر', 'بي سي', 'لابتوب', 'شاشة', 'ماوس', 'pc', 'computer', 'macbook'],
  ),
  const AppIconItem(
    icon: Icons.headphones_rounded,
    nameAr: 'موسيقى وسماعات',
    nameEn: 'Music & Audio',
    category: AppIconCategory.entertainment,
    keywords: ['موسيقى', 'أغاني', 'سماعات', 'سبوتيفاي', 'ساوند كلاود', 'music', 'headphones', 'spotify'],
  ),
  const AppIconItem(
    icon: Icons.podcasts_rounded,
    nameAr: 'بودكاست ومحتوى',
    nameEn: 'Podcasts',
    category: AppIconCategory.entertainment,
    keywords: ['بودكاست', 'حوار', 'صوتيات', 'تسجيل', 'podcast', 'audio'],
  ),
  const AppIconItem(
    icon: Icons.code_rounded,
    nameAr: 'برمجة واستضافة',
    nameEn: 'Coding & Dev',
    category: AppIconCategory.education,
    keywords: ['برمجة', 'كود', 'استضافة', 'سيرفر', 'دومين', 'موقع', 'coding', 'developer', 'hosting'],
  ),
  const AppIconItem(
    icon: Icons.cloud_rounded,
    nameAr: 'تخزين سحابي',
    nameEn: 'Cloud Storage',
    category: AppIconCategory.education,
    keywords: ['كلاود', 'تخزين', 'جوجل درايف', 'آي كلاود', 'سحابة', 'cloud', 'storage', 'drive', 'icloud'],
  ),
  const AppIconItem(
    icon: Icons.menu_book_rounded,
    nameAr: 'كتب وقراءة',
    nameEn: 'Books & Reading',
    category: AppIconCategory.education,
    keywords: ['كتاب', 'كتب', 'مكتبة', 'رواية', 'قراءة', 'معرض الكتاب', 'book', 'reading', 'library'],
  ),
  const AppIconItem(
    icon: Icons.psychology_rounded,
    nameAr: 'تطوير ذات وكورسات',
    nameEn: 'Self Development',
    category: AppIconCategory.education,
    keywords: ['مهارات', 'تطوير', 'تدريب', 'كورس', 'ذكاء', 'psychology', 'skills', 'course'],
  ),
  const AppIconItem(
    icon: Icons.history_edu_rounded,
    nameAr: 'شهادات ودبلومات',
    nameEn: 'Certificates & Diploma',
    category: AppIconCategory.education,
    keywords: ['شهادة', 'دبلومة', 'ماجستير', 'جامعة', 'تخرج', 'diploma', 'certificate'],
  ),
  const AppIconItem(
    icon: Icons.cake_rounded,
    nameAr: 'أعياد ميلاد وتورتة',
    nameEn: 'Birthday & Cake',
    category: AppIconCategory.family,
    keywords: ['عيد ميلاد', 'تورتة', 'كيك', 'شمعة', 'birthday', 'cake', 'celebration'],
  ),
  const AppIconItem(
    icon: Icons.attractions_rounded,
    nameAr: 'ملاهي وألعاب',
    nameEn: 'Theme Parks & Rides',
    category: AppIconCategory.entertainment,
    keywords: ['ملاهي', 'ألعاب', 'تذاكر', 'خروجة', 'أطفال', 'amusement', 'rides', 'themepark'],
  ),
  const AppIconItem(
    icon: Icons.stadium_rounded,
    nameAr: 'ماتشات وحفلات',
    nameEn: 'Stadium & Events',
    category: AppIconCategory.entertainment,
    keywords: ['استاد', 'ماتش', 'حفلة', 'تذكرة', 'تذاكر', 'stadium', 'match', 'concert'],
  ),
  const AppIconItem(
    icon: Icons.theater_comedy_rounded,
    nameAr: 'مسرح وكوميدي',
    nameEn: 'Theater & Shows',
    category: AppIconCategory.entertainment,
    keywords: ['مسرح', 'ستاند اب', 'عروض', 'كوميديا', 'فن', 'theater', 'show', 'comedy'],
  ),
  const AppIconItem(
    icon: Icons.park_rounded,
    nameAr: 'منتزهات وحدائق',
    nameEn: 'Parks & Nature',
    category: AppIconCategory.entertainment,
    keywords: ['حديقة', 'منتزه', 'طبيعة', 'فسحة', 'شمس', 'park', 'nature'],
  ),
  const AppIconItem(
    icon: Icons.mosque_rounded,
    nameAr: 'مسجد وعمرة وزكاة',
    nameEn: 'Mosque & Worship',
    category: AppIconCategory.transport,
    keywords: ['مسجد', 'جامع', 'عمرة', 'حج', 'زكاة', 'صلاة', 'قرآن', 'mosque', 'umrah', 'hajj', 'islamic'],
  ),
  const AppIconItem(
    icon: Icons.pie_chart_rounded,
    nameAr: 'ميزانية وتحليلات',
    nameEn: 'Budget & Analytics',
    category: AppIconCategory.entertainment,
    keywords: ['ميزانية', 'تحليل', 'نسبة', 'تقارير', 'إحصائيات', 'budget', 'analytics', 'chart'],
  ),
  const AppIconItem(
    icon: Icons.price_check_rounded,
    nameAr: 'عروض وتخفيضات',
    nameEn: 'Discounts & Deals',
    category: AppIconCategory.finance,
    keywords: ['خصم', 'عروض', 'تخفيض', 'سيل', 'اوفر', 'discount', 'sale', 'deals'],
  ),
  const AppIconItem(
    icon: Icons.account_tree_rounded,
    nameAr: 'مشاريع وتقسيمات',
    nameEn: 'Projects & Workflows',
    category: AppIconCategory.education,
    keywords: ['مشروع', 'تخطيط', 'إدارة', 'شغل', 'workflow', 'project'],
  ),
  const AppIconItem(
    icon: Icons.gavel_rounded,
    nameAr: 'قانوني ومحاماة',
    nameEn: 'Legal & Gov',
    category: AppIconCategory.finance,
    keywords: ['قانون', 'محكمة', 'محامي', 'أوراق حكومية', 'توثيق', 'legal', 'lawyer', 'gov'],
  ),
  const AppIconItem(
    icon: Icons.local_pizza_rounded,
    nameAr: 'بيتزا ومخبوزات إيطالية',
    nameEn: 'Pizza & Italian',
    category: AppIconCategory.food,
    keywords: ['بيتزا', 'مخبوزات', 'ايطالي', 'pizza', 'italian', 'slice'],
  ),
  const AppIconItem(
    icon: Icons.coffee_rounded,
    nameAr: 'بن ومطاحن قهوة',
    nameEn: 'Coffee & Espresso',
    category: AppIconCategory.food,
    keywords: ['بن', 'مطحنة', 'اسبريسو', 'قهوة', 'مشروب', 'coffee', 'beans', 'espresso'],
  ),
  const AppIconItem(
    icon: Icons.set_meal_rounded,
    nameAr: 'أسماك ومأكولات بحرية',
    nameEn: 'Seafood & Fish',
    category: AppIconCategory.food,
    keywords: ['سمك', 'سي فود', 'جمبري', 'مأكولات بحرية', 'seafood', 'fish', 'shrimp'],
  ),
  const AppIconItem(
    icon: Icons.takeout_dining_rounded,
    nameAr: 'وجبات تيك أواي وتوصيل',
    nameEn: 'Takeout & Delivery',
    category: AppIconCategory.food,
    keywords: ['تيك اواي', 'توصيل', 'طلبات', 'دليفري', 'سفري', 'takeout', 'delivery', 'talabat'],
  ),
  const AppIconItem(
    icon: Icons.kebab_dining_rounded,
    nameAr: 'مشويات وكباب وكفتة',
    nameEn: 'Grills & BBQ',
    category: AppIconCategory.food,
    keywords: ['مشويات', 'كباب', 'كفتة', 'لحوم', 'مشوي', 'باربيكيو', 'grills', 'bbq', 'kebab'],
  ),
  const AppIconItem(
    icon: Icons.soup_kitchen_rounded,
    nameAr: 'شوربة ومأكولات دافئة',
    nameEn: 'Soup & Bowls',
    category: AppIconCategory.food,
    keywords: ['شوربة', 'حساء', 'سخن', 'soup', 'bowl', 'hot'],
  ),
  const AppIconItem(
    icon: Icons.egg_rounded,
    nameAr: 'بيض وألبان وبقالة فطار',
    nameEn: 'Eggs & Dairy',
    category: AppIconCategory.food,
    keywords: ['بيض', 'لبن', 'جبنة', 'فطار', 'dairy', 'eggs', 'breakfast'],
  ),
  const AppIconItem(
    icon: Icons.egg_alt_rounded,
    nameAr: 'فطار وأطباق صباحية',
    nameEn: 'Breakfast Dishes',
    category: AppIconCategory.food,
    keywords: ['فطار', 'صباح', 'أومليت', 'وجبة', 'breakfast', 'omelet', 'morning'],
  ),
  const AppIconItem(
    icon: Icons.emoji_food_beverage_rounded,
    nameAr: 'شاي وأعشاب ساخنة',
    nameEn: 'Tea & Herbs',
    category: AppIconCategory.food,
    keywords: ['شاي', 'أعشاب', 'سخن', 'نعناع', 'كركديه', 'tea', 'herbal', 'hot drink'],
  ),
  const AppIconItem(
    icon: Icons.rice_bowl_rounded,
    nameAr: 'أرز وأطباق شرقية',
    nameEn: 'Rice & Asian Cuisine',
    category: AppIconCategory.food,
    keywords: ['أرز', 'كبسة', 'شرقي', 'اسيوي', 'نودلز', 'rice', 'asian', 'bowl'],
  ),
  const AppIconItem(
    icon: Icons.medication_rounded,
    nameAr: 'أدوية وعقاقير',
    nameEn: 'Medication & Pills',
    category: AppIconCategory.health,
    keywords: ['دواء', 'علاج', 'روشتة', 'صيدلية', 'حبوب', 'برشام', 'meds', 'pills', 'pharmacy', 'prescription'],
  ),
  const AppIconItem(
    icon: Icons.healing_rounded,
    nameAr: 'إسعافات أولية وضمادات',
    nameEn: 'First Aid & Bandages',
    category: AppIconCategory.health,
    keywords: ['إسعافات', 'جروح', 'لصقة', 'شاش', 'علاج', 'first aid', 'bandage', 'healing'],
  ),
  const AppIconItem(
    icon: Icons.vaccines_rounded,
    nameAr: 'تطعيمات وأمصال وحقن',
    nameEn: 'Vaccines & Injections',
    category: AppIconCategory.health,
    keywords: ['تطعيم', 'مصل', 'حقنة', 'تحليل', 'لقاح', 'vaccine', 'injection', 'shot'],
  ),
  const AppIconItem(
    icon: Icons.masks_rounded,
    nameAr: 'كمامات ووقاية صحية',
    nameEn: 'Face Masks & Protection',
    category: AppIconCategory.health,
    keywords: ['كمامة', 'وقاية', 'عدوى', 'أمان', 'mask', 'protection', 'safety'],
  ),
  const AppIconItem(
    icon: Icons.monitor_heart_rounded,
    nameAr: 'فحوصات قلب ونبضات',
    nameEn: 'Heart & Cardiology',
    category: AppIconCategory.transport,
    keywords: ['قلب', 'نبض', 'فحص', 'تخطيط', 'دكتور', 'heart', 'cardiology', 'pulse', 'checkup'],
  ),
  const AppIconItem(
    icon: Icons.health_and_safety_rounded,
    nameAr: 'تأمين صحي وسلامة',
    nameEn: 'Health Insurance & Safety',
    category: AppIconCategory.health,
    keywords: ['تأمين صحي', 'سلامة', 'طوارئ', 'تأمين', 'health insurance', 'safety', 'medical'],
  ),
  const AppIconItem(
    icon: Icons.visibility_rounded,
    nameAr: 'عيون ونظارات وبصريات',
    nameEn: 'Eye Care & Optical',
    category: AppIconCategory.transport,
    keywords: ['عيون', 'نظارة', 'كشف عيون', 'بصريات', 'عدسات', 'eye', 'optical', 'glasses', 'vision'],
  ),
  const AppIconItem(
    icon: Icons.bloodtype_rounded,
    nameAr: 'تحاليل دم ومختبرات',
    nameEn: 'Blood Tests & Labs',
    category: AppIconCategory.health,
    keywords: ['تحليل', 'دم', 'مختبر', 'معمل', 'فحوصات', 'blood', 'lab', 'test', 'clinic'],
  ),
  const AppIconItem(
    icon: Icons.accessible_rounded,
    nameAr: 'رعاية خاصة واحتياجات',
    nameEn: 'Accessibility & Care',
    category: AppIconCategory.transport,
    keywords: ['احتياجات خاصة', 'علاج طبيعي', 'رعاية', 'accessible', 'care', 'therapy'],
  ),
  const AppIconItem(
    icon: Icons.biotech_rounded,
    nameAr: 'أبحاث طبية ومختبرية',
    nameEn: 'Biotech & Diagnostics',
    category: AppIconCategory.education,
    keywords: ['تحاليل متقدمة', 'أشعة', 'فحوصات', 'معامل', 'biotech', 'lab', 'diagnostics'],
  ),
  const AppIconItem(
    icon: Icons.ev_station_rounded,
    nameAr: 'شحن سيارات كهربائية',
    nameEn: 'EV Charging',
    category: AppIconCategory.transport,
    keywords: ['شحن سيارة', 'كهرباء', 'محطة شحن', 'تسلا', 'ev', 'charging', 'tesla', 'electric'],
  ),
  const AppIconItem(
    icon: Icons.local_car_wash_rounded,
    nameAr: 'غسيل وتلميع سيارات',
    nameEn: 'Car Wash',
    category: AppIconCategory.transport,
    keywords: ['غسيل سيارات', 'كار ووش', 'تلميع', 'نظافة عربية', 'car wash', 'cleaning'],
  ),
  const AppIconItem(
    icon: Icons.car_rental_rounded,
    nameAr: 'تأجير سيارات وليموزين',
    nameEn: 'Car Rental',
    category: AppIconCategory.transport,
    keywords: ['تأجير', 'إيجار سيارات', 'ليموزين', 'rent a car', 'rental'],
  ),
  const AppIconItem(
    icon: Icons.electric_car_rounded,
    nameAr: 'سيارة كهربائية',
    nameEn: 'Electric Vehicle',
    category: AppIconCategory.transport,
    keywords: ['سيارة كهرباء', 'عربية كهربائية', 'electric car', 'ev'],
  ),
  const AppIconItem(
    icon: Icons.electric_scooter_rounded,
    nameAr: 'سكوتر كهربائي',
    nameEn: 'Electric Scooter',
    category: AppIconCategory.transport,
    keywords: ['سكوتر', 'سكوتر كهرباء', 'scooter', 'e-scooter'],
  ),
  const AppIconItem(
    icon: Icons.electric_bike_rounded,
    nameAr: 'دراجة كهربائية',
    nameEn: 'E-Bike',
    category: AppIconCategory.transport,
    keywords: ['دراجة كهربائية', 'عجلة كهرباء', 'ebike', 'electric bike'],
  ),
  const AppIconItem(
    icon: Icons.train_rounded,
    nameAr: 'قطارات وسكك حديدية',
    nameEn: 'Trains & Railway',
    category: AppIconCategory.transport,
    keywords: ['قطار', 'سكة حديد', 'قطار سريع', 'محطة', 'train', 'railway'],
  ),
  const AppIconItem(
    icon: Icons.commute_rounded,
    nameAr: 'مواصلات عامة وتنقل',
    nameEn: 'Public Commute',
    category: AppIconCategory.transport,
    keywords: ['مواصلات', 'تنقل', 'مشاوير', 'باص ومترو', 'commute', 'transit'],
  ),
  const AppIconItem(
    icon: Icons.local_parking_rounded,
    nameAr: 'باركينج ومواقف سيارات',
    nameEn: 'Parking & Garages',
    category: AppIconCategory.transport,
    keywords: ['باركينج', 'جراج', 'ركنة', 'موقف', 'parking', 'garage'],
  ),
  const AppIconItem(
    icon: Icons.connecting_airports_rounded,
    nameAr: 'مطارات وترانزيت',
    nameEn: 'Airports & Transit',
    category: AppIconCategory.transport,
    keywords: ['مطار', 'ترانزيت', 'طيران', 'سفر دولي', 'airport', 'transit', 'flight'],
  ),
  const AppIconItem(
    icon: Icons.flight_land_rounded,
    nameAr: 'وصول ورجوع من السفر',
    nameEn: 'Flight Arrival',
    category: AppIconCategory.transport,
    keywords: ['رجوع', 'وصول', 'مطار', 'تذاكر عودة', 'arrival', 'landing', 'flight'],
  ),
  const AppIconItem(
    icon: Icons.sailing_rounded,
    nameAr: 'قوارب وبحري ويخوت',
    nameEn: 'Boats & Sailing',
    category: AppIconCategory.transport,
    keywords: ['مركب', 'يخت', 'بحر', 'قارب', 'رحلة بحرية', 'boat', 'yacht', 'sailing'],
  ),
  const AppIconItem(
    icon: Icons.directions_boat_rounded,
    nameAr: 'معديات وفيري وسفن',
    nameEn: 'Ferry & Ships',
    category: AppIconCategory.transport,
    keywords: ['عبارة', 'فيري', 'سفينة', 'نقل بحري', 'ferry', 'ship'],
  ),
  const AppIconItem(
    icon: Icons.traffic_rounded,
    nameAr: 'إشارات ومخالفات مرورية',
    nameEn: 'Traffic & Fines',
    category: AppIconCategory.finance,
    keywords: ['مرور', 'مخالفة', 'إشارة', 'كارته', 'طريق', 'traffic', 'fines', 'toll'],
  ),
  const AppIconItem(
    icon: Icons.alt_route_rounded,
    nameAr: 'طرق ورسوم كارته',
    nameEn: 'Tolls & Highways',
    category: AppIconCategory.finance,
    keywords: ['كارته', 'رسوم طريق', 'طريق سريع', 'بوابات', 'tolls', 'highway', 'tollway'],
  ),
  const AppIconItem(
    icon: Icons.navigation_rounded,
    nameAr: 'خرائط وخرائط طرق',
    nameEn: 'Navigation & GPS',
    category: AppIconCategory.transport,
    keywords: ['جي بي اس', 'ملاحة', 'خريطة', 'مشاوير', 'gps', 'navigation', 'maps'],
  ),
  const AppIconItem(
    icon: Icons.bedroom_parent_rounded,
    nameAr: 'غرفة نوم ومفروشات',
    nameEn: 'Bedroom & Bedding',
    category: AppIconCategory.home,
    keywords: ['غرفة نوم', 'سرير', 'مفروشات', 'ملايات', 'bedroom', 'bedding', 'sleep'],
  ),
  const AppIconItem(
    icon: Icons.bed_rounded,
    nameAr: 'فنادق وحجوزات إقامة',
    nameEn: 'Hotels & Stays',
    category: AppIconCategory.home,
    keywords: ['فندق', 'حجز فندق', 'لوكاندة', 'إقامة', 'hotel', 'stay', 'booking', 'airbnb'],
  ),
  const AppIconItem(
    icon: Icons.bathtub_rounded,
    nameAr: 'حمام ومستلزمات صحية',
    nameEn: 'Bathroom & Sanitary',
    category: AppIconCategory.home,
    keywords: ['حمام', 'بانيو', 'صحي', 'أدوات صحية', 'bathroom', 'tub'],
  ),
  const AppIconItem(
    icon: Icons.shower_rounded,
    nameAr: 'مستلزمات شاور واستحمام',
    nameEn: 'Shower & Bath',
    category: AppIconCategory.home,
    keywords: ['شاور', 'استحمام', 'صابون', 'شامبو', 'shower', 'bath'],
  ),
  const AppIconItem(
    icon: Icons.ac_unit_rounded,
    nameAr: 'تكييفات وتبريد',
    nameEn: 'AC & Cooling',
    category: AppIconCategory.home,
    keywords: ['تكييف', 'تبريد', 'صيانة تكييف', 'فريون', 'ac', 'air condition', 'cooling'],
  ),
  const AppIconItem(
    icon: Icons.fence_rounded,
    nameAr: 'عقارات وسياج وأراضي',
    nameEn: 'Fencing & Land',
    category: AppIconCategory.home,
    keywords: ['أرض', 'سور', 'فيلا', 'عقار', 'حديقة', 'fence', 'property', 'land'],
  ),
  const AppIconItem(
    icon: Icons.roofing_rounded,
    nameAr: 'تشطيبات وأسطح وبناء',
    nameEn: 'Roofing & Finishes',
    category: AppIconCategory.home,
    keywords: ['تشطيب', 'عزل', 'سقف', 'دهانات', 'بناء', 'roofing', 'finishes'],
  ),
  const AppIconItem(
    icon: Icons.iron_rounded,
    nameAr: 'مكواة وعناية بالملابس',
    nameEn: 'Ironing & Laundry Care',
    category: AppIconCategory.transport,
    keywords: ['مكواة', 'كوي', 'عناية باللبس', 'iron', 'ironing', 'laundry'],
  ),
  const AppIconItem(
    icon: Icons.handyman_rounded,
    nameAr: 'صنايعي وأعمال يدوية',
    nameEn: 'Handyman & Repairs',
    category: AppIconCategory.home,
    keywords: ['صنايعي', 'فني', 'تصليح', 'أعطال', 'handyman', 'repair', 'service'],
  ),
  const AppIconItem(
    icon: Icons.tv_rounded,
    nameAr: 'شاشات وتلفزيونات ورسيفر',
    nameEn: 'TV & Home Theater',
    category: AppIconCategory.home,
    keywords: ['شاشة', 'تلفزيون', 'رسيفر', 'هوم ثياتر', 'tv', 'smart tv', 'display'],
  ),
  const AppIconItem(
    icon: Icons.local_laundry_service_rounded,
    nameAr: 'غسالة ومجفف ومسحوق',
    nameEn: 'Washing & Laundry',
    category: AppIconCategory.home,
    keywords: ['غسالة', 'مسحوق', 'إريال', 'مغسلة', 'washing machine', 'detergent', 'laundry'],
  ),
  const AppIconItem(
    icon: Icons.garage_rounded,
    nameAr: 'جراج ومستودع منزلي',
    nameEn: 'Garage & Storage',
    category: AppIconCategory.home,
    keywords: ['جراج', 'مخزن', 'بدروم', 'ركنة خاصة', 'garage', 'storage'],
  ),
  const AppIconItem(
    icon: Icons.laptop_mac_rounded,
    nameAr: 'لابتوب وماك بوك',
    nameEn: 'Laptop & MacBook',
    category: AppIconCategory.education,
    keywords: ['لابتوب', 'ماك بوك', 'أبل', 'laptop', 'macbook', 'apple'],
  ),
  const AppIconItem(
    icon: Icons.tablet_mac_rounded,
    nameAr: 'آيباد وتابلت',
    nameEn: 'iPad & Tablet',
    category: AppIconCategory.education,
    keywords: ['ايباد', 'تابلت', 'لوحي', 'ipad', 'tablet'],
  ),
  const AppIconItem(
    icon: Icons.speaker_rounded,
    nameAr: 'سماعات صب وساوند بار',
    nameEn: 'Speakers & Audio',
    category: AppIconCategory.food,
    keywords: ['سماعة صب', 'ساوند بار', 'بلوتوث', 'مكبر صوت', 'speaker', 'soundbar', 'bluetooth'],
  ),
  const AppIconItem(
    icon: Icons.print_rounded,
    nameAr: 'طابعات وأوراق وأحبار',
    nameEn: 'Printing & Ink',
    category: AppIconCategory.education,
    keywords: ['طابعة', 'طباعة', 'ورق', 'حبر', 'مكتبة', 'print', 'printer', 'ink', 'copy'],
  ),
  const AppIconItem(
    icon: Icons.mouse_rounded,
    nameAr: 'ماوس وملحقات كمبيوتر',
    nameEn: 'Mouse & Accessories',
    category: AppIconCategory.entertainment,
    keywords: ['ماوس', 'فأرة', 'إكسسوار كمبيوتر', 'mouse', 'pc parts'],
  ),
  const AppIconItem(
    icon: Icons.keyboard_rounded,
    nameAr: 'كيبورد وملحقات كتابة',
    nameEn: 'Keyboards',
    category: AppIconCategory.education,
    keywords: ['كيبورد', 'لوحة مفاتيح', 'ألعاب', 'keyboard', 'typing'],
  ),
  const AppIconItem(
    icon: Icons.videocam_rounded,
    nameAr: 'كاميرات مراقبة وتصوير',
    nameEn: 'Security Cams & Video',
    category: AppIconCategory.home,
    keywords: ['كاميرا مراقبة', 'تسجيل', 'أمان', 'فيديو', 'cctv', 'camera', 'security cam'],
  ),
  const AppIconItem(
    icon: Icons.security_rounded,
    nameAr: 'أمن إلكتروني وحماية',
    nameEn: 'Cybersecurity & Antivirus',
    category: AppIconCategory.home,
    keywords: ['أمن معلومات', 'حماية', 'أنتي فيرس', 'vpn', 'security', 'antivirus'],
  ),
  const AppIconItem(
    icon: Icons.sim_card_rounded,
    nameAr: 'شريحة موبايل وباقة مكالمات',
    nameEn: 'SIM Card & Plans',
    category: AppIconCategory.transport,
    keywords: ['شريحة', 'خط موبايل', 'باقة اتصالات', 'sim', 'plan', 'telecom'],
  ),
  const AppIconItem(
    icon: Icons.router_rounded,
    nameAr: 'راوتر ومودم وشبكات',
    nameEn: 'Router & Modems',
    category: AppIconCategory.home,
    keywords: ['راوتر', 'مودم', 'شبكة', 'واي فاي منزلي', 'router', 'modem', 'network'],
  ),
  const AppIconItem(
    icon: Icons.cable_rounded,
    nameAr: 'كابلات ووصلات وشواحن',
    nameEn: 'Cables & Adapters',
    category: AppIconCategory.education,
    keywords: ['كابل', 'شاحن', 'وصلة', 'يو اس بي', 'cable', 'charger', 'adapter'],
  ),
  const AppIconItem(
    icon: Icons.terminal_rounded,
    nameAr: 'سيرفرات ولينكس وبرمجة',
    nameEn: 'Servers & Terminal',
    category: AppIconCategory.education,
    keywords: ['سيرفر', 'لينكس', 'أوامر', 'استضافة مواقع', 'terminal', 'server', 'linux'],
  ),
  const AppIconItem(
    icon: Icons.memory_rounded,
    nameAr: 'رامات ومكونات هاردوير',
    nameEn: 'RAM & Hardware',
    category: AppIconCategory.education,
    keywords: ['رامات', 'هاردوير', 'تجميعة', 'معالج', 'hardware', 'ram', 'cpu'],
  ),
  const AppIconItem(
    icon: Icons.shopping_basket_rounded,
    nameAr: 'سلة تبضع وماركت',
    nameEn: 'Shopping Basket',
    category: AppIconCategory.shopping,
    keywords: ['سلة', 'تبضع', 'طلبات سريعة', 'مستلزمات', 'basket', 'shopping'],
  ),
  const AppIconItem(
    icon: Icons.loyalty_rounded,
    nameAr: 'نقاط ولاء ومكافآت',
    nameEn: 'Loyalty & Rewards',
    category: AppIconCategory.finance,
    keywords: ['نقاط', 'ولاء', 'مكافأة', 'استرداد نقدي', 'كاش باك', 'loyalty', 'rewards', 'cashback'],
  ),
  const AppIconItem(
    icon: Icons.sell_rounded,
    nameAr: 'تاجات وأسعار وتخفيضات',
    nameEn: 'Price Tags & Offers',
    category: AppIconCategory.shopping,
    keywords: ['تاج', 'سعر', 'عرض خاص', 'أوفر', 'price tag', 'offers', 'deal'],
  ),
  const AppIconItem(
    icon: Icons.style_rounded,
    nameAr: 'أزياء وستايل وموضة',
    nameEn: 'Fashion Style',
    category: AppIconCategory.shopping,
    keywords: ['ستايل', 'موضة', 'أناقة', 'شياكة', 'style', 'fashion', 'look'],
  ),
  const AppIconItem(
    icon: Icons.inventory_2_rounded,
    nameAr: 'طرود وشحنات وأمانات',
    nameEn: 'Packages & Parcels',
    category: AppIconCategory.transport,
    keywords: ['طرد', 'شحنة', 'أرامكس', 'بوسطة', 'بريد', 'package', 'parcel', 'shipping', 'box'],
  ),
  const AppIconItem(
    icon: Icons.discount_rounded,
    nameAr: 'كوبونات وخصومات إضافية',
    nameEn: 'Discount & Coupons',
    category: AppIconCategory.shopping,
    keywords: ['كوبون', 'خصم', 'بروموكود', 'توفير', 'coupon', 'discount', 'promo code'],
  ),
  const AppIconItem(
    icon: Icons.sports_basketball_rounded,
    nameAr: 'كرة سلة',
    nameEn: 'Basketball',
    category: AppIconCategory.health,
    keywords: ['كرة سلة', 'باسكت', 'ملعب', 'basketball', 'hoops'],
  ),
  const AppIconItem(
    icon: Icons.sports_volleyball_rounded,
    nameAr: 'كرة طائرة',
    nameEn: 'Volleyball',
    category: AppIconCategory.health,
    keywords: ['كرة طائرة', 'فولي', 'بحر', 'volleyball'],
  ),
  const AppIconItem(
    icon: Icons.sports_baseball_rounded,
    nameAr: 'بيسبول ومضارب',
    nameEn: 'Baseball',
    category: AppIconCategory.health,
    keywords: ['بيسبول', 'مضرب', 'baseball'],
  ),
  const AppIconItem(
    icon: Icons.sports_mma_rounded,
    nameAr: 'ملاكمة وفنون قتالية',
    nameEn: 'Boxing & Martial Arts',
    category: AppIconCategory.health,
    keywords: ['ملاكمة', 'كيك بوكس', 'قتال', 'mma', 'boxing', 'martial arts'],
  ),
  const AppIconItem(
    icon: Icons.sports_golf_rounded,
    nameAr: 'جولف وملاعب خضراء',
    nameEn: 'Golf',
    category: AppIconCategory.health,
    keywords: ['جولف', 'ملاعب جولف', 'golf'],
  ),
  const AppIconItem(
    icon: Icons.directions_run_rounded,
    nameAr: 'جري وتراك وماراثون',
    nameEn: 'Running & Jogging',
    category: AppIconCategory.health,
    keywords: ['جري', 'تراك', 'ماراثون', 'مشي', 'رياضة', 'running', 'jogging', 'track'],
  ),
  const AppIconItem(
    icon: Icons.hiking_rounded,
    nameAr: 'هايكنج وتسلق ورحلات جبلية',
    nameEn: 'Hiking & Trekking',
    category: AppIconCategory.health,
    keywords: ['هايكنج', 'تسلق', 'جبال', 'مشي جبلي', 'hiking', 'trekking'],
  ),
  const AppIconItem(
    icon: Icons.skateboarding_rounded,
    nameAr: 'تزلج وسكيت بورد',
    nameEn: 'Skateboarding',
    category: AppIconCategory.health,
    keywords: ['سكيت', 'تزلج', 'لوح تزلج', 'skate', 'skateboard'],
  ),
  const AppIconItem(
    icon: Icons.kayaking_rounded,
    nameAr: 'كاياك وتجديف ومائي',
    nameEn: 'Kayaking & Rowing',
    category: AppIconCategory.health,
    keywords: ['كاياك', 'تجديف', 'نهر', 'بحر', 'kayak', 'rowing'],
  ),
  const AppIconItem(
    icon: Icons.surfing_rounded,
    nameAr: 'ركوب أمواج وسيرف',
    nameEn: 'Surfing & Waves',
    category: AppIconCategory.health,
    keywords: ['سيرف', 'ركوب أمواج', 'بحر', 'شاطئ', 'surf', 'surfing', 'waves'],
  ),
  const AppIconItem(
    icon: Icons.sports_motorsports_rounded,
    nameAr: 'سباق سيارات وموتورسبورت',
    nameEn: 'Motorsports & Racing',
    category: AppIconCategory.health,
    keywords: ['سباق', 'فورمولا', 'رالي', 'كارتينج', 'racing', 'motorsport', 'karting'],
  ),
  const AppIconItem(
    icon: Icons.science_rounded,
    nameAr: 'علوم ومختبرات وأبحاث',
    nameEn: 'Science & Chemistry',
    category: AppIconCategory.education,
    keywords: ['علوم', 'كيمياء', 'أبحاث', 'مختبر', 'science', 'chemistry', 'lab'],
  ),
  const AppIconItem(
    icon: Icons.calculate_rounded,
    nameAr: 'حسابات وضرائب ودفاتر',
    nameEn: 'Calculator & Accounting',
    category: AppIconCategory.finance,
    keywords: ['حاسبة', 'حسابات', 'محاسب', 'دفاتر', 'calculator', 'accounting', 'math'],
  ),
  const AppIconItem(
    icon: Icons.auto_stories_rounded,
    nameAr: 'مناهج ودورات تعليمية',
    nameEn: 'Learning Curriculum',
    category: AppIconCategory.education,
    keywords: ['منهج', 'دراسة', 'كورسات مكثفة', 'تعليم', 'curriculum', 'learning', 'study'],
  ),
  const AppIconItem(
    icon: Icons.draw_rounded,
    nameAr: 'رسم وتصميم وجرافيك',
    nameEn: 'Drawing & Illustration',
    category: AppIconCategory.entertainment,
    keywords: ['رسم', 'اسكتش', 'لوحات', 'جرافيك', 'drawing', 'art', 'illustration'],
  ),
  const AppIconItem(
    icon: Icons.design_services_rounded,
    nameAr: 'خدمات تصميم وفوتوشوب',
    nameEn: 'Design Services',
    category: AppIconCategory.education,
    keywords: ['تصميم', 'فوتوشوب', 'ديزاينر', 'واجهات', 'ui ux', 'design', 'graphic'],
  ),
  const AppIconItem(
    icon: Icons.architecture_rounded,
    nameAr: 'هندسة ومعمار ومخططات',
    nameEn: 'Architecture & CAD',
    category: AppIconCategory.education,
    keywords: ['معمار', 'هندسة', 'مخطط', 'رسم هندسي', 'architecture', 'cad', 'engineer'],
  ),
  const AppIconItem(
    icon: Icons.brush_rounded,
    nameAr: 'فنون وتلوين وديكورات',
    nameEn: 'Painting & Art',
    category: AppIconCategory.entertainment,
    keywords: ['ألوان', 'تلوين', 'فرشاة', 'لوحة', 'دهانات فنية', 'brush', 'painting', 'art'],
  ),
  const AppIconItem(
    icon: Icons.palette_rounded,
    nameAr: 'بالتة ألوان وفنون تشكيلية',
    nameEn: 'Art Palette',
    category: AppIconCategory.entertainment,
    keywords: ['بالتة', 'ألوان', 'فن', 'فنون تشكيلية', 'palette', 'art', 'colors'],
  ),
  const AppIconItem(
    icon: Icons.badge_rounded,
    nameAr: 'بطاقات هوية وتصاريح عمل',
    nameEn: 'Work Badges & ID',
    category: AppIconCategory.education,
    keywords: ['كارنيه', 'بادج', 'تصريح', 'هوية', 'badge', 'id', 'work pass'],
  ),
  const AppIconItem(
    icon: Icons.co_present_rounded,
    nameAr: 'محاضرات وندوات واجتماعات',
    nameEn: 'Presentations & Meetings',
    category: AppIconCategory.education,
    keywords: ['محاضرة', 'اجتماع', 'بريزنتيشن', 'سيمنار', 'meeting', 'presentation', 'lecture'],
  ),
  const AppIconItem(
    icon: Icons.assignment_rounded,
    nameAr: 'مهام وواجبات وتكليفات',
    nameEn: 'Tasks & Assignments',
    category: AppIconCategory.home,
    keywords: ['واجب', 'مهمة', 'تكليف', 'شيتات', 'assignment', 'tasks', 'homework'],
  ),
  const AppIconItem(
    icon: Icons.piano_rounded,
    nameAr: 'بيانو وآلات موسيقية',
    nameEn: 'Piano & Instruments',
    category: AppIconCategory.entertainment,
    keywords: ['بيانو', 'آلات موسيقية', 'عزف', 'موسيقى', 'piano', 'instrument', 'music'],
  ),
  const AppIconItem(
    icon: Icons.music_note_rounded,
    nameAr: 'نوتة موسيقية وألحان',
    nameEn: 'Music Notes',
    category: AppIconCategory.entertainment,
    keywords: ['أغنية', 'نغمة', 'لحن', 'تسجيل أغاني', 'music note', 'song', 'tune'],
  ),
  const AppIconItem(
    icon: Icons.library_music_rounded,
    nameAr: 'مكتبة موسيقية وبومات',
    nameEn: 'Music Albums',
    category: AppIconCategory.entertainment,
    keywords: ['ألبوم', 'مكتبة أغاني', 'تراك', 'music library', 'album', 'tracks'],
  ),
  const AppIconItem(
    icon: Icons.mic_rounded,
    nameAr: 'مايك وتسجيلات صوتية',
    nameEn: 'Microphone & Vocal',
    category: AppIconCategory.entertainment,
    keywords: ['مايك', 'تسجيل', 'صوت', 'فويس اوفر', 'غناء', 'mic', 'vocal', 'recording'],
  ),
  const AppIconItem(
    icon: Icons.radio_rounded,
    nameAr: 'راديو وبث مباشر',
    nameEn: 'Radio & Broadcast',
    category: AppIconCategory.entertainment,
    keywords: ['راديو', 'بث', 'إذاعة', 'محطة راديو', 'radio', 'broadcast', 'fm'],
  ),
  const AppIconItem(
    icon: Icons.camera_alt_rounded,
    nameAr: 'كاميرات وتصوير فوتوغرافي',
    nameEn: 'Photography',
    category: AppIconCategory.entertainment,
    keywords: ['كاميرا', 'سيشن', 'فوتوسيشن', 'تصوير', 'عدسة', 'camera', 'photo', 'photography'],
  ),
  const AppIconItem(
    icon: Icons.casino_rounded,
    nameAr: 'كازينو وترفيه ألعاب',
    nameEn: 'Casino & Games',
    category: AppIconCategory.entertainment,
    keywords: ['كازينو', 'حظ', 'ترفيه ألعاب', 'casino', 'poker', 'luck'],
  ),
  const AppIconItem(
    icon: Icons.nightlife_rounded,
    nameAr: 'سهرات وخروجات ليلية',
    nameEn: 'Nightlife & Lounges',
    category: AppIconCategory.entertainment,
    keywords: ['سهرة', 'لاونج', 'خروجة بالليل', 'nightlife', 'lounge', 'club'],
  ),
  const AppIconItem(
    icon: Icons.beach_access_rounded,
    nameAr: 'شواطئ ومصايف وشمسيات',
    nameEn: 'Beach & Resort',
    category: AppIconCategory.entertainment,
    keywords: ['بحر', 'شاطئ', 'مصيف', 'شمسية', 'ساحل', 'ريزورت', 'beach', 'resort', 'summer'],
  ),
  const AppIconItem(
    icon: Icons.cabin_rounded,
    nameAr: 'شاليه وكبائن ومخيمات',
    nameEn: 'Cabins & Chalets',
    category: AppIconCategory.home,
    keywords: ['شاليه', 'كوخ', 'كامب', 'مخيم', 'cabin', 'chalet', 'camp'],
  ),
  const AppIconItem(
    icon: Icons.deck_rounded,
    nameAr: 'تراس وجلسات خارجية',
    nameEn: 'Outdoor Deck & Terraces',
    category: AppIconCategory.home,
    keywords: ['تراس', 'جلسة خارجية', 'روف', 'بلكونة', 'deck', 'patio', 'terrace'],
  ),
  const AppIconItem(
    icon: Icons.castle_rounded,
    nameAr: 'معالم سياحية وقلاع وتاريخ',
    nameEn: 'Monuments & Castles',
    category: AppIconCategory.entertainment,
    keywords: ['قلعة', 'معلم سياحي', 'آثار', 'متحف', 'قصر', 'monument', 'castle', 'history'],
  ),
  const AppIconItem(
    icon: Icons.toys_rounded,
    nameAr: 'ألعاب أطفال وترفيه صغار',
    nameEn: 'Kids Toys',
    category: AppIconCategory.entertainment,
    keywords: ['ألعاب أطفال', 'لعب', 'عرايس', 'سيارات أطفال', 'toys', 'kids games'],
  ),
  const AppIconItem(
    icon: Icons.stroller_rounded,
    nameAr: 'عربات أطفال ومستلزمات بيبي',
    nameEn: 'Baby Stroller',
    category: AppIconCategory.family,
    keywords: ['عربة أطفال', 'بيبي', 'عربية بيبي', 'stroller', 'baby', 'pram'],
  ),
  const AppIconItem(
    icon: Icons.cruelty_free_rounded,
    nameAr: 'رفق بالحيوان ومنتجات طبيعية',
    nameEn: 'Animal Welfare & Care',
    category: AppIconCategory.transport,
    keywords: ['حيوان', 'رفق', 'منتجات طبيعية', 'cruelty free', 'animals'],
  ),
  const AppIconItem(
    icon: Icons.pest_control_rounded,
    nameAr: 'مكافحة حشرات ورش مبيدات',
    nameEn: 'Pest Control',
    category: AppIconCategory.home,
    keywords: ['رش مبيدات', 'مكافحة حشرات', 'نظافة', 'pest control', 'insects'],
  ),
  const AppIconItem(
    icon: Icons.child_friendly_rounded,
    nameAr: 'مرافق أطفال ورعاية صغار',
    nameEn: 'Child Friendly',
    category: AppIconCategory.transport,
    keywords: ['أطفال', 'بيئة أطفال', 'حضانة أطفال', 'child friendly', 'daycare'],
  ),
  const AppIconItem(
    icon: Icons.price_change_rounded,
    nameAr: 'تغير أسعار وفروق عملة',
    nameEn: 'Price Changes',
    category: AppIconCategory.finance,
    keywords: ['تغير أسعار', 'فروق', 'تسعير', 'تضخم', 'price change', 'inflation'],
  ),
  const AppIconItem(
    icon: Icons.query_stats_rounded,
    nameAr: 'إحصائيات وأداء مالي',
    nameEn: 'Financial Stats',
    category: AppIconCategory.finance,
    keywords: ['إحصائيات', 'أداء مالي', 'رسم بياني', 'تقارير', 'stats', 'financial performance'],
  ),
  const AppIconItem(
    icon: Icons.request_quote_rounded,
    nameAr: 'عروض أسعار وفواتير مبدئية',
    nameEn: 'Price Quotes',
    category: AppIconCategory.finance,
    keywords: ['عرض سعر', 'كوتيشن', 'فاتورة مبدئية', 'quote', 'invoice', 'estimate'],
  ),
  const AppIconItem(
    icon: Icons.balance_rounded,
    nameAr: 'ميزان عدل ومحاكم',
    nameEn: 'Justice & Balance',
    category: AppIconCategory.finance,
    keywords: ['ميزان', 'عدالة', 'قضاء', 'حقوق', 'justice', 'balance', 'court'],
  ),
  const AppIconItem(
    icon: Icons.receipt_rounded,
    nameAr: 'إيصالات مبسطة ودفع',
    nameEn: 'Payment Slips',
    category: AppIconCategory.finance,
    keywords: ['إيصال', 'وصل أمانة', 'وصل دفع', 'slip', 'receipt', 'voucher'],
  ),
  const AppIconItem(
    icon: Icons.paid_rounded,
    nameAr: 'دفعات مكتملة ومستحقات',
    nameEn: 'Paid & Settlements',
    category: AppIconCategory.finance,
    keywords: ['دفع مستحق', 'تسوية', 'مكتمل', 'سداد', 'paid', 'settlement'],
  ),
  const AppIconItem(
    icon: Icons.real_estate_agent_rounded,
    nameAr: 'سمسار وعمولات عقارية',
    nameEn: 'Real Estate Broker',
    category: AppIconCategory.finance,
    keywords: ['سمسار', 'وسيط عقاري', 'عمولة', 'تسويق عقاري', 'broker', 'real estate', 'realtor'],
  ),
  const AppIconItem(
    icon: Icons.domain_rounded,
    nameAr: 'أبراج وشركات كبرى',
    nameEn: 'Corporate Towers',
    category: AppIconCategory.entertainment,
    keywords: ['برج', 'شركة كبرى', 'مقر إداري', 'corporate', 'headquarters'],
  ),
  const AppIconItem(
    icon: Icons.corporate_fare_rounded,
    nameAr: 'مباني إدارية ومكاتب',
    nameEn: 'Office Buildings',
    category: AppIconCategory.home,
    keywords: ['مبنى إداري', 'مكتب', 'سنتر', 'office building', 'complex'],
  ),
  const AppIconItem(
    icon: Icons.church_rounded,
    nameAr: 'كنيسة ومناسبات قبطية',
    nameEn: 'Church',
    category: AppIconCategory.family,
    keywords: ['كنيسة', 'دير', 'مناسبات مسيحية', 'صلاة', 'church', 'christian'],
  ),
  const AppIconItem(
    icon: Icons.synagogue_rounded,
    nameAr: 'معابد دينية وتراث',
    nameEn: 'Synagogue & Heritage',
    category: AppIconCategory.family,
    keywords: ['معبد', 'تراث ديني', 'synagogue', 'heritage'],
  ),
  const AppIconItem(
    icon: Icons.eco_rounded,
    nameAr: 'بيئة وطاقة نظيفة ومنتجات خضراء',
    nameEn: 'Eco & Green',
    category: AppIconCategory.other,
    keywords: ['بيئة', 'أخضر', 'طبيعي', 'طاقة نظيفة', 'eco', 'green', 'organic'],
  ),
  const AppIconItem(
    icon: Icons.forest_rounded,
    nameAr: 'غابات ورحلات سفاري',
    nameEn: 'Forests & Nature',
    category: AppIconCategory.other,
    keywords: ['غابة', 'سفاري', 'أشجار', 'طبيعة برية', 'forest', 'safari', 'nature'],
  ),
  const AppIconItem(
    icon: Icons.agriculture_rounded,
    nameAr: 'زراعة ومزارع ومحاصيل',
    nameEn: 'Agriculture & Farming',
    category: AppIconCategory.other,
    keywords: ['زراعة', 'مزرعة', 'محصول', 'أسمدة', 'فلاحة', 'agriculture', 'farming', 'crops'],
  ),
  const AppIconItem(
    icon: Icons.water_rounded,
    nameAr: 'بحيرات وأنهار ومسطحات مائية',
    nameEn: 'Water Bodies & Lakes',
    category: AppIconCategory.other,
    keywords: ['بحيرة', 'نهر', 'بحر', 'مياه طبيعية', 'water', 'lake', 'river'],
  ),
  const AppIconItem(
    icon: Icons.favorite_rounded,
    nameAr: 'مفضلات وتبرعات قلبية',
    nameEn: 'Favorites & Heart',
    category: AppIconCategory.health,
    keywords: ['قلب', 'حب', 'مفضل', 'عاطفي', 'تبرع', 'favorite', 'love', 'heart'],
  ),
  const AppIconItem(
    icon: Icons.groups_rounded,
    nameAr: 'أصدقاء وجمعات عائلية',
    nameEn: 'Friends & Group Outings',
    category: AppIconCategory.family,
    keywords: ['صحاب', 'شلة', 'لمة', 'جمعة', 'عيلة', 'friends', 'group', 'social'],
  ),
  const AppIconItem(
    icon: Icons.auto_awesome_rounded,
    nameAr: 'أخرى ومتنوعة',
    nameEn: 'Custom / Other',
    category: AppIconCategory.other,
    keywords: ['أخرى', 'متنوع', 'عام', 'other', 'custom', 'special'],
  ),
];

/// Backwards compatibility alias
List<AppIconItem> get kAccountIconPresets => kAppIconItems;

/// Shows an iOS / Android Bottom Sheet picker with live search for icons.
/// On iOS: Uses [GlassModalSheet.present] with fluid iOS 26 liquid glass physics.
/// On Android: Uses [showModalBottomSheet] with adaptive surface styling.
Future<IconData?> showAppIconPicker(
  BuildContext context, {
  RenderBox? widgetRenderBox,
  required IconData selectedIcon,
  required bool isDarkMode,
  required bool isAr,
  String? title,
}) async {
  final focusNode = FocusNode();

  if (Platform.isIOS) {
    final sheetController = GlassModalSheetController();
    return await GlassModalSheet.present<IconData?>(
      context: context,
      controller: sheetController,
      halfSize: 0.72,
      fullSize: 0.90,
      onStateChanged: (state) {
        if (state == GlassSheetState.half) {
          focusNode.unfocus();
        }
      },
      builder: (sheetContext) => Material(
        type: MaterialType.transparency,
        child: AppIconModalContent(
          selectedIcon: selectedIcon,
          isDarkMode: isDarkMode,
          isAr: isAr,
          title: title,
          controller: sheetController,
          focusNode: focusNode,
          isGlass: true,
        ),
      ),
    );
  } else {
    return await showModalBottomSheet<IconData?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => AppIconModalContent(
        selectedIcon: selectedIcon,
        isDarkMode: isDarkMode,
        isAr: isAr,
        title: title,
        controller: null,
        focusNode: focusNode,
        isGlass: false,
      ),
    );
  }
}

/// Backwards compatibility alias for existing code
Future<IconData?> showCupertinoIconPicker(
  BuildContext context, {
  RenderBox? widgetRenderBox,
  required IconData selectedIcon,
  required bool isDarkMode,
  required bool isAr,
  String? title,
}) =>
    showAppIconPicker(
      context,
      widgetRenderBox: widgetRenderBox,
      selectedIcon: selectedIcon,
      isDarkMode: isDarkMode,
      isAr: isAr,
      title: title,
    );

class AppIconModalContent extends StatefulWidget {
  final IconData selectedIcon;
  final bool isDarkMode;
  final bool isAr;
  final String? title;
  final GlassModalSheetController? controller;
  final FocusNode focusNode;
  final bool isGlass;

  const AppIconModalContent({
    super.key,
    required this.selectedIcon,
    required this.isDarkMode,
    required this.isAr,
    this.title,
    this.controller,
    required this.focusNode,
    this.isGlass = false,
  });

  @override
  State<AppIconModalContent> createState() => _AppIconModalContentState();
}

class _AppIconModalContentState extends State<AppIconModalContent>
    with WidgetsBindingObserver {
  late TextEditingController _searchController;
  late IconData _selectedIcon;
  String _searchQuery = '';
  AppIconCategory _selectedCategory = AppIconCategory.all;
  bool _wasKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedIcon = widget.selectedIcon;
    WidgetsBinding.instance.addObserver(this);
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (widget.focusNode.hasFocus && widget.controller != null) {
      widget.controller?.snapToState(GlassSheetState.full);
    }
  }

  @override
  void didChangeMetrics() {
    final bottomInset =
        WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    if (isKeyboardOpen && !_wasKeyboardOpen) {
      if (widget.controller?.currentState != GlassSheetState.full) {
        widget.controller?.snapToState(GlassSheetState.full);
      }
    }
    _wasKeyboardOpen = isKeyboardOpen;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.focusNode.removeListener(_handleFocusChange);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final themeColor =
        widget.isDarkMode ? Colors.white : const Color(0xFF09090B);
    final isAr = widget.isAr;

    final sheetScrollController = widget.isGlass
        ? ScrollControllerProvider.of(context)?.controller
        : null;

    final bottomSpacing = widget.isGlass
        ? (viewInsetsBottom > 0
            ? viewInsetsBottom + 70
            : (safeAreaBottom > 0 ? safeAreaBottom + 96 : 100.0))
        : (safeAreaBottom > 0 ? safeAreaBottom + 80 : 90.0);

    final sheetContent = Column(
      children: [
        // Top Header Area (tap on header unfocuses keyboard)
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (widget.focusNode.hasFocus) {
              widget.focusNode.unfocus();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Android top drag handle
              if (!widget.isGlass)
                Center(
                  child: Container(
                    height: 4,
                    width: 38,
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              SizedBox(height: widget.isGlass ? 12 : 4),

              // Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 42,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        widget.title ??
                            (isAr ? 'أيقونة الحساب' : 'Account Icon'),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Cancel Button
                          widget.isGlass
                              ? GlassButton.custom(
                                  height: 38,
                                  shape: const LiquidRoundedRectangle(
                                      borderRadius: 19),
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
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 14),
                                    child: Center(
                                      child: Text(
                                        isAr ? 'إلغاء' : 'Cancel',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: widget.isDarkMode
                                              ? const Color(0xFFE4E4E7)
                                              : const Color(0xFF71717A),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : TextButton(
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    isAr ? 'إلغاء' : 'Cancel',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: widget.isDarkMode
                                              ? const Color(0xFFE4E4E7)
                                              : const Color(0xFF71717A),
                                    ),
                                  ),
                                ),
                          const SizedBox(width: 42),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Clean iOS Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? (widget.isGlass
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFF28282E))
                        : (widget.isGlass
                            ? Colors.black.withValues(alpha: 0.05)
                            : const Color(0xFFF2F2F7)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: widget.focusNode,
                    keyboardAppearance:
                        widget.isDarkMode ? Brightness.dark : Brightness.light,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                    cursorColor: widget.isDarkMode ? Colors.white : Colors.black,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: widget.isDarkMode
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF71717A),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: widget.isDarkMode
                                    ? const Color(0xFFA1A1AA)
                                    : const Color(0xFF71717A),
                              ),
                            )
                          : null,
                      suffixIconConstraints:
                          const BoxConstraints(minWidth: 32, minHeight: 36),
                      hintText: isAr
                          ? 'بحث في الأيقونات...'
                          : 'Search icons...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: widget.isDarkMode
                            ? const Color(0xFF71717A)
                            : const Color(0xFFA1A1AA),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val.trim());
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Category Filter Pills Bar (remains accessible even during search)
              _buildCategoryChipsBar(isAr, themeColor),
            ],
          ),
        ),

        // Scrollable Icons Area (Categorized Sections or Filtered Grid)
        Expanded(
          child: _buildScrollableBody(
            sheetScrollController,
            isAr,
            themeColor,
            bottomSpacing,
          ),
        ),
      ],
    );

    if (widget.isGlass) {
      return sheetContent;
    }

    final screenHeight = MediaQuery.sizeOf(context).height;
    final availableHeight = (screenHeight - viewInsetsBottom) * 0.85;

    return Container(
      height: availableHeight.clamp(320.0, 680.0),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF141417) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: widget.isDarkMode
              ? const Color(0xFF27272A)
              : const Color(0xFFE4E4E7),
          width: 1,
        ),
      ),
      child: SafeArea(
        top: false,
        child: sheetContent,
      ),
    );
  }

  // ==========================================
  // CATEGORY PILLS BAR
  // ==========================================
  Widget _buildCategoryChipsBar(bool isAr, Color themeColor) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kAppIconFilterCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final cat = kAppIconFilterCategories[index];
          final isSelected = cat == _selectedCategory;

          final selectedBg = widget.isDarkMode ? Colors.white : Colors.black;
          final selectedFg = widget.isDarkMode ? Colors.black : Colors.white;

          final unselectedBg = widget.isDarkMode
              ? (widget.isGlass
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFF26262C))
              : (widget.isGlass
                  ? Colors.black.withValues(alpha: 0.05)
                  : const Color(0xFFF4F4F6));
          final unselectedFg = widget.isDarkMode
              ? const Color(0xFFD4D4D8)
              : const Color(0xFF52525B);
          final unselectedBorder = widget.isDarkMode
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.black.withValues(alpha: 0.06);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = cat);
              },
              borderRadius: BorderRadius.circular(17),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? selectedBg : unselectedBg,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : unselectedBorder,
                    width: 0.8,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (widget.isDarkMode ? Colors.white : Colors.black)
                                .withValues(alpha: 0.20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 13,
                      color: isSelected ? selectedFg : unselectedFg,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cat.name(isAr),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? selectedFg : unselectedFg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // SCROLLABLE BODY
  // ==========================================
  Widget _buildScrollableBody(
    ScrollController? sheetScrollController,
    bool isAr,
    Color themeColor,
    double bottomSpacing,
  ) {
    // 1. Search Query Mode
    if (_searchQuery.isNotEmpty) {
      var results = kAppIconItems
          .where((item) => item.matches(_searchQuery))
          .toList();

      if (_selectedCategory != AppIconCategory.all) {
        results = results
            .where((item) => item.category == _selectedCategory)
            .toList();
      }

      if (results.isEmpty) {
        return _buildEmptyState(isAr, themeColor);
      }

      return CustomScrollView(
        controller: sheetScrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Text(
                isAr
                    ? 'نتائج البحث (${results.length})'
                    : 'Search Results (${results.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.isDarkMode
                      ? const Color(0xFFA1A1AA)
                      : const Color(0xFF71717A),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildIconTile(results[index], themeColor),
                childCount: results.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: bottomSpacing),
          ),
        ],
      );
    }

    // 2. Specific Category Mode
    if (_selectedCategory != AppIconCategory.all) {
      final items = kAppIconItems
          .where((item) => item.category == _selectedCategory)
          .toList();

      return CustomScrollView(
        controller: sheetScrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        slivers: [
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              _selectedCategory,
              items.length,
              isAr,
              themeColor,
              showShowAll: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildIconTile(items[index], themeColor),
                childCount: items.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: bottomSpacing),
          ),
        ],
      );
    }

    // 3. All Categories (Grouped Categorized Sections View)
    return CustomScrollView(
      controller: sheetScrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
      slivers: [
        for (final cat in kAppIconCategories) ...[
          Builder(
            builder: (context) {
              final catItems = kAppIconItems
                  .where((item) => item.category == cat)
                  .toList();
              if (catItems.isEmpty) return const SliverToBoxAdapter();

              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      cat,
                      catItems.length,
                      isAr,
                      themeColor,
                      showShowAll: false,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildIconTile(catItems[index], themeColor),
                        childCount: catItems.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 12),
                  ),
                ],
              );
            },
          ),
        ],
        SliverToBoxAdapter(
          child: SizedBox(height: bottomSpacing),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION HEADER
  // ==========================================
  Widget _buildSectionHeader(
    AppIconCategory cat,
    int count,
    bool isAr,
    Color themeColor, {
    bool showShowAll = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Icon(
                cat.icon,
                size: 13,
                color: themeColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            cat.name(isAr),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: themeColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode
                    ? const Color(0xFFA1A1AA)
                    : const Color(0xFF71717A),
              ),
            ),
          ),
          const Spacer(),
          if (showShowAll)
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = AppIconCategory.all);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: (widget.isDarkMode ? Colors.white : Colors.black)
                      .withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAr ? 'عرض الكل' : 'Show All',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkMode
                        ? const Color(0xFFD4D4D8)
                        : const Color(0xFF52525B),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // ICON TILE ITEM
  // ==========================================
  Widget _buildIconTile(AppIconItem item, Color themeColor) {
    final isSelected = item.icon == _selectedIcon;
    final isDark = widget.isDarkMode;
    final isGlass = widget.isGlass;

    final selectedBg = isDark ? Colors.white : Colors.black;
    final selectedFg = isDark ? Colors.black : Colors.white;

    final normalBg = isDark
        ? (isGlass ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF26262C))
        : (isGlass ? Colors.black.withValues(alpha: 0.05) : const Color(0xFFF4F4F6));

    final normalBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).pop(item.icon);
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : normalBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.transparent : normalBorder,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              item.icon,
              size: 22,
              color: isSelected ? selectedFg : themeColor,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================
  Widget _buildEmptyState(bool isAr, Color themeColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 34,
              color: widget.isDarkMode ? Colors.white38 : Colors.black38,
            ),
            const SizedBox(height: 8),
            Text(
              isAr ? 'لا توجد أيقونة مطابقة' : 'No matching icons',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = AppIconCategory.all;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (widget.isDarkMode ? Colors.white : Colors.black)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAr ? 'عرض كل الأيقونات' : 'Show all icons',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: themeColor,
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
