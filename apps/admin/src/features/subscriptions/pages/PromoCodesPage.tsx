import React from 'react';
import { Plus, Tag } from 'lucide-react';
import { useSubscriptions } from '../hooks/useSubscriptions';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatDate } from '../../../core/utils/formatters';

export const PromoCodesPage: React.FC = () => {
  const { promoCodes, isLoading } = useSubscriptions();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">
            Promo Codes & Discounts
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Create and track promotional discount vouchers for subscriber acquisition.
          </p>
        </div>

        <Button>
          <Plus className="h-4 w-4" />
          <span>Create Promo Code</span>
        </Button>
      </div>

      {/* Grid */}
      {isLoading ? (
        <div className="p-8 text-center text-zinc-400 text-xs font-medium">Loading promo codes...</div>
      ) : (
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
          {promoCodes.map((promo) => (
            <Card key={promo.id} className="p-6">
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-amber-50 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400">
                    <Tag className="h-5 w-5" />
                  </div>
                  <div>
                    <span className="font-mono text-base font-black tracking-wider text-zinc-900 dark:text-white">
                      {promo.code}
                    </span>
                    <p className="text-xs font-bold text-emerald-600 dark:text-emerald-400">
                      {promo.discountPercentage}% OFF Subscriptions
                    </p>
                  </div>
                </div>

                <Badge variant={promo.isActive ? 'success' : 'default'}>
                  {promo.isActive ? 'Active' : 'Expired'}
                </Badge>
              </div>

              <div className="mt-6 grid grid-cols-2 gap-4 border-t border-zinc-100 dark:border-zinc-800 pt-4 text-xs">
                <div>
                  <span className="text-zinc-400">Redemptions:</span>
                  <p className="font-bold text-zinc-900 dark:text-white">
                    {promo.usedCount} / {promo.maxUses}
                  </p>
                </div>
                <div>
                  <span className="text-zinc-400">Expires On:</span>
                  <p className="font-bold text-zinc-900 dark:text-white">
                    {formatDate(promo.expiresAt)}
                  </p>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};
