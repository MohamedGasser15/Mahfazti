import React from 'react';
import { ArrowUpRight, ArrowDownRight } from 'lucide-react';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { formatCurrency } from '../../../core/utils/formatters';
import type { QuickTransaction } from '../types';

export const RecentTransactionsTable: React.FC<{ transactions: QuickTransaction[] }> = ({
  transactions,
}) => {
  return (
    <Card className="p-5">
      <div className="mb-4">
        <h3 className="text-base font-bold text-slate-900 dark:text-slate-100">Recent Global Transactions</h3>
        <p className="text-xs text-slate-500 dark:text-slate-400">Latest activity registered across Mahfazti accounts</p>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-slate-200 dark:border-slate-800 text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">
            <tr>
              <th className="py-3 px-4">User</th>
              <th className="py-3 px-4">Category</th>
              <th className="py-3 px-4">Type</th>
              <th className="py-3 px-4">Amount</th>
              <th className="py-3 px-4 text-right">Time</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 dark:divide-slate-800/60 text-slate-700 dark:text-slate-300">
            {transactions.map((tx) => (
              <tr key={tx.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/30 transition">
                <td className="py-3.5 px-4">
                  <div>
                    <div className="font-semibold text-slate-900 dark:text-slate-200">{tx.userName}</div>
                    <div className="text-xs text-slate-500">{tx.userEmail}</div>
                  </div>
                </td>
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
                <td className="py-3.5 px-4 text-right text-xs text-slate-400 dark:text-slate-500">{tx.timeAgo}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  );
};
