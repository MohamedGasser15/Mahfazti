import React from 'react';
import { Layers, TrendingDown, TrendingUp, Archive } from 'lucide-react';
import { Card } from '../../../core/components/ui/Card';

export interface CategoriesKpiStats {
  all: number;
  expenses: number;
  income: number;
  archived: number;
}

interface CategoriesKpiCardsProps {
  stats: CategoriesKpiStats;
  isLoading: boolean;
  hasCategories: boolean;
  isAr: boolean;
}

export const CategoriesKpiCards: React.FC<CategoriesKpiCardsProps> = ({
  stats,
  isLoading,
  hasCategories,
  isAr,
}) => {
  const showSkeleton = isLoading && !hasCategories;

  const expensePct = stats.all > 0 ? Math.round((stats.expenses / stats.all) * 100) : 0;
  const incomePct = stats.all > 0 ? Math.round((stats.income / stats.all) * 100) : 0;
  const archivedPct = stats.all > 0 ? Math.round((stats.archived / stats.all) * 100) : 0;

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-3.5 sm:gap-4">
      {/* Total Categories */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-zinc-100 dark:bg-zinc-800 text-zinc-900 dark:text-white">
          <Layers className="h-6 w-6 text-zinc-900 dark:text-zinc-200" />
        </div>
        <div>
          <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            {isAr ? 'إجمالي التصنيفات' : 'Total Categories'}
          </p>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.all}
            </h3>
          )}
        </div>
      </Card>

      {/* Expense Categories */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-rose-50 dark:bg-rose-950/40 text-rose-600 dark:text-rose-400">
          <TrendingDown className="h-6 w-6" />
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
              {isAr ? 'تصنيفات المصاريف' : 'Expense Categories'}
            </p>
            {showSkeleton ? (
              <div className="h-4 w-7 rounded-full bg-rose-100 dark:bg-rose-950/80 animate-pulse" />
            ) : (
              <span className="text-[10px] font-bold px-1.5 py-0.2 rounded-full bg-rose-100 dark:bg-rose-950/80 text-rose-700 dark:text-rose-300">
                {expensePct}%
              </span>
            )}
          </div>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.expenses}
            </h3>
          )}
        </div>
      </Card>

      {/* Income Categories */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400">
          <TrendingUp className="h-6 w-6" />
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
              {isAr ? 'تصنيفات الإيرادات' : 'Income Categories'}
            </p>
            {showSkeleton ? (
              <div className="h-4 w-7 rounded-full bg-emerald-100 dark:bg-emerald-950/80 animate-pulse" />
            ) : (
              <span className="text-[10px] font-bold px-1.5 py-0.2 rounded-full bg-emerald-100 dark:bg-emerald-950/80 text-emerald-700 dark:text-emerald-300">
                {incomePct}%
              </span>
            )}
          </div>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.income}
            </h3>
          )}
        </div>
      </Card>

      {/* Archived Categories */}
      <Card className="p-4 sm:p-5 flex items-center gap-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-amber-50 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400">
          <Archive className="h-6 w-6" />
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
              {isAr ? 'التصنيفات المؤرشفة' : 'Archived'}
            </p>
            {showSkeleton ? (
              <div className="h-4 w-7 rounded-full bg-amber-100 dark:bg-amber-950/80 animate-pulse" />
            ) : (
              <span className="text-[10px] font-bold px-1.5 py-0.2 rounded-full bg-amber-100 dark:bg-amber-950/80 text-amber-700 dark:text-amber-300">
                {archivedPct}%
              </span>
            )}
          </div>
          {showSkeleton ? (
            <div className="h-7 w-14 rounded-lg bg-zinc-200 dark:bg-zinc-800 animate-pulse mt-1" />
          ) : (
            <h3 className="text-xl sm:text-2xl font-black text-zinc-950 dark:text-white mt-0.5">
              {stats.archived}
            </h3>
          )}
        </div>
      </Card>
    </div>
  );
};
