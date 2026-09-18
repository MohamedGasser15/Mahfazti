export interface UserItem {
  id: string;
  fullName: string;
  email: string;
  emailConfirmed: boolean;
  currency: string;
  role: 'SuperAdmin' | 'Admin' | 'User';
  isActive: boolean;
  createdAt: string;
  lastLoginAt?: string;
  walletsCount: number;
}

export interface RoleDefinition {
  id: string;
  name: string;
  slug: string;
  description: string;
  usersCount: number;
  isSystem: boolean;
  permissions: string[];
}

