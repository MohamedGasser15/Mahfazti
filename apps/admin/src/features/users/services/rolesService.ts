import { apiClient } from '../../../api/client';
import type {
  RoleDefinition,
  PermissionGroup,
  CreateRoleData,
  UpdateRoleData,
} from '../types';

let mockRoles: RoleDefinition[] = [
  {
    id: 1,
    name: 'SuperAdmin',
    description: 'المالك الرئيسي للنظام بكافة الصلاحيات والجذور الإدارية وإدارة التكوينات وسجلات الأمان.',
    usersCount: 1,
    isSystem: true,
    createdAt: '2026-09-01T00:00:00Z',
    permissions: [
      'users.view', 'users.create', 'users.edit', 'users.delete', 'users.roles',
      'categories.view', 'categories.create', 'categories.edit', 'categories.delete',
      'transactions.view', 'transactions.export',
      'subscriptions.view', 'subscriptions.manage', 'plans.manage',
      'audit_logs.view', 'audit_logs.export',
      'notifications.view', 'notifications.send',
      'roles.view', 'roles.manage',
      'system.settings', 'system.health', 'system.ai_logs',
    ],
  },
  {
    id: 2,
    name: 'Admin',
    description: 'مشرف تشغيلي مع صلاحيات إدارة المستخدمين والتصنيفات ومراقبة العمليات المالية وسجل النشاط.',
    usersCount: 2,
    isSystem: true,
    createdAt: '2026-09-01T00:00:00Z',
    permissions: [
      'users.view', 'users.create', 'users.edit',
      'categories.view', 'categories.create', 'categories.edit', 'categories.delete',
      'transactions.view', 'transactions.export',
      'subscriptions.view',
      'audit_logs.view',
      'notifications.view', 'notifications.send',
      'roles.view',
    ],
  },
  {
    id: 3,
    name: 'FinanceAdmin',
    description: 'إدارة خطط الأسعار والاشتراكات ومراقبة التدفقات المالية وعمليات الاسترجاع.',
    usersCount: 2,
    isSystem: false,
    createdAt: '2026-09-10T12:00:00Z',
    permissions: [
      'transactions.view', 'transactions.export',
      'subscriptions.view', 'subscriptions.manage', 'plans.manage',
      'audit_logs.view',
    ],
  },
  {
    id: 4,
    name: 'SupportAgent',
    description: 'التواصل المباشر مع المستخدمين وتقديم الدعم الفني وإرسال التنبيهات والإشعارات.',
    usersCount: 2,
    isSystem: false,
    createdAt: '2026-09-12T15:30:00Z',
    permissions: [
      'users.view',
      'notifications.view', 'notifications.send',
    ],
  },
  {
    id: 5,
    name: 'Auditor',
    description: 'صلاحيات قراءة شاملة لمراجعة السجلات الأمنية والامتثال ومراقبة الحركات المالية.',
    usersCount: 1,
    isSystem: false,
    createdAt: '2026-09-15T09:00:00Z',
    permissions: [
      'users.view',
      'categories.view',
      'transactions.view', 'transactions.export',
      'audit_logs.view', 'audit_logs.export',
      'roles.view',
    ],
  },
  {
    id: 6,
    name: 'User',
    description: 'مستخدم قياسي للمحفظة وتتبع المصروفات والمعاملات الشخصية.',
    usersCount: 12,
    isSystem: true,
    createdAt: '2026-09-01T00:00:00Z',
    permissions: [],
  },
];

const fallbackPermissionGroups: PermissionGroup[] = [
  {
    groupKey: 'users',
    groupNameEn: 'User Management',
    groupNameAr: 'إدارة المستخدمين',
    permissions: [
      { code: 'users.view', nameEn: 'View Users', nameAr: 'عرض المستخدمين', descriptionEn: 'Access users directory and view profile details', descriptionAr: 'استعراض دليل المستخدمين وملفاتهم الشخصية' },
      { code: 'users.create', nameEn: 'Create Users', nameAr: 'إضافة مستخدمين', descriptionEn: 'Register and create new user accounts', descriptionAr: 'إنشاء وتسجيل حسابات مستخدمين جدد' },
      { code: 'users.edit', nameEn: 'Edit Users', nameAr: 'تعديل المستخدمين', descriptionEn: 'Update profile information and toggle account status', descriptionAr: 'تعديل بيانات المستخدمين وتفعيل أو إيقاف الحسابات' },
      { code: 'users.delete', nameEn: 'Delete Users', nameAr: 'حذف المستخدمين', descriptionEn: 'Permanently remove or wipe user records', descriptionAr: 'الحذف النهائي لحسابات المستخدمين وسجلاتهم' },
      { code: 'users.roles', nameEn: 'Assign Roles', nameAr: 'تعيين الرتب للمستخدمين', descriptionEn: 'Promote or change administrator and user roles', descriptionAr: 'ترقية رتب المشرفين وصلاحياتهم الإدارية' },
    ],
  },
  {
    groupKey: 'categories',
    groupNameEn: 'Financial Categories',
    groupNameAr: 'التصنيفات المالية',
    permissions: [
      { code: 'categories.view', nameEn: 'View Categories', nameAr: 'عرض التصنيفات', descriptionEn: 'View system expense and income categories', descriptionAr: 'استعراض تصنيفات المصروفات والإيرادات' },
      { code: 'categories.create', nameEn: 'Create Categories', nameAr: 'إضافة تصنيفات', descriptionEn: 'Create new spending and earning categories', descriptionAr: 'إضافة تصنيفات جديدة للمصروفات والإيرادات' },
      { code: 'categories.edit', nameEn: 'Edit Categories', nameAr: 'تعديل التصنيفات', descriptionEn: 'Modify category icons, names, and types', descriptionAr: 'تعديل أيقونات ومسميات وأنواع التصنيفات' },
      { code: 'categories.delete', nameEn: 'Delete Categories', nameAr: 'أرشفة وحذف التصنيفات', descriptionEn: 'Archive or permanently delete categories', descriptionAr: 'أرشفة التصنيفات المالية أو حذفها نهائياً' },
    ],
  },
  {
    groupKey: 'transactions',
    groupNameEn: 'Transactions & Wallets',
    groupNameAr: 'المعاملات والمحافظ',
    permissions: [
      { code: 'transactions.view', nameEn: 'View Transactions', nameAr: 'مراقبة المعاملات', descriptionEn: 'Inspect financial movements and wallet balances', descriptionAr: 'متابعة الحركات المالية وأرصدة المحافظ' },
      { code: 'transactions.export', nameEn: 'Export Transactions', nameAr: 'تصدير المعاملات', descriptionEn: 'Download CSV and Excel financial reports', descriptionAr: 'تصدير تقارير العمليات المالية بصيغ الجداول' },
    ],
  },
  {
    groupKey: 'subscriptions',
    groupNameEn: 'Subscriptions & Plans',
    groupNameAr: 'الاشتراكات والخطط',
    permissions: [
      { code: 'subscriptions.view', nameEn: 'View Subscriptions', nameAr: 'عرض الاشتراكات', descriptionEn: 'Monitor user subscriptions and MRR revenue', descriptionAr: 'متابعة اشتراكات المستخدمين وإيرادات الـ MRR' },
      { code: 'subscriptions.manage', nameEn: 'Manage Subscriptions', nameAr: 'إدارة الاشتراكات', descriptionEn: 'Cancel, refund, or extend memberships', descriptionAr: 'إلغاء وتمديد اشتراكات العضويات' },
      { code: 'plans.manage', nameEn: 'Manage Plans', nameAr: 'إدارة خطط الأسعار', descriptionEn: 'Create and configure pricing tiers and promo codes', descriptionAr: 'إنشاء وتعديل باقات الاشتراك وكوبونات الخصم' },
    ],
  },
  {
    groupKey: 'audit_logs',
    groupNameEn: 'Security & Audit Trail',
    groupNameAr: 'سجل النشاط والأمان',
    permissions: [
      { code: 'audit_logs.view', nameEn: 'View Audit Trail', nameAr: 'عرض سجل النشاط', descriptionEn: 'Inspect administrative actions and security history', descriptionAr: 'مراقبة كافة عمليات المشرفين وسجل الأمان' },
      { code: 'audit_logs.export', nameEn: 'Export Audit Trail', nameAr: 'تصدير سجل النشاط', descriptionEn: 'Export security compliance logs and IP history', descriptionAr: 'تصدير تقارير الرقابة وسجلات عناوين الـ IP' },
    ],
  },
  {
    groupKey: 'notifications',
    groupNameEn: 'Push Notifications',
    groupNameAr: 'الإشعارات والبث',
    permissions: [
      { code: 'notifications.view', nameEn: 'View Notifications', nameAr: 'عرض سجل الإشعارات', descriptionEn: 'Inspect broadcast delivery rates and analytics', descriptionAr: 'استعراض نسب وصول الإشعارات والتفاعل' },
      { code: 'notifications.send', nameEn: 'Broadcast Notifications', nameAr: 'إرسال إشعارات عامة', descriptionEn: 'Send promotional messages and alerts to users', descriptionAr: 'إرسال رسائل وتنبيهات جماعية لأجهزة المستخدمين' },
    ],
  },
  {
    groupKey: 'roles',
    groupNameEn: 'Roles & Permissions',
    groupNameAr: 'الأدوار والصلاحيات',
    permissions: [
      { code: 'roles.view', nameEn: 'View Roles', nameAr: 'استعراض الأدوار', descriptionEn: 'Inspect access control roles and assigned claims', descriptionAr: 'استعراض مصفوفة الرتب الإدارية والصلاحيات' },
      { code: 'roles.manage', nameEn: 'Manage Roles', nameAr: 'إدارة الأدوار والصلاحيات', descriptionEn: 'Create custom roles and configure permissions matrix', descriptionAr: 'إنشاء رتب مخصصة وتعديل مصفوفة الصلاحيات' },
    ],
  },
  {
    groupKey: 'system',
    groupNameEn: 'System & Settings',
    groupNameAr: 'النظام والإعدادات',
    permissions: [
      { code: 'system.settings', nameEn: 'Platform Settings', nameAr: 'إعدادات المنصة', descriptionEn: 'Configure global application settings and currencies', descriptionAr: 'ضبط الإعدادات العامة للمنصة والعملات' },
      { code: 'system.health', nameEn: 'System Health', nameAr: 'صحة النظام والخوادم', descriptionEn: 'Monitor server metrics, latency, and cache', descriptionAr: 'مراقبة أداء الخوادم ومعدلات الاستجابة والذاكرة' },
      { code: 'system.ai_logs', nameEn: 'AI Analytics', nameAr: 'سجلات الذكاء الاصطناعي', descriptionEn: 'Inspect AI advisor usage and token consumption', descriptionAr: 'متابعة استهلاك واستجابات مستشار الذكاء الاصطناعي' },
    ],
  },
];

export const rolesService = {
  getRoles: async (): Promise<RoleDefinition[]> => {
    try {
      const res = await apiClient.get<RoleDefinition[]>('/roles');
      if (Array.isArray(res.data)) {
        return res.data;
      }
    } catch {
      // Fallback
    }
    return mockRoles;
  },

  getRoleById: async (id: number | string): Promise<RoleDefinition> => {
    try {
      const res = await apiClient.get<RoleDefinition>(`/roles/${id}`);
      if (res.data) return res.data;
    } catch {
      // Fallback
    }
    const found = mockRoles.find((r) => String(r.id) === String(id));
    if (!found) throw new Error(`Role ${id} not found`);
    return found;
  },

  getAvailablePermissions: async (): Promise<PermissionGroup[]> => {
    try {
      const res = await apiClient.get<PermissionGroup[]>('/roles/permissions');
      if (Array.isArray(res.data)) {
        return res.data;
      }
    } catch {
      // Fallback
    }
    return fallbackPermissionGroups;
  },

  createRole: async (data: CreateRoleData): Promise<RoleDefinition> => {
    try {
      const res = await apiClient.post<RoleDefinition>('/roles', data);
      if (res.data) {
        mockRoles.push(res.data);
        return res.data;
      }
    } catch (err: any) {
      if (err?.response?.data?.message) {
        throw new Error(err.response.data.message);
      }
    }

    const newRole: RoleDefinition = {
      id: Date.now(),
      name: data.name.trim(),
      description: data.description?.trim() || 'رتبة مخصصة محددة الصلاحيات.',
      usersCount: 0,
      isSystem: false,
      createdAt: new Date().toISOString(),
      permissions: data.permissions || [],
    };
    mockRoles.push(newRole);
    return newRole;
  },

  updateRole: async (id: number | string, data: UpdateRoleData): Promise<RoleDefinition> => {
    try {
      const res = await apiClient.put<RoleDefinition>(`/roles/${id}`, data);
      if (res.data) {
        mockRoles = mockRoles.map((r) => (String(r.id) === String(id) ? res.data : r));
        return res.data;
      }
    } catch (err: any) {
      if (err?.response?.data?.message) {
        throw new Error(err.response.data.message);
      }
    }

    const existing = mockRoles.find((r) => String(r.id) === String(id));
    if (!existing) throw new Error(`Role ${id} not found`);

    const updated: RoleDefinition = {
      ...existing,
      name: existing.isSystem ? existing.name : data.name.trim(),
      description: data.description?.trim(),
      permissions: data.permissions,
    };
    mockRoles = mockRoles.map((r) => (String(r.id) === String(id) ? updated : r));
    return updated;
  },

  deleteRole: async (id: number | string): Promise<void> => {
    try {
      await apiClient.delete(`/roles/${id}`);
      mockRoles = mockRoles.filter((r) => String(r.id) !== String(id));
      return;
    } catch (err: any) {
      if (err?.response?.data?.message) {
        throw new Error(err.response.data.message);
      }
    }

    const existing = mockRoles.find((r) => String(r.id) === String(id));
    if (existing?.isSystem) {
      throw new Error('لا يمكن حذف رتبة النظام الأساسية المحمية.');
    }
    if (existing && existing.usersCount > 0) {
      throw new Error(`لا يمكن حذف الرتبة لأنها مسندة حالياً إلى ${existing.usersCount} مستخدم.`);
    }
    mockRoles = mockRoles.filter((r) => String(r.id) !== String(id));
  },
};
