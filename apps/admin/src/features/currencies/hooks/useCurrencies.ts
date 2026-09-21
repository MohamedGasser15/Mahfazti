import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { currenciesService } from '../services/currenciesService';

export const CURRENCIES_QUERY_KEY = ['currencies'];

export const useCurrencies = () => {
  const queryClient = useQueryClient();

  // Fetch all currencies
  const {
    data: currencies = [],
    isLoading,
    isRefetching,
    error,
    refetch,
  } = useQuery({
    queryKey: CURRENCIES_QUERY_KEY,
    queryFn: () => currenciesService.getCurrencies(),
  });

  // Sync Live Rates Mutation
  const syncLiveRatesMutation = useMutation({
    mutationFn: () => currenciesService.syncLiveRates(),
    onSuccess: (data) => {
      queryClient.setQueryData(CURRENCIES_QUERY_KEY, data.items);
      toast.success(data.message || 'Live exchange rates synced successfully!');
    },
    onError: (err: any) => {
      const msg = err.response?.data?.message || err.message || 'Failed to sync live rates.';
      toast.error(msg);
    },
  });

  // Toggle Active Status Mutation
  const toggleActiveMutation = useMutation({
    mutationFn: (code: string) => currenciesService.toggleActive(code),
    onSuccess: (updated) => {
      queryClient.setQueryData(CURRENCIES_QUERY_KEY, (old: any[] = []) =>
        old.map((c) => (c.code === updated.code ? updated : c))
      );
      toast.success(
        updated.isActive
          ? `${updated.code} has been enabled.`
          : `${updated.code} has been disabled.`
      );
    },
    onError: (err: any) => {
      const msg = err.response?.data?.message || err.message || 'Failed to update status.';
      toast.error(msg);
    },
  });

  // Toggle Featured Mutation
  const toggleFeaturedMutation = useMutation({
    mutationFn: (code: string) => currenciesService.toggleFeatured(code),
    onSuccess: (updated) => {
      queryClient.setQueryData(CURRENCIES_QUERY_KEY, (old: any[] = []) =>
        old.map((c) => (c.code === updated.code ? updated : c))
      );
      toast.success(
        updated.isFeatured
          ? `${updated.code} marked as featured.`
          : `${updated.code} removed from featured.`
      );
    },
    onError: (err: any) => {
      const msg = err.response?.data?.message || err.message || 'Failed to update featured status.';
      toast.error(msg);
    },
  });

  // Set Base Currency Mutation
  const setBaseCurrencyMutation = useMutation({
    mutationFn: (code: string) => currenciesService.setBaseCurrency(code),
    onSuccess: (target) => {
      queryClient.setQueryData(CURRENCIES_QUERY_KEY, (old: any[] = []) =>
        old.map((c) => ({
          ...c,
          isDefault: c.code === target.code,
          isActive: c.code === target.code ? true : c.isActive,
        }))
      );
      toast.success(`Base currency switched to ${target.code}.`);
    },
    onError: (err: any) => {
      const msg = err.response?.data?.message || err.message || 'Failed to change base currency.';
      toast.error(msg);
    },
  });

  return {
    currencies,
    isLoading,
    isRefetching,
    error,
    refetch,
    syncLiveRates: syncLiveRatesMutation.mutateAsync,
    isSyncing: syncLiveRatesMutation.isPending,
    toggleActive: toggleActiveMutation.mutateAsync,
    isToggling: toggleActiveMutation.isPending,
    toggleFeatured: toggleFeaturedMutation.mutateAsync,
    isTogglingFeatured: toggleFeaturedMutation.isPending,
    setBaseCurrency: setBaseCurrencyMutation.mutateAsync,
    isSettingBase: setBaseCurrencyMutation.isPending,
  };
};
