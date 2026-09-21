export interface CurrencyItem {
  code: string; // e.g. EGP, USD, SAR, AED, EUR
  nameEn: string;
  nameAr: string;
  name?: string;
  symbol: string;
  exchangeRateToEgp: number; // 1 Currency = X EGP
  isDefault: boolean;
  isFeatured: boolean;
  isActive: boolean;
  lastUpdated: string;
}

export interface CreateCurrencyPayload {
  code: string;
  nameEn: string;
  nameAr: string;
  symbol: string;
  exchangeRateToEgp: number;
  isActive?: boolean;
}

export interface UpdateCurrencyRatePayload {
  exchangeRateToEgp: number;
}
