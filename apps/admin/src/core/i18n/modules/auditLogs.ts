export interface AuditLogsTranslationSchema {
  pageTitle: string;
  pageSubtitle: string;
  refresh: string;
  kpi: {
    totalEvents: string;
    userOps: string;
    securityEvents: string;
    alertsWarnings: string;
  };
  tabs: {
    all: string;
    userManagement: string;
    security: string;
    billingPricing: string;
    system: string;
  };
  searchPlaceholder: string;
  statusFilterLabel: string;
  allStatuses: string;
  filters: {
    tableView: string;
    cardsView: string;
  };
  statuses: {
    success: string;
    warning: string;
    failed: string;
  };
  categories: {
    userManagement: string;
    security: string;
    billingPricing: string;
    system: string;
  };
  table: {
    action: string;
    targetResource: string;
    category: string;
    admin: string;
    ipAddress: string;
    status: string;
    timestamp: string;
    details: string;
    copyResource: string;
    copiedToast: string;
    viewDetails: string;
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
    events: string;
    prev: string;
    next: string;
  };
  modal: {
    title: string;
    executedBy: string;
    category: string;
    ipAddress: string;
    timestamp: string;
    notesTitle: string;
    copyRecord: string;
    copiedToast: string;
    closeBtn: string;
  };
}

export const auditLogsEn: AuditLogsTranslationSchema = {
  pageTitle: 'Admin Activity & Audit Logs',
  pageSubtitle: 'Immutable timeline tracking all administrator actions, security operations, and platform changes.',
  refresh: 'Refresh Feed',
  kpi: {
    totalEvents: 'Total Events',
    userOps: 'User Ops',
    securityEvents: 'Security Events',
    alertsWarnings: 'Alerts & Warnings',
  },
  tabs: {
    all: 'All Activity',
    userManagement: 'User Management',
    security: 'Security',
    billingPricing: 'Billing & Pricing',
    system: 'System',
  },
  searchPlaceholder: 'Search by action, admin name, email, IP, or resource...',
  statusFilterLabel: 'Status:',
  allStatuses: 'All Statuses',
  filters: {
    tableView: 'Table View',
    cardsView: 'Cards Grid View',
  },
  statuses: {
    success: 'Success',
    warning: 'Warning',
    failed: 'Failed',
  },
  categories: {
    userManagement: 'User Management',
    security: 'Security',
    billingPricing: 'Billing & Pricing',
    system: 'System',
  },
  table: {
    action: 'Action / Event',
    targetResource: 'Target Resource',
    category: 'Category',
    admin: 'Admin',
    ipAddress: 'IP Address',
    status: 'Status',
    timestamp: 'Timestamp',
    details: 'Details',
    copyResource: 'Copy Resource',
    copiedToast: 'Copied to clipboard',
    viewDetails: 'View Full Details',
  },
  emptyState: {
    title: 'No audit records found',
    description: 'Try adjusting your search query or switching category filters.',
    resetFilters: 'Reset Filters',
  },
  pagination: {
    showing: 'Showing',
    to: 'to',
    of: 'of',
    events: 'events',
    prev: 'Prev',
    next: 'Next',
  },
  modal: {
    title: 'Audit Record Details',
    executedBy: 'Executed By',
    category: 'Category',
    ipAddress: 'IP Address',
    timestamp: 'Timestamp',
    notesTitle: 'Additional Notes / Payload:',
    copyRecord: 'Copy Record',
    copiedToast: 'Audit record copied to clipboard',
    closeBtn: 'Close',
  },
};

export const auditLogsAr: AuditLogsTranslationSchema = {
  pageTitle: 'سجل نشاط المشرفين والعمليات',
  pageSubtitle: 'تتبع تاريخي غير قابل للتعديل لكافة إجراءات المشرفين، التعديلات الأمنية، والعمليات الحساسة.',
  refresh: 'تحديث السجل',
  kpi: {
    totalEvents: 'إجمالي العمليات',
    userOps: 'إدارة المستخدمين',
    securityEvents: 'الأمان والصلاحيات',
    alertsWarnings: 'تنبيهات / عمليات حساسة',
  },
  tabs: {
    all: 'كافة الأنشطة',
    userManagement: 'إدارة المستخدمين',
    security: 'الأمان والصلاحيات',
    billingPricing: 'الفوترة والأسعار',
    system: 'النظام',
  },
  searchPlaceholder: 'بحث بالعملية، المشرف، البريد، عنوان IP، أو المورد المستهدف...',
  statusFilterLabel: 'الحالة:',
  allStatuses: 'كافة الحالات',
  filters: {
    tableView: 'عرض الجدول',
    cardsView: 'عرض الكروت',
  },
  statuses: {
    success: 'ناجحة',
    warning: 'تحذير',
    failed: 'فاشلة',
  },
  categories: {
    userManagement: 'إدارة المستخدمين',
    security: 'الأمان والصلاحيات',
    billingPricing: 'الفوترة والأسعار',
    system: 'النظام',
  },
  table: {
    action: 'الإجراء / العملية',
    targetResource: 'المورد المستهدف',
    category: 'التصنيف',
    admin: 'المشرف',
    ipAddress: 'عنوان IP',
    status: 'الحالة',
    timestamp: 'التاريخ والوقت',
    details: 'التفاصيل',
    copyResource: 'نسخ المورد',
    copiedToast: 'تم النسخ بنجاح',
    viewDetails: 'عرض التفاصيل التقنية',
  },
  emptyState: {
    title: 'لم يتم العثور على أي سجلات مطابقة',
    description: 'جرّب تغيير كلمات البحث أو تغيير تبويب التصنيف لعرض السجلات المطلوبة.',
    resetFilters: 'إعادة ضبط الفلاتر',
  },
  pagination: {
    showing: 'عرض',
    to: 'إلى',
    of: 'من أصل',
    events: 'عملية',
    prev: 'السابق',
    next: 'التالي',
  },
  modal: {
    title: 'تفاصيل سجل العملية',
    executedBy: 'المشرف المنفذ للعملية',
    category: 'التصنيف',
    ipAddress: 'عنوان IP',
    timestamp: 'التاريخ والوقت',
    notesTitle: 'تفاصيل إضافية / الملاحظات:',
    copyRecord: 'نسخ السجل',
    copiedToast: 'تم نسخ بيانات السجل بالكامل',
    closeBtn: 'إغلاق',
  },
};
