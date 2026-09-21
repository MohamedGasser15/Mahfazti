export interface UserItem {
  id: string;
  fullName: string;
  email: string;
  emailConfirmed: boolean;
  currency: string;
  role: 'SuperAdmin' | 'Admin' | 'User' | string;
  isActive: boolean;
  createdAt: string;
  lastLoginAt?: string;
  walletsCount: number;
}

export interface RoleDefinition {
  id: number | string;
  name: string;
  slug?: string;
  description?: string | null;
  usersCount: number;
  isSystem: boolean;
  createdAt?: string;
  permissions: string[];
}

export interface PermissionItem {
  code: string;
  nameEn: string;
  nameAr: string;
  descriptionEn: string;
  descriptionAr: string;
}

export interface PermissionGroup {
  groupKey: string;
  groupNameEn: string;
  groupNameAr: string;
  permissions: PermissionItem[];
}

export interface CreateRoleData {
  name: string;
  description?: string;
  permissions: string[];
}

export interface UpdateRoleData {
  name: string;
  description?: string;
  permissions: string[];
}

export interface RoleStats {
  totalRoles: number;
  systemRolesCount: number;
  customRolesCount: number;
  assignedUsersCount: number;
  totalPermissionsCount: number;
}
