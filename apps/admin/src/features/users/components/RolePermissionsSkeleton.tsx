import React from 'react';
import { Card } from '../../../core/components/ui/Card';

export const RolePermissionsSkeleton: React.FC = () => {
  return (
    <div className="space-y-6 pb-12 animate-pulse">
      {/* 1. Header Skeleton */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-2xl bg-zinc-200 dark:bg-zinc-800 shrink-0" />
          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <div className="h-6 w-48 rounded-lg bg-zinc-200 dark:bg-zinc-800" />
              <div className="h-5 w-16 rounded-full bg-zinc-200 dark:bg-zinc-800" />
            </div>
            <div className="h-3 w-64 rounded bg-zinc-200/70 dark:bg-zinc-800/60" />
          </div>
        </div>

        <div className="flex items-center gap-2 self-start sm:self-auto">
          <div className="h-9 w-24 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
          <div className="h-9 w-32 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
        </div>
      </div>

      {/* 2. Top KPI Cards Skeleton (4 Cards) */}
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <Card
            key={i}
            className="p-4 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs space-y-3"
          >
            <div className="flex items-center justify-between">
              <div className="h-3.5 w-24 bg-zinc-200 dark:bg-zinc-800 rounded-md" />
              <div className="h-9 w-9 bg-zinc-200 dark:bg-zinc-800 rounded-xl" />
            </div>
            <div className="flex items-baseline gap-2 pt-1">
              <div className="h-7 w-14 bg-zinc-200 dark:bg-zinc-800 rounded-md" />
              <div className="h-4 w-20 bg-zinc-100 dark:bg-zinc-800/60 rounded-full" />
            </div>
          </Card>
        ))}
      </div>

      {/* 3. Search Bar Skeleton */}
      <Card className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 p-3 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
        <div className="h-9 flex-1 rounded-xl bg-zinc-200/80 dark:bg-zinc-800/80" />
        <div className="flex items-center gap-2 shrink-0">
          <div className="h-8 w-20 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
          <div className="h-8 w-20 rounded-xl bg-zinc-200 dark:bg-zinc-800" />
        </div>
      </Card>

      {/* 4. Module Cards Grid Skeleton (8 Cards) */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {Array.from({ length: 8 }).map((_, i) => (
          <Card
            key={i}
            className="p-0 overflow-hidden bg-white dark:bg-[#121215] border-zinc-200/80 dark:border-zinc-800/80 rounded-2xl shadow-2xs flex flex-col"
          >
            {/* Header */}
            <div className="p-4 border-b border-zinc-100 dark:border-zinc-800/80 bg-zinc-50/50 dark:bg-zinc-900/40 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-xl bg-zinc-200 dark:bg-zinc-800 shrink-0" />
                <div className="space-y-1.5">
                  <div
                    className="h-4 rounded bg-zinc-200 dark:bg-zinc-800"
                    style={{ width: `${80 + (i % 3) * 20}px` }}
                  />
                  <div className="h-2.5 w-16 rounded bg-zinc-200/70 dark:bg-zinc-800/60" />
                </div>
              </div>
              <div className="h-5 w-9 rounded-full bg-zinc-200 dark:bg-zinc-800 shrink-0" />
            </div>

            {/* Rows */}
            <div className="p-3 space-y-2">
              {Array.from({ length: 3 }).map((_, j) => (
                <div
                  key={j}
                  className="flex items-center justify-between gap-2.5 px-3 py-2.5 rounded-xl"
                >
                  <div className="space-y-1.5 flex-1 min-w-0">
                    <div
                      className="h-3.5 rounded bg-zinc-200/80 dark:bg-zinc-800/80"
                      style={{ width: `${100 + ((i + j) % 3) * 25}px` }}
                    />
                    <div
                      className="h-2.5 rounded bg-zinc-200/60 dark:bg-zinc-800/50"
                      style={{ width: `${60 + ((i + j) % 2) * 20}px` }}
                    />
                  </div>
                  <div className="h-4 w-7 rounded-full bg-zinc-200 dark:bg-zinc-800 shrink-0" />
                </div>
              ))}
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
};
