import React from 'react';
import { Mic, CheckCircle2, Sparkles, Clock, AlertTriangle } from 'lucide-react';
import { useAiLogs } from '../hooks/useAiLogs';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';

export const AiLogsPage: React.FC = () => {
  const { logs, isLoading } = useAiLogs();

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">Voice & AI Engine Logs</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400">
            Inspect Natural Language Processing (NLP) results, success rates, and voice parsing accuracy.
          </p>
        </div>
      </div>

      {/* Overview Cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <Card className="flex items-center gap-3.5 p-5">
          <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-emerald-50 dark:bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
            <CheckCircle2 className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs text-slate-500 dark:text-slate-400 font-semibold uppercase tracking-wider">
              Successful Extractions
            </p>
            <h3 className="text-xl font-bold text-slate-900 dark:text-white">98.2%</h3>
          </div>
        </Card>

        <Card className="flex items-center gap-3.5 p-5">
          <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-blue-50 dark:bg-blue-600/10 text-blue-600 dark:text-blue-400">
            <Clock className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs text-slate-500 dark:text-slate-400 font-semibold uppercase tracking-wider">
              Avg Latency
            </p>
            <h3 className="text-xl font-bold text-slate-900 dark:text-white">410 ms</h3>
          </div>
        </Card>

        <Card className="flex items-center gap-3.5 p-5">
          <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-purple-50 dark:bg-purple-500/10 text-purple-600 dark:text-purple-400">
            <Sparkles className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs text-slate-500 dark:text-slate-400 font-semibold uppercase tracking-wider">
              Supported Dialects
            </p>
            <h3 className="text-xl font-bold text-slate-900 dark:text-white">Egyptian Arabic</h3>
          </div>
        </Card>
      </div>

      {/* Logs Table */}
      <Card className="p-0 overflow-hidden">
        {isLoading ? (
          <div className="p-8 text-center text-slate-400">Loading AI logs...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="border-b border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-900/80 text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                <tr>
                  <th className="py-3.5 px-4">User</th>
                  <th className="py-3.5 px-4">Voice Speech Text (العامية المصرية)</th>
                  <th className="py-3.5 px-4">Extracted Output</th>
                  <th className="py-3.5 px-4">Confidence</th>
                  <th className="py-3.5 px-4">Latency</th>
                  <th className="py-3.5 px-4 text-right">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800/60 text-slate-700 dark:text-slate-300">
                {logs.map((log) => (
                  <tr key={log.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/30 transition">
                    <td className="py-3.5 px-4 text-xs text-slate-500 dark:text-slate-400">{log.userEmail}</td>
                    <td className="py-3.5 px-4">
                      <div className="flex items-center gap-2">
                        <Mic className="h-4 w-4 text-blue-600 dark:text-blue-400 shrink-0" />
                        <span className="font-arabic font-medium text-slate-900 dark:text-slate-100 text-sm dir-rtl">
                          "{log.rawText}"
                        </span>
                      </div>
                    </td>
                    <td className="py-3.5 px-4">
                      {log.isSuccess ? (
                        <div className="flex items-center gap-2 text-xs">
                          <span className="font-bold text-emerald-600 dark:text-emerald-400">
                            {log.parsedAmount} EGP
                          </span>
                          <span className="text-slate-400">&bull;</span>
                          <span className="text-slate-700 dark:text-slate-300 font-medium">{log.parsedCategory}</span>
                          <span className="text-slate-400">({log.parsedType})</span>
                        </div>
                      ) : (
                        <span className="text-xs text-rose-600 dark:text-rose-400 flex items-center gap-1">
                          <AlertTriangle className="h-3 w-3" />
                          {log.errorMessage}
                        </span>
                      )}
                    </td>
                    <td className="py-3.5 px-4 font-mono text-xs">
                      <span
                        className={
                          log.confidenceScore && log.confidenceScore > 0.8
                            ? 'text-emerald-600 dark:text-emerald-400 font-semibold'
                            : 'text-amber-600 dark:text-amber-400 font-semibold'
                        }
                      >
                        {log.confidenceScore ? `${Math.round(log.confidenceScore * 100)}%` : 'N/A'}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-xs font-mono text-slate-500 dark:text-slate-400">
                      {log.durationMs} ms
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      <Badge variant={log.isSuccess ? 'success' : 'danger'}>
                        {log.isSuccess ? 'Success' : 'Failed'}
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
