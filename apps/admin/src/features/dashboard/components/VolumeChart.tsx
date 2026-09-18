import React from 'react';
import { TrendingUp } from 'lucide-react';
import { Card } from '../../../core/components/ui/Card';
import { useTheme } from '../../../core/context/ThemeContext';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import type { VolumeTrendPoint } from '../types';

export const VolumeChart: React.FC<{ data: VolumeTrendPoint[] }> = ({ data }) => {
  const { theme } = useTheme();
  const isDark = theme === 'dark';

  return (
    <Card className="p-5">
      <div className="mb-4 flex items-center justify-between">
        <div>
          <h3 className="text-base font-bold text-slate-900 dark:text-slate-100">Financial Volume Growth</h3>
          <p className="text-xs text-slate-500 dark:text-slate-400">Monthly breakdown of recorded income vs expenses</p>
        </div>
        <TrendingUp className="h-5 w-5 text-blue-600 dark:text-blue-400" />
      </div>

      <div className="h-72 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
            <defs>
              <linearGradient id="incomeColor" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#00c853" stopOpacity={0.4} />
                <stop offset="95%" stopColor="#00c853" stopOpacity={0.0} />
              </linearGradient>
              <linearGradient id="expenseColor" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#2962ff" stopOpacity={0.4} />
                <stop offset="95%" stopColor="#2962ff" stopOpacity={0.0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke={isDark ? '#1e293b' : '#f1f5f9'} />
            <XAxis dataKey="month" stroke={isDark ? '#64748b' : '#94a3b8'} fontSize={12} tickLine={false} />
            <YAxis stroke={isDark ? '#64748b' : '#94a3b8'} fontSize={12} tickLine={false} />
            <Tooltip
              contentStyle={{
                backgroundColor: isDark ? '#0f172a' : '#ffffff',
                borderColor: isDark ? '#334155' : '#e2e8f0',
                borderRadius: '12px',
                fontSize: '12px',
                color: isDark ? '#f8fafc' : '#0f172a',
                boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
              }}
            />
            <Area
              type="monotone"
              dataKey="income"
              stroke="#00c853"
              strokeWidth={2.5}
              fillOpacity={1}
              fill="url(#incomeColor)"
              name="Income (EGP)"
            />
            <Area
              type="monotone"
              dataKey="expense"
              stroke="#2962ff"
              strokeWidth={2.5}
              fillOpacity={1}
              fill="url(#expenseColor)"
              name="Expense (EGP)"
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </Card>
  );
};
