import { apiClient } from '../../../api/client';
import type { UserItem, RoleDefinition } from '../types';

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
    lastLoginAt: '2026-09-19T14:10:00Z',
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
    lastLoginAt: '2026-09-18T20:45:00Z',
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
    lastLoginAt: '2026-09-20T05:00:00Z',
    walletsCount: 4,
  },
  {
    id: 'u-5',
    fullName: 'Nour El-Din Tarek',
    email: 'nour.tarek@example.com',
    emailConfirmed: true,
    currency: 'SAR',
    role: 'Admin',
    isActive: true,
    createdAt: '2026-07-15T10:30:00Z',
    lastLoginAt: '2026-09-19T22:15:00Z',
    walletsCount: 2,
  },
  {
    id: 'u-6',
    fullName: 'Layla Mahmoud',
    email: 'layla.m@example.com',
    emailConfirmed: true,
    currency: 'AED',
    role: 'User',
    isActive: true,
    createdAt: '2026-08-20T16:40:00Z',
    lastLoginAt: '2026-09-20T08:30:00Z',
    walletsCount: 5,
  },
  {
    id: 'u-7',
    fullName: 'Karim Mostafa',
    email: 'karim.mostafa@example.com',
    emailConfirmed: false,
    currency: 'EGP',
    role: 'User',
    isActive: false,
    createdAt: '2026-09-05T12:00:00Z',
    lastLoginAt: '2026-09-06T14:20:00Z',
    walletsCount: 0,
  },
  {
    id: 'u-8',
    fullName: 'Fatima Al-Zahraa',
    email: 'fatima.z@example.com',
    emailConfirmed: true,
    currency: 'USD',
    role: 'Admin',
    isActive: true,
    createdAt: '2026-08-01T11:15:00Z',
    lastLoginAt: '2026-09-19T18:05:00Z',
    walletsCount: 3,
  },
  {
    id: 'u-9',
    fullName: 'Youssef Ibrahim',
    email: 'youssef.ibrahim@example.com',
    emailConfirmed: true,
    currency: 'EUR',
    role: 'User',
    isActive: true,
    createdAt: '2026-08-28T09:45:00Z',
    lastLoginAt: '2026-09-18T12:10:00Z',
    walletsCount: 2,
  },
  {
    id: 'u-10',
    fullName: 'Mona Adel',
    email: 'mona.adel@example.com',
    emailConfirmed: false,
    currency: 'EGP',
    role: 'User',
    isActive: true,
    createdAt: '2026-09-10T15:20:00Z',
    lastLoginAt: '2026-09-15T19:00:00Z',
    walletsCount: 1,
  },
  {
    id: 'u-11',
    fullName: 'Ziad Bassam',
    email: 'ziad.bassam@example.com',
    emailConfirmed: true,
    currency: 'SAR',
    role: 'User',
    isActive: false,
    createdAt: '2026-09-12T13:10:00Z',
    lastLoginAt: '2026-09-13T11:40:00Z',
    walletsCount: 2,
  },
  {
    id: 'u-12',
    fullName: 'Hala Samir',
    email: 'hala.samir@example.com',
    emailConfirmed: true,
    currency: 'EGP',
    role: 'User',
    isActive: true,
    createdAt: '2026-09-14T17:50:00Z',
    lastLoginAt: '2026-09-20T09:15:00Z',
    walletsCount: 4,
  },
];

let mockRoles: RoleDefinition[] = [
  {
    id: 'r-superadmin',
    name: 'Super Admin',
    slug: 'SuperAdmin',
    description: 'Full system ownership with root access to billing, users, server configurations, and database audits.',
    usersCount: 1,
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
    usersCount: 2,
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
    usersCount: 2,
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

export interface CreateUserData {
  fullName: string;
  email: string;
  role: 'SuperAdmin' | 'Admin' | 'User';
  currency: string;
  emailConfirmed?: boolean;
}

export interface UpdateUserData {
  fullName: string;
  email: string;
  role: 'SuperAdmin' | 'Admin' | 'User';
  currency: string;
  emailConfirmed?: boolean;
}

const extractApiErrorMessage = (err: unknown, defaultMsg?: string): string => {
  const axiosErr = err as {
    response?: {
      status?: number;
      data?: { message?: string; title?: string };
    };
  };
  return (
    axiosErr?.response?.data?.message ||
    axiosErr?.response?.data?.title ||
    (axiosErr?.response?.status === 400
      ? 'هذا البريد الإلكتروني مسجل بالفعل لمستخدم آخر'
      : defaultMsg || (err instanceof Error ? err.message : 'حدث خطأ أثناء تنفيذ العملية'))
  );
};

export const usersService = {
  /**
   * Fetches all users from GET /api/Users with fallback to local state
   */
  getUsers: async (): Promise<UserItem[]> => {
    try {
      const res = await apiClient.get<UserItem[]>('/Users');
      const rawData = res.data;
      const items = Array.isArray(rawData)
        ? rawData
        : (rawData as unknown as { data?: UserItem[] })?.data || [];
      if (items.length > 0) {
        mockUsers = items;
        return items;
      }
      return [...mockUsers];
    } catch {
      // In isolated frontend dev or when offline, fallback gracefully
      return [...mockUsers];
    }
  },

  /**
   * Fetches roles definitions
   */
  getRoles: async (): Promise<RoleDefinition[]> => {
    return new Promise((resolve) => {
      setTimeout(() => resolve([...mockRoles]), 80);
    });
  },

  /**
   * Toggles user status via PUT /api/Users/{id}/status with local fallback
   */
  toggleUserStatus: async (userId: string): Promise<UserItem> => {
    const numericId = parseInt(userId.replace('u-', ''), 10);
    try {
      if (!isNaN(numericId)) {
        const res = await apiClient.put<UserItem>(`/Users/${numericId}/status`);
        const updated = (res.data as unknown as { data?: UserItem })?.data || res.data;
        mockUsers = mockUsers.map((u) => (u.id === userId ? { ...u, ...updated } : u));
        return { ...updated, id: userId };
      }
    } catch {
      // Local fallback
    }

    const user = mockUsers.find((u) => u.id === userId);
    if (!user) throw new Error('User not found');
    user.isActive = !user.isActive;
    return { ...user };
  },

  /**
   * Bulk updates user statuses via POST /api/Users/bulk-status
   */
  bulkUpdateStatus: async (userIds: string[], isActive: boolean): Promise<UserItem[]> => {
    try {
      await apiClient.post('/Users/bulk-status', { userIds, isActive });
    } catch {
      // Local fallback
    }

    const set = new Set(userIds);
    mockUsers = mockUsers.map((u) => (set.has(u.id) ? { ...u, isActive } : u));
    return [...mockUsers];
  },

  /**
   * Updates user role via PUT /api/Users/{id}/role
   */
  updateUserRole: async (userId: string, role: 'SuperAdmin' | 'Admin' | 'User'): Promise<UserItem> => {
    const numericId = parseInt(userId.replace('u-', ''), 10);
    try {
      if (!isNaN(numericId)) {
        const res = await apiClient.put<UserItem>(`/Users/${numericId}/role`, { role });
        const updated = (res.data as unknown as { data?: UserItem })?.data || res.data;
        mockUsers = mockUsers.map((u) => (u.id === userId ? { ...u, ...updated } : u));
        return { ...updated, id: userId };
      }
    } catch {
      // Local fallback
    }

    const user = mockUsers.find((u) => u.id === userId);
    if (!user) throw new Error('User not found');
    user.role = role;
    return { ...user };
  },

  /**
   * Creates a user via POST /api/Users
   */
  addUser: async (data: CreateUserData): Promise<UserItem> => {
    const normalizedEmail = data.email.trim().toLowerCase();

    // Check duplicate in local cache/state
    const isDuplicate = mockUsers.some(
      (u) => u.email.trim().toLowerCase() === normalizedEmail
    );

    try {
      const res = await apiClient.post<UserItem>('/Users', {
        fullName: data.fullName.trim(),
        email: normalizedEmail,
        role: data.role,
        currency: data.currency,
        emailConfirmed: data.emailConfirmed ?? true,
      });
      const created = (res.data as unknown as { data?: UserItem })?.data || res.data;
      mockUsers = [created, ...mockUsers];
      return created;
    } catch (err: unknown) {
      const errorMsg = extractApiErrorMessage(err);
      if (errorMsg && errorMsg !== 'حدث خطأ أثناء تنفيذ العملية') {
        throw new Error(errorMsg);
      }

      // If network failed / offline dev mode, check local duplicate
      if (isDuplicate) {
        throw new Error('هذا البريد الإلكتروني مسجل بالفعل لمستخدم آخر');
      }

      // Fallback: add locally if network failed and not a duplicate
      const newUser: UserItem = {
        id: `u-${mockUsers.length + 1}`,
        fullName: data.fullName.trim(),
        email: normalizedEmail,
        emailConfirmed: data.emailConfirmed ?? true,
        currency: data.currency || 'EGP',
        role: data.role,
        isActive: true,
        createdAt: new Date().toISOString(),
        lastLoginAt: undefined,
        walletsCount: 1,
      };
      mockUsers = [newUser, ...mockUsers];
      return newUser;
    }
  },

  /**
   * Updates an existing user via PUT /api/Users/{id}
   */
  updateUser: async (userId: string, data: UpdateUserData): Promise<UserItem> => {
    const normalizedEmail = data.email.trim().toLowerCase();

    // Check duplicate in local cache/state against OTHER users
    const isDuplicate = mockUsers.some(
      (u) => u.id !== userId && u.email.trim().toLowerCase() === normalizedEmail
    );

    const numericId = parseInt(userId.replace('u-', ''), 10);
    try {
      if (!isNaN(numericId)) {
        const res = await apiClient.put<UserItem>(`/Users/${numericId}`, {
          fullName: data.fullName.trim(),
          email: normalizedEmail,
          role: data.role,
          currency: data.currency,
          emailConfirmed: data.emailConfirmed ?? true,
        });
        const updated = (res.data as unknown as { data?: UserItem })?.data || res.data;
        mockUsers = mockUsers.map((u) => (u.id === userId ? { ...u, ...updated, id: userId } : u));
        return { ...updated, id: userId };
      }
    } catch (err: unknown) {
      const errorMsg = extractApiErrorMessage(err);
      if (errorMsg && errorMsg !== 'حدث خطأ أثناء تنفيذ العملية') {
        throw new Error(errorMsg);
      }
    }

    if (isDuplicate) {
      throw new Error('هذا البريد الإلكتروني مسجل بالفعل لمستخدم آخر');
    }

    const user = mockUsers.find((u) => u.id === userId);
    if (!user) throw new Error('User not found');
    user.fullName = data.fullName.trim();
    user.email = normalizedEmail;
    user.role = data.role;
    user.currency = data.currency;
    if (data.emailConfirmed !== undefined) {
      user.emailConfirmed = data.emailConfirmed;
    }
    return { ...user };
  },

  /**
   * Deletes a user via DELETE /api/Users/{id}
   */
  deleteUser: async (userId: string): Promise<void> => {
    const numericId = parseInt(userId.replace('u-', ''), 10);
    try {
      if (!isNaN(numericId)) {
        await apiClient.delete(`/Users/${numericId}`);
      }
    } catch (err: unknown) {
      throw new Error(extractApiErrorMessage(err, 'فشل حذف المستخدم'));
    }
    mockUsers = mockUsers.filter((u) => u.id !== userId);
  },

  /**
   * Bulk deletes users via POST /api/Users/bulk-delete
   */
  bulkDeleteUsers: async (userIds: string[]): Promise<void> => {
    try {
      await apiClient.post('/Users/bulk-delete', { userIds });
    } catch (err: unknown) {
      throw new Error(extractApiErrorMessage(err, 'فشل الحذف الجماعي للمستخدمين'));
    }
    const set = new Set(userIds);
    mockUsers = mockUsers.filter((u) => !set.has(u.id));
  },
};
