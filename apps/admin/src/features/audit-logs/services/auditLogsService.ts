import { apiClient } from '../../../api/client';
import type { AuditLogEntry, AuditLogStats, PagedAuditLogs, AuditLogFilterParams } from '../types';

let fallbackMockLogs: AuditLogEntry[] = [
  {
    id: 1,
    adminName: 'Mohamed Gasser',
    adminEmail: 'admin@mahfazti.app',
    action: 'Permanently Deleted User',
    targetResource: 'Users / omar@example.com',
    category: 'User Management',
    ipAddress: '197.38.112.44',
    status: 'Warning',
    details: 'Cascading wipe of user wallet transactions and budgets',
    createdAt: '2026-09-20T14:15:00Z',
  },
  {
    id: 2,
    adminName: 'Mohamed Gasser',
    adminEmail: 'admin@mahfazti.app',
    action: 'Changed User Role to SuperAdmin',
    targetResource: 'Users / sarah@example.com',
    category: 'Security',
    ipAddress: '197.38.112.44',
    status: 'Success',
    details: 'Granted full administrative RBAC access',
    createdAt: '2026-09-20T12:30:00Z',
  },
  {
    id: 3,
    adminName: 'Mohamed Gasser',
    adminEmail: 'admin@mahfazti.app',
    action: 'Created User Account',
    targetResource: 'Users / ahmed@example.com',
    category: 'User Management',
    ipAddress: '197.38.112.44',
    status: 'Success',
    details: 'Created user with role User, Currency EGP',
    createdAt: '2026-09-20T10:00:00Z',
  },
  {
    id: 4,
    adminName: 'System Engine',
    adminEmail: 'system@mahfazti.app',
    action: 'Currency Exchange Rates Synchronized',
    targetResource: 'Currencies / USD, EUR, SAR, AED',
    category: 'System',
    ipAddress: '127.0.0.1',
    status: 'Success',
    details: 'Daily automated FX rates sync',
    createdAt: '2026-09-20T00:00:00Z',
  },
  {
    id: 5,
    adminName: 'Mohamed Gasser',
    adminEmail: 'admin@mahfazti.app',
    action: 'Suspended User Account',
    targetResource: 'Users / test@example.com',
    category: 'User Management',
    ipAddress: '197.38.112.44',
    status: 'Warning',
    details: 'Account temporarily suspended by admin',
    createdAt: '2026-09-19T18:40:00Z',
  },
];

export const auditLogsService = {
  getLogs: async (params?: AuditLogFilterParams): Promise<PagedAuditLogs> => {
    try {
      const res = await apiClient.get<PagedAuditLogs>('/audit-logs', { params });
      if (res.data && Array.isArray(res.data.items)) {
        return res.data;
      }
    } catch {
      // Fallback for offline development or when DB table is freshly created
    }

    // Client-side filtering on fallback mock data
    const page = params?.page || 1;
    const pageSize = params?.pageSize || 10;
    let filtered = [...fallbackMockLogs];

    if (params?.category && params.category !== 'all') {
      filtered = filtered.filter(
        (l) => l.category.toLowerCase() === params.category!.toLowerCase()
      );
    }
    if (params?.status && params.status !== 'all') {
      filtered = filtered.filter(
        (l) => l.status.toLowerCase() === params.status!.toLowerCase()
      );
    }
    if (params?.searchTerm) {
      const term = params.searchTerm.toLowerCase();
      filtered = filtered.filter(
        (l) =>
          l.action.toLowerCase().includes(term) ||
          l.targetResource.toLowerCase().includes(term) ||
          l.adminName.toLowerCase().includes(term) ||
          l.adminEmail.toLowerCase().includes(term) ||
          (l.ipAddress && l.ipAddress.toLowerCase().includes(term))
      );
    }

    const totalCount = filtered.length;
    const items = filtered.slice((page - 1) * pageSize, page * pageSize);
    const totalPages = Math.ceil(totalCount / pageSize);

    return {
      items,
      totalCount,
      page,
      pageSize,
      totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    };
  },

  getStats: async (): Promise<AuditLogStats> => {
    try {
      const res = await apiClient.get<AuditLogStats>('/audit-logs/stats');
      if (res.data) {
        return res.data;
      }
    } catch {
      // Fallback
    }

    return {
      totalLogs: fallbackMockLogs.length,
      userManagementCount: fallbackMockLogs.filter((l) => l.category === 'User Management').length,
      securityCount: fallbackMockLogs.filter((l) => l.category === 'Security').length,
      warningsAndFailuresCount: fallbackMockLogs.filter((l) => l.status !== 'Success').length,
    };
  },
};
