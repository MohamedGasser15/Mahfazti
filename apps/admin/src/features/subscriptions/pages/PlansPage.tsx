import React from 'react';
import { Check, Plus, Sparkles, Edit2 } from 'lucide-react';
import { useSubscriptions } from '../hooks/useSubscriptions';
import { Card } from '../../../core/components/ui/Card';
import { Button } from '../../../core/components/ui/Button';
import { Badge } from '../../../core/components/ui/Badge';
import { formatCurrency } from '../../../core/utils/formatters';

export const PlansPage: React.FC = () => {
  const { plans, isLoading } = useSubscriptions();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">
            Pricing Plans & Feature Limits
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Define subscription tiers, pricing in EGP, and premium feature entitlements.
          </p>
        </div>

        <Button>
          <Plus className="h-4 w-4" />
          <span>New Pricing Plan</span>
        </Button>
      </div>

      {/* Plans Grid */}
      {isLoading ? (
        <div className="p-8 text-center text-zinc-400 text-xs font-medium">Loading pricing plans...</div>
      ) : (
        <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
          {plans.map((plan) => (
            <Card
              key={plan.id}
              className={`relative flex flex-col justify-between p-6 ${
                plan.isPopular
                  ? 'ring-2 ring-blue-600 dark:ring-blue-500 shadow-md'
                  : ''
              }`}
            >
              <div>
                <div className="flex items-center justify-between mb-3">
                  <Badge variant={plan.isPopular ? 'info' : 'default'}>
                    {plan.billingCycle}
                  </Badge>
                  {plan.isPopular && (
                    <span className="flex items-center gap-1 text-[10px] font-bold text-blue-600 dark:text-blue-400">
                      <Sparkles className="h-3 w-3" />
                      Most Popular
                    </span>
                  )}
                </div>

                <h3 className="text-lg font-black text-zinc-900 dark:text-white">
                  {plan.name}
                </h3>
                <p className="text-xs font-arabic text-zinc-400 mt-0.5">{plan.nameAr}</p>
                <p className="mt-2 text-xs text-zinc-500 dark:text-zinc-400 leading-relaxed">
                  {plan.description}
                </p>

                {/* Price */}
                <div className="mt-6 mb-6 pb-6 border-b border-zinc-100 dark:border-zinc-800">
                  <div className="flex items-baseline gap-1">
                    <span className="text-3xl font-black text-zinc-900 dark:text-white">
                      {plan.priceEgp === 0 ? 'Free' : formatCurrency(plan.priceEgp)}
                    </span>
                    {plan.priceEgp > 0 && (
                      <span className="text-xs font-semibold text-zinc-400">
                        / {plan.billingCycle === 'Monthly' ? 'mo' : 'yr'}
                      </span>
                    )}
                  </div>
                </div>

                {/* Features Checklist */}
                <div className="space-y-2.5">
                  <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-400">
                    Included Features:
                  </p>
                  {plan.features.map((feature, idx) => (
                    <div key={idx} className="flex items-start gap-2 text-xs text-zinc-700 dark:text-zinc-300">
                      <div className="flex h-4 w-4 shrink-0 items-center justify-center rounded-full bg-emerald-50 dark:bg-emerald-950/50 text-emerald-600 dark:text-emerald-400 mt-0.5">
                        <Check className="h-3 w-3" />
                      </div>
                      <span>{feature}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="mt-8 pt-4 border-t border-zinc-100 dark:border-zinc-800 flex items-center justify-between">
                <span className="text-xs font-semibold text-zinc-400">
                  Status: {plan.isActive ? 'Active' : 'Archived'}
                </span>
                <Button size="sm" variant="outline">
                  <Edit2 className="h-3.5 w-3.5" />
                  <span>Edit Plan</span>
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};
