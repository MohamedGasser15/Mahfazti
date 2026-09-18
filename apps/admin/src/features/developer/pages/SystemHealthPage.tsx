import React, { useState, useEffect } from 'react';
import { Activity, CheckCircle2, Zap, Server, Database } from 'lucide-react';
import { developerService } from '../services/developerService';
import type { SystemHealthMetric } from '../types';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';

export const SystemHealthPage: React.FC = () => {
  const [metrics, setMetrics] = useState<SystemHealthMetric[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    developerService.getHealthMetrics().then((data) => {
      setMetrics(data);
      setIsLoading(false);
    });
  }, []);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-white flex items-center gap-2">
            <Activity className="h-6 w-6 text-emerald-600 dark:text-emerald-500" />
            System Health & AI Infrastructure
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Real-time status of Whisper AI voice recognition engine, database nodes, and API clusters.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="flex h-2.5 w-2.5 rounded-full bg-emerald-500 animate-pulse" />
          <span className="text-xs font-semibold text-emerald-600 dark:text-emerald-400">
            All Systems Operational
          </span>
        </div>
      </div>

      {/* Top High-level KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card className="p-5">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-zinc-500 dark:text-zinc-400">
              Voice AI Recognition Latency
            </span>
            <Zap className="h-4 w-4 text-blue-500" />
          </div>
          <p className="text-2xl font-extrabold text-zinc-900 dark:text-white mt-2">
            142 <span className="text-xs font-normal text-zinc-400">ms (avg)</span>
          </p>
          <span className="text-[11px] text-emerald-600 font-medium">Whisper Large v3 (Fast)</span>
        </Card>

        <Card className="p-5">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-zinc-500 dark:text-zinc-400">
              Platform Global Uptime
            </span>
            <Server className="h-4 w-4 text-emerald-500" />
          </div>
          <p className="text-2xl font-extrabold text-zinc-900 dark:text-white mt-2">
            99.98%
          </p>
          <span className="text-[11px] text-zinc-400 font-medium">Last 90 days rolling</span>
        </Card>

        <Card className="p-5">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-zinc-500 dark:text-zinc-400">
              Database Connection Pool
            </span>
            <Database className="h-4 w-4 text-purple-500" />
          </div>
          <p className="text-2xl font-extrabold text-zinc-900 dark:text-white mt-2">
            24 / 100
          </p>
          <span className="text-[11px] text-emerald-600 font-medium">Healthy throughput</span>
        </Card>
      </div>

      {/* Nodes Status Table */}
      <Card className="overflow-hidden p-0">
        <div className="p-4 border-b border-zinc-100 dark:border-zinc-800">
          <h3 className="text-sm font-bold text-zinc-900 dark:text-white">Services & Nodes Health</h3>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-zinc-50/75 dark:bg-zinc-900/50 border-b border-zinc-100 dark:border-zinc-800 text-zinc-500 dark:text-zinc-400 font-semibold uppercase tracking-wider">
              <tr>
                <th className="px-6 py-3.5">Service Node</th>
                <th className="px-6 py-3.5">Status</th>
                <th className="px-6 py-3.5">Latency</th>
                <th className="px-6 py-3.5">Uptime (30d)</th>
                <th className="px-6 py-3.5">Workload / Metrics</th>
                <th className="px-6 py-3.5 text-right">Checked</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100 dark:divide-zinc-800">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-zinc-400">
                    Inspecting service health...
                  </td>
                </tr>
              ) : (
                metrics.map((m, idx) => (
                  <tr key={idx} className="hover:bg-zinc-50/50 dark:hover:bg-zinc-900/30">
                    <td className="px-6 py-4 font-semibold text-zinc-900 dark:text-white">
                      {m.service}
                    </td>
                    <td className="px-6 py-4">
                      <Badge variant={m.status === 'Healthy' ? 'success' : 'warning'}>
                        <CheckCircle2 className="h-3 w-3" />
                        {m.status}
                      </Badge>
                    </td>
                    <td className="px-6 py-4 font-mono text-zinc-600 dark:text-zinc-300">
                      {m.latencyMs}ms
                    </td>
                    <td className="px-6 py-4 font-semibold text-emerald-600 dark:text-emerald-400">
                      {m.uptimePercent}%
                    </td>
                    <td className="px-6 py-4 text-zinc-500 dark:text-zinc-400">
                      {m.load}
                    </td>
                    <td className="px-6 py-4 text-right text-zinc-400">
                      {m.lastChecked}
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
