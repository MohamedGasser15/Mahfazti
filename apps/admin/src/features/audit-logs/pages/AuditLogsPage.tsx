import React from 'react';
import { Shield } from 'lucide-react';
import { useAuditLogs } from '../hooks/useAuditLogs';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { formatDate } from '../../../core/utils/formatters';

export const AuditLogsPage: React.FC = () => {
  const { logs, categoryFilter, setCategoryFilter, isLoading } = useAuditLogs();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white flex items-center gap-2">
            <Shield className="h-6 w-6 text-blue-600 dark:text-blue-500" />
            Audit Logs & Security Activity
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Immutable tracking of administrator actions, billing alterations, and security operations.
          </p>
        </div>
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center gap-2 border-b border-zinc-100 dark:border-zinc-800 pb-2 overflow-x-auto">
        {(['all', 'Security', 'User Management', 'Billing & Pricing', 'System'] as const).map((cat) => (
          <button
            key={cat}
            onClick={() => setCategoryFilter(cat)}
            className={`rounded-xl px-4 py-2 text-xs font-semibold whitespace-nowrap transition cursor-pointer ${
              categoryFilter === cat
                ? 'bg-zinc-900 text-white dark:bg-white dark:text-black shadow-xs'
                : 'text-zinc-500 hover:text-black dark:text-zinc-400 dark:hover:text-white'
            }`}
          >
            {cat === 'all' ? 'All Activity' : cat}
          </button>
        ))}
      </div>

      {/* Logs Table */}
      <Card className="overflow-hidden p-0">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-zinc-50/75 dark:bg-zinc-900/50 border-b border-zinc-100 dark:border-zinc-800 text-zinc-500 dark:text-zinc-400 font-semibold uppercase tracking-wider">
              <tr>
                <th className="px-6 py-4">Action / Event</th>
                <th className="px-6 py-4">Target Resource</th>
                <th className="px-6 py-4">Category</th>
                <th className="px-6 py-4">Admin</th>
                <th className="px-6 py-4">IP Address</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4 text-right">Timestamp</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
              {isLoading ? (
                <tr>
                  <td colSpan={7} className="px-6 py-8 text-center text-zinc-400">
                    Loading audit trail...
                  </td>
                </tr>
              ) : logs.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-8 text-center text-zinc-400">
                    No log records match this category.
                  </td>
                </tr>
              ) : (
                logs.map((entry) => (
                  <tr
                    key={entry.id}
                    className="hover:bg-zinc-50/50 dark:hover:bg-zinc-900/30 transition duration-150"
                  >
                    <td className="px-6 py-4 font-semibold text-zinc-900 dark:text-white">
                      {entry.action}
                    </td>
                    <td className="px-6 py-4 font-mono text-zinc-600 dark:text-zinc-400">
                      {entry.targetResource}
                    </td>
                    <td className="px-6 py-4">
                      <span className="rounded-md bg-zinc-100 dark:bg-zinc-800 px-2 py-1 text-[11px] font-medium text-zinc-700 dark:text-zinc-300">
                        {entry.category}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div>
                        <div className="font-semibold text-zinc-900 dark:text-white">
                          {entry.adminName}
                        </div>
                        <div className="text-[11px] text-zinc-400">{entry.adminEmail}</div>
                      </div>
                    </td>
                    <td className="px-6 py-4 font-mono text-[11px] text-zinc-500 dark:text-zinc-400">
                      {entry.ipAddress}
                    </td>
                    <td className="px-6 py-4">
                      <Badge
                        variant={
                          entry.status === 'Success'
                            ? 'success'
                            : entry.status === 'Warning'
                            ? 'warning'
                            : 'danger'
                        }
                      >
                        {entry.status}
                      </Badge>
                    </td>
                    <td className="px-6 py-4 text-right text-zinc-500 dark:text-zinc-400 whitespace-nowrap">
                      {formatDate(entry.createdAt)}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
};
