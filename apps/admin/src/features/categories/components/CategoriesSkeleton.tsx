import React from 'react';
import { Card } from '../../../core/components/ui/Card';

export interface CategoriesCardsSkeletonProps {
  count?: number;
}

export const CategoriesCardsSkeleton: React.FC<CategoriesCardsSkeletonProps> = ({
  count = 8,
}) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      {Array.from({ length: count }).map((_, i) => (
        <Card
          key={i}
          className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800 flex flex-col justify-between space-y-4 shadow-2xs animate-pulse"
        >
          <div className="flex items-start justify-between">
            <div className="h-11 w-11 rounded-2xl bg-zinc-200 dark:bg-zinc-800 shrink-0" />
            <div className="h-5 w-16 rounded-full bg-zinc-200 dark:bg-zinc-800" />
          </div>
          <div className="space-y-2 pt-1">
            <div
              className="h-4 rounded-md bg-zinc-200 dark:bg-zinc-800"
              style={{ width: `${70 + (i % 3) * 10}%` }}
            />
            <div
              className="h-3 rounded-md bg-zinc-200/70 dark:bg-zinc-800/60"
              style={{ width: `${50 + (i % 3) * 12}%` }}
            />
          </div>
          <div className="pt-2 border-t border-zinc-100 dark:border-zinc-800/80 flex justify-between items-center">
            <div className="h-3.5 w-16 rounded bg-zinc-200 dark:bg-zinc-800" />
            <div className="h-5 w-14 rounded-md bg-zinc-200 dark:bg-zinc-800" />
          </div>
        </Card>
      ))}
    </div>
  );
};

export interface CategoriesTableSkeletonProps {
  count?: number;
  isAr?: boolean;
}

export const CategoriesTableSkeleton: React.FC<CategoriesTableSkeletonProps> = ({
  count = 8,
  isAr = false,
}) => {
  return (
    <Card className="p-0 overflow-hidden bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs min-h-[380px]">
      <div className="overflow-x-auto">
        <table className="w-full text-left rtl:text-right text-xs">
          <thead className="border-b border-zinc-200 dark:border-zinc-800 bg-zinc-50/80 dark:bg-zinc-900/50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            <tr>
              <th className="py-3.5 px-4 w-10 text-center">
                <div className="h-4 w-4 rounded-md bg-zinc-200 dark:bg-zinc-800 mx-auto" />
              </th>
              <th className="py-3.5 px-6">{isAr ? 'التصنيف' : 'Category'}</th>
              <th className="py-3.5 px-6">{isAr ? 'النوع' : 'Type'}</th>
              <th className="py-3.5 px-6">{isAr ? 'الحالة' : 'Status'}</th>
              <th className="py-3.5 px-6">{isAr ? 'المعاملات المرتبطة' : 'Transactions'}</th>
              <th className="py-3.5 px-6 text-center">{isAr ? 'الإجراءات' : 'Actions'}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-zinc-200/70 dark:divide-zinc-800/60">
            {Array.from({ length: count }).map((_, i) => (
              <tr key={i} className="animate-pulse">
                {/* Checkbox */}
                <td className="py-3.5 px-4 text-center">
                  <div className="h-4 w-4 rounded-md bg-zinc-200 dark:bg-zinc-800 mx-auto" />
                </td>

                {/* Category Icon & Names */}
                <td className="py-3.5 px-6">
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-2xl bg-zinc-200 dark:bg-zinc-800 shrink-0" />
                    <div className="space-y-1.5">
                      <div
                        className="h-4 rounded-md bg-zinc-200 dark:bg-zinc-800"
                        style={{ width: `${100 + (i % 4) * 20}px` }}
                      />
                      <div
                        className="h-3 rounded-md bg-zinc-200/70 dark:bg-zinc-800/60"
                        style={{ width: `${80 + (i % 3) * 25}px` }}
                      />
                    </div>
                  </div>
                </td>

                {/* Type Badge */}
                <td className="py-3.5 px-6">
                  <div className="h-6 w-16 rounded-full bg-zinc-200 dark:bg-zinc-800" />
                </td>

                {/* Status Badge */}
                <td className="py-3.5 px-6">
                  <div className="h-6 w-16 rounded-full bg-zinc-200 dark:bg-zinc-800" />
                </td>

                {/* Transactions Badge */}
                <td className="py-3.5 px-6">
                  <div className="h-5 w-24 rounded-md bg-zinc-200 dark:bg-zinc-800" />
                </td>

                {/* Actions */}
                <td className="py-3.5 px-6 text-center">
                  <div className="flex items-center justify-center gap-1.5">
                    <div className="h-8 w-8 rounded-lg bg-zinc-200 dark:bg-zinc-800" />
                    <div className="h-8 w-8 rounded-lg bg-zinc-200 dark:bg-zinc-800" />
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

export interface CategoriesSkeletonProps {
  count?: number;
  viewMode?: 'table' | 'cards';
  isAr?: boolean;
}

export const CategoriesSkeleton: React.FC<CategoriesSkeletonProps> = ({
  count = 8,
  viewMode = 'table',
  isAr = false,
}) => {
  if (viewMode === 'cards') {
    return <CategoriesCardsSkeleton count={count} />;
  }

  return (
    <>
      <div className="hidden lg:block">
        <CategoriesTableSkeleton count={count} isAr={isAr} />
      </div>
      <div className="lg:hidden">
        <CategoriesCardsSkeleton count={count} />
      </div>
    </>
  );
};
