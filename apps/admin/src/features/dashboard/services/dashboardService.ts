import type { DashboardData } from '../types';

const mockDashboardData: DashboardData = {
  kpis: [
    {
      title: 'Total Active Users',
      value: '1,420',
      change: '+14.2%',
      isPositive: true,
      iconName: 'users',
    },
    {
      title: 'Platform Volume',
      value: 'EGP 354,200',
      change: '+8.5%',
      isPositive: true,
      iconName: 'volume',
    },
    {
      title: 'Voice AI Requests',
      value: '4,890',
      change: '+28.4%',
      isPositive: true,
      iconName: 'ai',
    },
    {
      title: 'AI Parse Accuracy',
      value: '98.2%',
      change: '+1.1%',
      isPositive: true,
      iconName: 'accuracy',
    },
  ],
  volumeTrends: [
    { month: 'Jan', income: 45000, expense: 32000 },
    { month: 'Feb', income: 52000, expense: 38000 },
    { month: 'Mar', income: 61000, expense: 41000 },
    { month: 'Apr', income: 58000, expense: 39000 },
    { month: 'May', income: 72000, expense: 49000 },
    { month: 'Jun', income: 85000, expense: 56000 },
  ],
  categoryShares: [
    { name: 'Food & Dining', nameAr: 'طعام ومشروبات', value: 35, color: '#6366f1' },
    { name: 'Transport & Fuel', nameAr: 'مواصلات ووقود', value: 20, color: '#8b5cf6' },
    { name: 'Shopping', nameAr: 'تسوق', value: 18, color: '#ec4899' },
    { name: 'Bills & Utilities', nameAr: 'فواتير واشتراكات', value: 15, color: '#06b6d4' },
    { name: 'Health & Medical', nameAr: 'صحة وعلاج', value: 12, color: '#10b981' },
  ],
  recentTransactions: [
    {
      id: 'tx-1',
      userName: 'Ahmed Hassan',
      userEmail: 'ahmed@example.com',
      amount: 1450.0,
      type: 'Expense',
      category: 'Shopping',
      timeAgo: '5 mins ago',
    },
    {
      id: 'tx-2',
      userName: 'Sarah Mohamed',
      userEmail: 'sarah@example.com',
      amount: 8500.0,
      type: 'Income',
      category: 'Salary',
      timeAgo: '22 mins ago',
    },
    {
      id: 'tx-3',
      userName: 'Omar Khaled',
      userEmail: 'omar@example.com',
      amount: 320.0,
      type: 'Expense',
      category: 'Food & Dining',
      timeAgo: '1 hour ago',
    },
    {
      id: 'tx-4',
      userName: 'Nour Ali',
      userEmail: 'nour@example.com',
      amount: 1200.0,
      type: 'Expense',
      category: 'Bills & Utilities',
      timeAgo: '2 hours ago',
    },
  ],
};

export const dashboardService = {
  getDashboardData: async (): Promise<DashboardData> => {
    // Simulated async fetch
    return new Promise((resolve) => {
      setTimeout(() => resolve(mockDashboardData), 100);
    });
  },
};
