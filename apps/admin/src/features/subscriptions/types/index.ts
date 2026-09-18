export type PlanBillingCycle = 'Monthly' | 'Yearly' | 'Lifetime';
export type SubscriptionStatus = 'Active' | 'Expired' | 'Canceled' | 'Trial';
export type PaymentStatus = 'Success' | 'Failed' | 'Refunded' | 'Pending';

export interface PricingPlan {
  id: string;
  name: string;
  nameAr: string;
  priceEgp: number;
  billingCycle: PlanBillingCycle;
  description: string;
  features: string[];
  isPopular?: boolean;
  isActive: boolean;
  maxWallets: number; // e.g. 1 for Free, 999 for Pro
  maxAiRequestsPerMonth: number; // e.g. 10 for Free, unlimited for Pro
  canExportReports: boolean;
  canUseMultiCurrency: boolean;
}

export interface UserSubscription {
  id: string;
  userId: string;
  userName: string;
  userEmail: string;
  planId: string;
  planName: string;
  status: SubscriptionStatus;
  amountPaidEgp: number;
  gateway: 'Paymob' | 'Fawry' | 'Stripe' | 'ApplePay' | 'GooglePay';
  startDate: string;
  endDate: string;
  autoRenew: boolean;
}

export interface PaymentLog {
  id: string;
  invoiceNumber: string;
  userEmail: string;
  planName: string;
  amount: number;
  currency: string;
  gateway: 'Paymob' | 'Fawry' | 'Stripe' | 'ApplePay' | 'GooglePay';
  status: PaymentStatus;
  transactionRef: string;
  createdAt: string;
}

export interface PromoCode {
  id: string;
  code: string;
  discountPercentage: number;
  maxUses: number;
  usedCount: number;
  expiresAt: string;
  isActive: boolean;
}
