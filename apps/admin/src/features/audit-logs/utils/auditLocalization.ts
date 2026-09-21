/**
 * Comprehensive localization helpers for Admin Audit & History Logs.
 * Handles exact and dynamic action mappings, categories, statuses, and payload notes.
 */

export const formatAuditAction = (action: string, isAr: boolean): string => {
  if (!isAr) return action;

  // 1. Exact action mappings
  const exactMap: Record<string, string> = {
    'Created User Account': 'إنشاء حساب مستخدم جديد',
    'Failed User Creation': 'فشل إنشاء حساب مستخدم',
    'Updated User Details': 'تعديل بيانات المستخدم',
    'Activated User Account': 'تفعيل حساب المستخدم',
    'Suspended User Account': 'تعليق / حظر حساب المستخدم',
    'Permanently Deleted User': 'حذف مستخدم نهائياً',
    'Currency Exchange Rates Synchronized': 'مزامنة أسعار صرف العملات',
    'Reset Password': 'إعادة تعيين كلمة المرور',
    'User Login': 'تسجيل دخول مستخدم',
    'Admin Login': 'تسجيل دخول مشرف',
  };

  if (exactMap[action]) {
    return exactMap[action];
  }

  // 2. Role Change Patterns (e.g., "Changed User Role to SuperAdmin")
  const roleMatch = action.match(/^Changed User Role to\s+(.+)$/i);
  if (roleMatch) {
    const role = roleMatch[1].trim();
    const roleArMap: Record<string, string> = {
      SuperAdmin: 'مدير عام (SuperAdmin)',
      Admin: 'مشرف (Admin)',
      Support: 'دعم فني (Support)',
      User: 'مستخدم عادي (User)',
    };
    return `تغيير دور المستخدم إلى ${roleArMap[role] || role}`;
  }

  // 3. Bulk Action Patterns
  const bulkActMatch = action.match(/^Bulk Activated\s*\((\d+)\)\s*Users$/i);
  if (bulkActMatch) {
    return `تفعيل جماعي لـ (${bulkActMatch[1]}) مستخدمين`;
  }

  const bulkSuspMatch = action.match(/^Bulk Suspended\s*\((\d+)\)\s*Users$/i);
  if (bulkSuspMatch) {
    return `حظر جماعي لـ (${bulkSuspMatch[1]}) مستخدمين`;
  }

  const bulkDelMatch = action.match(/^Bulk Deleted\s*\((\d+)\)\s*Users Permanently$/i);
  if (bulkDelMatch) {
    return `حذف نهائي جماعي لـ (${bulkDelMatch[1]}) مستخدمين`;
  }

  return action;
};

export const formatAuditCategory = (category: string, isAr: boolean): string => {
  if (!isAr) return category;
  const map: Record<string, string> = {
    'User Management': 'إدارة المستخدمين',
    'Security': 'الأمان والصلاحيات',
    'Billing & Pricing': 'الفوترة والأسعار',
    'System': 'النظام',
  };
  return map[category] || category;
};

export const formatAuditStatus = (status: string, isAr: boolean): string => {
  if (!isAr) return status;
  const map: Record<string, string> = {
    Success: 'ناجحة',
    Warning: 'تحذير',
    Failed: 'فاشلة',
  };
  return map[status] || status;
};

export const formatAdminName = (name: string, isAr: boolean): string => {
  if (!isAr) return name;
  if (name === 'System Engine') return 'محرك النظام';
  if (name === 'Administrator') return 'مشرف النظام';
  return name;
};

export const formatAuditDetails = (
  details: string | undefined | null,
  isAr: boolean
): string | null => {
  if (!details) return null;
  if (!isAr) return details;

  const exactMap: Record<string, string> = {
    'Cascading wipe of user wallet transactions and budgets':
      'حذف شامل لكافة المعاملات المالية والمحافظ والميزانيات للمستخدم',
    'Granted full administrative RBAC access':
      'منح صلاحيات إدارية كاملة في نظام التحكم بالوصول (RBAC)',
    'Created user with role User, Currency EGP':
      'تم إنشاء حساب المستخدم برتبة مستخدم وعملة افتراضية جنيه مصري (EGP)',
    'Daily automated FX rates sync':
      'مزامنة مؤتمتة يومية لأسعار صرف العملات الأجنبية',
    'Account temporarily suspended by admin':
      'تم تعليق الحساب مؤقتاً بواسطة المشرف',
    'Hard cascading deletion of user account, wallets, transactions, and budgets':
      'حذف نهائي جذري للحساب وكافة المحافظ والمعاملات المالية والميزانيات المرتبطة',
  };

  if (exactMap[details]) return exactMap[details];

  // Pattern: "Role: {role}, Full Name: {name}"
  const roleNameMatch = details.match(/^Role:\s*([^,]+),\s*Full Name:\s*(.+)$/i);
  if (roleNameMatch) {
    const role = roleNameMatch[1].trim();
    const roleArMap: Record<string, string> = {
      SuperAdmin: 'مدير عام (SuperAdmin)',
      Admin: 'مشرف (Admin)',
      Support: 'دعم فني (Support)',
      User: 'مستخدم عادي (User)',
    };
    return `الدور: ${roleArMap[role] || role}، الاسم الكامل: ${roleNameMatch[2].trim()}`;
  }

  // Pattern: "Updated profile info for {name}"
  const updatedInfoMatch = details.match(/^Updated profile info for\s+(.+)$/i);
  if (updatedInfoMatch) {
    return `تم تحديث البيانات الشخصية لـ ${updatedInfoMatch[1].trim()}`;
  }

  // Pattern: "Hard cascading deletion of {count} users and all their associated financial records"
  const hardCascadeBulkMatch = details.match(
    /^Hard cascading deletion of\s+(\d+)\s+users and all their associated financial records$/i
  );
  if (hardCascadeBulkMatch) {
    return `حذف نهائي شامل لـ (${hardCascadeBulkMatch[1]}) من المستخدمين وكافة سجلاتهم المالية`;
  }

  return details;
};
