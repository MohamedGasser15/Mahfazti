import type { AuditLogEntry } from '../types';

let mockAuditLogs: AuditLogEntry[] = [
  {
    id: 'aud-1',
    adminName: 'Mohamed Gasser',
    adminEmail: 'admin@mahfazti.app',
    action: 'Created Promo Code "LAUNCH50"',
    targetResource: 'PromoCodes / LAUNCH50',
    category: 'Billing & Pricing',
    ipAddress: '197.38.112.44',
    status: 'Success',
    createdAt: '2026-09-18T22:15:00Z',
  },
  {
    id: 'aud-2',
    adminName: 'Mohamed Gasser',
    adminEmail: 'admin@mahfazti.app',
    action: 'Toggled User Status to Blocked',
    targetResource: 'Users / omar@example.com',
    category: 'User Management',
    ipAddress: '197.38.112.44',
    status: 'Warning',
    createdAt: '2026-09-18T16:40:00Z',
  },
  {
    id: 'aud-3',
    adminName: 'System Engine',
    adminEmail: 'system@mahfazti.app',
    action: 'Live Currency Rates Synchronized',
    targetResource: 'Currencies / USD, SAR, AED, EUR',
    category: 'System',
    ipAddress: '127.0.0.1',
    status: 'Success',
    createdAt: '2026-09-18T00:00:00Z',
  },
  {
    id: 'aud-4',
    adminName: 'Mohamed Gasser',
    adminEmail: 'admin@mahfazti.app',
    action: 'Updated Token Lifetime Policies',
    targetResource: 'Security / JWT Settings',
    category: 'Security',
    ipAddress: '197.38.112.44',
    status: 'Success',
    createdAt: '2026-09-17T11:20:00Z',
  },
];

export const auditLogsService = {
  getLogs: async (): Promise<AuditLogEntry[]> => {
    return new Promise((resolve) => setTimeout(() => resolve([...mockAuditLogs]), 100));
  },
};
