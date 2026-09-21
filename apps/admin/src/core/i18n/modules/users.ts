export interface UsersTranslationSchema {
  pageTitle: string;
  pageSubtitle: string;
  refresh: string;
  addNewUser: string;
  kpi: {
    totalAccounts: string;
    activeUsers: string;
    suspended: string;
    adminsStaff: string;
  };
  tabs: {
    all: string;
    active: string;
    inactive: string;
    admins: string;
  };
  searchPlaceholder: string;
  roleFilterLabel: string;
  allRoles: string;
  roles: {
    superAdmin: string;
    admin: string;
    user: string;
  };
  views: {
    table: string;
    cards: string;
  };
  cards: {
    walletsAndCurrency: string;
    email: string;
    view: string;
    edit: string;
  };
  table: {
    user: string;
    role: string;
    currencyWallets: string;
    emailStatus: string;
    status: string;
    joined: string;
    actions: string;
    noWallets: string;
    walletsCount: string;
    verified: string;
    unverified: string;
    active: string;
    suspended: string;
  };
  emptyState: {
    title: string;
    description: string;
    resetFilters: string;
  };
  pagination: {
    showing: string;
    to: string;
    of: string;
    users: string;
    prev: string;
    next: string;
  };
  bulk: {
    selectedCount: string;
    activateInactive: string;
    activateSelected: string;
    suspendActive: string;
    suspendSelected: string;
    deleteSelected: string;
    deselect: string;
    successActivated: string;
    successSuspended: string;
    failed: string;
  };
  actionsMenu: {
    triggerTooltip: string;
    viewDetails: string;
    editProfile: string;
    copyEmail: string;
    copiedToast: string;
    changeRole: string;
    suspendAccount: string;
    activateAccount: string;
    deleteAccount: string;
    protectedAccountTooltip: string;
    protectedAccountLabel: string;
  };
  addModal: {
    title: string;
    subtitle: string;
    fullNameLabel: string;
    fullNamePlaceholder: string;
    emailLabel: string;
    emailPlaceholder: string;
    roleLabel: string;
    currencyLabel: string;
    verifiedLabel: string;
    verifiedDesc: string;
    cancelBtn: string;
    submitBtn: string;
    submittingBtn: string;
    successToast: string;
    nameRequired: string;
    emailInvalid: string;
    emailDuplicate: string;
    errorToast: string;
    livePreview: string;
    defaultFullName: string;
    currencyPreviewLabel: string;
  };
  editModal: {
    title: string;
    subtitle: string;
    fullNameLabel: string;
    fullNamePlaceholder: string;
    emailLabel: string;
    emailPlaceholder: string;
    roleLabel: string;
    currencyLabel: string;
    verifiedLabel: string;
    verifiedDesc: string;
    cancelBtn: string;
    submitBtn: string;
    submittingBtn: string;
    successToast: string;
    nameRequired: string;
    emailInvalid: string;
    emailDuplicate: string;
    errorToast: string;
    livePreview: string;
    currencyPreviewLabel: string;
  };
  deleteModal: {
    titleSingle: string;
    titleMultiple: string;
    descSingle: string;
    descMultiple: string;
    warningTitle: string;
    warningDesc: string;
    selfProtectedAlert: string;
    cascadingWipeListTitle: string;
    walletsWipe: string;
    transactionsWipe: string;
    budgetsWipe: string;
    userProfileWipe: string;
    userToDeleteLabel: string;
    joinedDateLabel: string;
    cancelBtn: string;
    confirmBtnSingle: string;
    confirmBtnMultiple: string;
    deletingBtn: string;
    successSingle: string;
    successMultiple: string;
    errorToast: string;
  };
  detailsModal: {
    title: string;
    idLabel: string;
    emailLabel: string;
    currencyLabel: string;
    walletsCountLabel: string;
    joinedDateLabel: string;
    lastLoginLabel: string;
    neverLoggedIn: string;
    verifiedBadge: string;
    unverifiedBadge: string;
    closeBtn: string;
    idCopiedToast: string;
    accountStatusLabel: string;
    activeStatus: string;
    suspendedStatus: string;
    roleSectionTitle: string;
    roleDescriptions: {
      superAdmin: string;
      admin: string;
      user: string;
    };
  };
  toasts: {
    userSuspended: string;
    userActivated: string;
    statusFailed: string;
    roleUpdated: string;
  };
}

export const usersEn: UsersTranslationSchema = {
  pageTitle: 'Users & Access Management',
  pageSubtitle: 'Monitor user profiles, security status, and manage administrative privileges',
  refresh: 'Refresh',
  addNewUser: 'Add New User',
  kpi: {
    totalAccounts: 'Total Accounts',
    activeUsers: 'Active Users',
    suspended: 'Suspended',
    adminsStaff: 'Admins & Staff',
  },
  tabs: {
    all: 'All',
    active: 'Active',
    inactive: 'Suspended',
    admins: 'Admins',
  },
  searchPlaceholder: 'Search by full name, email address, or user ID...',
  roleFilterLabel: 'Role:',
  allRoles: 'All Roles',
  roles: {
    superAdmin: 'Super Admin',
    admin: 'Admin',
    user: 'User',
  },
  views: {
    table: 'Table View',
    cards: 'Cards View',
  },
  cards: {
    walletsAndCurrency: 'Wallets & Cur.',
    email: 'Email',
    view: 'View',
    edit: 'Edit',
  },
  table: {
    user: 'User',
    role: 'Role',
    currencyWallets: 'Currency & Wallets',
    emailStatus: 'Email',
    status: 'Status',
    joined: 'Joined',
    actions: 'Actions',
    noWallets: 'No wallets',
    walletsCount: 'Wallets',
    verified: 'Verified',
    unverified: 'Unverified',
    active: 'Active',
    suspended: 'Suspended',
  },
  emptyState: {
    title: 'No users found',
    description: 'Try modifying search criteria or switching status tabs to locate users.',
    resetFilters: 'Reset Filters',
  },
  pagination: {
    showing: 'Showing',
    to: 'to',
    of: 'of',
    users: 'users',
    prev: 'Prev',
    next: 'Next',
  },
  bulk: {
    selectedCount: 'users selected',
    activateInactive: 'Activate Inactive',
    activateSelected: 'Activate Selected',
    suspendActive: 'Suspend Active',
    suspendSelected: 'Suspend Selected',
    deleteSelected: 'Delete Selected',
    deselect: 'Deselect',
    successActivated: 'Activated accounts successfully',
    successSuspended: 'Suspended accounts successfully',
    failed: 'Bulk action failed',
  },
  actionsMenu: {
    triggerTooltip: 'More Options',
    viewDetails: 'View Details',
    editProfile: 'Edit Profile',
    copyEmail: 'Copy Email Address',
    copiedToast: 'Email copied to clipboard',
    changeRole: 'Change Role',
    suspendAccount: 'Suspend Account',
    activateAccount: 'Activate Account',
    deleteAccount: 'Delete Account',
    protectedAccountTooltip: 'You cannot delete your own account',
    protectedAccountLabel: 'Your Account (Protected)',
  },
  addModal: {
    title: 'Add New User',
    subtitle: 'Create a new user account with platform privileges and default wallet currency.',
    fullNameLabel: 'Full Name',
    fullNamePlaceholder: 'e.g. Omar Tarek',
    emailLabel: 'Email Address',
    emailPlaceholder: 'e.g. name@example.com',
    roleLabel: 'Platform Role',
    currencyLabel: 'Default Currency',
    verifiedLabel: 'Mark Email as Verified',
    verifiedDesc: 'Allows instant access without requiring an activation link confirmation.',
    cancelBtn: 'Cancel',
    submitBtn: 'Create Account',
    submittingBtn: 'Creating Account...',
    successToast: 'User account created successfully',
    nameRequired: 'Please enter full name',
    emailInvalid: 'Please enter a valid email',
    emailDuplicate: 'This email is already registered to another user!',
    errorToast: 'Failed to add user',
    livePreview: 'Live User Preview',
    defaultFullName: 'User Full Name',
    currencyPreviewLabel: 'Currency:',
  },
  editModal: {
    title: 'Edit User Profile',
    subtitle: 'Modify user account details, administrative role, and system configurations.',
    fullNameLabel: 'Full Name',
    fullNamePlaceholder: 'e.g. Omar Tarek',
    emailLabel: 'Email Address',
    emailPlaceholder: 'e.g. name@example.com',
    roleLabel: 'Platform Role',
    currencyLabel: 'Default Currency',
    verifiedLabel: 'Email Confirmed',
    verifiedDesc: 'User email is confirmed and verified for security compliance.',
    cancelBtn: 'Cancel',
    submitBtn: 'Save Changes',
    submittingBtn: 'Saving Changes...',
    successToast: 'User profile updated successfully',
    nameRequired: 'Please enter full name',
    emailInvalid: 'Please enter a valid email',
    emailDuplicate: 'This email is already registered to another user!',
    errorToast: 'Failed to update user',
    livePreview: 'Live User Preview',
    currencyPreviewLabel: 'Currency:',
  },
  deleteModal: {
    titleSingle: 'Permanently Delete User Account',
    titleMultiple: 'Permanently Delete Selected Users',
    descSingle: 'Are you sure you want to permanently delete this user account? This action cannot be undone.',
    descMultiple: 'Are you sure you want to permanently delete these users? This action cannot be undone.',
    warningTitle: 'Permanent Cascading Wipe',
    warningDesc: 'All associated wallet balances, transactions, and budgets will be permanently deleted from the database.',
    selfProtectedAlert: 'Your current account was automatically excluded from deletion for security.',
    cascadingWipeListTitle: 'Data that will be permanently wiped:',
    walletsWipe: 'All digital wallets and balance registries',
    transactionsWipe: 'All financial transaction logs and transfer history',
    budgetsWipe: 'All personal budgets and spending thresholds',
    userProfileWipe: 'Authentication profile and identity credentials',
    userToDeleteLabel: 'Account to be deleted:',
    joinedDateLabel: 'Member since:',
    cancelBtn: 'Cancel',
    confirmBtnSingle: 'Yes, Delete Permanently',
    confirmBtnMultiple: 'Yes, Delete All Selected',
    deletingBtn: 'Deleting Permanently...',
    successSingle: 'User and all associated records permanently wiped',
    successMultiple: 'Users and all associated records permanently wiped',
    errorToast: 'Failed to delete user(s)',
  },
  detailsModal: {
    title: 'User Profile Details',
    idLabel: 'User ID',
    emailLabel: 'Email Address',
    currencyLabel: 'Primary Currency',
    walletsCountLabel: 'Registered Wallets',
    joinedDateLabel: 'Registered Date',
    lastLoginLabel: 'Last Login',
    neverLoggedIn: 'Never logged in',
    verifiedBadge: 'Verified',
    unverifiedBadge: 'Unverified',
    closeBtn: 'Close',
    idCopiedToast: 'User ID copied to clipboard',
    accountStatusLabel: 'Account Status',
    activeStatus: 'Active',
    suspendedStatus: 'Suspended',
    roleSectionTitle: 'User Platform Role & Permissions',
    roleDescriptions: {
      superAdmin: 'Full Control',
      admin: 'Management',
      user: 'Standard',
    },
  },
  toasts: {
    userSuspended: 'Account suspended',
    userActivated: 'Account activated',
    statusFailed: 'Failed to update user status',
    roleUpdated: 'User role updated successfully',
  },
};

export const usersAr: UsersTranslationSchema = {
  pageTitle: 'إدارة المستخدمين والحسابات',
  pageSubtitle: 'متابعة حسابات المستخدمين، الأمان، وتعيين الصلاحيات الإدارية',
  refresh: 'تحديث',
  addNewUser: 'إضافة مستخدم',
  kpi: {
    totalAccounts: 'إجمالي المستخدمين',
    activeUsers: 'الحسابات النشطة',
    suspended: 'حسابات محظورة',
    adminsStaff: 'فريق الإدارة',
  },
  tabs: {
    all: 'الكل',
    active: 'النشطة',
    inactive: 'المحظورة',
    admins: 'الإداريون',
  },
  searchPlaceholder: 'بحث بالاسم، البريد الإلكتروني، أو معرف المستخدم...',
  roleFilterLabel: 'الدور:',
  allRoles: 'جميع الأدوار',
  roles: {
    superAdmin: 'مدير نظام (SuperAdmin)',
    admin: 'مشرف (Admin)',
    user: 'مستخدم قياسي (User)',
  },
  views: {
    table: 'عرض جدول',
    cards: 'عرض بطاقات',
  },
  cards: {
    walletsAndCurrency: 'المحافظ والعملة',
    email: 'البريد الإلكتروني',
    view: 'عرض',
    edit: 'تعديل',
  },
  table: {
    user: 'المستخدم',
    role: 'الدور',
    currencyWallets: 'العملة والمحافظ',
    emailStatus: 'تأكيد البريد',
    status: 'الحالة',
    joined: 'تاريخ الانضمام',
    actions: 'الإجراءات',
    noWallets: 'بدون محافظ',
    walletsCount: 'محافظ',
    verified: 'موثق',
    unverified: 'غير موثق',
    active: 'نشط',
    suspended: 'محظور',
  },
  emptyState: {
    title: 'لم يتم العثور على أي مستخدمين',
    description: 'جرّب تغيير كلمات البحث أو تغيير التبويب المختار لعرض النتائج المطلوبة.',
    resetFilters: 'إعادة ضبط الفلاتر',
  },
  pagination: {
    showing: 'عرض',
    to: 'إلى',
    of: 'من أصل',
    users: 'مستخدم',
    prev: 'السابق',
    next: 'التالي',
  },
  bulk: {
    selectedCount: 'مستخدم محدد',
    activateInactive: 'تفعيل المعطلين',
    activateSelected: 'تفعيل المحدد',
    suspendActive: 'حظر النشطين',
    suspendSelected: 'حظر المحدد',
    deleteSelected: 'حذف المحدد',
    deselect: 'إلغاء',
    successActivated: 'تم تفعيل الحسابات المحددة بنجاح',
    successSuspended: 'تم حظر الحسابات المحددة بنجاح',
    failed: 'حدث خطأ أثناء تنفيذ الإجراء الجماعي',
  },
  actionsMenu: {
    triggerTooltip: 'خيارات إضافية',
    viewDetails: 'عرض التفاصيل',
    editProfile: 'تعديل البيانات',
    copyEmail: 'نسخ البريد الإلكتروني',
    copiedToast: 'تم نسخ البريد الإلكتروني',
    changeRole: 'تغيير الدور',
    suspendAccount: 'حظر هذا الحساب',
    activateAccount: 'تفعيل الحساب',
    deleteAccount: 'حذف الحساب نهائياً',
    protectedAccountTooltip: 'لا يمكنك حذف حسابك الخاص',
    protectedAccountLabel: 'حسابك الحالي (محمي)',
  },
  addModal: {
    title: 'إضافة مستخدم جديد',
    subtitle: 'إنشاء حساب مستخدم جديد وتحديد دوره الإداري والعملة الافتراضية لمحفظته.',
    fullNameLabel: 'الاسم الكامل',
    fullNamePlaceholder: 'مثال: عمر طارق',
    emailLabel: 'عنوان البريد الإلكتروني',
    emailPlaceholder: 'مثال: name@example.com',
    roleLabel: 'الدور في النظام',
    currencyLabel: 'العملة الافتراضية',
    verifiedLabel: 'تأكيد وتوثيق البريد الإلكتروني فوراً',
    verifiedDesc: 'يتيح تسجيل الدخول الفوري دون انتظار رابط التفعيل عبر البريد.',
    cancelBtn: 'إلغاء',
    submitBtn: 'إنشاء الحساب',
    submittingBtn: 'جاري إنشاء الحساب...',
    successToast: 'تم إنشاء حساب المستخدم بنجاح',
    nameRequired: 'يرجى إدخال اسم المستخدم',
    emailInvalid: 'يرجى إدخال بريد إلكتروني صحيح',
    emailDuplicate: 'هذا البريد الإلكتروني مسجل بالفعل لمستخدم آخر!',
    errorToast: 'حدث خطأ أثناء إضافة المستخدم',
    livePreview: 'معاينة بطاقة المستخدم',
    defaultFullName: 'اسم المستخدم',
    currencyPreviewLabel: 'العملة:',
  },
  editModal: {
    title: 'تعديل بيانات المستخدم',
    subtitle: 'تحديث البيانات الشخصية للمستخدم، صلاحياته، وإعدادات حسابه في المنصة.',
    fullNameLabel: 'الاسم الكامل',
    fullNamePlaceholder: 'مثال: عمر طارق',
    emailLabel: 'عنوان البريد الإلكتروني',
    emailPlaceholder: 'مثال: name@example.com',
    roleLabel: 'الدور في النظام',
    currencyLabel: 'العملة الافتراضية',
    verifiedLabel: 'البريد الإلكتروني موثق',
    verifiedDesc: 'حالة التحقق من البريد الإلكتروني وتأكيده أمنياً.',
    cancelBtn: 'إلغاء',
    submitBtn: 'حفظ التعديلات',
    submittingBtn: 'جاري حفظ التعديلات...',
    successToast: 'تم تحديث بيانات المستخدم بنجاح',
    nameRequired: 'يرجى إدخال اسم المستخدم',
    emailInvalid: 'يرجى إدخال بريد إلكتروني صحيح',
    emailDuplicate: 'هذا البريد الإلكتروني مسجل بالفعل لمستخدم آخر!',
    errorToast: 'حدث خطأ أثناء تعديل المستخدم',
    livePreview: 'معاينة بطاقة المستخدم',
    currencyPreviewLabel: 'العملة:',
  },
  deleteModal: {
    titleSingle: 'حذف حساب المستخدم نهائياً',
    titleMultiple: 'حذف الحسابات المحددة نهائياً',
    descSingle: 'هل أنت متأكد من رغبتك في حذف هذا الحساب نهائياً؟ هذا الإجراء لا يمكن التراجع عنه.',
    descMultiple: 'هل أنت متأكد من رغبتك في حذف الحسابات المحددة نهائياً؟ هذا الإجراء لا يمكن التراجع عنه.',
    warningTitle: 'حذف جذري وشامل من قاعدة البيانات',
    warningDesc: 'سيتم مسح كافة الأرصدة، المحافظ الرقمية، المعاملات، والميزانيات المرتبطة بهذا الحساب نهائياً.',
    selfProtectedAlert: 'تم استبعاد حسابك الإداري الحالي تلقائياً من عملية الحذف لحمايته.',
    cascadingWipeListTitle: 'البيانات التي سيتم مسحها نهائياً:',
    walletsWipe: 'كافة المحافظ الرقمية وسجلات الأرصدة المالية',
    transactionsWipe: 'جميع سجلات المعاملات والتحويلات المالية التاريخية',
    budgetsWipe: 'الميزانيات الشهرية وحدود الإنفاق المحددة',
    userProfileWipe: 'ملف التعريف الإداري وبيانات تسجيل الدخول',
    userToDeleteLabel: 'الحساب المستهدف بالحذف:',
    joinedDateLabel: 'تاريخ الانضمام:',
    cancelBtn: 'إلغاء',
    confirmBtnSingle: 'نعم، احذف الحساب نهائياً',
    confirmBtnMultiple: 'نعم، احذف كافة الحسابات المحددة',
    deletingBtn: 'جاري الحذف النهائي...',
    successSingle: 'تم مسح المستخدم وكافة سجلاته المالية ومحافظه نهائياً',
    successMultiple: 'تم مسح المستخدمين المحددين وكافة سجلاتهم نهائياً',
    errorToast: 'حدث خطأ أثناء حذف الحساب',
  },
  detailsModal: {
    title: 'تفاصيل بطاقة المستخدم',
    idLabel: 'معرف المستخدم',
    emailLabel: 'البريد الإلكتروني',
    currencyLabel: 'العملة الرئيسية',
    walletsCountLabel: 'المحافظ المسجلة',
    joinedDateLabel: 'تاريخ التسجيل',
    lastLoginLabel: 'آخر تسجيل دخول',
    neverLoggedIn: 'لم يسجل دخول بعد',
    verifiedBadge: 'موثق',
    unverifiedBadge: 'غير موثق',
    closeBtn: 'إغلاق',
    idCopiedToast: 'تم نسخ معرف المستخدم',
    accountStatusLabel: 'حالة الحساب',
    activeStatus: 'نشط ومفعل',
    suspendedStatus: 'محظور / معطل',
    roleSectionTitle: 'صلاحيات ودور المستخدم في المنصة',
    roleDescriptions: {
      superAdmin: 'تحكم كامل',
      admin: 'إشراف وإدارة',
      user: 'مستخدم قياسي',
    },
  },
  toasts: {
    userSuspended: 'تم حظر الحساب بنجاح',
    userActivated: 'تم تفعيل الحساب بنجاح',
    statusFailed: 'حدث خطأ أثناء تعديل الحالة',
    roleUpdated: 'تم تحديث دور المستخدم بنجاح',
  },
};
