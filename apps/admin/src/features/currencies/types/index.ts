export interface CurrencyItem {
  code: string; // e.g. EGP, USD, SAR, AED, EUR
  name: string;
  nameAr: string;
  symbol: string;
  exchangeRateToEgp: number; // e.g. 1 USD = 48.6 EGP
  isDefault: boolean;
  isActive: boolean;
  lastUpdated: string;
}
