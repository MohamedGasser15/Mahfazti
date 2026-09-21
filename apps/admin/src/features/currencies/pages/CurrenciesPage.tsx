import React, { useState, useMemo } from 'react';
import {
  RefreshCw,
  Coins,
  CheckCircle2,
  Clock,
  Sparkles,
  ChevronDown,
  Search,
  Globe2,
  SlidersHorizontal,
  LayoutGrid,
  Table as TableIcon,
  Star,
  Copy,
  Check,
  X,
  Eye,
  EyeOff,
} from 'lucide-react';
import { toast } from 'sonner';
import { useCurrencies } from '../hooks/useCurrencies';
import { useLocale } from '../../../core/context/LocaleContext';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatDate } from '../../../core/utils/formatters';
import { getCurrencyExtra } from '../utils/currencyMetadata';

type RegionFilter = 'all' | 'active' | 'arab' | 'global' | 'catalog';
type ViewMode = 'grid' | 'table';

export const CurrenciesPage: React.FC = () => {
  const { locale, t } = useLocale();
  const isAr = locale === 'ar';
  const ct = t.currencies;

  const {
    currencies,
    isLoading,
    syncLiveRates,
    isSyncing,
    toggleActive,
    isToggling,
    toggleFeatured,
    isTogglingFeatured,
    setBaseCurrency,
    isSettingBase,
  } = useCurrencies();

  const [activeFilter, setActiveFilter] = useState<RegionFilter>('active');
  const [viewMode, setViewMode] = useState<ViewMode>('grid');
  const [searchQuery, setSearchQuery] = useState('');
  const [copiedCode, setCopiedCode] = useState<string | null>(null);

  // Identify the default base currency (fallback to EGP or first item)
  const baseCurrency = useMemo(() => {
    return (
      currencies.find((c) => c.isDefault) ||
      currencies.find((c) => c.code === 'EGP') ||
      currencies[0]
    );
  }, [currencies]);

  // Filter out the base currency itself so redundant "1 Base = 1.00 Base" does NOT appear in list
  const otherCurrencies = useMemo(() => {
    return currencies.filter((c) => c.code !== (baseCurrency?.code || 'EGP'));
  }, [currencies, baseCurrency]);

  const activeCount = useMemo(() => currencies.filter((c) => c.isActive).length, [currencies]);
  const featuredCount = useMemo(() => currencies.filter((c) => c.isFeatured).length, [currencies]);
  const inactiveCount = useMemo(() => otherCurrencies.filter((c) => !c.isActive).length, [otherCurrencies]);
  const lastSyncDate = currencies.length > 0 ? currencies[0].lastUpdated : null;

  // Filter based on active filter and search query, prioritizing Featured currencies at the top
  const filteredCurrencies = useMemo(() => {
    let list = otherCurrencies;

    if (activeFilter === 'active') {
      list = list.filter((c) => c.isActive);
    } else if (activeFilter === 'catalog') {
      list = list.filter((c) => !c.isActive);
    } else if (activeFilter === 'arab') {
      list = list.filter((c) => getCurrencyExtra(c.code).region === 'arab');
    } else if (activeFilter === 'global') {
      list = list.filter((c) => getCurrencyExtra(c.code).region === 'global');
    }

    if (searchQuery.trim()) {
      const q = searchQuery.trim().toLowerCase();
      list = list.filter(
        (c) =>
          c.code.toLowerCase().includes(q) ||
          c.nameEn.toLowerCase().includes(q) ||
          c.nameAr.toLowerCase().includes(q)
      );
    }

    return list.slice().sort((a, b) => {
      // 1. Featured first
      if (a.isFeatured !== b.isFeatured) {
        return a.isFeatured ? -1 : 1;
      }
      // 2. Active status
      if (a.isActive !== b.isActive) {
        return a.isActive ? -1 : 1;
      }
      // 3. Alphabetical code
      return a.code.localeCompare(b.code);
    });
  }, [otherCurrencies, activeFilter, searchQuery]);

  const formatRate = (rate: number): string => {
    if (isNaN(rate) || rate <= 0) return '0.00';
    if (rate >= 1) {
      return new Intl.NumberFormat('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }).format(rate);
    }
    return new Intl.NumberFormat('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 4,
    }).format(rate);
  };

  const handleSync = async () => {
    try {
      await syncLiveRates();
    } catch {
      // Handled in hook
    }
  };

  const handleBaseCurrencyChange = async (newBaseCode: string) => {
    if (!newBaseCode || newBaseCode === baseCurrency?.code) return;
    await setBaseCurrency(newBaseCode);
  };

  const handleCopyRate = (code: string, relativeRate: number) => {
    const text = `1 ${code} = ${formatRate(relativeRate)} ${baseCurrency?.code || 'EGP'}`;
    navigator.clipboard.writeText(text);
    setCopiedCode(code);
    toast.success(`${ct.actions.rateCopied}${text}`);
    setTimeout(() => setCopiedCode(null), 2000);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-950 dark:text-white flex items-center gap-2.5">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-zinc-900 text-white dark:bg-white dark:text-zinc-950 shadow-xs">
              <Coins className="h-5 w-5" />
            </div>
            <span>{ct.pageTitle}</span>
          </h1>
          <p className="text-xs sm:text-sm text-zinc-500 dark:text-zinc-400 mt-1 font-medium">
            {ct.pageSubtitle}
          </p>
        </div>

        <div className="flex items-center gap-2.5 flex-wrap">
          <Button
            variant="outline"
            size="sm"
            onClick={handleSync}
            disabled={isSyncing || isLoading}
            className="gap-2 shadow-2xs font-semibold bg-white dark:bg-zinc-900 hover:bg-zinc-50 dark:hover:bg-zinc-800"
          >
            <RefreshCw className={`h-4 w-4 ${isSyncing ? 'animate-spin text-blue-600' : 'text-zinc-500'}`} />
            <span>{isSyncing ? ct.syncing : ct.syncRates}</span>
          </Button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Card 1: Base Currency Switcher */}
        <Card className="p-4 border-zinc-200/90 dark:border-zinc-800/90 shadow-2xs bg-gradient-to-br from-amber-500/10 via-amber-500/5 to-transparent relative overflow-hidden">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider">
              {ct.kpi.baseCurrency}
            </span>
            <span className="flex items-center gap-1 text-[10px] font-bold text-amber-700 dark:text-amber-400 bg-amber-500/15 dark:bg-amber-500/20 px-2 py-0.5 rounded-full border border-amber-500/30">
              <Sparkles className="h-3 w-3" />
              {ct.kpi.baseBadge}
            </span>
          </div>

          <div className="mt-2.5 flex items-center justify-between gap-2">
            <div className="min-w-0">
              <div className="text-base font-black text-zinc-950 dark:text-white flex items-center gap-1.5">
                <span className="text-xl">{getCurrencyExtra(baseCurrency?.code || 'EGP').flag}</span>
                <span>{baseCurrency?.code || 'EGP'}</span>
                <span className="text-xs text-zinc-500 font-medium">
                  ({baseCurrency?.symbol || 'EGP'})
                </span>
              </div>
              <p className="text-[11px] text-zinc-500 font-arabic truncate mt-0.5">
                {isAr ? baseCurrency?.nameAr : baseCurrency?.nameEn}
              </p>
            </div>

            {/* Selector Dropdown */}
            <div className="relative shrink-0">
              <select
                value={baseCurrency?.code || 'EGP'}
                onChange={(e) => handleBaseCurrencyChange(e.target.value)}
                disabled={isSettingBase || isLoading}
                className="appearance-none cursor-pointer bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-700 text-xs font-bold text-zinc-900 dark:text-white rounded-xl py-1.5 ps-3 pe-8 focus:outline-hidden focus:ring-1 focus:ring-amber-500 shadow-2xs hover:border-zinc-300 dark:hover:border-zinc-600 transition"
                title={ct.kpi.changeBaseTooltip}
              >
                {currencies.map((c) => (
                  <option key={c.code} value={c.code}>
                    {getCurrencyExtra(c.code).flag} {c.code} ({c.symbol})
                  </option>
                ))}
              </select>
              <ChevronDown className="h-3.5 w-3.5 text-zinc-400 absolute end-2.5 top-2.5 pointer-events-none" />
            </div>
          </div>
        </Card>

        {/* Card 2: Active Currencies */}
        <Card className="p-4 flex items-center gap-3.5 border-zinc-200/90 dark:border-zinc-800/90 shadow-2xs bg-white dark:bg-[#121215]">
          <div className="h-11 w-11 rounded-2xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 flex items-center justify-center font-bold shrink-0 border border-emerald-500/20">
            <CheckCircle2 className="h-5 w-5" />
          </div>
          <div>
            <span className="text-[11px] font-bold text-zinc-400 uppercase tracking-wider">
              {ct.kpi.activeMobile}
            </span>
            <div className="text-xl font-mono font-black text-emerald-600 dark:text-emerald-400 mt-0.5">
              {activeCount} <span className="text-xs font-sans font-semibold text-zinc-500">{ct.kpi.activeSuffix}</span>
            </div>
          </div>
        </Card>

        {/* Card 3: Featured Priority */}
        <Card className="p-4 flex items-center gap-3.5 border-zinc-200/90 dark:border-zinc-800/90 shadow-2xs bg-white dark:bg-[#121215]">
          <div className="h-11 w-11 rounded-2xl bg-amber-500/10 text-amber-600 dark:text-amber-400 flex items-center justify-center font-bold shrink-0 border border-amber-500/20">
            <Star className="h-5 w-5 fill-amber-400 text-amber-500" />
          </div>
          <div>
            <span className="text-[11px] font-bold text-zinc-400 uppercase tracking-wider">
              {ct.kpi.featuredCount}
            </span>
            <div className="text-xl font-mono font-black text-amber-600 dark:text-amber-400 mt-0.5">
              {featuredCount} <span className="text-xs font-sans font-semibold text-zinc-500">{ct.kpi.featuredSuffix}</span>
            </div>
          </div>
        </Card>

        {/* Card 4: Last Sync */}
        <Card className="p-4 flex items-center gap-3.5 border-zinc-200/90 dark:border-zinc-800/90 shadow-2xs bg-white dark:bg-[#121215]">
          <div className="h-11 w-11 rounded-2xl bg-blue-500/10 text-blue-600 dark:text-blue-400 flex items-center justify-center font-bold shrink-0 border border-blue-500/20">
            <Clock className="h-5 w-5" />
          </div>
          <div className="min-w-0">
            <span className="text-[11px] font-bold text-zinc-400 uppercase tracking-wider">
              {ct.kpi.lastRatesSync}
            </span>
            <div className="text-xs font-bold text-zinc-800 dark:text-zinc-200 truncate mt-0.5 font-mono">
              {lastSyncDate ? formatDate(lastSyncDate) : ct.kpi.notSpecified}
            </div>
          </div>
        </Card>
      </div>

      {/* Filter Tabs, Search Bar & View Mode Toggle */}
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-3 bg-white dark:bg-[#121215] p-2 rounded-2xl border border-zinc-200/90 dark:border-zinc-800/90 shadow-2xs">
        {/* Filter Pills */}
        <div className="flex items-center gap-1.5 flex-wrap p-1 bg-zinc-100/80 dark:bg-zinc-900/90 rounded-xl border border-zinc-200/60 dark:border-zinc-800/60">
          <button
            onClick={() => setActiveFilter('active')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer flex items-center gap-1.5 ${
              activeFilter === 'active'
                ? 'bg-white dark:bg-zinc-800 text-zinc-950 dark:text-white shadow-xs'
                : 'text-zinc-500 hover:text-zinc-950 dark:hover:text-white'
            }`}
          >
            <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />
            <span>{ct.tabs.active}</span>
            <span className="text-[10px] px-1.5 py-0.2 rounded-full bg-zinc-200 dark:bg-zinc-700 text-zinc-800 dark:text-zinc-200 font-mono">
              {otherCurrencies.filter((c) => c.isActive).length}
            </span>
          </button>

          <button
            onClick={() => setActiveFilter('arab')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer flex items-center gap-1.5 ${
              activeFilter === 'arab'
                ? 'bg-white dark:bg-zinc-800 text-zinc-950 dark:text-white shadow-xs'
                : 'text-zinc-500 hover:text-zinc-950 dark:hover:text-white'
            }`}
          >
            <span>🇸🇦</span>
            <span>{ct.tabs.arab}</span>
          </button>

          <button
            onClick={() => setActiveFilter('global')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer flex items-center gap-1.5 ${
              activeFilter === 'global'
                ? 'bg-white dark:bg-zinc-800 text-zinc-950 dark:text-white shadow-xs'
                : 'text-zinc-500 hover:text-zinc-950 dark:hover:text-white'
            }`}
          >
            <span>🌐</span>
            <span>{ct.tabs.global}</span>
          </button>

          <button
            onClick={() => setActiveFilter('catalog')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer flex items-center gap-1.5 ${
              activeFilter === 'catalog'
                ? 'bg-white dark:bg-zinc-800 text-zinc-950 dark:text-white shadow-xs'
                : 'text-zinc-500 hover:text-zinc-950 dark:hover:text-white'
            }`}
          >
            <Globe2 className="h-3.5 w-3.5 text-blue-500" />
            <span>{ct.tabs.catalog}</span>
            <span className="text-[10px] px-1.5 py-0.2 rounded-full bg-zinc-200 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-300 font-mono">
              {inactiveCount}
            </span>
          </button>

          <button
            onClick={() => setActiveFilter('all')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer flex items-center gap-1.5 ${
              activeFilter === 'all'
                ? 'bg-white dark:bg-zinc-800 text-zinc-950 dark:text-white shadow-xs'
                : 'text-zinc-500 hover:text-zinc-950 dark:hover:text-white'
            }`}
          >
            <SlidersHorizontal className="h-3.5 w-3.5 text-zinc-500" />
            <span>{ct.tabs.all}</span>
          </button>
        </div>

        {/* Search & View Mode Switcher */}
        <div className="flex items-center gap-2">
          <div className="relative flex-1 sm:w-64">
            <Search className="h-3.5 w-3.5 text-zinc-400 absolute start-3 top-2.5" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder={ct.searchPlaceholder}
              className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl ps-9 pe-8 py-1.5 text-xs text-zinc-900 dark:text-white placeholder:text-zinc-400 focus:outline-hidden focus:ring-1 focus:ring-zinc-950 dark:focus:ring-white transition shadow-2xs"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute end-2.5 top-2.5 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 cursor-pointer"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>

          <div className="flex items-center p-1 bg-zinc-100/80 dark:bg-zinc-900/90 rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 shadow-2xs shrink-0">
            <button
              onClick={() => setViewMode('grid')}
              title={ct.viewMode.grid}
              className={`p-1.5 rounded-lg transition cursor-pointer ${
                viewMode === 'grid'
                  ? 'bg-white dark:bg-zinc-800 text-zinc-950 dark:text-white shadow-xs'
                  : 'text-zinc-400 hover:text-zinc-800 dark:hover:text-white'
              }`}
            >
              <LayoutGrid className="h-3.5 w-3.5" />
            </button>
            <button
              onClick={() => setViewMode('table')}
              title={ct.viewMode.table}
              className={`p-1.5 rounded-lg transition cursor-pointer ${
                viewMode === 'table'
                  ? 'bg-white dark:bg-zinc-800 text-zinc-950 dark:text-white shadow-xs'
                  : 'text-zinc-400 hover:text-zinc-800 dark:hover:text-white'
              }`}
            >
              <TableIcon className="h-3.5 w-3.5" />
            </button>
          </div>
        </div>
      </div>

      {/* Currencies Grid / Table */}
      {isLoading ? (
        <div className="p-20 text-center text-zinc-400 text-xs font-medium flex flex-col items-center justify-center gap-3">
          <RefreshCw className="h-6 w-6 animate-spin text-zinc-500" />
          <span>{ct.empty.loading}</span>
        </div>
      ) : filteredCurrencies.length === 0 ? (
        <Card className="p-16 text-center text-zinc-400 border-dashed border-2">
          <Coins className="h-12 w-12 mx-auto text-zinc-300 dark:text-zinc-700 mb-3" />
          <p className="text-sm font-semibold text-zinc-700 dark:text-zinc-300">
            {searchQuery ? ct.empty.noResultsSearch : ct.empty.noCurrenciesSection}
          </p>
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="mt-3 text-xs text-blue-600 dark:text-blue-400 font-bold hover:underline cursor-pointer"
            >
              {ct.actions.clearSearch}
            </button>
          )}
        </Card>
      ) : viewMode === 'grid' ? (
        /* GRID VIEW */
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredCurrencies.map((currency) => {
            const baseRateEgp = baseCurrency?.exchangeRateToEgp || 1.0;
            const currencyRateEgp = currency.exchangeRateToEgp || 1.0;
            const relativeRate = currencyRateEgp / baseRateEgp;
            const extra = getCurrencyExtra(currency.code);
            const isCopied = copiedCode === currency.code;

            return (
              <Card
                key={currency.code}
                className={`p-4.5 relative transition-all duration-200 border rounded-2xl flex flex-col justify-between ${
                  currency.isFeatured
                    ? 'border-amber-500/40 dark:border-amber-500/30 bg-gradient-to-b from-amber-500/[0.04] via-transparent to-transparent shadow-xs hover:border-amber-500/60 dark:hover:border-amber-400/50 hover:shadow-md'
                    : currency.isActive
                    ? 'border-zinc-200/90 dark:border-zinc-800/90 bg-white dark:bg-[#121215] shadow-2xs hover:shadow-md hover:border-zinc-300 dark:hover:border-zinc-700'
                    : 'border-zinc-200/60 dark:border-zinc-800/50 bg-zinc-50/50 dark:bg-zinc-900/20 opacity-75 hover:opacity-100'
                }`}
              >
                {/* Top Row: Flag, Name, Star Pin & Badge */}
                <div>
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex items-center gap-3 min-w-0">
                      <div
                        className={`flex h-11 w-11 items-center justify-center rounded-2xl text-xl shadow-xs shrink-0 bg-gradient-to-br ${extra.gradient} border border-zinc-200/80 dark:border-zinc-800/80`}
                      >
                        <span>{extra.flag}</span>
                      </div>
                      <div className="min-w-0">
                        <div className="flex items-center gap-1.5">
                          <h3 className="font-bold text-zinc-950 dark:text-white text-sm truncate">
                            {currency.nameEn || currency.name}
                          </h3>
                          <span className="text-[10px] font-mono font-bold text-zinc-500 dark:text-zinc-400 px-1 py-0.5 rounded-md bg-zinc-100 dark:bg-zinc-800">
                            {currency.code}
                          </span>
                        </div>
                        <p className="text-xs text-zinc-400 font-arabic truncate mt-0.5">
                          {currency.nameAr}
                        </p>
                      </div>
                    </div>

                    {/* Star & Status Badge */}
                    <div className="flex items-center gap-1.5 shrink-0">
                      <button
                        onClick={() => toggleFeatured(currency.code)}
                        disabled={isTogglingFeatured}
                        title={ct.actions.toggleFeatured}
                        className={`p-1.5 rounded-xl transition cursor-pointer ${
                          currency.isFeatured
                            ? 'text-amber-500 fill-amber-400 bg-amber-500/15 border border-amber-500/30 shadow-2xs'
                            : 'text-zinc-300 dark:text-zinc-600 hover:text-amber-500 hover:bg-amber-500/10'
                        }`}
                      >
                        <Star
                          className={`h-4 w-4 ${
                            currency.isFeatured ? 'fill-amber-400 text-amber-500' : ''
                          }`}
                        />
                      </button>

                      {(!currency.isFeatured || !currency.isActive) && (
                        <Badge
                          variant={currency.isActive ? 'success' : 'default'}
                          className="text-[10px]"
                        >
                          {currency.isActive ? ct.status.active : ct.status.hidden}
                        </Badge>
                      )}
                    </div>
                  </div>

                  {/* Financial Rate Box */}
                  <div className="mt-4 rounded-xl bg-zinc-50 dark:bg-zinc-900/60 p-3 border border-zinc-100 dark:border-zinc-800/80 group">
                    <div className="flex items-center justify-between text-[10px] font-bold uppercase tracking-wider text-zinc-400 mb-1">
                      <span>{ct.card.valuationVs} {baseCurrency?.code || 'EGP'}</span>
                      <button
                        onClick={() => handleCopyRate(currency.code, relativeRate)}
                        title={ct.actions.copyRate}
                        className="flex items-center gap-1 text-zinc-400 hover:text-zinc-900 dark:hover:text-white transition cursor-pointer"
                      >
                        {isCopied ? (
                          <span className="flex items-center gap-0.5 text-emerald-600 dark:text-emerald-400 text-[10px]">
                            <Check className="h-3 w-3" />
                          </span>
                        ) : (
                          <Copy className="h-3 w-3" />
                        )}
                      </button>
                    </div>

                    <div className="flex items-baseline justify-between">
                      <div className="font-mono font-black text-xl text-zinc-950 dark:text-white tracking-tight flex items-baseline gap-1.5">
                        <span className="text-sm font-bold text-zinc-400">1 {currency.code} =</span>
                        <span className="text-blue-600 dark:text-blue-400 font-extrabold text-2xl">
                          {formatRate(relativeRate)}
                        </span>
                        <span className="text-xs font-semibold text-zinc-500">
                          {baseCurrency?.code || 'EGP'}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Card Footer: Metadata & Quick Action Switch */}
                <div className="flex items-center justify-between pt-3 mt-3 text-[11px] text-zinc-400 border-t border-zinc-100 dark:border-zinc-800/80">
                  <div className="flex items-center gap-1.5 truncate">
                    <span className="text-zinc-500 font-medium">
                      {ct.card.updated} {formatDate(currency.lastUpdated)}
                    </span>
                  </div>

                  <button
                    onClick={() => toggleActive(currency.code)}
                    disabled={isToggling}
                    className={`flex items-center gap-1.5 font-bold text-xs cursor-pointer px-3 py-1.5 rounded-xl transition ${
                      currency.isActive
                        ? 'bg-zinc-100 hover:bg-rose-50 text-zinc-700 hover:text-rose-600 dark:bg-zinc-800 dark:text-zinc-300 dark:hover:bg-rose-950/40 dark:hover:text-rose-400 border border-zinc-200 dark:border-zinc-700 hover:border-rose-300'
                        : 'bg-emerald-600 hover:bg-emerald-500 text-white shadow-xs'
                    }`}
                  >
                    {currency.isActive ? (
                      <>
                        <EyeOff className="h-3.5 w-3.5" />
                        <span>{ct.actions.hideFromApp}</span>
                      </>
                    ) : (
                      <>
                        <Eye className="h-3.5 w-3.5" />
                        <span>{ct.actions.enableAndShow}</span>
                      </>
                    )}
                  </button>
                </div>
              </Card>
            );
          })}
        </div>
      ) : (
        /* TABLE VIEW */
        <Card className="overflow-hidden border-zinc-200/90 dark:border-zinc-800/90 shadow-2xs rounded-2xl">
          <div className="overflow-x-auto">
            <table className="w-full text-start text-xs">
              <thead className="bg-zinc-50/80 dark:bg-zinc-900/80 border-b border-zinc-200/80 dark:border-zinc-800/80 text-zinc-400 font-bold uppercase text-[10px] tracking-wider">
                <tr>
                  <th className="py-3 px-4 text-start">{ct.table.currency}</th>
                  <th className="py-3 px-4 text-start">{ct.table.symbol}</th>
                  <th className="py-3 px-4 text-start">
                    {ct.table.rateVs} {baseCurrency?.code || 'EGP'}
                  </th>
                  <th className="py-3 px-4 text-start">{ct.table.status}</th>
                  <th className="py-3 px-4 text-start">{ct.table.lastUpdated}</th>
                  <th className="py-3 px-4 text-end">{ct.table.actions}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800/80">
                {filteredCurrencies.map((currency) => {
                  const baseRateEgp = baseCurrency?.exchangeRateToEgp || 1.0;
                  const currencyRateEgp = currency.exchangeRateToEgp || 1.0;
                  const relativeRate = currencyRateEgp / baseRateEgp;
                  const extra = getCurrencyExtra(currency.code);
                  const isCopied = copiedCode === currency.code;

                  return (
                    <tr
                      key={currency.code}
                      className={`hover:bg-zinc-50/70 dark:hover:bg-zinc-900/40 transition ${
                        currency.isFeatured ? 'bg-amber-500/[0.02]' : ''
                      }`}
                    >
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2.5">
                          <span className="text-lg">{extra.flag}</span>
                          <div>
                            <div className="font-bold text-zinc-950 dark:text-white flex items-center gap-1.5">
                              <span>{currency.nameEn}</span>
                              <span className="text-[10px] font-mono text-zinc-500 dark:text-zinc-400 font-bold px-1 py-0.2 rounded-md bg-zinc-100 dark:bg-zinc-800">
                                {currency.code}
                              </span>
                            </div>
                            <div className="text-[11px] text-zinc-400 font-arabic">
                              {currency.nameAr}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4 font-mono font-bold text-zinc-900 dark:text-white">
                        {currency.symbol}
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2 font-mono font-bold text-sm text-zinc-900 dark:text-white">
                          <span className="text-blue-600 dark:text-blue-400 font-extrabold">
                            {formatRate(relativeRate)}
                          </span>
                          <span className="text-xs text-zinc-400 font-normal">
                            {baseCurrency?.code || 'EGP'}
                          </span>
                          <button
                            onClick={() => handleCopyRate(currency.code, relativeRate)}
                            title={ct.actions.copyRate}
                            className="text-zinc-400 hover:text-zinc-800 dark:hover:text-white cursor-pointer"
                          >
                            {isCopied ? <Check className="h-3 w-3 text-emerald-500" /> : <Copy className="h-3 w-3" />}
                          </button>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <Badge
                          variant={currency.isActive ? 'success' : 'default'}
                          className="text-[10px]"
                        >
                          {currency.isActive ? ct.status.active : ct.status.hidden}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 text-zinc-400 text-[11px] font-mono">
                        {formatDate(currency.lastUpdated)}
                      </td>
                      <td className="py-3 px-4 text-end">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => toggleFeatured(currency.code)}
                            disabled={isTogglingFeatured}
                            title={ct.actions.toggleFeatured}
                            className={`p-1.5 rounded-xl transition cursor-pointer ${
                              currency.isFeatured
                                ? 'text-amber-500 fill-amber-400 bg-amber-500/15 border border-amber-500/30'
                                : 'text-zinc-300 dark:text-zinc-600 hover:text-amber-500 hover:bg-amber-500/10'
                            }`}
                          >
                            <Star
                              className={`h-4 w-4 ${
                                currency.isFeatured ? 'fill-amber-400 text-amber-500' : ''
                              }`}
                            />
                          </button>
                          <button
                            onClick={() => toggleActive(currency.code)}
                            disabled={isToggling}
                            className={`flex items-center gap-1 font-bold text-xs cursor-pointer px-2.5 py-1 rounded-xl transition ${
                              currency.isActive
                                ? 'bg-zinc-100 hover:bg-rose-50 text-zinc-700 hover:text-rose-600 dark:bg-zinc-800 dark:text-zinc-300 dark:hover:bg-rose-950/40 dark:hover:text-rose-400 border border-zinc-200 dark:border-zinc-700'
                                : 'bg-emerald-600 hover:bg-emerald-500 text-white shadow-xs'
                            }`}
                          >
                            {currency.isActive ? (
                              <>
                                <EyeOff className="h-3 w-3" />
                                <span>{ct.actions.hideFromApp}</span>
                              </>
                            ) : (
                              <>
                                <Eye className="h-3 w-3" />
                                <span>{ct.actions.enableAndShow}</span>
                              </>
                            )}
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  );
};
