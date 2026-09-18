import { useState, useEffect } from 'react';
import type { AuditLogEntry } from '../types';
import { auditLogsService } from '../services/auditLogsService';

export const useAuditLogs = () => {
  const [logs, setLogs] = useState<AuditLogEntry[]>([]);
  const [categoryFilter, setCategoryFilter] = useState<'all' | AuditLogEntry['category']>('all');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    auditLogsService.getLogs().then((res) => {
      setLogs(res);
      setIsLoading(false);
    });
  }, []);

  const filtered = logs.filter((l) => (categoryFilter === 'all' ? true : l.category === categoryFilter));

  return {
    logs: filtered,
    categoryFilter,
    setCategoryFilter,
    isLoading,
  };
};
