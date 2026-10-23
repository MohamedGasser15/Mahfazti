/// Model representing a supported world or regional currency with flags,
/// bilingual titles, symbols, and rich search keywords.
class AppCurrency {
  final String code;
  final String nameEn;
  final String nameAr;
  final String flag;
  final String symbol;
  final String symbolAr;
  final List<String> keywords;

  const AppCurrency({
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.flag,
    required this.symbol,
    required this.symbolAr,
    this.keywords = const [],
  });

  bool matches(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return true;
    if (code.toLowerCase().contains(clean)) return true;
    if (nameEn.toLowerCase().contains(clean)) return true;
    if (nameAr.toLowerCase().contains(clean)) return true;
    if (symbol.toLowerCase().contains(clean)) return true;
    if (symbolAr.toLowerCase().contains(clean)) return true;
    for (final kw in keywords) {
      if (kw.toLowerCase().contains(clean)) return true;
    }
    return false;
  }
}

/// Comprehensive list of currencies (Middle East, Arab world, and global).
const List<AppCurrency> kAllCurrencies = [
  // --- Popular Middle Eastern & Arab Currencies ---
  AppCurrency(
    code: 'EGP',
    nameEn: 'Egyptian Pound',
    nameAr: 'جنيه مصري',
    flag: '🇪🇬',
    symbol: 'E£',
    symbolAr: 'ج.م',
    keywords: ['مصر', 'جنيه', 'egypt', 'pound', 'cairo', 'egp'],
  ),
  AppCurrency(
    code: 'SAR',
    nameEn: 'Saudi Riyal',
    nameAr: 'ريال سعودي',
    flag: '🇸🇦',
    symbol: 'SAR',
    symbolAr: 'ر.س',
    keywords: ['السعودية', 'ريال', 'saudi', 'arabia', 'riyal', 'sar'],
  ),
  AppCurrency(
    code: 'AED',
    nameEn: 'UAE Dirham',
    nameAr: 'درهم إماراتي',
    flag: '🇦🇪',
    symbol: 'AED',
    symbolAr: 'د.إ',
    keywords: ['الإمارات', 'درهم', 'دبي', 'uae', 'dubai', 'dirham', 'aed'],
  ),
  AppCurrency(
    code: 'KWD',
    nameEn: 'Kuwaiti Dinar',
    nameAr: 'دينار كويتي',
    flag: '🇰🇼',
    symbol: 'KWD',
    symbolAr: 'د.ك',
    keywords: ['الكويت', 'دينار', 'kuwait', 'dinar', 'kwd'],
  ),
  AppCurrency(
    code: 'QAR',
    nameEn: 'Qatari Riyal',
    nameAr: 'ريال قطري',
    flag: '🇶🇦',
    symbol: 'QAR',
    symbolAr: 'ر.ق',
    keywords: ['قطر', 'ريال', 'qatar', 'riyal', 'qar'],
  ),
  AppCurrency(
    code: 'BHD',
    nameEn: 'Bahraini Dinar',
    nameAr: 'دينار بحريني',
    flag: '🇧🇭',
    symbol: 'BHD',
    symbolAr: 'د.ب',
    keywords: ['البحرين', 'دينار', 'bahrain', 'dinar', 'bhd'],
  ),
  AppCurrency(
    code: 'OMR',
    nameEn: 'Omani Rial',
    nameAr: 'ريال عماني',
    flag: '🇴🇲',
    symbol: 'OMR',
    symbolAr: 'ر.ع',
    keywords: ['عمان', 'سلطنة عمان', 'ريال', 'oman', 'rial', 'omr'],
  ),
  AppCurrency(
    code: 'JOD',
    nameEn: 'Jordanian Dinar',
    nameAr: 'دينار أردني',
    flag: '🇯🇴',
    symbol: 'JOD',
    symbolAr: 'د.أ',
    keywords: ['الأردن', 'دينار', 'jordan', 'dinar', 'jod'],
  ),

  // --- Major World Currencies ---
  AppCurrency(
    code: 'USD',
    nameEn: 'US Dollar',
    nameAr: 'دولار أمريكي',
    flag: '🇺🇸',
    symbol: '\$',
    symbolAr: '\$',
    keywords: ['أمريكا', 'دولار', 'us', 'usa', 'dollar', 'buck', 'usd'],
  ),
  AppCurrency(
    code: 'EUR',
    nameEn: 'Euro',
    nameAr: 'يورو أوروبي',
    flag: '🇪🇺',
    symbol: '€',
    symbolAr: '€',
    keywords: ['أوروبا', 'يورو', 'europe', 'euro', 'eur'],
  ),
  AppCurrency(
    code: 'GBP',
    nameEn: 'British Pound',
    nameAr: 'جنيه إسترليني',
    flag: '🇬🇧',
    symbol: '£',
    symbolAr: '£',
    keywords: ['بريطانيا', 'إنجلترا', 'إسترليني', 'uk', 'britain', 'pound', 'sterling', 'gbp'],
  ),
  AppCurrency(
    code: 'CAD',
    nameEn: 'Canadian Dollar',
    nameAr: 'دولار كندي',
    flag: '🇨🇦',
    symbol: 'C\$',
    symbolAr: 'C\$',
    keywords: ['كندا', 'دولار كندي', 'canada', 'dollar', 'cad'],
  ),
  AppCurrency(
    code: 'AUD',
    nameEn: 'Australian Dollar',
    nameAr: 'دولار أسترالي',
    flag: '🇦🇺',
    symbol: 'A\$',
    symbolAr: 'A\$',
    keywords: ['أستراليا', 'دولار', 'australia', 'dollar', 'aud'],
  ),
  AppCurrency(
    code: 'CHF',
    nameEn: 'Swiss Franc',
    nameAr: 'فرنك سويسري',
    flag: '🇨🇭',
    symbol: 'CHF',
    symbolAr: 'فرنك',
    keywords: ['سويسرا', 'فرنك', 'switzerland', 'franc', 'chf'],
  ),
  AppCurrency(
    code: 'JPY',
    nameEn: 'Japanese Yen',
    nameAr: 'ين ياباني',
    flag: '🇯🇵',
    symbol: '¥',
    symbolAr: '¥',
    keywords: ['اليابان', 'ين', 'japan', 'yen', 'jpy'],
  ),
  AppCurrency(
    code: 'CNY',
    nameEn: 'Chinese Yuan',
    nameAr: 'يوان صيني',
    flag: '🇨🇳',
    symbol: '¥',
    symbolAr: '¥',
    keywords: ['الصين', 'يوان', 'china', 'yuan', 'rmb', 'cny'],
  ),
  AppCurrency(
    code: 'TRY',
    nameEn: 'Turkish Lira',
    nameAr: 'ليرة تركية',
    flag: '🇹🇷',
    symbol: '₺',
    symbolAr: 'ل.ت',
    keywords: ['تركيا', 'ليرة', 'turkey', 'lira', 'try'],
  ),

  // --- North Africa & Levant Currencies ---
  AppCurrency(
    code: 'MAD',
    nameEn: 'Moroccan Dirham',
    nameAr: 'درهم مغربي',
    flag: '🇲🇦',
    symbol: 'MAD',
    symbolAr: 'د.م',
    keywords: ['المغرب', 'درهم', 'morocco', 'dirham', 'mad'],
  ),
  AppCurrency(
    code: 'DZD',
    nameEn: 'Algerian Dinar',
    nameAr: 'دينار جزائري',
    flag: '🇩🇿',
    symbol: 'DZD',
    symbolAr: 'د.ج',
    keywords: ['الجزائر', 'دينار', 'algeria', 'dinar', 'dzd'],
  ),
  AppCurrency(
    code: 'TND',
    nameEn: 'Tunisian Dinar',
    nameAr: 'دينار تونسي',
    flag: '🇹🇳',
    symbol: 'TND',
    symbolAr: 'د.ت',
    keywords: ['تونس', 'دينار', 'tunisia', 'dinar', 'tnd'],
  ),
  AppCurrency(
    code: 'LYD',
    nameEn: 'Libyan Dinar',
    nameAr: 'دينار ليبي',
    flag: '🇱🇾',
    symbol: 'LYD',
    symbolAr: 'د.ل',
    keywords: ['ليبيا', 'دينار', 'libya', 'dinar', 'lyd'],
  ),
  AppCurrency(
    code: 'SDG',
    nameEn: 'Sudanese Pound',
    nameAr: 'جنيه سوداني',
    flag: '🇸🇩',
    symbol: 'SDG',
    symbolAr: 'ج.س',
    keywords: ['السودان', 'جنيه', 'sudan', 'pound', 'sdg'],
  ),
  AppCurrency(
    code: 'IQD',
    nameEn: 'Iraqi Dinar',
    nameAr: 'دينار عراقي',
    flag: '🇮🇶',
    symbol: 'IQD',
    symbolAr: 'د.ع',
    keywords: ['العراق', 'دينار', 'iraq', 'dinar', 'iqd'],
  ),
  AppCurrency(
    code: 'LBP',
    nameEn: 'Lebanese Pound',
    nameAr: 'ليرة لبنانية',
    flag: '🇱🇧',
    symbol: 'LBP',
    symbolAr: 'ل.ل',
    keywords: ['لبنان', 'ليرة', 'lebanon', 'pound', 'lbp'],
  ),
  AppCurrency(
    code: 'YER',
    nameEn: 'Yemeni Rial',
    nameAr: 'ريال يمني',
    flag: '🇾🇪',
    symbol: 'YER',
    symbolAr: 'ر.ي',
    keywords: ['اليمن', 'ريال', 'yemen', 'rial', 'yer'],
  ),
  AppCurrency(
    code: 'SYP',
    nameEn: 'Syrian Pound',
    nameAr: 'ليرة سورية',
    flag: '🇸🇾',
    symbol: 'SYP',
    symbolAr: 'ل.س',
    keywords: ['سوريا', 'ليرة', 'syria', 'pound', 'syp'],
  ),

  // --- Other Global & Asian Currencies ---
  AppCurrency(
    code: 'INR',
    nameEn: 'Indian Rupee',
    nameAr: 'روبية هندية',
    flag: '🇮🇳',
    symbol: '₹',
    symbolAr: '₹',
    keywords: ['الهند', 'روبية', 'india', 'rupee', 'inr'],
  ),
  AppCurrency(
    code: 'PKR',
    nameEn: 'Pakistani Rupee',
    nameAr: 'روبية باكستانية',
    flag: '🇵🇰',
    symbol: 'PKR',
    symbolAr: 'ر.ب',
    keywords: ['باكستان', 'روبية', 'pakistan', 'rupee', 'pkr'],
  ),
  AppCurrency(
    code: 'RUB',
    nameEn: 'Russian Ruble',
    nameAr: 'روبل روسي',
    flag: '🇷🇺',
    symbol: '₽',
    symbolAr: '₽',
    keywords: ['روسيا', 'روبل', 'russia', 'ruble', 'rub'],
  ),
  AppCurrency(
    code: 'BRL',
    nameEn: 'Brazilian Real',
    nameAr: 'ريال برازيلي',
    flag: '🇧🇷',
    symbol: 'R\$',
    symbolAr: 'R\$',
    keywords: ['البرازيل', 'ريال', 'brazil', 'real', 'brl'],
  ),
  AppCurrency(
    code: 'MXN',
    nameEn: 'Mexican Peso',
    nameAr: 'بيزو مكسيكي',
    flag: '🇲🇽',
    symbol: 'Mex\$',
    symbolAr: 'Mex\$',
    keywords: ['المكسيك', 'بيزو', 'mexico', 'peso', 'mxn'],
  ),
  AppCurrency(
    code: 'ZAR',
    nameEn: 'South African Rand',
    nameAr: 'راند جنوب أفريقي',
    flag: '🇿🇦',
    symbol: 'R',
    symbolAr: 'راند',
    keywords: ['جنوب أفريقيا', 'راند', 'south africa', 'rand', 'zar'],
  ),
  AppCurrency(
    code: 'KRW',
    nameEn: 'South Korean Won',
    nameAr: 'وون كوري',
    flag: '🇰🇷',
    symbol: '₩',
    symbolAr: '₩',
    keywords: ['كوريا', 'وون', 'korea', 'won', 'krw'],
  ),
  AppCurrency(
    code: 'SEK',
    nameEn: 'Swedish Krona',
    nameAr: 'كرونة سويدية',
    flag: '🇸🇪',
    symbol: 'kr',
    symbolAr: 'كرونة',
    keywords: ['السويد', 'كرونة', 'sweden', 'krona', 'sek'],
  ),
  AppCurrency(
    code: 'NOK',
    nameEn: 'Norwegian Krone',
    nameAr: 'كرونة نرويجية',
    flag: '🇳🇴',
    symbol: 'kr',
    symbolAr: 'كرونة',
    keywords: ['النرويج', 'كرونة', 'norway', 'krone', 'nok'],
  ),
  AppCurrency(
    code: 'DKK',
    nameEn: 'Danish Krone',
    nameAr: 'كرونة دنماركية',
    flag: '🇩🇰',
    symbol: 'kr',
    symbolAr: 'كرونة',
    keywords: ['الدنمارك', 'كرونة', 'denmark', 'krone', 'dkk'],
  ),
  AppCurrency(
    code: 'PLN',
    nameEn: 'Polish Zloty',
    nameAr: 'زلوتي بولندي',
    flag: '🇵🇱',
    symbol: 'zł',
    symbolAr: 'زلوتي',
    keywords: ['بولندا', 'زلوتي', 'poland', 'zloty', 'pln'],
  ),
  AppCurrency(
    code: 'THB',
    nameEn: 'Thai Baht',
    nameAr: 'بات تايلاندي',
    flag: '🇹🇭',
    symbol: '฿',
    symbolAr: 'بات',
    keywords: ['تايلاند', 'بات', 'thailand', 'baht', 'thb'],
  ),
  AppCurrency(
    code: 'MYR',
    nameEn: 'Malaysian Ringgit',
    nameAr: 'رينغيت ماليزي',
    flag: '🇲🇾',
    symbol: 'RM',
    symbolAr: 'ر.م',
    keywords: ['ماليزيا', 'رينغيت', 'malaysia', 'ringgit', 'myr'],
  ),
  AppCurrency(
    code: 'IDR',
    nameEn: 'Indonesian Rupiah',
    nameAr: 'روبية إندونيسية',
    flag: '🇮🇩',
    symbol: 'Rp',
    symbolAr: 'روبية',
    keywords: ['إندونيسيا', 'روبية', 'indonesia', 'rupiah', 'idr'],
  ),
  AppCurrency(
    code: 'PHP',
    nameEn: 'Philippine Peso',
    nameAr: 'بيزو فلبيني',
    flag: '🇵🇭',
    symbol: '₱',
    symbolAr: 'بيزو',
    keywords: ['الفلبين', 'بيزو', 'philippines', 'peso', 'php'],
  ),
  AppCurrency(
    code: 'SGD',
    nameEn: 'Singapore Dollar',
    nameAr: 'دولار سنغافوري',
    flag: '🇸🇬',
    symbol: 'S\$',
    symbolAr: 'S\$',
    keywords: ['سنغافورة', 'دولار', 'singapore', 'dollar', 'sgd'],
  ),
  AppCurrency(
    code: 'NZD',
    nameEn: 'New Zealand Dollar',
    nameAr: 'دولار نيوزيلندي',
    flag: '🇳🇿',
    symbol: 'NZ\$',
    symbolAr: 'NZ\$',
    keywords: ['نيوزيلندا', 'دولار', 'new zealand', 'dollar', 'nzd'],
  ),
  AppCurrency(
    code: 'NGN',
    nameEn: 'Nigerian Naira',
    nameAr: 'نايرا نيجيرية',
    flag: '🇳🇬',
    symbol: '₦',
    symbolAr: 'نايرا',
    keywords: ['نيجيريا', 'نايرا', 'nigeria', 'naira', 'ngn'],
  ),
  AppCurrency(
    code: 'KES',
    nameEn: 'Kenyan Shilling',
    nameAr: 'شلن كيني',
    flag: '🇰🇪',
    symbol: 'KSh',
    symbolAr: 'شلن',
    keywords: ['كينيا', 'شلن', 'kenya', 'shilling', 'kes'],
  ),
  AppCurrency(
    code: 'ARS',
    nameEn: 'Argentine Peso',
    nameAr: 'بيزو أرجنتيني',
    flag: '🇦🇷',
    symbol: '\$',
    symbolAr: '\$',
    keywords: ['الأرجنتين', 'بيزو', 'argentina', 'peso', 'ars'],
  ),
];

/// Fallback / fast lookup map for English currency symbols
final Map<String, String> currencySymbols = {
  for (final c in kAllCurrencies) c.code: c.symbol,
};

/// Fallback / fast lookup map for Arabic currency symbols
final Map<String, String> currencySymbolsAr = {
  for (final c in kAllCurrencies) c.code: c.symbolAr,
};

/// Retrieves the symbol for [currencyCode], formatted according to [isAr].
String getCurrencySymbol(String currencyCode, {bool isAr = false}) {
  final upper = currencyCode.toUpperCase();
  if (isAr) {
    return currencySymbolsAr[upper] ?? currencySymbols[upper] ?? upper;
  }
  return currencySymbols[upper] ?? upper;
}
