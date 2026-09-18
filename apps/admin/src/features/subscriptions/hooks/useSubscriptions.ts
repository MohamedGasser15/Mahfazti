import { useState, useEffect } from 'react';
import type {
  PricingPlan,
  UserSubscription,
  PaymentLog,
  PromoCode,
} from '../types';
import { subscriptionsService } from '../services/subscriptionsService';

export const useSubscriptions = () => {
  const [plans, setPlans] = useState<PricingPlan[]>([]);
  const [subscriptions, setSubscriptions] = useState<UserSubscription[]>([]);
  const [payments, setPayments] = useState<PaymentLog[]>([]);
  const [promoCodes, setPromoCodes] = useState<PromoCode[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      subscriptionsService.getPlans(),
      subscriptionsService.getSubscriptions(),
      subscriptionsService.getPayments(),
      subscriptionsService.getPromoCodes(),
    ]).then(([p, s, pay, pr]) => {
      setPlans(p);
      setSubscriptions(s);
      setPayments(pay);
      setPromoCodes(pr);
      setIsLoading(false);
    });
  }, []);

  return {
    plans,
    subscriptions,
    payments,
    promoCodes,
    isLoading,
  };
};
