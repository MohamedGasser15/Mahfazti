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
  descriptionAr?: string;
  features: string[];
  featuresAr?: string[];
  isPopular?: boolean;
  isActive: boolean;
  displayOrder?: number;
  maxWallets: number;
  maxAiRequestsPerMonth: number;
  canExportReports: boolean;
  canUseMultiCurrency: boolean;
}

export interface CreatePricingPlanPayload {
  id?: string;
  name: string;
  nameAr: string;
  priceEgp: number;
  billingCycle: PlanBillingCycle;
  description: string;
  descriptionAr?: string;
  features: string[];
  featuresAr?: string[];
  isPopular?: boolean;
  isActive?: boolean;
  displayOrder?: number;
  maxWallets: number;
  maxAiRequestsPerMonth: number;
  canExportReports: boolean;
  canUseMultiCurrency: boolean;
}

export interface UpdatePricingPlanPayload {
  name: string;
  nameAr: string;
  priceEgp: number;
  billingCycle: PlanBillingCycle;
  description: string;
  descriptionAr?: string;
  features: string[];
  featuresAr?: string[];
  isPopular?: boolean;
  isActive: boolean;
  displayOrder?: number;
  maxWallets: number;
  maxAiRequestsPerMonth: number;
  canExportReports: boolean;
  canUseMultiCurrency: boolean;
}

export interface ReorderPricingPlansPayload {
  planIds: string[];
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
  gateway: 'Paymob' | 'Fawry' | 'Stripe' | 'ApplePay' | 'GooglePay' | string;
  startDate: string;
  endDate: string;
  autoRenew: boolean;
}

export interface SubscriptionStats {
  monthlyRecurringRevenue: number;
  activePaidSubscribers: number;
  expiredSubscribers: number;
  totalSubscribers: number;
  churnRatePercentage: number;
}

export interface PaymentLog {
  id: string;
  invoiceNumber: string;
  userEmail: string;
  planName: string;
  amount: number;
  currency: string;
  gateway: 'Paymob' | 'Fawry' | 'Stripe' | 'ApplePay' | 'GooglePay' | string;
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
  expiresAt?: string;
  isActive: boolean;
  createdAt: string;
}

export interface CreatePromoCodePayload {
  code: string;
  discountPercentage: number;
  maxUses: number;
  expiresAt?: string;
  isActive?: boolean;
}
