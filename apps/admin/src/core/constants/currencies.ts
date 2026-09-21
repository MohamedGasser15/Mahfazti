/**
 * Supported platform currencies and their display metadata.
 */

export const SUPPORTED_CURRENCIES = ['EGP', 'USD', 'SAR', 'EUR', 'AED', 'KWD'] as const;

export type SupportedCurrency = (typeof SUPPORTED_CURRENCIES)[number];

export interface CurrencyMetadata {
  code: SupportedCurrency;
  nameEn: string;
  nameAr: string;
  symbol: string;
}

export const CURRENCIES_METADATA: Record<SupportedCurrency, CurrencyMetadata> = {
  EGP: { code: 'EGP', nameEn: 'Egyptian Pound', nameAr: 'جنيه مصري', symbol: 'EGP' },
  USD: { code: 'USD', nameEn: 'US Dollar', nameAr: 'دولار أمريكي', symbol: '$' },
  SAR: { code: 'SAR', nameEn: 'Saudi Riyal', nameAr: 'ريال سعودي', symbol: 'SAR' },
  EUR: { code: 'EUR', nameEn: 'Euro', nameAr: 'يورو', symbol: '€' },
  AED: { code: 'AED', nameEn: 'UAE Dirham', nameAr: 'درهم إماراتي', symbol: 'AED' },
  KWD: { code: 'KWD', nameEn: 'Kuwaiti Dinar', nameAr: 'دينار كويتي', symbol: 'KWD' },
};
