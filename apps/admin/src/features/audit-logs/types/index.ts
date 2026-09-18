export interface AuditLogEntry {
  id: string;
  adminName: string;
  adminEmail: string;
  action: string;
  targetResource: string;
  category: 'Security' | 'User Management' | 'Billing & Pricing' | 'System';
  ipAddress: string;
  status: 'Success' | 'Warning' | 'Failed';
  createdAt: string;
}
