export interface DashboardKPI {
  title: string;
  value: string;
  change: string;
  isPositive: boolean;
  iconName: 'users' | 'volume' | 'ai' | 'accuracy';
}

export interface VolumeTrendPoint {
  month: string;
  income: number;
  expense: number;
}

export interface CategoryShare {
  name: string;
  nameAr: string;
  value: number;
  color: string;
}

export interface QuickTransaction {
  id: string;
  userName: string;
  userEmail: string;
  amount: number;
  type: 'Income' | 'Expense';
  category: string;
  timeAgo: string;
}

export interface DashboardData {
  kpis: DashboardKPI[];
  volumeTrends: VolumeTrendPoint[];
  categoryShares: CategoryShare[];
  recentTransactions: QuickTransaction[];
}
