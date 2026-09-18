import React from 'react';
import { Plus, RefreshCw, Star } from 'lucide-react';
import { useCurrencies } from '../hooks/useCurrencies';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatDate } from '../../../core/utils/formatters';

export const CurrenciesPage: React.FC = () => {
  const { currencies, toggleActive, isLoading } = useCurrencies();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">
            Currencies & Exchange Rates
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Configure mobile app available currencies and exchange rate valuations against EGP.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button variant="outline">
            <RefreshCw className="h-4 w-4" />
            <span>Sync Live Rates</span>
          </Button>
          <Button>
            <Plus className="h-4 w-4" />
            <span>Add Currency</span>
          </Button>
        </div>
      </div>

      {/* Grid */}
      {isLoading ? (
        <div className="p-8 text-center text-zinc-400 text-xs">Loading currencies...</div>
      ) : (
        <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
          {currencies.map((currency) => (
            <Card key={currency.code} className="p-6 relative">
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-zinc-100 dark:bg-zinc-800 text-base font-black text-zinc-900 dark:text-white">
                    {currency.symbol}
                  </div>
                  <div>
                    <div className="flex items-center gap-1.5">
                      <h3 className="font-bold text-zinc-900 dark:text-white text-sm">
                        {currency.name}
                      </h3>
                      {currency.isDefault && (
                        <Star className="h-3.5 w-3.5 text-amber-500 fill-amber-500" />
                      )}
                    </div>
                    <p className="text-xs text-zinc-400 font-arabic">{currency.nameAr}</p>
                  </div>
                </div>

                <Badge variant={currency.isActive ? 'success' : 'default'}>
                  {currency.isActive ? 'Active' : 'Disabled'}
                </Badge>
              </div>

              {/* Rate */}
              <div className="mt-6 mb-4 rounded-2xl bg-zinc-50 dark:bg-zinc-900/60 p-4 border border-zinc-100 dark:border-zinc-800">
                <span className="text-[10px] font-bold uppercase tracking-wider text-zinc-400">
                  Exchange Rate (Valuation):
                </span>
                <div className="mt-1 flex items-baseline gap-1 font-mono font-black text-xl text-zinc-900 dark:text-white">
                  <span>1 {currency.code}</span>
                  <span className="text-zinc-400 text-sm font-normal">=</span>
                  <span className="text-blue-600 dark:text-blue-400">
                    {currency.exchangeRateToEgp.toFixed(2)} EGP
                  </span>
                </div>
              </div>

              <div className="flex items-center justify-between pt-2 text-[11px] text-zinc-400 border-t border-zinc-100 dark:border-zinc-800">
                <span>Updated: {formatDate(currency.lastUpdated)}</span>
                {!currency.isDefault && (
                  <button
                    onClick={() => toggleActive(currency.code)}
                    className="font-bold text-xs text-blue-600 dark:text-blue-400 hover:underline cursor-pointer"
                  >
                    {currency.isActive ? 'Disable' : 'Enable'}
                  </button>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};
