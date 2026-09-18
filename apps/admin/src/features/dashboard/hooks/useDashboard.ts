import { useState, useEffect } from 'react';
import type { DashboardData } from '../types';
import { dashboardService } from '../services/dashboardService';

export const useDashboard = () => {
  const [data, setData] = useState<DashboardData | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  useEffect(() => {
    dashboardService.getDashboardData().then((res) => {
      setData(res);
      setIsLoading(false);
    });
  }, []);

  return {
    data,
    isLoading,
  };
};
