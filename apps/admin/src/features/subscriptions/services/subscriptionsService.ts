import type {
  PricingPlan,
  UserSubscription,
  PaymentLog,
  PromoCode,
} from '../types';

let mockPlans: PricingPlan[] = [
  {
    id: 'plan-free',
    name: 'Free Basic',
    nameAr: 'الباقة المجانية',
    priceEgp: 0,
    billingCycle: 'Monthly',
    description: 'Essential features for personal budget tracking',
    features: [
      '1 Cash Wallet',
      '15 AI Voice Expenses / Month',
      'Basic Categories',
      'Standard Analytics',
    ],
    isActive: true,
    maxWallets: 1,
    maxAiRequestsPerMonth: 15,
    canExportReports: false,
    canUseMultiCurrency: false,
  },
  {
    id: 'plan-pro-monthly',
    name: 'Mahfazti Pro (Monthly)',
    nameAr: 'باقة المحترفين (شهري)',
    priceEgp: 89,
    billingCycle: 'Monthly',
    description: 'For power users needing multiple wallets & unlimited AI',
    features: [
      'Unlimited Multi-Wallets & Banks',
      'Unlimited Voice AI Recognition',
      'Export PDF & Excel Reports',
      'Multi-Currency Exchange Sync',
      'Priority Customer Support',
    ],
    isPopular: true,
    isActive: true,
    maxWallets: 999,
    maxAiRequestsPerMonth: 999999,
    canExportReports: true,
    canUseMultiCurrency: true,
  },
  {
    id: 'plan-pro-yearly',
    name: 'Mahfazti Pro (Annual)',
    nameAr: 'باقة المحترفين (سنوي - وفر 35%)',
    priceEgp: 699,
    billingCycle: 'Yearly',
    description: 'Best value for year-round financial freedom',
    features: [
      'All Monthly Pro Features Included',
      '2 Months Free (Save 35%)',
      'Early access to new AI models',
      'Family sharing (up to 3 members)',
    ],
    isActive: true,
    maxWallets: 999,
    maxAiRequestsPerMonth: 999999,
    canExportReports: true,
    canUseMultiCurrency: true,
  },
];

let mockSubscriptions: UserSubscription[] = [
  {
    id: 'sub-1',
    userId: 'u-1',
    userName: 'Ahmed Hassan',
    userEmail: 'ahmed@example.com',
    planId: 'plan-pro-yearly',
    planName: 'Mahfazti Pro (Annual)',
    status: 'Active',
    amountPaidEgp: 699,
    gateway: 'Paymob',
    startDate: '2026-08-01T00:00:00Z',
    endDate: '2027-08-01T00:00:00Z',
    autoRenew: true,
  },
  {
    id: 'sub-2',
    userId: 'u-2',
    userName: 'Sarah Mohamed',
    userEmail: 'sarah@example.com',
    planId: 'plan-pro-monthly',
    planName: 'Mahfazti Pro (Monthly)',
    status: 'Active',
    amountPaidEgp: 89,
    gateway: 'ApplePay',
    startDate: '2026-09-01T00:00:00Z',
    endDate: '2026-10-01T00:00:00Z',
    autoRenew: true,
  },
  {
    id: 'sub-3',
    userId: 'u-3',
    userName: 'Omar Khaled',
    userEmail: 'omar@example.com',
    planId: 'plan-pro-monthly',
    planName: 'Mahfazti Pro (Monthly)',
    status: 'Expired',
    amountPaidEgp: 89,
    gateway: 'Fawry',
    startDate: '2026-07-15T00:00:00Z',
    endDate: '2026-08-15T00:00:00Z',
    autoRenew: false,
  },
];

let mockPayments: PaymentLog[] = [
  {
    id: 'pay-1',
    invoiceNumber: 'INV-2026-0089',
    userEmail: 'sarah@example.com',
    planName: 'Mahfazti Pro (Monthly)',
    amount: 89,
    currency: 'EGP',
    gateway: 'ApplePay',
    status: 'Success',
    transactionRef: 'APL_948192841',
    createdAt: '2026-09-01T12:30:00Z',
  },
  {
    id: 'pay-2',
    invoiceNumber: 'INV-2026-0088',
    userEmail: 'ahmed@example.com',
    planName: 'Mahfazti Pro (Annual)',
    amount: 699,
    currency: 'EGP',
    gateway: 'Paymob',
    status: 'Success',
    transactionRef: 'PMB_817294012',
    createdAt: '2026-08-01T10:15:00Z',
  },
  {
    id: 'pay-3',
    invoiceNumber: 'INV-2026-0087',
    userEmail: 'karim@example.com',
    planName: 'Mahfazti Pro (Monthly)',
    amount: 89,
    currency: 'EGP',
    gateway: 'Fawry',
    status: 'Failed',
    transactionRef: 'FWR_109283120',
    createdAt: '2026-09-17T18:40:00Z',
  },
];

let mockPromoCodes: PromoCode[] = [
  {
    id: 'promo-1',
    code: 'LAUNCH50',
    discountPercentage: 50,
    maxUses: 100,
    usedCount: 42,
    expiresAt: '2026-12-31T23:59:59Z',
    isActive: true,
  },
  {
    id: 'promo-2',
    code: 'MAHFAZTI2026',
    discountPercentage: 25,
    maxUses: 500,
    usedCount: 118,
    expiresAt: '2026-10-30T23:59:59Z',
    isActive: true,
  },
];

export const subscriptionsService = {
  getPlans: async (): Promise<PricingPlan[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockPlans]), 100));
  },
  getSubscriptions: async (): Promise<UserSubscription[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockSubscriptions]), 100));
  },
  getPayments: async (): Promise<PaymentLog[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockPayments]), 100));
  },
  getPromoCodes: async (): Promise<PromoCode[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockPromoCodes]), 100));
  },
};
