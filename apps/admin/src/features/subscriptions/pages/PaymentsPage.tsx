import React, { useState } from 'react';
import { Search, Download, CheckCircle2, XCircle, RefreshCw, Receipt, Clock } from 'lucide-react';
import { useSubscriptions } from '../hooks/useSubscriptions';
import { Badge } from '../../../core/components/ui/Badge';
import { formatCurrency, formatDate } from '../../../core/utils/formatters';
import { useLocale } from '../../../core/context/LocaleContext';
import { toast } from 'sonner';

export const PaymentsPage: React.FC = () => {
  const { isAr } = useLocale();
  const { payments, isLoadingPayments, refetchPayments } = useSubscriptions();
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'Success' | 'Failed' | 'Refunded'>('all');

  const filtered = payments.filter((p) => {
    const matchSearch =
      p.invoiceNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.userEmail.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.planName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.gateway.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.transactionRef.toLowerCase().includes(searchTerm.toLowerCase());

    const matchStatus = statusFilter === 'all' ? true : p.status === statusFilter;
    return matchSearch && matchStatus;
  });

  const handleExportCsv = () => {
    if (filtered.length === 0) {
      toast.error(isAr ? 'لا توجد مدفوعات لتصديرها.' : 'No payments to export.');
      return;
    }

    const headers = ['InvoiceNumber', 'UserEmail', 'PlanName', 'Amount', 'Currency', 'Gateway', 'Status', 'TransactionRef', 'Date'];
    const rows = filtered.map((p) => [
      p.invoiceNumber,
      p.userEmail,
      p.planName,
      p.amount,
      p.currency,
      p.gateway,
      p.status,
      p.transactionRef,
      p.createdAt,
    ]);

    const csvContent = 'data:text/csv;charset=utf-8,' + [headers.join(','), ...rows.map((e) => e.join(','))].join('\n');
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', `payments_export_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    toast.success(isAr ? 'تم تصدير ملف الـ CSV بنجاح.' : 'Payments exported to CSV successfully.');
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-950 dark:text-white flex items-center gap-2.5">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-600 text-white shadow-md">
              <Receipt className="h-5 w-5" />
            </div>
            <span>{isAr ? 'سجل المدفوعات والفواتير' : 'Payment Logs & Invoices'}</span>
          </h1>
          <p className="text-xs sm:text-sm text-zinc-500 dark:text-zinc-400 mt-1 font-medium">
            {isAr
              ? 'سجل المعاملات والعمليات المالية المباشرة عبر Paymob و Fawry و Apple Pay و Stripe.'
              : 'Real-time gateway transactions from Paymob, Fawry, Apple Pay, and Stripe.'}
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={() => refetchPayments()}
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold bg-white dark:bg-zinc-900 hover:bg-zinc-100 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-200 border border-zinc-200 dark:border-zinc-700 shadow-2xs transition cursor-pointer"
          >
            <RefreshCw className={`h-3.5 w-3.5 ${isLoadingPayments ? 'animate-spin' : ''}`} />
            <span>{isAr ? 'تحديث' : 'Refresh'}</span>
          </button>

          <button
            onClick={handleExportCsv}
            className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-blue-600 hover:bg-blue-700 text-white shadow-md hover:shadow-lg transition cursor-pointer"
          >
            <Download className="h-4 w-4" />
            <span>{isAr ? 'تصدير ملف CSV' : 'Export CSV'}</span>
          </button>
        </div>
      </div>

      {/* Filter Tabs & Search Bar */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between bg-white dark:bg-[#121215] p-3 rounded-2xl border border-zinc-200 dark:border-zinc-800 shadow-xs">
        <div className="flex items-center gap-1.5 p-1 bg-zinc-100 dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800">
          {(['all', 'Success', 'Failed', 'Refunded'] as const).map((st) => {
            const label =
              st === 'all'
                ? isAr ? 'الكل' : 'All'
                : st === 'Success'
                ? isAr ? 'ناجحة' : 'Success'
                : st === 'Failed'
                ? isAr ? 'فاشلة' : 'Failed'
                : isAr ? 'مسترجعة' : 'Refunded';

            return (
              <button
                key={st}
                onClick={() => setStatusFilter(st)}
                className={`px-3.5 py-1.5 rounded-lg text-xs font-bold transition cursor-pointer ${
                  statusFilter === st
                    ? 'bg-white dark:bg-zinc-800 text-zinc-950 dark:text-white shadow-2xs'
                    : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white'
                }`}
              >
                {label}
              </button>
            );
          })}
        </div>

        <div className="relative w-full sm:w-72">
          <Search className="absolute start-3 top-2.5 h-4 w-4 text-zinc-400" />
          <input
            type="text"
            placeholder={isAr ? 'بحث برقم الفاتورة، البريد...' : 'Search invoice, email, ref...'}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl ps-9 pe-4 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 shadow-2xs"
          />
        </div>
      </div>

      {/* Payments Table */}
      <div className="rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-xs overflow-hidden">
        {isLoadingPayments ? (
          <div className="p-16 text-center text-zinc-400 text-xs font-medium flex flex-col items-center justify-center gap-3">
            <RefreshCw className="h-6 w-6 animate-spin text-blue-500" />
            <span>{isAr ? 'جاري تحميل سجل المدفوعات...' : 'Loading payments...'}</span>
          </div>
        ) : filtered.length === 0 ? (
          <div className="p-12 text-center text-zinc-400">
            <Receipt className="h-10 w-10 mx-auto text-zinc-300 dark:text-zinc-700 mb-2" />
            <p className="text-sm font-bold text-zinc-700 dark:text-zinc-300">
              {isAr ? 'لا توجد فواتير أو مدفوعات تطابق معايير البحث.' : 'No payment records found matching your filters.'}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-start text-xs">
              <thead className="bg-zinc-50/70 dark:bg-zinc-900/50 border-b border-zinc-200 dark:border-zinc-800 text-zinc-500 uppercase tracking-wider font-bold">
                <tr>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'رقم الفاتورة' : 'Invoice'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'المستخدم' : 'Customer'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'الباقة' : 'Plan'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'المبلغ' : 'Amount'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'بوابة الدفع' : 'Gateway'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'المرجع' : 'Reference'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'الحالة' : 'Status'}</th>
                  <th className="px-5 py-3.5 text-start">{isAr ? 'التاريخ' : 'Date'}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800/60">
                {filtered.map((payment) => {
                  const getStatusBadge = (status: string) => {
                    switch (status.toLowerCase()) {
                      case 'success':
                        return (
                          <Badge variant="success" className="gap-1">
                            <CheckCircle2 className="h-3 w-3" />
                            <span>{isAr ? 'ناجحة' : 'Success'}</span>
                          </Badge>
                        );
                      case 'failed':
                        return (
                          <Badge variant="danger" className="gap-1">
                            <XCircle className="h-3 w-3" />
                            <span>{isAr ? 'فاشلة' : 'Failed'}</span>
                          </Badge>
                        );
                      case 'refunded':
                        return (
                          <Badge variant="warning">
                            {isAr ? 'مسترجعة' : 'Refunded'}
                          </Badge>
                        );
                      default:
                        return <Badge variant="default">{payment.status}</Badge>;
                    }
                  };

                  return (
                    <tr key={payment.id} className="hover:bg-zinc-50/50 dark:hover:bg-zinc-900/30 transition">
                      <td className="px-5 py-3.5 font-mono font-bold text-zinc-900 dark:text-white">
                        {payment.invoiceNumber}
                      </td>
                      <td className="px-5 py-3.5">
                        <span className="font-mono text-zinc-600 dark:text-zinc-300">
                          {payment.userEmail}
                        </span>
                      </td>
                      <td className="px-5 py-3.5 font-semibold text-zinc-800 dark:text-zinc-200">
                        {payment.planName}
                      </td>
                      <td className="px-5 py-3.5 font-mono font-bold text-zinc-900 dark:text-white">
                        {formatCurrency(payment.amount)}
                      </td>
                      <td className="px-5 py-3.5">
                        <span className="px-2 py-0.5 rounded-md bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 font-semibold text-[11px]">
                          {payment.gateway}
                        </span>
                      </td>
                      <td className="px-5 py-3.5 font-mono text-[11px] text-zinc-400">
                        {payment.transactionRef}
                      </td>
                      <td className="px-5 py-3.5">{getStatusBadge(payment.status)}</td>
                      <td className="px-5 py-3.5 text-zinc-400 text-[11px] flex items-center gap-1 mt-1">
                        <Clock className="h-3 w-3" />
                        <span>{formatDate(payment.createdAt)}</span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};
