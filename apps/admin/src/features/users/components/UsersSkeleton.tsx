import React from 'react';
import { useLocale } from '../../../core/context/LocaleContext';
import { Card } from '../../../core/components/ui/Card';

interface UsersTableSkeletonProps {
  count?: number;
}

export const UsersTableSkeleton: React.FC<UsersTableSkeletonProps> = ({
  count = 8,
}) => {
  const { t } = useLocale();

  return (
    <Card className="p-0 overflow-hidden bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs min-h-[380px]">
      <div className="overflow-x-auto">
        <table className="w-full text-left rtl:text-right text-xs">
          <thead className="border-b border-zinc-200 dark:border-zinc-800 bg-zinc-50/80 dark:bg-zinc-900/50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            <tr>
              <th className="py-3.5 px-4 w-10 text-center">
                <div className="h-4 w-4 rounded-md bg-zinc-200 dark:bg-zinc-800 mx-auto" />
              </th>
              <th className="py-3.5 px-4">{t.users.table.user}</th>
              <th className="py-3.5 px-4">{t.users.table.role}</th>
              <th className="py-3.5 px-4">{t.users.table.currencyWallets}</th>
              <th className="py-3.5 px-4">{t.users.table.emailStatus}</th>
              <th className="py-3.5 px-4">{t.users.table.status}</th>
              <th className="py-3.5 px-4">{t.users.table.joined}</th>
              <th className="py-3.5 px-4 text-center">{t.users.table.actions}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-zinc-200/70 dark:divide-zinc-800/60">
            {Array.from({ length: count }).map((_, i) => (
              <tr key={i} className="animate-pulse">
                {/* Checkbox */}
                <td className="py-3.5 px-4 text-center">
                  <div className="h-4 w-4 rounded-md bg-zinc-200 dark:bg-zinc-800 mx-auto" />
                </td>

                {/* User Avatar & Info */}
                <td className="py-3.5 px-4">
                  <div className="flex items-center gap-3">
                    <div className="h-9 w-9 shrink-0 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
                    <div className="space-y-1.5">
                      <div
                        className="h-3.5 rounded-md bg-zinc-200 dark:bg-zinc-800"
                        style={{ width: `${90 + (i % 4) * 25}px` }}
                      />
                      <div
                        className="h-2.5 rounded-md bg-zinc-200/70 dark:bg-zinc-800/60"
                        style={{ width: `${120 + (i % 3) * 30}px` }}
                      />
                    </div>
                  </div>
                </td>

                {/* Role badge */}
                <td className="py-3.5 px-4">
                  <div className="h-5 w-16 rounded-full bg-zinc-200 dark:bg-zinc-800" />
                </td>

                {/* Currency & Wallets */}
                <td className="py-3.5 px-4">
                  <div className="flex items-center gap-2">
                    <div className="h-4 w-8 rounded bg-zinc-200 dark:bg-zinc-800" />
                    <div className="h-1 w-1 rounded-full bg-zinc-300 dark:bg-zinc-700" />
                    <div className="h-3.5 w-16 rounded bg-zinc-200 dark:bg-zinc-800" />
                  </div>
                </td>

                {/* Email Verification */}
                <td className="py-3.5 px-4">
                  <div className="h-4 w-14 rounded-md bg-zinc-200 dark:bg-zinc-800" />
                </td>

                {/* Status badge */}
                <td className="py-3.5 px-4">
                  <div className="h-5 w-14 rounded-full bg-zinc-200 dark:bg-zinc-800" />
                </td>

                {/* Joined Date */}
                <td className="py-3.5 px-4">
                  <div className="h-3.5 w-20 rounded-md bg-zinc-200 dark:bg-zinc-800" />
                </td>

                {/* Actions */}
                <td className="py-3.5 px-4 text-center">
                  <div className="flex items-center justify-center gap-1">
                    <div className="h-8 w-8 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
                    <div className="h-8 w-8 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
                    <div className="h-8 w-8 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
                    <div className="h-8 w-8 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  );
};

interface UsersCardsSkeletonProps {
  count?: number;
}

export const UsersCardsSkeleton: React.FC<UsersCardsSkeletonProps> = ({ count = 8 }) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      {Array.from({ length: count }).map((_, i) => (
        <Card
          key={i}
          className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800 flex flex-col justify-between space-y-4 shadow-2xs animate-pulse"
        >
          {/* Header row: Checkbox & Avatar */}
          <div className="flex items-start justify-between">
            <div className="flex items-center gap-3">
              <div className="h-11 w-11 rounded-2xl bg-zinc-200 dark:bg-zinc-800 shrink-0" />
              <div className="space-y-1.5 min-w-0">
                <div
                  className="h-3.5 rounded-md bg-zinc-200 dark:bg-zinc-800"
                  style={{ width: `${85 + (i % 3) * 20}px` }}
                />
                <div
                  className="h-2.5 rounded-md bg-zinc-200/70 dark:bg-zinc-800/60"
                  style={{ width: `${110 + (i % 3) * 25}px` }}
                />
              </div>
            </div>
            <div className="h-4 w-4 rounded-md bg-zinc-200 dark:bg-zinc-800" />
          </div>

          {/* Badges row */}
          <div className="flex items-center gap-2 pt-1">
            <div className="h-5 w-16 rounded-full bg-zinc-200 dark:bg-zinc-800" />
            <div className="h-5 w-14 rounded-full bg-zinc-200 dark:bg-zinc-800" />
          </div>

          {/* Wallets & Date row */}
          <div className="pt-2 border-t border-zinc-100 dark:border-zinc-800/80 flex items-center justify-between">
            <div className="h-3.5 w-24 rounded bg-zinc-200 dark:bg-zinc-800" />
            <div className="h-3 w-16 rounded bg-zinc-200/70 dark:bg-zinc-800/60" />
          </div>

          {/* Action buttons */}
          <div className="flex items-center gap-1.5 pt-1 border-t border-zinc-100 dark:border-zinc-800/80">
            <div className="h-8 flex-1 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
            <div className="h-8 flex-1 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
            <div className="h-8 w-8 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
          </div>
        </Card>
      ))}
    </div>
  );
};
