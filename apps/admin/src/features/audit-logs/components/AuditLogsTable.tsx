import React from 'react';
import {
  Layers,
  Copy,
  Check,
  Eye,
  CheckCircle2,
  AlertTriangle,
  XCircle,
} from 'lucide-react';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { formatDate } from '../../../core/utils/formatters';
import type { AuditLogEntry } from '../types';
import {
  formatAuditAction,
  formatAuditCategory,
  formatAuditStatus,
  formatAdminName,
} from '../utils/auditLocalization';

interface AuditLogsTableProps {
  logs: AuditLogEntry[];
  isAr: boolean;
  copiedId: string | number | null;
  onCopy: (text: string, id: string | number) => void;
  onSelectLog: (log: AuditLogEntry) => void;
  t: any;
}

export const AuditLogsTable: React.FC<AuditLogsTableProps> = ({
  logs,
  isAr,
  copiedId,
  onCopy,
  onSelectLog,
  t,
}) => {
  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'Success':
        return <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />;
      case 'Warning':
        return <AlertTriangle className="h-3.5 w-3.5 text-amber-500" />;
      default:
        return <XCircle className="h-3.5 w-3.5 text-rose-500" />;
    }
  };

  const getStatusVariant = (status: string) => {
    switch (status) {
      case 'Success':
        return 'success';
      case 'Warning':
        return 'warning';
      default:
        return 'danger';
    }
  };

  const getCategoryBadgeVariant = (cat: string) => {
    switch (cat) {
      case 'Security':
        return 'purple';
      case 'User Management':
        return 'info';
      case 'Billing & Pricing':
        return 'warning';
      default:
        return 'default';
    }
  };

  return (
    <Card className="p-0 overflow-hidden bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs min-h-[380px]">
      <div className="overflow-x-auto">
        <table className="w-full text-left rtl:text-right text-xs">
          <thead className="border-b border-zinc-200 dark:border-zinc-800 bg-zinc-50/80 dark:bg-zinc-900/50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            <tr>
              <th className="py-3.5 px-6">{t.auditLogs.table.action}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.targetResource}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.category}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.admin}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.ipAddress}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.status}</th>
              <th className="py-3.5 px-6">{t.auditLogs.table.timestamp}</th>
              <th className="py-3.5 px-6 text-center">{t.auditLogs.table.details}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-zinc-200/70 dark:divide-zinc-800/60 text-zinc-700 dark:text-zinc-300">
            {logs.map((entry) => (
              <tr
                key={entry.id}
                className="hover:bg-zinc-50/80 dark:hover:bg-zinc-800/40 transition-colors"
              >
                {/* Action / Event */}
                <td className="py-3.5 px-6">
                  <div className="flex items-center gap-2.5">
                    <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300">
                      <Layers className="h-4 w-4" />
                    </div>
                    <span className="font-bold text-zinc-950 dark:text-white">
                      {formatAuditAction(entry.action, isAr)}
                    </span>
                  </div>
                </td>

                {/* Target Resource with copy */}
                <td className="py-3.5 px-6">
                  <div className="flex items-center gap-1.5">
                    <span className="font-mono text-zinc-600 dark:text-zinc-400 truncate max-w-[170px]">
                      {entry.targetResource}
                    </span>
                    <button
                      type="button"
                      onClick={() => onCopy(entry.targetResource, `res-${entry.id}`)}
                      title={t.auditLogs.table.copyResource}
                      className="text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 transition-colors cursor-pointer"
                    >
                      {copiedId === `res-${entry.id}` ? (
                        <Check className="h-3 w-3 text-emerald-500" />
                      ) : (
                        <Copy className="h-3 w-3" />
                      )}
                    </button>
                  </div>
                </td>

                {/* Category */}
                <td className="py-3.5 px-6">
                  <Badge
                    variant={getCategoryBadgeVariant(entry.category)}
                    className="text-[11px] font-semibold"
                  >
                    {formatAuditCategory(entry.category, isAr)}
                  </Badge>
                </td>

                {/* Admin info */}
                <td className="py-3.5 px-6">
                  <div>
                    <p className="font-bold text-zinc-950 dark:text-white">
                      {formatAdminName(entry.adminName, isAr)}
                    </p>
                    <p className="text-[11px] text-zinc-400 font-mono">
                      {entry.adminEmail}
                    </p>
                  </div>
                </td>

                {/* IP Address */}
                <td className="py-3.5 px-6 font-mono text-[11px] text-zinc-500 dark:text-zinc-400">
                  {entry.ipAddress || '127.0.0.1'}
                </td>

                {/* Status */}
                <td className="py-3.5 px-6">
                  <Badge
                    variant={getStatusVariant(entry.status)}
                    className="text-[11px] font-bold gap-1"
                  >
                    {getStatusIcon(entry.status)}
                    <span>{formatAuditStatus(entry.status, isAr)}</span>
                  </Badge>
                </td>

                {/* Timestamp */}
                <td className="py-3.5 px-6 text-zinc-500 dark:text-zinc-400 text-[11px] whitespace-nowrap">
                  {formatDate(entry.createdAt, isAr ? 'ar-EG' : 'en-US')}
                </td>

                {/* Details Modal Trigger */}
                <td className="py-3.5 px-6 text-center">
                  <button
                    type="button"
                    onClick={() => onSelectLog(entry)}
                    title={t.auditLogs.table.viewDetails}
                    className="flex h-8 w-8 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 hover:bg-zinc-100 dark:bg-zinc-900 dark:hover:bg-zinc-800 text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white mx-auto transition-colors cursor-pointer"
                  >
                    <Eye className="h-4 w-4" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  );
};
