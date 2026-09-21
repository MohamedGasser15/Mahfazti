import { useState, useEffect, useMemo, useCallback } from 'react';
import type { AuditLogEntry, AuditLogStats } from '../types';
import { auditLogsService } from '../services/auditLogsService';

export const useAuditLogs = () => {
  const [allLogs, setAllLogs] = useState<AuditLogEntry[]>([]);
  const [backendStats, setBackendStats] = useState<AuditLogStats | null>(null);
  const [categoryFilter, setCategoryFilter] = useState<string>('all');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [currentPage, setCurrentPage] = useState<number>(1);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [isRefreshing, setIsRefreshing] = useState<boolean>(false);
  const pageSize = 10;

  // Initial fetch on mount
  useEffect(() => {
    let ignore = false;

    Promise.all([
      auditLogsService.getLogs({ page: 1, pageSize: 500 }),
      auditLogsService.getStats(),
    ])
      .then(([logsData, statsData]) => {
        if (!ignore) {
          setAllLogs(logsData.items || []);
          setBackendStats(statsData);
          setIsLoading(false);
        }
      })
      .catch(() => {
        if (!ignore) {
          setIsLoading(false);
        }
      });

    return () => {
      ignore = true;
    };
  }, []);

  // Manual refetch
  const refetch = useCallback(async () => {
    setIsRefreshing(true);
    try {
      const [logsData, statsData] = await Promise.all([
        auditLogsService.getLogs({ page: 1, pageSize: 500 }),
        auditLogsService.getStats(),
      ]);
      setAllLogs(logsData.items || []);
      setBackendStats(statsData);
    } finally {
      setIsRefreshing(false);
    }
  }, []);

  // Category counts
  const categoryCounts = useMemo(() => {
    const counts: Record<string, number> = {
      all: allLogs.length,
      'User Management': 0,
      Security: 0,
      'Billing & Pricing': 0,
      System: 0,
    };

    allLogs.forEach((log) => {
      const cat = log.category;
      if (counts[cat] !== undefined) {
        counts[cat]++;
      } else {
        counts[cat] = 1;
      }
    });

    return counts;
  }, [allLogs]);

  // Dynamic or backend stats
  const stats = useMemo<AuditLogStats>(() => {
    if (backendStats && backendStats.totalLogs > 0) {
      return backendStats;
    }
    const totalLogs = allLogs.length;
    const userManagementCount = allLogs.filter(
      (l) => l.category?.toLowerCase() === 'user management'
    ).length;
    const securityCount = allLogs.filter(
      (l) => l.category?.toLowerCase() === 'security'
    ).length;
    const warningsAndFailuresCount = allLogs.filter(
      (l) => l.status?.toLowerCase() !== 'success'
    ).length;

    return {
      totalLogs,
      userManagementCount,
      securityCount,
      warningsAndFailuresCount,
    };
  }, [allLogs, backendStats]);

  // Instant in-memory filtering (0ms)
  const filteredLogs = useMemo(() => {
    const query = searchTerm.toLowerCase().trim();

    return allLogs.filter((log) => {
      // 1. Category Filter
      if (
        categoryFilter !== 'all' &&
        log.category?.toLowerCase() !== categoryFilter.toLowerCase()
      ) {
        return false;
      }

      // 2. Status Filter
      if (
        statusFilter !== 'all' &&
        log.status?.toLowerCase() !== statusFilter.toLowerCase()
      ) {
        return false;
      }

      // 3. Search Term
      if (query) {
        const matches =
          (log.action && log.action.toLowerCase().includes(query)) ||
          (log.targetResource && log.targetResource.toLowerCase().includes(query)) ||
          (log.adminName && log.adminName.toLowerCase().includes(query)) ||
          (log.adminEmail && log.adminEmail.toLowerCase().includes(query)) ||
          (log.ipAddress && log.ipAddress.toLowerCase().includes(query)) ||
          (log.category && log.category.toLowerCase().includes(query)) ||
          (log.details && log.details.toLowerCase().includes(query));

        if (!matches) return false;
      }

      return true;
    });
  }, [allLogs, categoryFilter, statusFilter, searchTerm]);

  // Dynamic pagination based on filtered logs
  const totalCount = filteredLogs.length;
  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));

  const paginatedLogs = useMemo(() => {
    const startIndex = (currentPage - 1) * pageSize;
    return filteredLogs.slice(startIndex, startIndex + pageSize);
  }, [filteredLogs, currentPage, pageSize]);

  // Filter setters (reset page to 1)
  const handleCategoryFilter = (cat: string) => {
    setCategoryFilter(cat);
    setCurrentPage(1);
  };

  const handleStatusFilter = (st: string) => {
    setStatusFilter(st);
    setCurrentPage(1);
  };

  const handleSearchTerm = (term: string) => {
    setSearchTerm(term);
    setCurrentPage(1);
  };

  const goToPage = (page: number) => {
    setCurrentPage(Math.max(1, Math.min(page, totalPages)));
  };

  const nextPage = () => {
    setCurrentPage((prev) => Math.min(prev + 1, totalPages));
  };

  const prevPage = () => {
    setCurrentPage((prev) => Math.max(prev - 1, 1));
  };

  return {
    logs: paginatedLogs,
    allLogs,
    filteredLogs,
    stats,
    categoryCounts,
    categoryFilter,
    setCategoryFilter: handleCategoryFilter,
    statusFilter,
    setStatusFilter: handleStatusFilter,
    searchTerm,
    setSearchTerm: handleSearchTerm,
    currentPage,
    totalPages,
    totalCount,
    pageSize,
    goToPage,
    nextPage,
    prevPage,
    isLoading,
    isRefreshing,
    refetch,
  };
};
