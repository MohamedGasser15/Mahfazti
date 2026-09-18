import type { CurrencyItem } from '../types';

let mockCurrencies: CurrencyItem[] = [
  {
    code: 'EGP',
    name: 'Egyptian Pound',
    nameAr: 'الجنيه المصري',
    symbol: 'EGP',
    exchangeRateToEgp: 1.0,
    isDefault: true,
    isActive: true,
    lastUpdated: '2026-09-18T23:00:00Z',
  },
  {
    code: 'USD',
    name: 'US Dollar',
    nameAr: 'الدولار الأمريكي',
    symbol: '$',
    exchangeRateToEgp: 48.65,
    isDefault: false,
    isActive: true,
    lastUpdated: '2026-09-18T23:00:00Z',
  },
  {
    code: 'SAR',
    name: 'Saudi Riyal',
    nameAr: 'الريال السعودي',
    symbol: 'SAR',
    exchangeRateToEgp: 12.97,
    isDefault: false,
    isActive: true,
    lastUpdated: '2026-09-18T23:00:00Z',
  },
  {
    code: 'AED',
    name: 'UAE Dirham',
    nameAr: 'الدرهم الإماراتي',
    symbol: 'AED',
    exchangeRateToEgp: 13.25,
    isDefault: false,
    isActive: true,
    lastUpdated: '2026-09-18T23:00:00Z',
  },
  {
    code: 'EUR',
    name: 'Euro',
    nameAr: 'اليورو الأوروبي',
    symbol: '€',
    exchangeRateToEgp: 53.80,
    isDefault: false,
    isActive: true,
    lastUpdated: '2026-09-18T23:00:00Z',
  },
];

export const currenciesService = {
  getCurrencies: async (): Promise<CurrencyItem[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockCurrencies]), 100));
  },
  toggleActive: async (code: string): Promise<CurrencyItem> => {
    const c = mockCurrencies.find((item) => item.code === code);
    if (c) c.isActive = !c.isActive;
    return new Promise((resolve) => setTimeout(() => resolve({ ...c! }), 100));
  },
};
