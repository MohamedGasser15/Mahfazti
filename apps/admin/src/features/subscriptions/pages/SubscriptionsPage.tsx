import React, { useState } from 'react';
import {
  CreditCard,
  Search,
  CheckCircle2,
  XCircle,
  Clock,
  Sparkles,
  DollarSign,
  Users,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';
import { useSubscriptions } from '../hooks/useSubscriptions';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatCurrency, formatDate } from '../../../core/utils/formatters';

export const SubscriptionsPage: React.FC = () => {
  const { subscriptions, isLoading } = useSubscriptions();
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'Active' | 'Expired'>('all');
  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 8;

  const handleSearchTerm = (val: string) => {
    setSearchTerm(val);
    setCurrentPage(1);
  };

  const handleStatusFilter = (val: 'all' | 'Active' | 'Expired') => {
    setStatusFilter(val);
    setCurrentPage(1);
  };

  const filtered = subscriptions.filter((s) => {
    const matchSearch =
      s.userName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      s.userEmail.toLowerCase().includes(searchTerm.toLowerCase()) ||
      s.planName.toLowerCase().includes(searchTerm.toLowerCase());
    const matchStatus = statusFilter === 'all' ? true : s.status === statusFilter;
    return matchSearch && matchStatus;
  });

  const totalCount = filtered.length;
  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));
  const validCurrentPage = Math.min(Math.max(1, currentPage), totalPages);

  const paginatedSubscriptions = filtered.slice(
    (validCurrentPage - 1) * pageSize,
    validCurrentPage * pageSize
  );
  const startRecord = totalCount > 0 ? (validCurrentPage - 1) * pageSize + 1 : 0;
  const endRecord = Math.min(validCurrentPage * pageSize, totalCount);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">
            User Subscriptions
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Monitor subscriber tiers, active renewals, and monthly recurring revenue.
          </p>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <Card className="flex items-center gap-4 p-5">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400">
            <DollarSign className="h-6 w-6" />
          </div>
          <div>
            <p className="text-xs font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
              Monthly Recurring (MRR)
            </p>
            <h3 className="text-xl font-black text-zinc-900 dark:text-white">
              EGP 42,850
            </h3>
          </div>
        </Card>

        <Card className="flex items-center gap-4 p-5">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400">
            <Users className="h-6 w-6" />
          </div>
          <div>
            <p className="text-xs font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
              Active Paid Subscribers
            </p>
            <h3 className="text-xl font-black text-zinc-900 dark:text-white">
              348 Users
            </h3>
          </div>
        </Card>

        <Card className="flex items-center gap-4 p-5">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-purple-50 dark:bg-purple-950/40 text-purple-600 dark:text-purple-400">
            <Sparkles className="h-6 w-6" />
          </div>
          <div>
            <p className="text-xs font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
              Annual Plan Share
            </p>
            <h3 className="text-xl font-black text-zinc-900 dark:text-white">
              64.5%
            </h3>
          </div>
        </Card>
      </div>

      {/* Toolbar */}
      <Card className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between p-4">
        <div className="relative flex-1">
          <Search className="absolute top-1/2 left-3.5 h-4 w-4 -translate-y-1/2 text-zinc-400 dark:text-zinc-500" />
          <input
            type="text"
            placeholder="Search by subscriber name, email, or plan..."
            value={searchTerm}
            onChange={(e) => handleSearchTerm(e.target.value)}
            className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 py-2 pr-4 pl-10 text-xs font-medium text-black dark:text-white placeholder-zinc-400 dark:placeholder-zinc-500 focus:outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <select
            value={statusFilter}
            onChange={(e: any) => handleStatusFilter(e.target.value)}
            className="rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 px-3 py-2 text-xs font-semibold text-black dark:text-white focus:outline-none"
          >
            <option value="all">All Statuses</option>
            <option value="Active">Active Only</option>
            <option value="Expired">Expired</option>
          </select>
        </div>
      </Card>

      {/* Table */}
      <Card className="p-0 overflow-hidden">
        {isLoading ? (
          <div className="p-8 text-center text-zinc-400 text-xs font-medium">Loading subscriptions...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="border-b border-zinc-100 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900/50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
                <tr>
                  <th className="py-3.5 px-4">Subscriber</th>
                  <th className="py-3.5 px-4">Plan</th>
                  <th className="py-3.5 px-4">Gateway</th>
                  <th className="py-3.5 px-4">Amount Paid</th>
                  <th className="py-3.5 px-4">Renewal Date</th>
                  <th className="py-3.5 px-4">Auto-Renew</th>
                  <th className="py-3.5 px-4 text-right">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800/60 text-zinc-700 dark:text-zinc-300">
                {paginatedSubscriptions.map((sub) => (
                  <tr key={sub.id} className="hover:bg-zinc-50 dark:hover:bg-zinc-900/40 transition">
                    <td className="py-3.5 px-4">
                      <div>
                        <div className="font-bold text-zinc-900 dark:text-white">{sub.userName}</div>
                        <div className="text-[11px] text-zinc-400">{sub.userEmail}</div>
                      </div>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="inline-flex items-center gap-1 font-semibold text-zinc-900 dark:text-white">
                        <CreditCard className="h-3.5 w-3.5 text-blue-600 dark:text-blue-400" />
                        {sub.planName}
                      </span>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="rounded-md border border-zinc-200 dark:border-zinc-800 bg-zinc-100 dark:bg-zinc-900 px-2 py-0.5 text-[10px] font-bold text-zinc-700 dark:text-zinc-300">
                        {sub.gateway}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 font-bold text-zinc-900 dark:text-white">
                      {formatCurrency(sub.amountPaidEgp)}
                    </td>
                    <td className="py-3.5 px-4 text-zinc-500 dark:text-zinc-400">
                      {formatDate(sub.endDate)}
                    </td>
                    <td className="py-3.5 px-4">
                      {sub.autoRenew ? (
                        <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-600 dark:text-emerald-400">
                          <CheckCircle2 className="h-3.5 w-3.5" />
                          Enabled
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-zinc-400">
                          <XCircle className="h-3.5 w-3.5" />
                          Disabled
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <Badge variant={sub.status === 'Active' ? 'success' : 'danger'}>
                        {sub.status === 'Active' ? (
                          <CheckCircle2 className="h-3 w-3" />
                        ) : (
                          <Clock className="h-3 w-3" />
                        )}
                        {sub.status}
                      </Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      {/* Pagination Toolbar */}
      {!isLoading && totalCount > 0 && (
        <Card className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 p-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
          <p className="text-xs text-zinc-500 dark:text-zinc-400 text-center sm:text-start">
            Showing <strong className="text-zinc-900 dark:text-white font-mono">{startRecord}</strong> to{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{endRecord}</strong> of{' '}
            <strong className="text-zinc-900 dark:text-white font-mono">{totalCount}</strong> subscriptions
          </p>

          <div className="flex items-center justify-center gap-1.5">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setCurrentPage((p) => Math.max(p - 1, 1))}
              disabled={validCurrentPage === 1}
              className="text-xs font-bold px-2.5"
            >
              <ChevronLeft className="h-4 w-4" />
              <span className="ms-1">Prev</span>
            </Button>

            <div className="flex items-center gap-1">
              {Array.from({ length: totalPages }, (_, i) => i + 1).map((p) => (
                <button
                  key={p}
                  type="button"
                  onClick={() => setCurrentPage(p)}
                  className={`h-8 w-8 rounded-xl text-xs font-bold transition-colors cursor-pointer ${
                    validCurrentPage === p
                      ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                      : 'border border-zinc-200 dark:border-zinc-800 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800'
                  }`}
                >
                  {p}
                </button>
              ))}
            </div>

            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
              disabled={validCurrentPage === totalPages}
              className="text-xs font-bold px-2.5"
            >
              <span className="me-1">Next</span>
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        </Card>
      )}
    </div>
  );
};
