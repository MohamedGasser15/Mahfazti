import React, { useState } from 'react';
import { Search, Download, CheckCircle2, XCircle } from 'lucide-react';
import { useSubscriptions } from '../hooks/useSubscriptions';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatCurrency, formatDate } from '../../../core/utils/formatters';

export const PaymentsPage: React.FC = () => {
  const { payments, isLoading } = useSubscriptions();
  const [searchTerm, setSearchTerm] = useState('');

  const filtered = payments.filter(
    (p) =>
      p.invoiceNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.userEmail.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.gateway.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white">
            Payment Logs & Invoices
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Real-time gateway transactions from Paymob, Fawry, Apple Pay, and Stripe.
          </p>
        </div>

        <Button variant="secondary">
          <Download className="h-4 w-4" />
          <span>Export Invoices</span>
        </Button>
      </div>

      {/* Toolbar */}
      <Card className="p-4">
        <div className="relative">
          <Search className="absolute top-1/2 left-3.5 h-4 w-4 -translate-y-1/2 text-zinc-400 dark:text-zinc-500" />
          <input
            type="text"
            placeholder="Search by invoice number, email, or gateway..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 py-2 pr-4 pl-10 text-xs font-medium text-black dark:text-white placeholder-zinc-400 dark:placeholder-zinc-500 focus:outline-none"
          />
        </div>
      </Card>

      {/* Table */}
      <Card className="p-0 overflow-hidden">
        {isLoading ? (
          <div className="p-8 text-center text-zinc-400 text-xs font-medium">Loading payments...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="border-b border-zinc-100 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900/50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
                <tr>
                  <th className="py-3.5 px-4">Invoice #</th>
                  <th className="py-3.5 px-4">User</th>
                  <th className="py-3.5 px-4">Plan</th>
                  <th className="py-3.5 px-4">Gateway</th>
                  <th className="py-3.5 px-4">Gateway Ref</th>
                  <th className="py-3.5 px-4">Amount</th>
                  <th className="py-3.5 px-4">Date</th>
                  <th className="py-3.5 px-4 text-right">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800/60 text-zinc-700 dark:text-zinc-300">
                {filtered.map((pay) => (
                  <tr key={pay.id} className="hover:bg-zinc-50 dark:hover:bg-zinc-900/40 transition">
                    <td className="py-3.5 px-4 font-mono font-bold text-zinc-900 dark:text-white">
                      {pay.invoiceNumber}
                    </td>
                    <td className="py-3.5 px-4 font-medium text-zinc-700 dark:text-zinc-300">
                      {pay.userEmail}
                    </td>
                    <td className="py-3.5 px-4 font-semibold text-zinc-900 dark:text-white">
                      {pay.planName}
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="rounded-md border border-zinc-200 dark:border-zinc-800 bg-zinc-100 dark:bg-zinc-900 px-2 py-0.5 text-[10px] font-bold text-zinc-700 dark:text-zinc-300">
                        {pay.gateway}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 font-mono text-[11px] text-zinc-400">
                      {pay.transactionRef}
                    </td>
                    <td className="py-3.5 px-4 font-bold text-zinc-900 dark:text-white">
                      {formatCurrency(pay.amount, pay.currency)}
                    </td>
                    <td className="py-3.5 px-4 text-zinc-500 dark:text-zinc-400">
                      {formatDate(pay.createdAt)}
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <Badge variant={pay.status === 'Success' ? 'success' : 'danger'}>
                        {pay.status === 'Success' ? (
                          <CheckCircle2 className="h-3 w-3" />
                        ) : (
                          <XCircle className="h-3 w-3" />
                        )}
                        {pay.status}
                      </Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    </div>
  );
};
