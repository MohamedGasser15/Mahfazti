import React, { useState, useEffect } from 'react';
import { Webhook, Plus, CheckCircle2, RefreshCw } from 'lucide-react';
import { developerService } from '../services/developerService';
import type { WebhookEndpoint, WebhookLog } from '../types';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatDate } from '../../../core/utils/formatters';

export const WebhooksPage: React.FC = () => {
  const [endpoints, setEndpoints] = useState<WebhookEndpoint[]>([]);
  const [logs, setLogs] = useState<WebhookLog[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      developerService.getEndpoints(),
      developerService.getWebhookLogs(),
    ]).then(([eps, lgs]) => {
      setEndpoints(eps);
      setLogs(lgs);
      setIsLoading(false);
    });
  }, []);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white flex items-center gap-2">
            <Webhook className="h-6 w-6 text-blue-600 dark:text-blue-500" />
            Webhooks & Payment Integrations
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Real-time HTTP delivery streams for Paymob, Fawry, Apple Pay, and automation bots.
          </p>
        </div>
        <Button variant="primary" size="md">
          <Plus className="h-4 w-4" />
          <span>Add Endpoint</span>
        </Button>
      </div>

      {/* Endpoints Grid */}
      {isLoading ? (
        <div className="p-8 text-center text-zinc-400 text-xs">Loading webhook configurations...</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {endpoints.map((ep) => (
            <Card key={ep.id} className="p-5 space-y-3">
              <div className="flex items-start justify-between">
                <div>
                  <h3 className="text-sm font-bold text-zinc-900 dark:text-white">{ep.service}</h3>
                  <p className="text-xs font-mono text-zinc-500 dark:text-zinc-400 truncate mt-0.5">
                    {ep.url}
                  </p>
                </div>
                <Badge variant={ep.status === 'Active' ? 'success' : 'warning'}>
                  {ep.status}
                </Badge>
              </div>

              <div className="flex items-center justify-between text-xs text-zinc-500 dark:text-zinc-400 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                <div className="flex items-center gap-2 font-medium">
                  <span className="inline-flex items-center gap-1 text-emerald-600 dark:text-emerald-400 font-mono">
                    <CheckCircle2 className="h-3.5 w-3.5" />
                    {ep.lastDeliveryStatus}
                  </span>
                  <span>&bull;</span>
                  <span>{ep.eventsCount.toLocaleString()} deliveries</span>
                </div>
                <span className="text-[11px]">{formatDate(ep.lastTriggeredAt)}</span>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Webhook Activity Stream */}
      <Card className="overflow-hidden p-0">
        <div className="p-4 border-b border-zinc-100 dark:border-zinc-800 flex items-center justify-between">
          <div>
            <h3 className="text-sm font-bold text-zinc-900 dark:text-white">Recent Delivery Logs</h3>
            <p className="text-xs text-zinc-500 dark:text-zinc-400">Incoming payloads and delivery response times</p>
          </div>
          <Button variant="outline" size="sm">
            <RefreshCw className="h-3.5 w-3.5" />
            <span>Refresh</span>
          </Button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-zinc-50/75 dark:bg-zinc-900/50 border-b border-zinc-100 dark:border-zinc-800 text-zinc-500 dark:text-zinc-400 font-semibold uppercase tracking-wider">
              <tr>
                <th className="px-6 py-3.5">Event</th>
                <th className="px-6 py-3.5">Source Gateway</th>
                <th className="px-6 py-3.5">Status</th>
                <th className="px-6 py-3.5">Latency</th>
                <th className="px-6 py-3.5">Payload Preview</th>
                <th className="px-6 py-3.5 text-right">Time</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
              {logs.map((log) => (
                <tr key={log.id} className="hover:bg-zinc-50/50 dark:hover:bg-zinc-900/30">
                  <td className="px-6 py-3 font-mono font-bold text-zinc-900 dark:text-white">
                    {log.event}
                  </td>
                  <td className="px-6 py-3 text-zinc-600 dark:text-zinc-300">
                    {log.source}
                  </td>
                  <td className="px-6 py-3">
                    <Badge variant={log.statusCode === 200 ? 'success' : 'danger'}>
                      {log.statusCode}
                    </Badge>
                  </td>
                  <td className="px-6 py-3 font-mono text-zinc-500 dark:text-zinc-400">
                    {log.durationMs}ms
                  </td>
                  <td className="px-6 py-3 font-mono text-[11px] text-zinc-500 dark:text-zinc-400 max-w-xs truncate">
                    {log.payload}
                  </td>
                  <td className="px-6 py-3 text-right text-zinc-400 whitespace-nowrap">
                    {formatDate(log.timestamp)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
};
