const Map<String, String> currencySymbols = {
  'USD': '\$',
  'EUR': '€',
  'EGP': 'E£',
  'SAR': '﷼',
  'AED': 'د.إ',
  'KWD': 'د.ك',
};

const Map<String, String> currencySymbolsAr = {
  'USD': '\$',
  'EUR': '€',
  'EGP': 'ج.م',
  'SAR': 'ر.س',
  'AED': 'د.إ',
  'KWD': 'د.ك',
};

String getCurrencySymbol(String currencyCode, {bool isAr = false}) {
  final upper = currencyCode.toUpperCase();
  if (isAr) {
    return currencySymbolsAr[upper] ?? currencySymbols[upper] ?? upper;
  }
  return currencySymbols[upper] ?? upper;
}
