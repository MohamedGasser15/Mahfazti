import React, { useState } from 'react';
import {
  CreditCard,
  Search,
  DollarSign,
  Users,
  ChevronLeft,
  ChevronRight,
  RefreshCw,
  TrendingDown,
  Sparkles,
} from 'lucide-react';
import { useSubscriptions } from '../hooks/useSubscriptions';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { formatCurrency, formatDate } from '../../../core/utils/formatters';
import { useLocale } from '../../../core/context/LocaleContext';

export const SubscriptionsPage: React.FC = () => {
  const { isAr } = useLocale();
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'Active' | 'Expired' | 'Canceled'>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 10;

  const {
    subscriptions,
    stats,
    isLoadingSubscriptions,
    refetchSubscriptions,
  } = useSubscriptions({
    status: statusFilter,
    search: searchTerm,
  });

  const handleSearchTerm = (val: string) => {
    setSearchTerm(val);
    setCurrentPage(1);
  };

  const handleStatusFilter = (val: 'all' | 'Active' | 'Expired' | 'Canceled') => {
    setStatusFilter(val);
    setCurrentPage(1);
  };

  const totalCount = subscriptions.length;
  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));
  const validCurrentPage = Math.min(Math.max(1, currentPage), totalPages);

  const paginatedSubscriptions = subscriptions.slice(
    (validCurrentPage - 1) * pageSize,
    validCurrentPage * pageSize
  );
  const startRecord = totalCount > 0 ? (validCurrentPage - 1) * pageSize + 1 : 0;
  const endRecord = Math.min(validCurrentPage * pageSize, totalCount);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-950 dark:text-white flex items-center gap-2.5">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-600 text-white shadow-md">
              <CreditCard className="h-5 w-5" />
            </div>
            <span>{isAr ? 'اشتراكات المستخدمين' : 'User Subscriptions'}</span>
          </h1>
          <p className="text-xs sm:text-sm text-zinc-500 dark:text-zinc-400 mt-1 font-medium">
            {isAr
              ? 'متابعة وتتبع اشتراكات المستخدمين، التجديدات النشطة، والإيرادات الشهرية المتكررة.'
              : 'Monitor subscriber tiers, active renewals, and monthly recurring revenue.'}
          </p>
        </div>

        <button
          onClick={() => refetchSubscriptions()}
          className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold bg-white dark:bg-zinc-900 hover:bg-zinc-100 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-200 border border-zinc-200 dark:border-zinc-700 shadow-2xs transition cursor-pointer self-start sm:self-auto"
        >
          <RefreshCw className={`h-3.5 w-3.5 ${isLoadingSubscriptions ? 'animate-spin' : ''}`} />
          <span>{isAr ? 'تحديث' : 'Refresh'}</span>
        </button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        {/* MRR */}
        <Card className="flex items-center gap-4 p-5 rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-xs">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20">
            <DollarSign className="h-6 w-6" />
          </div>
          <div>
            <p className="text-xs font-bold uppercase tracking-wider text-zinc-400">
              {isAr ? 'الإيراد الشهري المتكرر (MRR)' : 'Monthly Recurring (MRR)'}
            </p>
            <h3 className="text-xl font-mono font-black text-zinc-950 dark:text-white mt-0.5">
              {formatCurrency(stats?.monthlyRecurringRevenue || 0)}
            </h3>
          </div>
        </Card>

        {/* Active Paid Subscribers */}
        <Card className="flex items-center gap-4 p-5 rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-xs">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-500/10 text-blue-600 dark:text-blue-400 border border-blue-500/20">
            <Users className="h-6 w-6" />
          </div>
          <div>
            <p className="text-xs font-bold uppercase tracking-wider text-zinc-400">
              {isAr ? 'المشتركون النشطون' : 'Active Subscribers'}
            </p>
            <h3 className="text-xl font-mono font-black text-zinc-950 dark:text-white mt-0.5">
              {stats?.activePaidSubscribers || 0}
            </h3>
          </div>
        </Card>

        {/* Churn Rate */}
        <Card className="flex items-center gap-4 p-5 rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-xs">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-rose-500/10 text-rose-600 dark:text-rose-400 border border-rose-500/20">
            <TrendingDown className="h-6 w-6" />
          </div>
          <div>
            <p className="text-xs font-bold uppercase tracking-wider text-zinc-400">
              {isAr ? 'معدل الإلغاء (Churn Rate)' : 'Churn Rate'}
            </p>
            <h3 className="text-xl font-mono font-black text-zinc-950 dark:text-white mt-0.5">
              {stats?.churnRatePercentage || 0}%
            </h3>
          </div>
        </Card>
      </div>

      {/* Filters & Search */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="relative w-full max-w-sm">
          <Search className="absolute start-3 top-2.5 h-4 w-4 text-zinc-400" />
          <input
            type="text"
            placeholder={isAr ? 'بحث بالاسم، البريد، أو الباقة...' : 'Search subscriber name, email, or plan...'}
            value={searchTerm}
            onChange={(e) => handleSearchTerm(e.target.value)}
            className="w-full bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl ps-9 pe-4 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-emerald-500 shadow-2xs"
          />
        </div>

        {/* Status Filters */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0">
          {(['all', 'Active', 'Expired', 'Canceled'] as const).map((status) => {
            const label =
              status === 'all'
                ? isAr ? 'الكل' : 'All'
                : status === 'Active'
                ? isAr ? 'نشط' : 'Active'
                : status === 'Expired'
                ? isAr ? 'منتهي' : 'Expired'
                : isAr ? 'ملغي' : 'Canceled';

            return (
              <button
                key={status}
                onClick={() => handleStatusFilter(status)}
                className={`px-3 py-1.5 rounded-xl text-xs font-bold transition cursor-pointer border ${
                  statusFilter === status
                    ? 'bg-zinc-900 text-white dark:bg-white dark:text-zinc-900 border-zinc-900 dark:border-white shadow-2xs'
                    : 'bg-white dark:bg-zinc-900 text-zinc-600 dark:text-zinc-400 border-zinc-200 dark:border-zinc-800 hover:bg-zinc-100 dark:hover:bg-zinc-800'
                }`}
              >
                {label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Table */}
      <div className="rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-xs overflow-hidden">
        {isLoadingSubscriptions ? (
          <div className="p-16 text-center text-zinc-400 text-xs font-medium flex flex-col items-center justify-center gap-3">
            <RefreshCw className="h-6 w-6 animate-spin text-emerald-500" />
            <span>{isAr ? 'جاري تحميل الاشتراكات...' : 'Loading subscriptions...'}</span>
          </div>
        ) : paginatedSubscriptions.length === 0 ? (
          <div className="p-12 text-center text-zinc-400">
            <CreditCard className="h-10 w-10 mx-auto text-zinc-300 dark:text-zinc-700 mb-2" />
            <p className="text-sm font-bold text-zinc-700 dark:text-zinc-300">
              {isAr ? 'لا توجد نتائج اشتراكات مطابقة.' : 'No subscriptions found matching your query.'}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-start text-xs">
              <thead className="bg-zinc-50/70 dark:bg-zinc-900/50 border-b border-zinc-200 dark:border-zinc-800 text-zinc-500 uppercase tracking-wider font-bold">
                <tr>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'المستخدم' : 'Subscriber'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'الباقة' : 'Plan'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'الحالة' : 'Status'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'المبلغ' : 'Amount'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'بوابة الدفع' : 'Gateway'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'فترة الاشتراك' : 'Period'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'تجديد تلقائي' : 'Auto-Renew'}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800/60">
                {paginatedSubscriptions.map((sub) => {
                  const getStatusBadge = (status: string) => {
                    switch (status.toLowerCase()) {
                      case 'active':
                        return <Badge variant="success">{isAr ? 'نشط' : 'Active'}</Badge>;
                      case 'expired':
                        return <Badge variant="warning">{isAr ? 'منتهي' : 'Expired'}</Badge>;
                      case 'canceled':
                        return <Badge variant="danger">{isAr ? 'ملغي' : 'Canceled'}</Badge>;
                      default:
                        return <Badge variant="default">{status}</Badge>;
                    }
                  };

                  return (
                    <tr key={sub.id} className="hover:bg-zinc-50/50 dark:hover:bg-zinc-900/30 transition">
                      <td className="px-5 py-3.5">
                        <div className="font-bold text-zinc-900 dark:text-white">
                          {sub.userName}
                        </div>
                        <div className="text-[11px] text-zinc-400 font-mono">
                          {sub.userEmail}
                        </div>
                      </td>
                      <td className="px-5 py-3.5">
                        <div className="flex items-center gap-1.5 font-bold text-zinc-900 dark:text-zinc-200">
                          <Sparkles className="h-3.5 w-3.5 text-blue-500" />
                          <span>{sub.planName}</span>
                        </div>
                      </td>
                      <td className="px-5 py-3.5">{getStatusBadge(sub.status)}</td>
                      <td className="px-5 py-3.5 font-mono font-bold text-zinc-900 dark:text-white">
                        {formatCurrency(sub.amountPaidEgp)}
                      </td>
                      <td className="px-5 py-3.5">
                        <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                          {sub.gateway}
                        </span>
                      </td>
                      <td className="px-5 py-3.5 text-zinc-500 text-[11px]">
                        <div>{formatDate(sub.startDate)}</div>
                        <div className="text-zinc-400">
                          {isAr ? 'إلى' : 'to'} {formatDate(sub.endDate)}
                        </div>
                      </td>
                      <td className="px-5 py-3.5">
                        <span
                          className={`font-bold ${
                            sub.autoRenew
                              ? 'text-emerald-600 dark:text-emerald-400'
                              : 'text-zinc-400'
                          }`}
                        >
                          {sub.autoRenew ? (isAr ? 'نعم' : 'Yes') : (isAr ? 'لا' : 'No')}
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}

        {/* Pagination */}
        {totalCount > 0 && (
          <div className="flex items-center justify-between px-5 py-3.5 border-t border-zinc-100 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900/30 text-xs">
            <span className="text-zinc-500">
              {isAr
                ? `عرض ${startRecord} إلى ${endRecord} من إجمالي ${totalCount} سجل`
                : `Showing ${startRecord} to ${endRecord} of ${totalCount} subscriptions`}
            </span>
            <div className="flex items-center gap-1.5">
              <button
                disabled={validCurrentPage <= 1}
                onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                className="p-1.5 rounded-lg border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-200 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-zinc-100 dark:hover:bg-zinc-800 transition cursor-pointer"
              >
                <ChevronLeft className="h-4 w-4" />
              </button>
              <span className="px-2.5 font-bold text-zinc-900 dark:text-white">
                {validCurrentPage} / {totalPages}
              </span>
              <button
                disabled={validCurrentPage >= totalPages}
                onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                className="p-1.5 rounded-lg border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-200 disabled:opacity-40 disabled:cursor-not-allowed hover:bg-zinc-100 dark:hover:bg-zinc-800 transition cursor-pointer"
              >
                <ChevronRight className="h-4 w-4" />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
