export interface AdminUser {
  id: string;
  email: string;
  fullName: string;
  role: 'SuperAdmin' | 'Admin' | 'Auditor';
  avatarUrl?: string;
}
