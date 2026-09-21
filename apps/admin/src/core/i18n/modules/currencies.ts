export interface CurrenciesTranslationSchema {
  pageTitle: string;
  pageSubtitle: string;
  syncRates: string;
  syncing: string;
  kpi: {
    baseCurrency: string;
    baseBadge: string;
    changeBaseTooltip: string;
    activeMobile: string;
    activeSuffix: string;
    featuredCount: string;
    featuredSuffix: string;
    catalogAvailable: string;
    availableSuffix: string;
    lastRatesSync: string;
    notSpecified: string;
  };
  tabs: {
    active: string;
    arab: string;
    global: string;
    catalog: string;
    all: string;
  };
  searchPlaceholder: string;
  viewMode: {
    grid: string;
    table: string;
  };
  status: {
    active: string;
    hidden: string;
    featured: string;
  };
  actions: {
    setAsBase: string;
    copyRate: string;
    rateCopied: string;
    hideFromApp: string;
    enableAndShow: string;
    toggleFeatured: string;
    clearSearch: string;
  };
  card: {
    valuationVs: string;
    updated: string;
  };
  table: {
    currency: string;
    symbol: string;
    rateVs: string;
    status: string;
    lastUpdated: string;
    actions: string;
  };
  empty: {
    loading: string;
    noResultsSearch: string;
    noCurrenciesSection: string;
  };
}

export const currenciesEn: CurrenciesTranslationSchema = {
  pageTitle: 'Currencies & Live Exchange Rates',
  pageSubtitle: 'Manage active platform currencies, toggle world & Arab currencies on/off, and sync live rates',
  syncRates: 'Sync Live Rates',
  syncing: 'Syncing Rates...',
  kpi: {
    baseCurrency: 'Base Currency',
    baseBadge: 'Base',
    changeBaseTooltip: 'Change Base Currency',
    activeMobile: 'Active Mobile Currencies',
    activeSuffix: 'Active',
    featuredCount: 'Priority Currencies',
    featuredSuffix: 'Featured',
    catalogAvailable: 'Catalog Available',
    availableSuffix: 'Available',
    lastRatesSync: 'Last Rates Sync',
    notSpecified: 'N/A',
  },
  tabs: {
    active: 'Active',
    arab: 'Arab & GCC',
    global: 'Major Global',
    catalog: 'Catalog',
    all: 'All',
  },
  searchPlaceholder: 'Search (USD, Riyal...)',
  viewMode: {
    grid: 'Grid View',
    table: 'Table View',
  },
  status: {
    active: 'Active',
    hidden: 'Hidden',
    featured: 'Featured',
  },
  actions: {
    setAsBase: 'Set as Base Currency',
    copyRate: 'Copy Rate',
    rateCopied: 'Copied: ',
    hideFromApp: 'Hide from App',
    enableAndShow: 'Enable & Show',
    toggleFeatured: 'Toggle Featured / Priority',
    clearSearch: 'Clear search',
  },
  card: {
    valuationVs: 'Valuation vs',
    updated: 'Updated: ',
  },
  table: {
    currency: 'Currency',
    symbol: 'Symbol',
    rateVs: 'Rate vs',
    status: 'Status',
    lastUpdated: 'Last Updated',
    actions: 'Actions',
  },
  empty: {
    loading: 'Loading currencies...',
    noResultsSearch: 'No currencies match your search query',
    noCurrenciesSection: 'No currencies found in this section',
  },
};

export const currenciesAr: CurrenciesTranslationSchema = {
  pageTitle: 'العملات وأسعار الصرف الرسمية',
  pageSubtitle: 'إدارة العملات المعتمدة في تطبيق محفظتي والتحكم في إظهار أو إخفاء العملات ومزامنة أسعارها',
  syncRates: 'تحديث الأسعار الرسمية',
  syncing: 'جاري المزامنة...',
  kpi: {
    baseCurrency: 'العملة الأساسية للنظام',
    baseBadge: 'أساسية',
    changeBaseTooltip: 'تغيير العملة الأساسية',
    activeMobile: 'العملات المفعلة بالموبايل',
    activeSuffix: 'عملات نشطة',
    featuredCount: 'العملات المميزة في المقدمة',
    featuredSuffix: 'مميزة',
    catalogAvailable: 'مكتبة العملات الجاهزة',
    availableSuffix: 'عملة جاهزة',
    lastRatesSync: 'آخر تحديث للأسعار',
    notSpecified: 'غير محدد',
  },
  tabs: {
    active: 'المفعلة',
    arab: 'الخليج والوطن العربي',
    global: 'عملات عالمية',
    catalog: 'المكتبة المتاحة',
    all: 'الكل',
  },
  searchPlaceholder: 'بحث بالاسم أو الرمز (USD, ريال...)',
  viewMode: {
    grid: 'عرض كروت',
    table: 'عرض جدول',
  },
  status: {
    active: 'مفعل',
    hidden: 'مخفي',
    featured: 'مميزة',
  },
  actions: {
    setAsBase: 'تعيين كعملة أساسية للنظام',
    copyRate: 'نسخ السعر',
    rateCopied: 'تم نسخ السعر: ',
    hideFromApp: 'إخفاء من التطبيق',
    enableAndShow: 'إظهار وتفعيل',
    toggleFeatured: 'تثبيت / إلغاء التمييز في المقدمة',
    clearSearch: 'إلغاء البحث',
  },
  card: {
    valuationVs: 'سعر الصرف مقابل',
    updated: 'تحديث: ',
  },
  table: {
    currency: 'العملة',
    symbol: 'الرمز',
    rateVs: 'السعر مقابل',
    status: 'الحالة',
    lastUpdated: 'آخر تحديث',
    actions: 'إجراء',
  },
  empty: {
    loading: 'جاري تحميل قائمة العملات...',
    noResultsSearch: 'لا توجد نتائج مطابقة لبحثك',
    noCurrenciesSection: 'لا توجد عملات في هذا القسم حالياً',
  },
};
