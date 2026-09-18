import React from 'react';
import { useDashboard } from '../hooks/useDashboard';
import { StatCard } from '../components/StatCard';
import { VolumeChart } from '../components/VolumeChart';
import { CategoryDistribution } from '../components/CategoryDistribution';
import { RecentTransactionsTable } from '../components/RecentTransactionsTable';

export const DashboardPage: React.FC = () => {
  const { data, isLoading } = useDashboard();

  if (isLoading || !data) {
    return (
      <div className="flex h-64 items-center justify-center text-slate-400">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-blue-600 border-t-transparent" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Top Banner */}
      <div className="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">System Overview</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400">
            Real-time insights on users, financial volume, and AI services.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="flex items-center gap-1.5 rounded-full border border-emerald-500/30 bg-emerald-50 dark:bg-emerald-500/10 px-3 py-1 text-xs font-semibold text-emerald-700 dark:text-emerald-400">
            <span className="h-2 w-2 rounded-full bg-emerald-500 animate-ping" />
            Mock Engine Active
          </span>
        </div>
      </div>

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {data.kpis.map((kpi, idx) => (
          <StatCard key={idx} kpi={kpi} />
        ))}
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2">
          <VolumeChart data={data.volumeTrends} />
        </div>
        <div>
          <CategoryDistribution data={data.categoryShares} />
        </div>
      </div>

      {/* Recent Activity Table */}
      <RecentTransactionsTable transactions={data.recentTransactions} />
    </div>
  );
};
