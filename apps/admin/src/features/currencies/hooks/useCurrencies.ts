import { useState, useEffect } from 'react';
import type { CurrencyItem } from '../types';
import { currenciesService } from '../services/currenciesService';

export const useCurrencies = () => {
  const [currencies, setCurrencies] = useState<CurrencyItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    currenciesService.getCurrencies().then((res) => {
      setCurrencies(res);
      setIsLoading(false);
    });
  }, []);

  const toggleActive = async (code: string) => {
    const updated = await currenciesService.toggleActive(code);
    setCurrencies((prev) => prev.map((c) => (c.code === code ? updated : c)));
  };

  return {
    currencies,
    toggleActive,
    isLoading,
  };
};
