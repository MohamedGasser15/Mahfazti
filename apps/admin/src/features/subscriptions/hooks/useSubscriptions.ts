import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { subscriptionsService } from '../services/subscriptionsService';
import type {
  CreatePricingPlanPayload,
  UpdatePricingPlanPayload,
  CreatePromoCodePayload,
  PricingPlan,
  PromoCode,
} from '../types';

export const PLANS_QUERY_KEY = ['pricing-plans'];
export const SUBSCRIPTIONS_QUERY_KEY = ['user-subscriptions'];
export const SUBSCRIPTION_STATS_KEY = ['subscription-stats'];
export const PAYMENTS_QUERY_KEY = ['payment-logs'];
export const PROMO_CODES_QUERY_KEY = ['promo-codes'];

export const useSubscriptions = (subscriptionFilters?: { status?: string; search?: string }) => {
  const queryClient = useQueryClient();

  // 1. Fetch Plans
  const {
    data: plans = [],
    isLoading: isLoadingPlans,
    refetch: refetchPlans,
  } = useQuery({
    queryKey: PLANS_QUERY_KEY,
    queryFn: () => subscriptionsService.getPlans(),
  });

  // 2. Fetch User Subscriptions
  const {
    data: subscriptions = [],
    isLoading: isLoadingSubscriptions,
    refetch: refetchSubscriptions,
  } = useQuery({
    queryKey: [SUBSCRIPTIONS_QUERY_KEY, subscriptionFilters?.status, subscriptionFilters?.search],
    queryFn: () =>
      subscriptionsService.getSubscriptions(
        subscriptionFilters?.status,
        subscriptionFilters?.search
      ),
  });

  // 3. Fetch Subscription Stats
  const { data: stats, isLoading: isLoadingStats } = useQuery({
    queryKey: SUBSCRIPTION_STATS_KEY,
    queryFn: () => subscriptionsService.getSubscriptionStats(),
  });

  // 4. Fetch Payments
  const {
    data: payments = [],
    isLoading: isLoadingPayments,
    refetch: refetchPayments,
  } = useQuery({
    queryKey: PAYMENTS_QUERY_KEY,
    queryFn: () => subscriptionsService.getPayments(),
  });

  // 5. Fetch Promo Codes
  const {
    data: promoCodes = [],
    isLoading: isLoadingPromoCodes,
    refetch: refetchPromoCodes,
  } = useQuery({
    queryKey: PROMO_CODES_QUERY_KEY,
    queryFn: () => subscriptionsService.getPromoCodes(),
  });

  // Plan Mutations
  const createPlanMutation = useMutation({
    mutationFn: (payload: CreatePricingPlanPayload) => subscriptionsService.createPlan(payload),
    onSuccess: (created) => {
      queryClient.setQueryData<PricingPlan[]>(PLANS_QUERY_KEY, (old = []) => [...old, created]);
      toast.success(`Plan "${created.name}" created successfully.`);
    },
    onError: (err: any) => {
      const msg = err.response?.data?.message || err.message || 'Failed to create plan.';
      toast.error(msg);
    },
  });

  const updatePlanMutation = useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: UpdatePricingPlanPayload }) =>
      subscriptionsService.updatePlan(id, payload),
    onSuccess: (updated) => {
      queryClient.setQueryData<PricingPlan[]>(PLANS_QUERY_KEY, (old = []) =>
        old.map((p) => (p.id === updated.id ? updated : p))
      );
      toast.success(`Plan "${updated.name}" updated successfully.`);
    },
    onError: (err: any) => {
      const msg = err.response?.data?.message || err.message || 'Failed to update plan.';
      toast.error(msg);
    },
  });

  const deletePlanMutation = useMutation({
    mutationFn: (id: string) => subscriptionsService.deletePlan(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PLANS_QUERY_KEY });
      toast.success('Pricing plan deleted/archived.');
    },
    onError: (err: any) => {
      const msg = err.response?.data?.message || err.message || 'Failed to delete plan.';
      toast.error(msg);
    },
  });

  const reorderPlansMutation = useMutation({
    mutationFn: (planIds: string[]) => subscriptionsService.reorderPlans(planIds),
    onMutate: async (newPlanIds: string[]) => {
      await queryClient.cancelQueries({ queryKey: PLANS_QUERY_KEY });
      const previousPlans = queryClient.getQueryData<PricingPlan[]>(PLANS_QUERY_KEY) || [];
      const planMap = new Map(previousPlans.map((p) => [p.id, p]));
      const reordered = newPlanIds
        .map((id, index) => {
          const item = planMap.get(id);
          return item ? { ...item, displayOrder: index } : null;
        })
        .filter(Boolean) as PricingPlan[];
      queryClient.setQueryData(PLANS_QUERY_KEY, reordered);
      return { previousPlans };
    },
    onError: (err: any, _vars, context) => {
      if (context?.previousPlans) {
        queryClient.setQueryData(PLANS_QUERY_KEY, context.previousPlans);
      }
      const msg = err.response?.data?.message || err.message || 'Failed to reorder plans.';
      toast.error(msg);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: PLANS_QUERY_KEY });
    },
  });

  // Promo Code Mutations
  const createPromoCodeMutation = useMutation({
    mutationFn: (payload: CreatePromoCodePayload) => subscriptionsService.createPromoCode(payload),
    onSuccess: (created) => {
      queryClient.setQueryData<PromoCode[]>(PROMO_CODES_QUERY_KEY, (old = []) => [created, ...old]);
      toast.success(`Promo code "${created.code}" created successfully.`);
    },
    onError: (err: any) => {
      const msg = err.response?.data?.message || err.message || 'Failed to create promo code.';
      toast.error(msg);
    },
  });

  const togglePromoCodeMutation = useMutation({
    mutationFn: (id: string) => subscriptionsService.togglePromoCode(id),
    onSuccess: (updated) => {
      queryClient.setQueryData<PromoCode[]>(PROMO_CODES_QUERY_KEY, (old = []) =>
        old.map((p) => (p.id === updated.id ? updated : p))
      );
      toast.success(
        updated.isActive
          ? `Promo code ${updated.code} is now active.`
          : `Promo code ${updated.code} is now deactivated.`
      );
    },
    onError: (err: any) => {
      const msg = err.response?.data?.message || err.message || 'Failed to update promo code.';
      toast.error(msg);
    },
  });

  const deletePromoCodeMutation = useMutation({
    mutationFn: (id: string) => subscriptionsService.deletePromoCode(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PROMO_CODES_QUERY_KEY });
      toast.success('Promo code deleted.');
    },
    onError: (err: any) => {
      const msg = err.response?.data?.message || err.message || 'Failed to delete promo code.';
      toast.error(msg);
    },
  });

  return {
    // Data
    plans,
    subscriptions,
    stats,
    payments,
    promoCodes,

    // Loading states
    isLoading:
      isLoadingPlans ||
      isLoadingSubscriptions ||
      isLoadingStats ||
      isLoadingPayments ||
      isLoadingPromoCodes,
    isLoadingPlans,
    isLoadingSubscriptions,
    isLoadingStats,
    isLoadingPayments,
    isLoadingPromoCodes,

    // Refetches
    refetchPlans,
    refetchSubscriptions,
    refetchPayments,
    refetchPromoCodes,

    // Plan Actions
    createPlan: createPlanMutation.mutateAsync,
    isCreatingPlan: createPlanMutation.isPending,
    updatePlan: updatePlanMutation.mutateAsync,
    isUpdatingPlan: updatePlanMutation.isPending,
    deletePlan: deletePlanMutation.mutateAsync,
    isDeletingPlan: deletePlanMutation.isPending,
    reorderPlans: reorderPlansMutation.mutateAsync,
    isReorderingPlans: reorderPlansMutation.isPending,

    // Promo Code Actions
    createPromoCode: createPromoCodeMutation.mutateAsync,
    isCreatingPromoCode: createPromoCodeMutation.isPending,
    togglePromoCode: togglePromoCodeMutation.mutateAsync,
    isTogglingPromoCode: togglePromoCodeMutation.isPending,
    deletePromoCode: deletePromoCodeMutation.mutateAsync,
    isDeletingPromoCode: deletePromoCodeMutation.isPending,
  };
};
