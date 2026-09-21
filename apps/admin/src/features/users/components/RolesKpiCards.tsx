import React from 'react';
import { ShieldCheck, Lock, Key, Users } from 'lucide-react';
import { Card } from '../../../core/components/ui/Card';
import type { RoleStats } from '../types';

interface RolesKpiCardsProps {
  stats: RoleStats;
  isLoading: boolean;
  isAr: boolean;
}

export const RolesKpiCards: React.FC<RolesKpiCardsProps> = ({
  stats,
  isLoading,
  isAr,
}) => {
  const systemPercentage =
    stats.totalRoles > 0
      ? Math.round((stats.systemRolesCount / stats.totalRoles) * 100)
      : 0;

  const customPercentage =
    stats.totalRoles > 0
      ? Math.round((stats.customRolesCount / stats.totalRoles) * 100)
      : 0;

  const cards = [
    {
      id: 'total',
      title: isAr ? 'إجمالي الرتب' : 'Total Roles',
      value: stats.totalRoles,
      badge: `${stats.totalPermissionsCount} ${isAr ? 'صلاحية معرفة' : 'permissions'}`,
      badgeColor: 'bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300',
      icon: <ShieldCheck className="h-5 w-5 text-blue-600 dark:text-blue-400" />,
      iconBg: 'bg-blue-50 dark:bg-blue-950/50',
    },
    {
      id: 'system',
      title: isAr ? 'رتب النظام الأساسية' : 'System Default Roles',
      value: stats.systemRolesCount,
      badge: `${systemPercentage}% ${isAr ? 'من الإجمالي' : 'of total'}`,
      badgeColor: 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-700 dark:text-emerald-400',
      icon: <Lock className="h-5 w-5 text-emerald-600 dark:text-emerald-400" />,
      iconBg: 'bg-emerald-50 dark:bg-emerald-950/50',
    },
    {
      id: 'custom',
      title: isAr ? 'الرتب المخصصة' : 'Custom Defined Roles',
      value: stats.customRolesCount,
      badge: `${customPercentage}% ${isAr ? 'مخصصة' : 'custom'}`,
      badgeColor: 'bg-purple-50 dark:bg-purple-950/60 text-purple-700 dark:text-purple-400',
      icon: <Key className="h-5 w-5 text-purple-600 dark:text-purple-400" />,
      iconBg: 'bg-purple-50 dark:bg-purple-950/50',
    },
    {
      id: 'assigned',
      title: isAr ? 'المشرفين المعينين' : 'Assigned Users & Admins',
      value: stats.assignedUsersCount,
      badge: isAr ? 'حساب نشط' : 'active accounts',
      badgeColor: 'bg-blue-50 dark:bg-blue-950/60 text-blue-700 dark:text-blue-400',
      icon: <Users className="h-5 w-5 text-zinc-700 dark:text-zinc-300" />,
      iconBg: 'bg-zinc-100 dark:bg-zinc-800',
    },
  ];

  if (isLoading) {
    return (
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <Card
            key={i}
            className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs space-y-3 animate-pulse"
          >
            <div className="flex items-center justify-between">
              <div className="h-3 w-20 bg-zinc-200 dark:bg-zinc-800 rounded-md" />
              <div className="h-8 w-8 bg-zinc-200 dark:bg-zinc-800 rounded-xl" />
            </div>
            <div className="h-7 w-12 bg-zinc-200 dark:bg-zinc-800 rounded-md" />
            <div className="h-4 w-16 bg-zinc-100 dark:bg-zinc-800/60 rounded-full" />
          </Card>
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
      {cards.map((card) => (
        <Card
          key={card.id}
          className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs hover:shadow-xs transition-shadow"
        >
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-zinc-500 dark:text-zinc-400">
              {card.title}
            </span>
            <div
              className={`flex h-9 w-9 items-center justify-center rounded-xl ${card.iconBg}`}
            >
              {card.icon}
            </div>
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <span className="text-2xl font-black text-zinc-950 dark:text-white font-mono">
              {card.value}
            </span>
            <span
              className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold ${card.badgeColor}`}
            >
              {card.badge}
            </span>
          </div>
        </Card>
      ))}
    </div>
  );
};
