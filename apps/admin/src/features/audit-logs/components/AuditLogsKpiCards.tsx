import React from 'react';
import { Shield, Users, Lock, AlertTriangle } from 'lucide-react';
import { useLocale } from '../../../core/context/LocaleContext';
import { Card } from '../../../core/components/ui/Card';
import type { AuditLogStats } from '../types';

interface AuditLogsKpiCardsProps {
  stats: AuditLogStats;
  isLoading: boolean;
  hasLogs: boolean;
}

export const AuditLogsKpiCards: React.FC<AuditLogsKpiCardsProps> = ({
  stats,
  isLoading,
  hasLogs,
}) => {
  const { t } = useLocale();
  const showSkeleton = isLoading && !hasLogs;

  const userOpsPct =
    stats.totalLogs > 0
      ? Math.round((stats.userManagementCount / stats.totalLogs) * 100)
      : 0;
  const securityPct =
    stats.totalLogs > 0
      ? Math.round((stats.securityCount / stats.totalLogs) * 100)
      : 0;
  const warningsPct =
    stats.totalLogs > 0
      ? Math.round((stats.warningsAndFailuresCount / stats.totalLogs) * 100)
      : 0;

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-3.5 sm:gap-4">
      {/* 1. Total Events */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-zinc-100 dark:bg-zinc-800 text-zinc-900 dark:text-white">
          <Shield className="h-6 w-6 text-zinc-900 dark:text-zinc-200" />
        </div>
        <div>
          <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            {t.auditLogs.kpi.totalEvents}
          </p>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.totalLogs}
            </h3>
          )}
        </div>
      </Card>

      {/* 2. User Operations */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400">
          <Users className="h-6 w-6" />
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
              {t.auditLogs.kpi.userOps}
            </p>
            {showSkeleton ? (
              <div className="h-4 w-7 rounded-full bg-emerald-100 dark:bg-emerald-950/80 animate-pulse" />
            ) : (
              <span className="text-[10px] font-bold px-1.5 py-0.2 rounded-full bg-emerald-100 dark:bg-emerald-950/80 text-emerald-700 dark:text-emerald-300">
                {userOpsPct}%
              </span>
            )}
          </div>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.userManagementCount}
            </h3>
          )}
        </div>
      </Card>

      {/* 3. Security Events */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-purple-50 dark:bg-purple-950/40 text-purple-600 dark:text-purple-400">
          <Lock className="h-6 w-6" />
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
              {t.auditLogs.kpi.securityEvents}
            </p>
            {showSkeleton ? (
              <div className="h-4 w-7 rounded-full bg-purple-100 dark:bg-purple-950/80 animate-pulse" />
            ) : (
              <span className="text-[10px] font-bold px-1.5 py-0.2 rounded-full bg-purple-100 dark:bg-purple-950/80 text-purple-700 dark:text-purple-300">
                {securityPct}%
              </span>
            )}
          </div>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.securityCount}
            </h3>
          )}
        </div>
      </Card>

      {/* 4. Alerts & Warnings */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-amber-50 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400">
          <AlertTriangle className="h-6 w-6" />
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
              {t.auditLogs.kpi.alertsWarnings}
            </p>
            {showSkeleton ? (
              <div className="h-4 w-7 rounded-full bg-amber-100 dark:bg-amber-950/80 animate-pulse" />
            ) : (
              <span className="text-[10px] font-bold px-1.5 py-0.2 rounded-full bg-amber-100 dark:bg-amber-950/80 text-amber-700 dark:text-amber-300">
                {warningsPct}%
              </span>
            )}
          </div>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.warningsAndFailuresCount}
            </h3>
          )}
        </div>
      </Card>
    </div>
  );
};
