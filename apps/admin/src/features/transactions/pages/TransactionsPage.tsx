import React from 'react';
import { Search, Filter, ArrowUpRight, ArrowDownRight, Download, ChevronLeft, ChevronRight } from 'lucide-react';
import { useTransactions } from '../hooks/useTransactions';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatCurrency, formatDate } from '../../../core/utils/formatters';

export const TransactionsPage: React.FC = () => {
  const {
    transactions,
    totalCount,
    currentPage,
    pageSize,
    totalPages,
    goToPage,
    nextPage,
    prevPage,
    searchTerm,
    setSearchTerm,
    typeFilter,
    setTypeFilter,
    isLoading,
  } = useTransactions();

  const startRecord = totalCount > 0 ? (currentPage - 1) * pageSize + 1 : 0;
  const endRecord = Math.min(currentPage * pageSize, totalCount);

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">Transactions Oversight</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400">
            Real-time feed of all recorded financial movements and wallet balances.
          </p>
        </div>

        <Button variant="secondary">
          <Download className="h-4 w-4" />
          <span>Export CSV</span>
        </Button>
      </div>

      {/* Filter Toolbar */}
      <Card className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between p-4">
        <div className="relative flex-1">
          <Search className="absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-slate-400 dark:text-slate-500" />
          <input
            type="text"
            placeholder="Search transactions by user, category or note..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/60 py-2 pr-4 pl-9 text-sm text-slate-800 dark:text-slate-200 placeholder-slate-400 dark:placeholder-slate-500 focus:border-blue-600 focus:outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <Filter className="h-4 w-4 text-slate-500 dark:text-slate-400" />
          <select
            value={typeFilter}
            onChange={(e: any) => setTypeFilter(e.target.value)}
            className="rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/80 px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:border-blue-600 focus:outline-none"
          >
            <option value="all">All Types</option>
            <option value="Income">Income (دخل)</option>
            <option value="Expense">Expense (مصروف)</option>
          </select>
        </div>
      </Card>

      {/* Transactions Table */}
      <Card className="p-0 overflow-hidden">
        {isLoading ? (
          <div className="p-8 text-center text-slate-400">Loading transactions...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="border-b border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-900/80 text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                <tr>
                  <th className="py-3.5 px-4">Transaction ID</th>
                  <th className="py-3.5 px-4">User</th>
                  <th className="py-3.5 px-4">Wallet</th>
                  <th className="py-3.5 px-4">Category</th>
                  <th className="py-3.5 px-4">Type</th>
                  <th className="py-3.5 px-4">Amount</th>
                  <th className="py-3.5 px-4">Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800/60 text-slate-700 dark:text-slate-300">
                {transactions.map((tx) => (
                  <tr key={tx.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/30 transition">
                    <td className="py-3.5 px-4 font-mono text-xs text-slate-500 dark:text-slate-400">{tx.id}</td>
                    <td className="py-3.5 px-4">
                      <span className="font-semibold text-slate-900 dark:text-slate-200">{tx.userEmail}</span>
                    </td>
                    <td className="py-3.5 px-4 text-xs text-slate-500 dark:text-slate-400">{tx.walletName}</td>
                    <td className="py-3.5 px-4">
                      <span className="rounded-lg border border-slate-200 dark:border-slate-700 bg-slate-100 dark:bg-slate-800/80 px-2.5 py-1 text-xs font-medium text-slate-700 dark:text-slate-300">
                        {tx.category}
                      </span>
                    </td>
                    <td className="py-3.5 px-4">
                      <Badge variant={tx.type === 'Income' ? 'success' : 'danger'}>
                        {tx.type === 'Income' ? (
                          <ArrowUpRight className="h-3 w-3" />
                        ) : (
                          <ArrowDownRight className="h-3 w-3" />
                        )}
                        {tx.type}
                      </Badge>
                    </td>
                    <td className="py-3.5 px-4 font-bold text-slate-900 dark:text-slate-100">
                      {tx.type === 'Income' ? '+' : '-'} {formatCurrency(tx.amount)}
                    </td>
                    <td className="py-3.5 px-4 text-xs text-slate-500 dark:text-slate-400">
                      {formatDate(tx.createdAt)}
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
            <strong className="text-zinc-900 dark:text-white font-mono">{totalCount}</strong> transactions
          </p>

          <div className="flex items-center justify-center gap-1.5">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={prevPage}
              disabled={currentPage === 1}
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
                  onClick={() => goToPage(p)}
                  className={`h-8 w-8 rounded-xl text-xs font-bold transition-colors cursor-pointer ${
                    currentPage === p
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
              onClick={nextPage}
              disabled={currentPage === totalPages}
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
