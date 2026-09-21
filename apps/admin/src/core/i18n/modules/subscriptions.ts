export interface SubscriptionsTranslationSchema {
  plans: {
    pageTitle: string;
    pageSubtitle: string;
    refresh: string;
    newPlan: string;
    loading: string;
    emptyTitle: string;
    createFirst: string;
    dragHint: string;
    sortByPrice: string;
    reorderSuccess: string;
    card: {
      monthly: string;
      yearly: string;
      lifetime: string;
      mostPopular: string;
      free: string;
      perMonth: string;
      perYear: string;
      wallets: string;
      aiRequests: string;
      unlimited: string;
      includedFeatures: string;
      noFeatures: string;
      active: string;
      archived: string;
      edit: string;
      delete: string;
      confirmDelete: string;
      noDescription: string;
    };
    modal: {
      createTitle: string;
      editTitle: string;
      createSubtitle: string;
      editSubtitle: string;
      nameEn: string;
      nameAr: string;
      nameEnPlaceholder: string;
      nameArPlaceholder: string;
      priceEgp: string;
      billingCycle: string;
      monthlyOption: string;
      yearlyOption: string;
      lifetimeOption: string;
      descriptionEn: string;
      descriptionAr: string;
      descriptionEnPlaceholder: string;
      descriptionArPlaceholder: string;
      maxWallets: string;
      maxAiRequests: string;
      highlightPopular: string;
      activeAvailable: string;
      allowExport: string;
      allowMultiCurrency: string;
      featuresSectionTitle: string;
      featuresCountSuffix: string;
      featureEnPlaceholder: string;
      featureArPlaceholder: string;
      addFeature: string;
      noFeaturesYet: string;
      noFeaturesHelper: string;
      removeFeature: string;
      noEnFeature: string;
      noArFeature: string;
      cancel: string;
      saveChanges: string;
      createPlan: string;
      saving: string;
    };
  };
  promoCodes: {
    pageTitle: string;
    pageSubtitle: string;
    refresh: string;
    newPromoCode: string;
    loading: string;
    emptyTitle: string;
    createFirst: string;
    card: {
      discountOff: string;
      active: string;
      disabled: string;
      toggleStatus: string;
      redemptions: string;
      expires: string;
      neverExpires: string;
      delete: string;
      confirmDelete: string;
    };
    modal: {
      createTitle: string;
      createSubtitle: string;
      codeLabel: string;
      codePlaceholder: string;
      discountLabel: string;
      maxUsesLabel: string;
      expiresLabel: string;
      activeLabel: string;
      cancel: string;
      create: string;
      creating: string;
    };
  };
  subscriptions: {
    pageTitle: string;
    pageSubtitle: string;
    refresh: string;
    loading: string;
    emptyTitle: string;
    kpis: {
      mrr: string;
      activeSubscribers: string;
      churnRate: string;
    };
    filters: {
      searchPlaceholder: string;
      all: string;
      active: string;
      expired: string;
      canceled: string;
    };
    table: {
      subscriber: string;
      plan: string;
      status: string;
      amount: string;
      gateway: string;
      period: string;
      autoRenew: string;
      to: string;
      yes: string;
      no: string;
      showingCount: (start: number, end: number, total: number) => string;
    };
  };
  payments: {
    pageTitle: string;
    pageSubtitle: string;
    refresh: string;
    exportCsv: string;
    exportSuccess: string;
    exportError: string;
    loading: string;
    emptyTitle: string;
    filters: {
      searchPlaceholder: string;
      all: string;
      success: string;
      failed: string;
      refunded: string;
    };
    table: {
      invoice: string;
      customer: string;
      plan: string;
      amount: string;
      gateway: string;
      reference: string;
      status: string;
      date: string;
    };
  };
}

export const subscriptionsEn: SubscriptionsTranslationSchema = {
  plans: {
    pageTitle: 'Pricing Plans & Feature Limits',
    pageSubtitle: 'Define subscription tiers, pricing in EGP, and bilingual feature entitlements.',
    refresh: 'Refresh',
    newPlan: 'New Pricing Plan',
    loading: 'Loading pricing plans...',
    emptyTitle: 'No pricing plans configured yet.',
    createFirst: 'Create First Plan',
    dragHint: 'Drag and drop cards to customize their display order across mobile and web apps.',
    sortByPrice: 'Sort by Cheapest',
    reorderSuccess: 'Plans order updated successfully.',
    card: {
      monthly: 'Monthly',
      yearly: 'Yearly',
      lifetime: 'Lifetime',
      mostPopular: 'Most Popular',
      free: 'Free',
      perMonth: '/ mo',
      perYear: '/ yr',
      wallets: 'Wallets:',
      aiRequests: 'AI Req/mo:',
      unlimited: 'Unlimited',
      includedFeatures: 'Included Features:',
      noFeatures: 'No custom features listed',
      active: 'Active',
      archived: 'Archived',
      edit: 'Edit',
      delete: 'Delete',
      confirmDelete: 'Are you sure you want to delete or archive plan "{name}"?',
      noDescription: 'No description provided',
    },
    modal: {
      createTitle: 'Create Pricing Plan',
      editTitle: 'Edit Pricing Plan',
      createSubtitle: 'Define tier details, limits, and bilingual features',
      editSubtitle: 'Update tier details, limits, and bilingual features',
      nameEn: 'Plan Name (English)',
      nameAr: 'Plan Name (Arabic)',
      nameEnPlaceholder: 'e.g. Mahfazti Pro',
      nameArPlaceholder: 'مثال: باقة المحترفين',
      priceEgp: 'Price (EGP)',
      billingCycle: 'Billing Cycle',
      monthlyOption: 'Monthly',
      yearlyOption: 'Yearly',
      lifetimeOption: 'Lifetime',
      descriptionEn: 'Description (English)',
      descriptionAr: 'Description (Arabic)',
      descriptionEnPlaceholder: 'Brief summary of this tier in English...',
      descriptionArPlaceholder: 'نبذة مختصرة عن الباقة بالعربية...',
      maxWallets: 'Max Wallets',
      maxAiRequests: 'Monthly AI Requests',
      highlightPopular: 'Highlight (Most Popular)',
      activeAvailable: 'Active (Available)',
      allowExport: 'Allow Report Export (PDF/Excel)',
      allowMultiCurrency: 'Allow Multi-Currency Sync',
      featuresSectionTitle: 'Bilingual Feature Entitlements',
      featuresCountSuffix: 'features',
      featureEnPlaceholder: 'Feature (English): e.g. Export Reports',
      featureArPlaceholder: 'Feature (Arabic): مثال: تصدير التقارير',
      addFeature: 'Add',
      noFeaturesYet: 'No features added yet.',
      noFeaturesHelper: 'Type English and Arabic feature texts and click Add.',
      removeFeature: 'Remove Feature',
      noEnFeature: 'No English',
      noArFeature: 'No Arabic translation',
      cancel: 'Cancel',
      saveChanges: 'Save Changes',
      createPlan: 'Create Plan',
      saving: 'Saving...',
    },
  },
  promoCodes: {
    pageTitle: 'Promo Codes & Discounts',
    pageSubtitle: 'Create and track promotional discount vouchers for subscriber acquisition.',
    refresh: 'Refresh',
    newPromoCode: 'Create Promo Code',
    loading: 'Loading promo codes...',
    emptyTitle: 'No active discount promo codes.',
    createFirst: 'Create Promo Code',
    card: {
      discountOff: 'OFF Subscriptions',
      active: 'Active',
      disabled: 'Disabled',
      toggleStatus: 'Toggle Promo Code Status',
      redemptions: 'Redemptions:',
      expires: 'Expires:',
      neverExpires: 'Never expires',
      delete: 'Delete',
      confirmDelete: 'Are you sure you want to delete promo code "{code}"?',
    },
    modal: {
      createTitle: 'Create Promo Code',
      createSubtitle: 'Discount voucher for subscriptions',
      codeLabel: 'Promo Code',
      codePlaceholder: 'e.g. SUMMER50',
      discountLabel: 'Discount (%)',
      maxUsesLabel: 'Max Uses',
      expiresLabel: 'Expiry Date (Optional)',
      activeLabel: 'Active immediately',
      cancel: 'Cancel',
      create: 'Create Promo Code',
      creating: 'Creating...',
    },
  },
  subscriptions: {
    pageTitle: 'User Subscriptions',
    pageSubtitle: 'Monitor subscriber tiers, active renewals, and monthly recurring revenue.',
    refresh: 'Refresh',
    loading: 'Loading subscriptions...',
    emptyTitle: 'No subscriptions found matching your query.',
    kpis: {
      mrr: 'Monthly Recurring (MRR)',
      activeSubscribers: 'Active Paid Subscribers',
      churnRate: 'Churn Rate',
    },
    filters: {
      searchPlaceholder: 'Search subscriber name, email, or plan...',
      all: 'All',
      active: 'Active',
      expired: 'Expired',
      canceled: 'Canceled',
    },
    table: {
      subscriber: 'Subscriber',
      plan: 'Plan',
      status: 'Status',
      amount: 'Amount',
      gateway: 'Gateway',
      period: 'Period',
      autoRenew: 'Auto-Renew',
      to: 'to',
      yes: 'Yes',
      no: 'No',
      showingCount: (start, end, total) => `Showing ${start} to ${end} of ${total} subscriptions`,
    },
  },
  payments: {
    pageTitle: 'Payment Logs & Invoices',
    pageSubtitle: 'Real-time gateway transactions from Paymob, Fawry, Apple Pay, and Stripe.',
    refresh: 'Refresh',
    exportCsv: 'Export CSV',
    exportSuccess: 'Payments exported to CSV successfully.',
    exportError: 'No payments to export.',
    loading: 'Loading payments...',
    emptyTitle: 'No payment records found matching your filters.',
    filters: {
      searchPlaceholder: 'Search invoice, email, ref...',
      all: 'All',
      success: 'Success',
      failed: 'Failed',
      refunded: 'Refunded',
    },
    table: {
      invoice: 'Invoice',
      customer: 'Customer',
      plan: 'Plan',
      amount: 'Amount',
      gateway: 'Gateway',
      reference: 'Reference',
      status: 'Status',
      date: 'Date',
    },
  },
};

export const subscriptionsAr: SubscriptionsTranslationSchema = {
  plans: {
    pageTitle: 'باقات الاشتراك وحدود الميزات',
    pageSubtitle: 'إدارة وتحديد مستويات الاشتراك، الأسعار بالجنيه المصري، ومميزات الباقات باللغتين العربية والإنجليزية.',
    refresh: 'تحديث',
    newPlan: 'إضافة باقة جديدة',
    loading: 'جاري تحميل باقات الاشتراك...',
    emptyTitle: 'لم يتم إنشاء أي باقات اشتراك حتى الآن.',
    createFirst: 'إنشاء أول باقة',
    dragHint: 'اسحب وأفلت كروت الباقات لترتيب ظهورها المباشر في تطبيقات الموبايل والموقع.',
    sortByPrice: 'ترتيب: الأرخص أولاً',
    reorderSuccess: 'تم تحديث وترتيب الباقات بنجاح.',
    card: {
      monthly: 'شهري',
      yearly: 'سنوي',
      lifetime: 'مدى الحياة',
      mostPopular: 'الأكثر طلباً',
      free: 'مجاناً',
      perMonth: '/ شهرياً',
      perYear: '/ سنوياً',
      wallets: 'المحافظ:',
      aiRequests: 'طلبات الذكاء الاصطناعي:',
      unlimited: 'غير محدود',
      includedFeatures: 'المميزات المضمنة:',
      noFeatures: 'لا توجد مميزات مخصصة',
      active: 'نشطة',
      archived: 'مؤرشفة',
      edit: 'تعديل',
      delete: 'حذف',
      confirmDelete: 'هل أنت متأكد من حذف أو أرشفة باقة "{name}"؟',
      noDescription: 'لا يوجد وصف مضاف',
    },
    modal: {
      createTitle: 'إنشاء باقة اشتراك جديدة',
      editTitle: 'تعديل باقة الاشتراك',
      createSubtitle: 'حدد الأسعار، الحدود، والمميزات باللغتين العربية والإنجليزية',
      editSubtitle: 'تحديث الأسعار، الحدود، والمميزات باللغتين العربية والإنجليزية',
      nameEn: 'اسم الباقة (English)',
      nameAr: 'اسم الباقة (بالعربي)',
      nameEnPlaceholder: 'e.g. Mahfazti Pro',
      nameArPlaceholder: 'مثال: باقة المحترفين',
      priceEgp: 'السعر (جنيه مصري - EGP)',
      billingCycle: 'دورة الفوترة',
      monthlyOption: 'شهري (Monthly)',
      yearlyOption: 'سنوي (Yearly)',
      lifetimeOption: 'مدى الحياة (Lifetime)',
      descriptionEn: 'الوصف (English)',
      descriptionAr: 'الوصف (بالعربي)',
      descriptionEnPlaceholder: 'نبذة مختصرة عن الباقة بالإنجليزية...',
      descriptionArPlaceholder: 'نبذة مختصرة عن الباقة بالعربية...',
      maxWallets: 'الحد الأقصى للمحافظ',
      maxAiRequests: 'طلبات الذكاء الاصطناعي الشهرية',
      highlightPopular: 'تمييز الباقة (الأكثر طلباً)',
      activeAvailable: 'الباقة نشطة (متاحة للمستخدمين)',
      allowExport: 'السماح بتصدير التقارير (PDF/Excel)',
      allowMultiCurrency: 'السماح بتعدد ومزامنة العملات',
      featuresSectionTitle: 'المميزات المضمنة باللغتين',
      featuresCountSuffix: 'ميزات',
      featureEnPlaceholder: 'الميزة (English): e.g. Export Reports',
      featureArPlaceholder: 'الميزة (بالعربي): مثال: تصدير التقارير',
      addFeature: 'إضافة',
      noFeaturesYet: 'لا توجد مميزات مضافة حتى الآن.',
      noFeaturesHelper: 'اكتب الميزة باللغتين واضغط زر إضافة.',
      removeFeature: 'حذف الميزة',
      noEnFeature: 'بدون إنجليزية',
      noArFeature: 'بدون ترجمة عربية',
      cancel: 'إلغاء',
      saveChanges: 'حفظ التعديلات',
      createPlan: 'إنشاء الباقة',
      saving: 'جاري الحفظ...',
    },
  },
  promoCodes: {
    pageTitle: 'أكواد الخصم والعروض الترويجية',
    pageSubtitle: 'إنشاء ومتابعة قسائم وأكواد الخصم الترويجية لاكتساب المشتركين.',
    refresh: 'تحديث',
    newPromoCode: 'إنشاء كود خصم',
    loading: 'جاري تحميل أكواد الخصم...',
    emptyTitle: 'لا توجد أكواد خصم مفعلة حتى الآن.',
    createFirst: 'إنشاء أول كود خصم',
    card: {
      discountOff: 'خصم على الاشتراكات',
      active: 'نشط',
      disabled: 'معطل',
      toggleStatus: 'تبديل حالة التفعيل',
      redemptions: 'عدد مرات الاستخدام:',
      expires: 'ينتهي في:',
      neverExpires: 'لا تنتهي صلاحيته',
      delete: 'حذف',
      confirmDelete: 'هل أنت متأكد من حذف كود الخصم "{code}"؟',
    },
    modal: {
      createTitle: 'إنشاء كود خصم جديد',
      createSubtitle: 'قسيمة خصم مئوية على الاشتراكات',
      codeLabel: 'كود الخصم (Promo Code)',
      codePlaceholder: 'مثال: SUMMER50',
      discountLabel: 'نسبة الخصم (%)',
      maxUsesLabel: 'أقصى عدد مرات استخدام',
      expiresLabel: 'تاريخ الانتهاء (اختياري)',
      activeLabel: 'تفعيل الكود فوراً',
      cancel: 'إلغاء',
      create: 'إنشاء كود الخصم',
      creating: 'جاري الإنشاء...',
    },
  },
  subscriptions: {
    pageTitle: 'اشتراكات المستخدمين',
    pageSubtitle: 'متابعة وتتبع اشتراكات المستخدمين، التجديدات النشطة، والإيرادات الشهرية المتكررة.',
    refresh: 'تحديث',
    loading: 'جاري تحميل الاشتراكات...',
    emptyTitle: 'لا توجد نتائج اشتراكات مطابقة.',
    kpis: {
      mrr: 'الإيراد الشهري المتكرر (MRR)',
      activeSubscribers: 'المشتركون النشطون',
      churnRate: 'معدل الإلغاء (Churn Rate)',
    },
    filters: {
      searchPlaceholder: 'بحث بالاسم، البريد، أو الباقة...',
      all: 'الكل',
      active: 'نشط',
      expired: 'منتهي',
      canceled: 'ملغي',
    },
    table: {
      subscriber: 'المستخدم',
      plan: 'الباقة',
      status: 'الحالة',
      amount: 'المبلغ',
      gateway: 'بوابة الدفع',
      period: 'فترة الاشتراك',
      autoRenew: 'تجديد تلقائي',
      to: 'إلى',
      yes: 'نعم',
      no: 'لا',
      showingCount: (start, end, total) => `عرض ${start} إلى ${end} من إجمالي ${total} سجل`,
    },
  },
  payments: {
    pageTitle: 'سجل المدفوعات والفواتير',
    pageSubtitle: 'سجل العمليات المالية المباشرة عبر Paymob و Fawry و Apple Pay و Stripe.',
    refresh: 'تحديث',
    exportCsv: 'تصدير ملف CSV',
    exportSuccess: 'تم تصدير ملف الـ CSV بنجاح.',
    exportError: 'لا توجد مدفوعات لتصديرها.',
    loading: 'جاري تحميل سجل المدفوعات...',
    emptyTitle: 'لا توجد فواتير أو مدفوعات تطابق معايير البحث.',
    filters: {
      searchPlaceholder: 'بحث برقم الفاتورة، البريد، المرجع...',
      all: 'الكل',
      success: 'ناجحة',
      failed: 'فاشلة',
      refunded: 'مسترجعة',
    },
    table: {
      invoice: 'رقم الفاتورة',
      customer: 'المستخدم',
      plan: 'الباقة',
      amount: 'المبلغ',
      gateway: 'بوابة الدفع',
      reference: 'المرجع',
      status: 'الحالة',
      date: 'التاريخ',
    },
  },
};
