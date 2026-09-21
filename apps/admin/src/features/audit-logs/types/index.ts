export interface AuditLogEntry {
  id: string | number;
  adminId?: number | null;
  adminName: string;
  adminEmail: string;
  action: string;
  targetResource: string;
  category: 'Security' | 'User Management' | 'Billing & Pricing' | 'System' | string;
  ipAddress?: string;
  status: 'Success' | 'Warning' | 'Failed' | string;
  details?: string | null;
  createdAt: string;
}

export interface AuditLogStats {
  totalLogs: number;
  userManagementCount: number;
  securityCount: number;
  warningsAndFailuresCount: number;
}

export interface PagedAuditLogs {
  items: AuditLogEntry[];
  totalCount: number;
  page: number;
  pageSize: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
}

export interface AuditLogFilterParams {
  category?: string;
  searchTerm?: string;
  status?: string;
  page?: number;
  pageSize?: number;
}
