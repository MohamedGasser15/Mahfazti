import { usersEn, usersAr, type UsersTranslationSchema } from './modules/users';
import { auditLogsEn, auditLogsAr, type AuditLogsTranslationSchema } from './modules/auditLogs';
import { rolesTranslationsEn, rolesTranslationsAr, type RolesTranslationSchema } from './modules/roles';

export type Locale = 'en' | 'ar';
export type Direction = 'ltr' | 'rtl';

export interface TranslationSchema {
  common: {
    language: string;
    switchLanguage: string;
    lightMode: string;
    darkMode: string;
    toggleTheme: string;
    loading: string;
    cancel: string;
    active: string;
    secure: string;
    verified: string;
  };
  auth: {
    brandSubtitle: string;
    signInTitle: string;
    signInSubtitle: string;
    emailLabel: string;
    emailPlaceholder: string;
    passwordLabel: string;
    passwordPlaceholder: string;
    forgotPassword: string;
    showPassword: string;
    hidePassword: string;
    keepSignedIn: string;
    signInButton: string;
    signingIn: string;
    securityNoticeTitle: string;
    securityNoticeDesc: string;
    resetModal: {
      title: string;
      description: string;
      emailLabel: string;
      emailPlaceholder: string;
      cancelBtn: string;
      submitBtn: string;
      submittingBtn: string;
      successTitle: string;
      successDesc: string;
    };
    toasts: {
      signedInTitle: string;
      signedInDesc: string;
      missingCredsTitle: string;
      missingCredsDesc: string;
      resetDispatchedTitle: string;
      resetDispatchedDesc: string;
      authFailedTitle: string;
    };
    errors: {
      accessDenied: string;
      invalidCredentials: string;
      missingCredentials: string;
      accountBanned: string;
      accountLocked: string;
      networkError: string;
      serverError: string;
      unexpectedError: string;
      resetFailed: string;
    };
    resetPasswordPage: {
      title: string;
      subtitle: string;
      emailLabel: string;
      newPasswordLabel: string;
      newPasswordPlaceholder: string;
      confirmPasswordLabel: string;
      confirmPasswordPlaceholder: string;
      submitBtn: string;
      submittingBtn: string;
      backToLogin: string;
      invalidLinkTitle: string;
      invalidLinkDesc: string;
      requestNewLink: string;
      successTitle: string;
      successDesc: string;
      goToLogin: string;
      passwordMismatch: string;
      passwordTooShort: string;
    };
    slides: Array<{
      badge: string;
      title: string;
      description: string;
      cardLabel: string;
      cardValue: string;
      cardBadge: string;
      pills: Array<{ label: string; val: string }>;
      stat1: {
        title: string;
        value: string;
        desc: string;
      };
      stat2: {
        title: string;
        value: string;
        desc: string;
      };
    }>;
  };
  sidebar: {
    workspaceTitle: string;
    workspaceSubtitle: string;
    overview: string;
    modulesTitle: string;
    superAdminRole: string;
    signOutTooltip: string;
    signedOutToast: string;
    groups: {
      finance: {
        label: string;
        transactions: string;
        currencies: string;
      };
      users: {
        label: string;
        directory: string;
        roles: string;
      };
      monetization: {
        label: string;
        subscriptions: string;
        plans: string;
        payments: string;
        promoCodes: string;
      };
      engagement: {
        label: string;
        notifications: string;
        support: string;
      };
      system: {
        label: string;
        aiLogs: string;
        categories: string;
        auditLogs: string;
      };
      devOps: {
        label: string;
        webhooks: string;
        health: string;
        settings: string;
      };
    };
  };
  navbar: {
    searchPlaceholder: string;
    searchShortcut: string;
    notificationsTooltip: string;
    superAdmin: string;
    routes: Record<string, { section: string; title: string }>;
  };
  users: UsersTranslationSchema;
  auditLogs: AuditLogsTranslationSchema;
  roles: RolesTranslationSchema;
}

export const translations: Record<Locale, TranslationSchema> = {
  en: {
    common: {
      language: 'English',
      switchLanguage: 'Switch to Arabic',
      lightMode: 'Switch to Light Mode',
      darkMode: 'Switch to Dark Mode',
      toggleTheme: 'Toggle color theme',
      loading: 'Loading...',
      cancel: 'Cancel',
      active: 'Active',
      secure: 'Secure',
      verified: 'Verified',
    },
    auth: {
      brandSubtitle: 'Digital Wallet & Financial Platform',
      signInTitle: 'Sign In',
      signInSubtitle: 'Enter your administrative credentials to access your dashboard.',
      emailLabel: 'Email Address',
      emailPlaceholder: 'name@mahfazti.app',
      passwordLabel: 'Password',
      passwordPlaceholder: 'Enter your password',
      forgotPassword: 'Forgot password?',
      showPassword: 'Show password',
      hidePassword: 'Hide password',
      keepSignedIn: 'Keep me signed in',
      signInButton: 'Sign In to Workspace',
      signingIn: 'Authenticating...',
      securityNoticeTitle: 'Restricted Institutional Access',
      securityNoticeDesc:
        'All login sessions are cryptographically signed, timestamped, and audited according to SOC2 Type II compliance standards.',
      resetModal: {
        title: 'Reset Password',
        description:
          'Enter your account email address and we will send you a secure link to reset your password.',
        emailLabel: 'Email Address',
        emailPlaceholder: 'name@mahfazti.app',
        cancelBtn: 'Cancel',
        submitBtn: 'Send Reset Link',
        submittingBtn: 'Sending...',
        successTitle: 'Reset Link Dispatched',
        successDesc: 'Check your email inbox for password recovery instructions.',
      },
      toasts: {
        signedInTitle: 'Signed In Successfully',
        signedInDesc: 'Welcome back to Mahfazti Console',
        missingCredsTitle: 'Missing Credentials',
        missingCredsDesc: 'Please enter both your email address and password.',
        resetDispatchedTitle: 'Reset Link Dispatched',
        resetDispatchedDesc: 'Password recovery instructions sent to your email.',
        authFailedTitle: 'Authentication Failed',
      },
      errors: {
        accessDenied: 'Access Denied: You do not have administrator permissions to access this console.',
        invalidCredentials: 'Invalid email address or password. Please check your credentials and try again.',
        missingCredentials: 'Please enter both your email address and password.',
        accountBanned: 'This account has been suspended by administration.',
        accountLocked: 'Account is temporarily locked out due to multiple failed login attempts. Please try again later.',
        networkError: 'Unable to reach the server. Please check your internet connection and try again.',
        serverError: 'Server is temporarily unavailable. Please try again shortly.',
        unexpectedError: 'An unexpected error occurred during authentication. Please try again.',
        resetFailed: 'Failed to send password reset instructions. Please try again.',
      },
      resetPasswordPage: {
        title: 'Set New Password',
        subtitle: 'Enter and confirm your new administrator password below.',
        emailLabel: 'Account Email',
        newPasswordLabel: 'New Password',
        newPasswordPlaceholder: 'Enter new password (min. 8 chars)',
        confirmPasswordLabel: 'Confirm New Password',
        confirmPasswordPlaceholder: 'Re-enter your new password',
        submitBtn: 'Update Password',
        submittingBtn: 'Updating Password...',
        backToLogin: 'Back to Sign In',
        invalidLinkTitle: 'Invalid or Expired Link',
        invalidLinkDesc: 'This password reset link is invalid or has expired. Please request a new link from the login page.',
        requestNewLink: 'Request New Link',
        successTitle: 'Password Reset Complete',
        successDesc: 'Your administrator password has been updated successfully. You can now sign in with your new credentials.',
        goToLogin: 'Proceed to Sign In',
        passwordMismatch: 'Passwords do not match. Please verify and try again.',
        passwordTooShort: 'Password must be at least 8 characters long.',
      },
      slides: [
        {
          badge: 'Next-Gen Ledger Architecture',
          title: 'Automated double-entry reconciliation and multi-currency vault.',
          description:
            'Autonomous balance tracking, zero-drift reserves, and real-time transaction verification across all digital wallets and merchant accounts.',
          cardLabel: 'Total Platform Liquidity',
          cardValue: '$48,295,400.00',
          cardBadge: 'LIVE +14.2%',
          pills: [
            { label: 'Vault', val: 'Protected' },
            { label: 'Drift', val: '0.000%' },
            { label: 'Ledger', val: 'Synced' },
            { label: 'Health', val: 'Optimal' },
          ],
          stat1: {
            title: 'Settlement Speed',
            value: '< 180ms',
            desc: 'Real-time multi-corridor clearing',
          },
          stat2: {
            title: 'Audit Compliance',
            value: 'SOC2 Type II',
            desc: 'FIDO2 passkey and audit trail',
          },
        },
        {
          badge: 'Global Settlement Network',
          title: 'Zero-latency clearing across high-volume payment corridors.',
          description:
            'Execute instant batch disbursements, automated payroll routing, and peer-to-peer transfers with real-time settlement telemetry.',
          cardLabel: '24h Processed Volume',
          cardValue: '$14,320,680.00',
          cardBadge: '99.999%',
          pills: [
            { label: 'Cairo', val: 'Active' },
            { label: 'Riyadh', val: 'Active' },
            { label: 'Dubai', val: 'Active' },
            { label: 'London', val: 'Active' },
          ],
          stat1: {
            title: 'Peak Throughput',
            value: '98,000 TPS',
            desc: 'Distributed concurrent ledger',
          },
          stat2: {
            title: 'FX Conversion',
            value: 'Instant Parity',
            desc: 'Zero slippage routing',
          },
        },
        {
          badge: 'Enterprise Zero-Trust',
          title: 'Institutional-grade vault security and immutable audit trails.',
          description:
            'Protected by hardware-backed FIDO2 passkeys, proactive fraud mitigation heuristics, and cryptographically signed tamper-proof administrative ledgers.',
          cardLabel: 'Protected Reserve Assets',
          cardValue: '100% Verified',
          cardBadge: 'SOC2 Type II',
          pills: [
            { label: 'Auth', val: 'FIDO2' },
            { label: 'Vault', val: 'TLS 1.3' },
            { label: 'Logs', val: 'Signed' },
            { label: 'State', val: 'Secure' },
          ],
          stat1: {
            title: 'Hardware MFA',
            value: 'WebAuthn Ready',
            desc: 'Zero-trust biometric protection',
          },
          stat2: {
            title: 'Audit Trail',
            value: 'Forensic Ledger',
            desc: 'Tamper-proof compliance logs',
          },
        },
      ],
    },
    sidebar: {
      workspaceTitle: 'Mahfazti',
      workspaceSubtitle: 'Admin Workspace',
      overview: 'Overview Dashboard',
      modulesTitle: 'Workspace Modules',
      superAdminRole: 'Super Admin',
      signOutTooltip: 'Sign Out',
      signedOutToast: 'Signed out successfully',
      groups: {
        finance: {
          label: 'Finance & Banking',
          transactions: 'All Transactions',
          currencies: 'Currencies & Rates',
        },
        users: {
          label: 'Users & Team',
          directory: 'User Directory',
          roles: 'Roles & Permissions',
        },
        monetization: {
          label: 'Billing & Plans',
          subscriptions: 'Subscriptions',
          plans: 'Plans & Limits',
          payments: 'Payment Logs',
          promoCodes: 'Promo Codes',
        },
        engagement: {
          label: 'Engagement & Support',
          notifications: 'Push Notifications',
          support: 'Support Tickets',
        },
        system: {
          label: 'System & Intelligence',
          aiLogs: 'AI Voice Transcripts',
          categories: 'System Categories',
          auditLogs: 'Audit Trail',
        },
        devOps: {
          label: 'Developer & Operations',
          webhooks: 'Webhooks & Gateways',
          health: 'System Status & AI',
          settings: 'General Settings',
        },
      },
    },
    navbar: {
      searchPlaceholder: 'Search anything (users, txs, logs)...',
      searchShortcut: 'K',
      notificationsTooltip: 'Notifications',
      superAdmin: 'Super Admin',
      routes: {
        '/': { section: 'Home', title: 'Overview' },
        '/transactions': { section: 'Finance & Banking', title: 'All Transactions' },
        '/currencies': { section: 'Finance & Banking', title: 'Currencies & Rates' },
        '/users': { section: 'Users & Team', title: 'User Directory' },
        '/roles': { section: 'Users & Team', title: 'Roles & Permissions' },
        '/subscriptions': { section: 'Billing & Plans', title: 'Subscriptions' },
        '/plans': { section: 'Billing & Plans', title: 'Plans & Limits' },
        '/payments': { section: 'Billing & Plans', title: 'Payment Logs' },
        '/promo-codes': { section: 'Billing & Plans', title: 'Promo Codes' },
        '/notifications': { section: 'Engagement & Support', title: 'Push Notifications' },
        '/support': { section: 'Engagement & Support', title: 'Support Tickets' },
        '/ai-logs': { section: 'System & Intelligence', title: 'AI Voice Transcripts' },
        '/categories': { section: 'System & Intelligence', title: 'System Categories' },
        '/audit-logs': { section: 'System & Intelligence', title: 'Audit Trail' },
        '/webhooks': { section: 'Developer & Health', title: 'Webhooks & Gateways' },
        '/health': { section: 'Developer & Health', title: 'System Status & AI' },
        '/settings': { section: 'Developer & Health', title: 'General Settings' },
      },
    },
    users: usersEn,
    auditLogs: auditLogsEn,
    roles: rolesTranslationsEn,
  },
  ar: {
    common: {
      language: 'العربية',
      switchLanguage: 'التحويل إلى الإنجليزية',
      lightMode: 'الوضع الفاتح',
      darkMode: 'الوضع الداكن',
      toggleTheme: 'تبديل المظهر',
      loading: 'جاري التحميل...',
      cancel: 'إلغاء',
      active: 'نشط',
      secure: 'آمن',
      verified: 'موثق',
    },
    auth: {
      brandSubtitle: 'منصة المحفظة الرقمية والخدمات المالية',
      signInTitle: 'تسجيل الدخول',
      signInSubtitle: 'أدخل بيانات الاعتماد الإدارية للوصول إلى لوحة التحكم الخاصة بك.',
      emailLabel: 'البريد الإلكتروني',
      emailPlaceholder: 'name@mahfazti.app',
      passwordLabel: 'كلمة المرور',
      passwordPlaceholder: 'أدخل كلمة المرور',
      forgotPassword: 'نسيت كلمة المرور؟',
      showPassword: 'إظهار كلمة المرور',
      hidePassword: 'إخفاء كلمة المرور',
      keepSignedIn: 'البقاء متصلاً',
      signInButton: 'تسجيل الدخول إلى النظام',
      signingIn: 'جاري التحقق من الهوية...',
      securityNoticeTitle: 'وصول مؤسسي مقيد وعالي الأمان',
      securityNoticeDesc:
        'جميع جلسات تسجيل الدخول مشفرة وموقعة رقمياً ومسجلة في سجل التدقيق وفقاً لمعايير SOC2 Type II المؤسسية.',
      resetModal: {
        title: 'استعادة كلمة المرور',
        description:
          'أدخل عنوان بريدك الإلكتروني المسجل وسنرسل لك رابطاً آمناً لإعادة تعيين كلمة المرور.',
        emailLabel: 'البريد الإلكتروني',
        emailPlaceholder: 'name@mahfazti.app',
        cancelBtn: 'إلغاء',
        submitBtn: 'إرسال رابط الاستعادة',
        submittingBtn: 'جاري الإرسال...',
        successTitle: 'تم إرسال الرابط بنجاح',
        successDesc: 'يرجى مراجعة بريدك الإلكتروني للتعليمات الخاصة باستعادة الحساب.',
      },
      toasts: {
        signedInTitle: 'تم تسجيل الدخول بنجاح',
        signedInDesc: 'مرحباً بك مجدداً في لوحة تحكم محفظتي',
        missingCredsTitle: 'بيانات الاعتماد ناقصة',
        missingCredsDesc: 'يرجى إدخال البريد الإلكتروني وكلمة المرور للمتابعة.',
        resetDispatchedTitle: 'تم إرسال رابط الاستعادة',
        resetDispatchedDesc: 'تم إرسال تعليمات استعادة كلمة المرور إلى بريدك الإلكتروني.',
        authFailedTitle: 'فشل تسجيل الدخول',
      },
      errors: {
        accessDenied: 'تم رفض الوصول: هذا الحساب لا يملك صلاحيات إدارية للدخول إلى لوحة التحكم.',
        invalidCredentials: 'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى التحقق والمحاولة مجدداً.',
        missingCredentials: 'يرجى إدخال البريد الإلكتروني وكلمة المرور للمتابعة.',
        accountBanned: 'تم حظر هذا الحساب من قِبل إدارة النظام.',
        accountLocked: 'تم قفل الحساب مؤقتاً لكثرة المحاولات غير الناجحة. يرجى المحاولة لاحقاً.',
        networkError: 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
        serverError: 'الخادم غير متاح حالياً. يرجى المحاولة بعد قليل.',
        unexpectedError: 'حدث خطأ غير متوقع أثناء تسجيل الدخول. يرجى المحاولة مرة أخرى.',
        resetFailed: 'فشل إرسال رابط استعادة كلمة المرور. يرجى المحاولة مرة أخرى.',
      },
      resetPasswordPage: {
        title: 'تعيين كلمة مرور جديدة',
        subtitle: 'أدخل كلمة المرور الجديدة لحسابك الإداري وقم بتأكيدها للمتابعة.',
        emailLabel: 'البريد الإلكتروني للحساب',
        newPasswordLabel: 'كلمة المرور الجديدة',
        newPasswordPlaceholder: 'أدخل كلمة المرور الجديدة (8 خانات على الأقل)',
        confirmPasswordLabel: 'تأكيد كلمة المرور الجديدة',
        confirmPasswordPlaceholder: 'أعد إدخال كلمة المرور الجديدة',
        submitBtn: 'حفظ وتحديث كلمة المرور',
        submittingBtn: 'جاري التحديث...',
        backToLogin: 'العودة لتسجيل الدخول',
        invalidLinkTitle: 'رابط غير صالح أو منتهي الصلاحية',
        invalidLinkDesc: 'يبدو أن رابط استعادة كلمة المرور هذا غير صحيح أو انتهت صلاحيته. يرجى طلب رابط جديد من صفحة تسجيل الدخول.',
        requestNewLink: 'طلب رابط جديد',
        successTitle: 'تم تغيير كلمة المرور بنجاح',
        successDesc: 'تم تحديث كلمة المرور لحسابك الإداري بنجاح. يمكنك الآن تسجيل الدخول ببياناتك الجديدة.',
        goToLogin: 'الانتقال لتسجيل الدخول',
        passwordMismatch: 'كلمتا المرور غير متطابقتين. يرجى التحقق وإعادة المحاولة.',
        passwordTooShort: 'يجب ألا تقل كلمة المرور عن 8 أحرف وأرقام.',
      },
      slides: [
        {
          badge: 'معمارية دفتر الأستاذ المتقدمة',
          title: 'مطابقة قيود القيد المزدوج الآلية وخزينة العملات المتعددة.',
          description:
            'تتبع ذاتي وتلقائي للأرصدة، واحتياطيات صفرية الانحراف، وتحقق فوري من المعاملات المالية عبر جميع المحافظ الرقمية وحسابات التجار.',
          cardLabel: 'إجمالي السيولة النقدية للمنصة',
          cardValue: '$48,295,400.00',
          cardBadge: 'مباشر +14.2%',
          pills: [
            { label: 'الخزينة', val: 'محمية' },
            { label: 'الانحراف', val: '0.000%' },
            { label: 'الدفتر', val: 'متزامن' },
            { label: 'الحالة', val: 'ممتازة' },
          ],
          stat1: {
            title: 'سرعة التسوية',
            value: '< 180ms',
            desc: 'مقاصة فورية متعددة الممرات',
          },
          stat2: {
            title: 'التوافق الرقابي',
            value: 'SOC2 Type II',
            desc: 'مفاتيح FIDO2 وسجل تدقيق مشفر',
          },
        },
        {
          badge: 'شبكة التسوية والمقاصة العالمية',
          title: 'تسوية فورية بدون أي تأخير عبر مسارات الدفع ذات الأحجام العالية.',
          description:
            'تنفيذ فوري لعمليات الصرف المجمعة، وتوجيه الرواتب الآلي، والتحويلات المالية الفورية مع مراقبة حية لبيانات التسوية.',
          cardLabel: 'حجم المعاملات المعالجة (24 ساعة)',
          cardValue: '$14,320,680.00',
          cardBadge: '99.999%',
          pills: [
            { label: 'القاهرة', val: 'نشط' },
            { label: 'الرياض', val: 'نشط' },
            { label: 'دبي', val: 'نشط' },
            { label: 'لندن', val: 'نشط' },
          ],
          stat1: {
            title: 'القدرة التشغيلية القصوى',
            value: '98,000 TPS',
            desc: 'دفتر أستاذ موزع فائق التزامن',
          },
          stat2: {
            title: 'تحويل العملات الأجنبية',
            value: 'تطابق فوري',
            desc: 'توجيه تسعير بدون أي انزلاق',
          },
        },
        {
          badge: 'أمن مؤسسي بانعدام الثقة (Zero-Trust)',
          title: 'أمان خزينة مصرفية وسجلات تدقيق ومراجعة غير قابلة للتعديل.',
          description:
            'حماية معززة بأحدث معايير FIDO2 للعتاد الصلب، وخوارزميات استباقية لمنع الاحتيال، وسجلات إدارية موقعة تشفيرياً ضد أي تلاعب.',
          cardLabel: 'الأصول الاحتياطية المحمية',
          cardValue: '100% موثقة',
          cardBadge: 'SOC2 Type II',
          pills: [
            { label: 'المصادقة', val: 'FIDO2' },
            { label: 'الخزينة', val: 'TLS 1.3' },
            { label: 'السجلات', val: 'موقعة' },
            { label: 'الحالة', val: 'آمنة' },
          ],
          stat1: {
            title: 'المصادقة بالأجهزة',
            value: 'WebAuthn جاهز',
            desc: 'حماية بيومترية بدون ثقة مسبقة',
          },
          stat2: {
            title: 'سجل التدقيق الرقمي',
            value: 'دفتر جنائي',
            desc: 'سجلات امتثال غير قابلة للتلاعب',
          },
        },
      ],
    },
    sidebar: {
      workspaceTitle: 'محفظتي',
      workspaceSubtitle: 'مساحة الإدارة',
      overview: 'لوحة التحكم الرئيسية',
      modulesTitle: 'أقسام النظام',
      superAdminRole: 'مدير النظام العام',
      signOutTooltip: 'تسجيل الخروج',
      signedOutToast: 'تم تسجيل الخروج بنجاح',
      groups: {
        finance: {
          label: 'المالية والمصرفية',
          transactions: 'كافة المعاملات',
          currencies: 'العملات وأسعار الصرف',
        },
        users: {
          label: 'المستخدمون والفريق',
          directory: 'دليل المستخدمين',
          roles: 'الأدوار والصلاحيات',
        },
        monetization: {
          label: 'الفوترة والباقات',
          subscriptions: 'الاشتراكات الشهرية',
          plans: 'الباقات والحدود',
          payments: 'سجلات الدفع',
          promoCodes: 'أكواد الخصم والترويج',
        },
        engagement: {
          label: 'التفاعل والدعم الفني',
          notifications: 'الإشعارات الفورية',
          support: 'تذاكر الدعم الفني',
        },
        system: {
          label: 'النظام والذكاء الاصطناعي',
          aiLogs: 'نصوص الذكاء الاصطناعي',
          categories: 'تصنيفات النظام',
          auditLogs: 'سجل التدقيق الأمني',
        },
        devOps: {
          label: 'المطورون والعمليات',
          webhooks: 'الـ Webhooks وبوابات الربط',
          health: 'حالة النظام والـ AI',
          settings: 'الإعدادات العامة',
        },
      },
    },
    navbar: {
      searchPlaceholder: 'ابحث عن أي شيء (المستخدمين، المعاملات، السجلات)...',
      searchShortcut: 'K',
      notificationsTooltip: 'التنبيهات والإشعارات',
      superAdmin: 'مدير النظام العام',
      routes: {
        '/': { section: 'الرئيسية', title: 'نظرة عامة' },
        '/transactions': { section: 'المالية والمصرفية', title: 'كافة المعاملات' },
        '/currencies': { section: 'المالية والمصرفية', title: 'العملات وأسعار الصرف' },
        '/users': { section: 'المستخدمون والفريق', title: 'دليل المستخدمين' },
        '/roles': { section: 'المستخدمون والفريق', title: 'الأدوار والصلاحيات' },
        '/subscriptions': { section: 'الفوترة والباقات', title: 'الاشتراكات الشهرية' },
        '/plans': { section: 'الفوترة والباقات', title: 'الباقات والحدود' },
        '/payments': { section: 'الفوترة والباقات', title: 'سجلات الدفع' },
        '/promo-codes': { section: 'الفوترة والباقات', title: 'أكواد الخصم والترويج' },
        '/notifications': { section: 'التفاعل والدعم الفني', title: 'الإشعارات الفورية' },
        '/support': { section: 'التفاعل والدعم الفني', title: 'تذاكر الدعم الفني' },
        '/ai-logs': { section: 'النظام والذكاء الاصطناعي', title: 'نصوص الذكاء الاصطناعي' },
        '/categories': { section: 'النظام والذكاء الاصطناعي', title: 'تصنيفات النظام' },
        '/audit-logs': { section: 'النظام والذكاء الاصطناعي', title: 'سجل التدقيق الأمني' },
        '/webhooks': { section: 'المطورون والعمليات', title: 'الـ Webhooks وبوابات الربط' },
        '/health': { section: 'المطورون والعمليات', title: 'حالة النظام والـ AI' },
        '/settings': { section: 'المطورون والعمليات', title: 'الإعدادات العامة' },
      },
    },
    users: usersAr,
    auditLogs: auditLogsAr,
    roles: rolesTranslationsAr,
  },
};
