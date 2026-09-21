import React from 'react';
import { Users, UserCheck, UserX, ShieldCheck } from 'lucide-react';
import { useLocale } from '../../../core/context/LocaleContext';
import { Card } from '../../../core/components/ui/Card';

export interface UsersKpiStats {
  total: number;
  active: number;
  inactive: number;
  admins: number;
  verified: number;
  activePercentage: number;
}

interface UsersKpiCardsProps {
  stats: UsersKpiStats;
  isLoading: boolean;
  hasUsers: boolean;
}

export const UsersKpiCards: React.FC<UsersKpiCardsProps> = ({
  stats,
  isLoading,
  hasUsers,
}) => {
  const { t } = useLocale();
  const showSkeleton = isLoading && !hasUsers;

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-3.5 sm:gap-4">
      {/* Total Users */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-zinc-100 dark:bg-zinc-800 text-zinc-900 dark:text-white">
          <Users className="h-6 w-6 text-zinc-900 dark:text-zinc-200" />
        </div>
        <div>
          <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            {t.users.kpi.totalAccounts}
          </p>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.total}
            </h3>
          )}
        </div>
      </Card>

      {/* Active Accounts */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400">
          <UserCheck className="h-6 w-6" />
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
              {t.users.kpi.activeUsers}
            </p>
            {showSkeleton ? (
              <div className="h-4 w-7 rounded-full bg-emerald-100 dark:bg-emerald-950/80 animate-pulse" />
            ) : (
              <span className="text-[10px] font-bold px-1.5 py-0.2 rounded-full bg-emerald-100 dark:bg-emerald-950/80 text-emerald-700 dark:text-emerald-300">
                {stats.activePercentage}%
              </span>
            )}
          </div>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.active}
            </h3>
          )}
        </div>
      </Card>

      {/* Inactive / Suspended */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-rose-50 dark:bg-rose-950/40 text-rose-600 dark:text-rose-400">
          <UserX className="h-6 w-6" />
        </div>
        <div>
          <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            {t.users.kpi.suspended}
          </p>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.inactive}
            </h3>
          )}
        </div>
      </Card>

      {/* Admins & Staff */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-purple-50 dark:bg-purple-950/40 text-purple-600 dark:text-purple-400">
          <ShieldCheck className="h-6 w-6" />
        </div>
        <div>
          <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            {t.users.kpi.adminsStaff}
          </p>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.admins}
            </h3>
          )}
        </div>
      </Card>
    </div>
  );
};
