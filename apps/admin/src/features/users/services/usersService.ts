import type { UserItem } from '../types';

let mockUsers: UserItem[] = [
  {
    id: 'u-1',
    fullName: 'Ahmed Hassan',
    email: 'ahmed@example.com',
    emailConfirmed: true,
    currency: 'EGP',
    role: 'User',
    isActive: true,
    createdAt: '2026-08-10T14:32:00Z',
    lastLoginAt: '2026-09-18T04:10:00Z',
    walletsCount: 2,
  },
  {
    id: 'u-2',
    fullName: 'Sarah Mohamed',
    email: 'sarah@example.com',
    emailConfirmed: true,
    currency: 'USD',
    role: 'User',
    isActive: true,
    createdAt: '2026-08-15T09:12:00Z',
    lastLoginAt: '2026-09-17T20:45:00Z',
    walletsCount: 3,
  },
  {
    id: 'u-3',
    fullName: 'Omar Khaled',
    email: 'omar@example.com',
    emailConfirmed: false,
    currency: 'EGP',
    role: 'User',
    isActive: false,
    createdAt: '2026-09-01T11:20:00Z',
    lastLoginAt: '2026-09-02T10:00:00Z',
    walletsCount: 1,
  },
  {
    id: 'u-4',
    fullName: 'Mohamed Gasser',
    email: 'admin@mahfazti.app',
    emailConfirmed: true,
    currency: 'EGP',
    role: 'SuperAdmin',
    isActive: true,
    createdAt: '2026-07-01T08:00:00Z',
    lastLoginAt: '2026-09-18T05:00:00Z',
    walletsCount: 4,
  },
];

let mockRoles: import('../types').RoleDefinition[] = [
  {
    id: 'r-superadmin',
    name: 'Super Admin',
    slug: 'SuperAdmin',
    description: 'Full system ownership with root access to billing, users, server configurations, and database audits.',
    usersCount: 2,
    isSystem: true,
    permissions: [
      'users.manage',
      'users.delete',
      'finance.transactions',
      'finance.payouts',
      'billing.plans',
      'billing.coupons',
      'support.resolve',
      'system.ai_logs',
      'system.settings',
    ],
  },
  {
    id: 'r-finance',
    name: 'Finance Manager',
    slug: 'FinanceAdmin',
    description: 'Manage subscription plans, monitor MRR, inspect payment logs, and validate refunds.',
    usersCount: 4,
    isSystem: false,
    permissions: [
      'finance.transactions',
      'billing.plans',
      'billing.coupons',
      'system.currencies',
    ],
  },
  {
    id: 'r-support',
    name: 'Support Representative',
    slug: 'SupportAgent',
    description: 'Direct communication with users, responding to support tickets, and broadcasting app notifications.',
    usersCount: 7,
    isSystem: false,
    permissions: [
      'users.read',
      'support.resolve',
      'notifications.broadcast',
    ],
  },
  {
    id: 'r-auditor',
    name: 'Compliance & Auditor',
    slug: 'Auditor',
    description: 'Read-only access across the entire platform to verify security, logs, and financial consistency.',
    usersCount: 1,
    isSystem: false,
    permissions: [
      'users.read',
      'finance.read',
      'system.audit_logs',
    ],
  },
];

export const usersService = {
  getUsers: async (): Promise<UserItem[]> => {
    return new Promise((resolve) => {
      setTimeout(() => resolve([...mockUsers]), 100);
    });
  },

  getRoles: async (): Promise<import('../types').RoleDefinition[]> => {
    return new Promise((resolve) => {
      setTimeout(() => resolve([...mockRoles]), 100);
    });
  },

  toggleUserStatus: async (userId: string): Promise<UserItem> => {
    return new Promise((resolve, reject) => {
      const user = mockUsers.find((u) => u.id === userId);
      if (!user) return reject(new Error('User not found'));
      user.isActive = !user.isActive;
      resolve({ ...user });
    });
  },
};

