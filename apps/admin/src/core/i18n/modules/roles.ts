export interface RolesTranslationSchema {
  pageTitle: string;
  pageSubtitle: string;
  refresh: string;
  createNewRole: string;
  tabs: {
    all: string;
    system: string;
    custom: string;
  };
  searchPlaceholder: string;
  table: {
    roleName: string;
    systemStatus: string;
    grantedCapabilities: string;
    assignedUsers: string;
    actions: string;
    managePermissions: string;
    systemDefault: string;
    customRole: string;
  };
  cards: {
    assigned: string;
    grantedPermissions: string;
    permissions: string;
    edit: string;
    delete: string;
  };
  pagination: {
    showing: string;
    to: string;
    of: string;
    roles: string;
    prev: string;
    next: string;
  };
  toasts: {
    createSuccess: string;
    updateSuccess: string;
    permissionsUpdated: string;
    roleUpdated: string;
    deleteSuccess: string;
  };
  permissionsPage: {
    backToRoles: string;
    roleNotFound: string;
    roleNotFoundDesc: string;
    systemRoleBadge: string;
    customRoleBadge: string;
    systemBanner: string;
    saveChanges: string;
    saving: string;
    resetChanges: string;
    selectAll: string;
    clearAll: string;
    searchPlaceholder: string;
    allClaims: string;
    grantedClaims: string;
    deniedClaims: string;
    completion: string;
    grantedStatus: string;
    restrictedStatus: string;
    emptySearchTitle: string;
    emptySearchDesc: string;
  };
}

export const rolesTranslationsAr: RolesTranslationSchema = {
  pageTitle: 'مصفوفة الأدوار والصلاحيات',
  pageSubtitle: 'تخصيص رتب المشرفين وصلاحيات الوصول وإدارة تفويض المهام عبر المنصة',
  refresh: 'تحديث الرتب',
  createNewRole: 'إنشاء رتبة جديدة',
  tabs: {
    all: 'كافة الرتب',
    system: 'رتب النظام الأساسية',
    custom: 'الرتب المخصصة',
  },
  searchPlaceholder: 'البحث باسم الرتبة أو الوصف أو كود الصلاحية...',
  table: {
    roleName: 'الرتبة والمسؤوليات',
    systemStatus: 'النوع والحماية',
    grantedCapabilities: 'الصلاحيات الممنوحة',
    assignedUsers: 'المشرفين المعينين',
    actions: 'الإجراءات',
    managePermissions: 'إدارة الصلاحيات',
    systemDefault: 'أساسي ومحمي',
    customRole: 'رتبة مخصصة',
  },
  cards: {
    assigned: 'مشرف معين',
    grantedPermissions: 'صلاحيات ممنوحة',
    permissions: 'الصلاحيات',
    edit: 'تعديل البيانات',
    delete: 'حذف الرتبة',
  },
  pagination: {
    showing: 'عرض',
    to: 'إلى',
    of: 'من أصل',
    roles: 'رتبة',
    prev: 'السابق',
    next: 'التالي',
  },
  toasts: {
    createSuccess: 'تم إنشاء الرتبة الجديدة بنجاح',
    updateSuccess: 'تم حفظ التعديلات بنجاح',
    permissionsUpdated: 'تم تحديث مصفوفة الصلاحيات بنجاح',
    roleUpdated: 'تم تحديث بيانات الرتبة بنجاح',
    deleteSuccess: 'تم حذف الرتبة المخصصة بنجاح',
  },
  permissionsPage: {
    backToRoles: 'العودة إلى مصفوفة الأدوار',
    roleNotFound: 'الرتبة غير موجودة',
    roleNotFoundDesc: 'تعذر العثور على الرتبة المطلوبة، قد تكون تم حذفها أو أن الرابط غير صحيح.',
    systemRoleBadge: 'رتبة أساسية',
    customRoleBadge: 'رتبة مخصصة',
    systemBanner: 'رتبة نظام أساسية محمية: هذه الرتبة تمتلك صلاحيات كاملة وجذرية غير قابلة للتقييد لحماية استقرار المنصة.',
    saveChanges: 'حفظ مصفوفة الصلاحيات',
    saving: 'جاري الحفظ...',
    resetChanges: 'تراجع عن التعديلات',
    selectAll: 'تحديد الكل',
    clearAll: 'إلغاء التحديد',
    searchPlaceholder: 'البحث باسم الصلاحية، الوصف، أو الكود البرمجي...',
    allClaims: 'كافة الصلاحيات',
    grantedClaims: 'الممنوحة',
    deniedClaims: 'المحجوبة',
    completion: 'نسبة التغطية',
    grantedStatus: 'ممنوحة',
    restrictedStatus: 'محجوبة',
    emptySearchTitle: 'لا توجد صلاحيات مطابقة للبحث',
    emptySearchDesc: 'جرب البحث بكلمات أخرى أو قم بإلغاء الفلاتر المطبقة',
  },
};

export const rolesTranslationsEn: RolesTranslationSchema = {
  pageTitle: 'Roles & Permissions Matrix',
  pageSubtitle: 'Configure administrative roles, granular access levels, and team capabilities',
  refresh: 'Refresh Roles',
  createNewRole: 'Create New Role',
  tabs: {
    all: 'All Roles',
    system: 'System Roles',
    custom: 'Custom Roles',
  },
  searchPlaceholder: 'Search roles by name, description, or permission code...',
  table: {
    roleName: 'Role & Description',
    systemStatus: 'System Status',
    grantedCapabilities: 'Granted Capabilities',
    assignedUsers: 'Assigned Users',
    actions: 'Actions',
    managePermissions: 'Manage Permissions',
    systemDefault: 'System Protected',
    customRole: 'Custom Role',
  },
  cards: {
    assigned: 'assigned users',
    grantedPermissions: 'granted permissions',
    permissions: 'Permissions',
    edit: 'Edit Details',
    delete: 'Delete Role',
  },
  pagination: {
    showing: 'Showing',
    to: 'to',
    of: 'of',
    roles: 'roles',
    prev: 'Prev',
    next: 'Next',
  },
  toasts: {
    createSuccess: 'Role created successfully',
    updateSuccess: 'Changes saved successfully',
    permissionsUpdated: 'Role permissions updated successfully',
    roleUpdated: 'Role details updated successfully',
    deleteSuccess: 'Custom role deleted successfully',
  },
  permissionsPage: {
    backToRoles: 'Back to Roles Matrix',
    roleNotFound: 'Role Not Found',
    roleNotFoundDesc: 'The requested role could not be found or may have been deleted.',
    systemRoleBadge: 'System Protected',
    customRoleBadge: 'Custom Role',
    systemBanner: 'System Protected Role: This role holds permanent administrative root privileges to maintain platform integrity.',
    saveChanges: 'Save Permissions',
    saving: 'Saving...',
    resetChanges: 'Reset Changes',
    selectAll: 'Select All',
    clearAll: 'Clear All',
    searchPlaceholder: 'Search permissions by name, description, or code...',
    allClaims: 'All Permissions',
    grantedClaims: 'Granted',
    deniedClaims: 'Restricted',
    completion: 'Coverage',
    grantedStatus: 'Granted',
    restrictedStatus: 'Restricted',
    emptySearchTitle: 'No matching permissions',
    emptySearchDesc: 'Try searching with different keywords or clear applied filters',
  },
};
