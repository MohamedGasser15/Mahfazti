import { apiClient } from '../../../api/client';
import type {
  PricingPlan,
  CreatePricingPlanPayload,
  UpdatePricingPlanPayload,
  UserSubscription,
  SubscriptionStats,
  PaymentLog,
  PromoCode,
  CreatePromoCodePayload,
} from '../types';

interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  error?: string;
  errors?: string[];
}

export const subscriptionsService = {
  // 1. Pricing Plans
  getPlans: async (includeInactive = true): Promise<PricingPlan[]> => {
    const res = await apiClient.get<ApiResponse<PricingPlan[]>>('/plans', {
      params: { includeInactive },
    });
    const rawData = res.data;
    return Array.isArray(rawData)
      ? rawData
      : (rawData as ApiResponse<PricingPlan[]>).data || [];
  },

  getPlanById: async (id: string): Promise<PricingPlan> => {
    const res = await apiClient.get<ApiResponse<PricingPlan>>(`/plans/${id}`);
    const rawData = res.data;
    return (rawData as ApiResponse<PricingPlan>).data || (rawData as unknown as PricingPlan);
  },

  createPlan: async (payload: CreatePricingPlanPayload): Promise<PricingPlan> => {
    const res = await apiClient.post<ApiResponse<PricingPlan>>('/plans', payload);
    const rawData = res.data;
    return (rawData as ApiResponse<PricingPlan>).data || (rawData as unknown as PricingPlan);
  },

  updatePlan: async (id: string, payload: UpdatePricingPlanPayload): Promise<PricingPlan> => {
    const res = await apiClient.put<ApiResponse<PricingPlan>>(`/plans/${id}`, payload);
    const rawData = res.data;
    return (rawData as ApiResponse<PricingPlan>).data || (rawData as unknown as PricingPlan);
  },

  deletePlan: async (id: string): Promise<void> => {
    await apiClient.delete(`/plans/${id}`);
  },

  reorderPlans: async (planIds: string[]): Promise<boolean> => {
    const res = await apiClient.put<ApiResponse<boolean>>('/plans/reorder', { planIds });
    return res.data.success ?? true;
  },

  // 2. User Subscriptions
  getSubscriptions: async (status?: string, search?: string): Promise<UserSubscription[]> => {
    const res = await apiClient.get<ApiResponse<UserSubscription[]>>('/subscriptions', {
      params: { status, search },
    });
    const rawData = res.data;
    return Array.isArray(rawData)
      ? rawData
      : (rawData as ApiResponse<UserSubscription[]>).data || [];
  },

  getSubscriptionStats: async (): Promise<SubscriptionStats> => {
    const res = await apiClient.get<ApiResponse<SubscriptionStats>>('/subscriptions/stats');
    const rawData = res.data;
    return (
      (rawData as ApiResponse<SubscriptionStats>).data || {
        monthlyRecurringRevenue: 0,
        activePaidSubscribers: 0,
        expiredSubscribers: 0,
        totalSubscribers: 0,
        churnRatePercentage: 0,
      }
    );
  },

  // 3. Payment Logs
  getPayments: async (search?: string, status?: string): Promise<PaymentLog[]> => {
    const res = await apiClient.get<ApiResponse<PaymentLog[]>>('/subscriptions/payments', {
      params: { search, status },
    });
    const rawData = res.data;
    return Array.isArray(rawData)
      ? rawData
      : (rawData as ApiResponse<PaymentLog[]>).data || [];
  },

  // 4. Promo Codes
  getPromoCodes: async (): Promise<PromoCode[]> => {
    const res = await apiClient.get<ApiResponse<PromoCode[]>>('/subscriptions/promo-codes');
    const rawData = res.data;
    return Array.isArray(rawData)
      ? rawData
      : (rawData as ApiResponse<PromoCode[]>).data || [];
  },

  createPromoCode: async (payload: CreatePromoCodePayload): Promise<PromoCode> => {
    const res = await apiClient.post<ApiResponse<PromoCode>>('/subscriptions/promo-codes', payload);
    const rawData = res.data;
    return (rawData as ApiResponse<PromoCode>).data || (rawData as unknown as PromoCode);
  },

  togglePromoCode: async (id: string): Promise<PromoCode> => {
    const res = await apiClient.put<ApiResponse<PromoCode>>(
      `/subscriptions/promo-codes/${id}/toggle-status`
    );
    const rawData = res.data;
    return (rawData as ApiResponse<PromoCode>).data || (rawData as unknown as PromoCode);
  },

  deletePromoCode: async (id: string): Promise<void> => {
    await apiClient.delete(`/subscriptions/promo-codes/${id}`);
  },
};
