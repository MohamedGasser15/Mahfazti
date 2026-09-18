import React from 'react';
import { Users, CreditCard, Mic, Sparkles } from 'lucide-react';
import { Card } from '../../../core/components/ui/Card';
import type { DashboardKPI } from '../types';

export const StatCard: React.FC<{ kpi: DashboardKPI }> = ({ kpi }) => {
  const iconMap = {
    users: { icon: Users, color: 'bg-black text-white dark:bg-white dark:text-black' },
    volume: { icon: CreditCard, color: 'bg-emerald-600 text-white' },
    ai: { icon: Mic, color: 'bg-blue-600 text-white' },
    accuracy: { icon: Sparkles, color: 'bg-amber-500 text-black dark:text-white' },
  };

  const { icon: Icon, color } = iconMap[kpi.iconName];

  return (
    <Card className="flex items-center justify-between p-6">
      <div>
        <p className="text-xs font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
          {kpi.title}
        </p>
        <h3 className="mt-1.5 text-2xl md:text-3xl font-black tracking-tight text-black dark:text-white">
          {kpi.value}
        </h3>
        <div className="mt-2.5 flex items-center gap-2 text-xs font-bold">
          <span
            className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] ${
              kpi.isPositive
                ? 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-400'
                : 'bg-rose-50 text-rose-700 dark:bg-rose-950/40 dark:text-rose-400'
            }`}
          >
            {kpi.change}
          </span>
          <span className="text-zinc-400 font-medium">vs last month</span>
        </div>
      </div>
      <div className={`flex h-12 w-12 items-center justify-center rounded-2xl ${color} shadow-sm`}>
        <Icon className="h-6 w-6" />
      </div>
    </Card>
  );
};
