import React from 'react';
import { useLocale } from '../../../core/context/LocaleContext';
import { Card } from '../../../core/components/ui/Card';

export interface AuditLogsCardsSkeletonProps {
  count?: number;
}

export const AuditLogsCardsSkeleton: React.FC<AuditLogsCardsSkeletonProps> = ({
  count = 8,
}) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      {Array.from({ length: count }).map((_, i) => (
        <Card
          key={i}
          className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800 flex flex-col justify-between space-y-4 shadow-2xs animate-pulse"
        >
          {/* Header: Action Icon + Status Badge */}
          <div className="flex items-start justify-between gap-3">
            <div className="h-11 w-11 rounded-2xl bg-zinc-200 dark:bg-zinc-800 shrink-0" />
            <div className="flex items-center gap-1.5">
              <div className="h-5 w-16 rounded-full bg-zinc-200 dark:bg-zinc-800" />
            </div>
          </div>

          {/* Action Title + Target Resource */}
          <div className="space-y-2 pt-1">
            <div
              className="h-4 rounded-md bg-zinc-200 dark:bg-zinc-800"
              style={{ width: `${75 + (i % 3) * 10}%` }}
            />
            <div
              className="h-3 rounded-md bg-zinc-200/70 dark:bg-zinc-800/60"
              style={{ width: `${55 + (i % 4) * 10}%` }}
            />
          </div>

          {/* Admin Info */}
          <div className="space-y-1.5 pt-1">
            <div className="h-3 w-28 rounded-md bg-zinc-200 dark:bg-zinc-800" />
            <div className="h-2.5 w-36 rounded-md bg-zinc-200/70 dark:bg-zinc-800/60" />
          </div>

          {/* Footer: Date & Details Button */}
          <div className="pt-2 border-t border-zinc-100 dark:border-zinc-800/80 flex justify-between items-center">
            <div className="h-3.5 w-24 rounded bg-zinc-200 dark:bg-zinc-800" />
            <div className="h-7 w-16 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
          </div>
        </Card>
      ))}
    </div>
  );
};

export interface AuditLogsTableSkeletonProps {
  count?: number;
}

export const AuditLogsTableSkeleton: React.FC<AuditLogsTableSkeletonProps> = ({
  count = 8,
}) => {
  const { t } = useLocale();

  return (
    <Card className="p-0 overflow-hidden bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs min-h-[380px]">
      <div className="overflow-x-auto">
        <table className="w-full text-left rtl:text-right text-xs">
          <thead className="border-b border-zinc-200 dark:border-zinc-800 bg-zinc-50/80 dark:bg-zinc-900/50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            <tr>
              <th className="py-3.5 px-6">{t.auditLogs.table.action}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.targetResource}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.category}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.admin}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.ipAddress}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.status}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.timestamp}</th>
              <th className="py-3.5 px-6 text-center">{t.auditLogs.table.details}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-zinc-200/70 dark:divide-zinc-800/60">
            {Array.from({ length: count }).map((_, i) => (
              <tr key={i} className="animate-pulse">
                {/* Action */}
                <td className="py-3.5 px-6">
                  <div className="flex items-center gap-2.5">
                    <div className="h-8 w-8 rounded-xl bg-zinc-200 dark:bg-zinc-800 shrink-0" />
                    <div
                      className="h-4 rounded-md bg-zinc-200 dark:bg-zinc-800"
                      style={{ width: `${110 + (i % 4) * 20}px` }}
                    />
                  </div>
                </td>

                {/* Target Resource */}
                <td className="py-3.5 px-6">
                  <div
                    className="h-3.5 rounded-md bg-zinc-200 dark:bg-zinc-800"
                    style={{ width: `${130 + (i % 3) * 25}px` }}
                  />
                </td>

                {/* Category */}
                <td className="py-3.5 px-6">
                  <div className="h-5 w-24 rounded-full bg-zinc-200 dark:bg-zinc-800" />
                </td>

                {/* Admin info */}
                <td className="py-3.5 px-6">
                  <div className="space-y-1">
                    <div className="h-3.5 w-24 rounded-md bg-zinc-200 dark:bg-zinc-800" />
                    <div className="h-2.5 w-32 rounded-md bg-zinc-200/70 dark:bg-zinc-800/60" />
                  </div>
                </td>

                {/* IP Address */}
                <td className="py-3.5 px-6">
                  <div className="h-3.5 w-20 rounded bg-zinc-200 dark:bg-zinc-800 font-mono" />
                </td>

                {/* Status */}
                <td className="py-3.5 px-6">
                  <div className="h-5 w-16 rounded-full bg-zinc-200 dark:bg-zinc-800" />
                </td>

                {/* Timestamp */}
                <td className="py-3.5 px-6">
                  <div className="h-3.5 w-24 rounded bg-zinc-200 dark:bg-zinc-800" />
                </td>

                {/* View button */}
                <td className="py-3.5 px-6 text-center">
                  <div className="h-8 w-8 rounded-xl bg-zinc-200 dark:bg-zinc-800 mx-auto" />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  );
};

export interface AuditLogsSkeletonProps {
  count?: number;
  viewMode?: 'table' | 'cards';
}

export const AuditLogsSkeleton: React.FC<AuditLogsSkeletonProps> = ({
  count = 8,
  viewMode = 'table',
}) => {
  if (viewMode === 'cards') {
    return <AuditLogsCardsSkeleton count={count} />;
  }

  return (
    <>
      <div className="hidden lg:block">
        <AuditLogsTableSkeleton count={count} />
      </div>
      <div className="lg:hidden">
        <AuditLogsCardsSkeleton count={count} />
      </div>
    </>
  );
};
