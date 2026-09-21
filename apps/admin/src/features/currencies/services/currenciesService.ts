import { apiClient } from '../../../api/client';
import type { CurrencyItem, CreateCurrencyPayload, UpdateCurrencyRatePayload } from '../types';

interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  error?: string;
  errors?: string[];
}

export const currenciesService = {
  getCurrencies: async (): Promise<CurrencyItem[]> => {
    const res = await apiClient.get<ApiResponse<CurrencyItem[]>>('/currencies');
    const rawData = res.data;
    const items: CurrencyItem[] = Array.isArray(rawData)
      ? rawData
      : (rawData as ApiResponse<CurrencyItem[]>).data || [];
    return items.map((c) => ({
      ...c,
      name: c.nameEn || c.nameAr || c.code,
    }));
  },

  syncLiveRates: async (): Promise<{ items: CurrencyItem[]; message?: string }> => {
    const res = await apiClient.post<ApiResponse<CurrencyItem[]>>('/currencies/sync-rates');
    const rawData = res.data;
    const items: CurrencyItem[] = Array.isArray(rawData)
      ? rawData
      : (rawData as ApiResponse<CurrencyItem[]>).data || [];
    return {
      items: items.map((c) => ({ ...c, name: c.nameEn || c.nameAr || c.code })),
      message: (rawData as ApiResponse<CurrencyItem[]>).message || 'Rates synced successfully',
    };
  },

  toggleActive: async (code: string): Promise<CurrencyItem> => {
    const res = await apiClient.put<ApiResponse<CurrencyItem>>(`/currencies/${code}/toggle-status`);
    const rawData = res.data;
    const item = (rawData as ApiResponse<CurrencyItem>).data || (rawData as unknown as CurrencyItem);
    return {
      ...item,
      name: item.nameEn || item.nameAr || item.code,
    };
  },

  toggleFeatured: async (code: string): Promise<CurrencyItem> => {
    const res = await apiClient.put<ApiResponse<CurrencyItem>>(`/currencies/${code}/toggle-featured`);
    const rawData = res.data;
    const item = (rawData as ApiResponse<CurrencyItem>).data || (rawData as unknown as CurrencyItem);
    return {
      ...item,
      name: item.nameEn || item.nameAr || item.code,
    };
  },

  setBaseCurrency: async (code: string): Promise<CurrencyItem> => {
    const res = await apiClient.put<ApiResponse<CurrencyItem>>(`/currencies/${code}/set-base`);
    const rawData = res.data;
    const item = (rawData as ApiResponse<CurrencyItem>).data || (rawData as unknown as CurrencyItem);
    return {
      ...item,
      name: item.nameEn || item.nameAr || item.code,
    };
  },

  updateRate: async (code: string, exchangeRateToEgp: number): Promise<CurrencyItem> => {
    const payload: UpdateCurrencyRatePayload = { exchangeRateToEgp };
    const res = await apiClient.put<ApiResponse<CurrencyItem>>(`/currencies/${code}/rate`, payload);
    const rawData = res.data;
    const item = (rawData as ApiResponse<CurrencyItem>).data || (rawData as unknown as CurrencyItem);
    return {
      ...item,
      name: item.nameEn || item.nameAr || item.code,
    };
  },

  addCurrency: async (payload: CreateCurrencyPayload): Promise<CurrencyItem> => {
    const res = await apiClient.post<ApiResponse<CurrencyItem>>('/currencies', payload);
    const rawData = res.data;
    const item = (rawData as ApiResponse<CurrencyItem>).data || (rawData as unknown as CurrencyItem);
    return {
      ...item,
      name: item.nameEn || item.nameAr || item.code,
    };
  },
};
