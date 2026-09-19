import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
  ShieldCheck,
  Lock,
  Cpu,
  FileText,
  UserCheck,
  Globe,
  Mail,
  ArrowLeft,
  ArrowRight,
  Sun,
  Moon,
  Languages,
  CheckCircle2,
  Database,
  ExternalLink,
} from 'lucide-react';
import { useTheme } from '../../../core/context/ThemeContext';
import { useLocale } from '../../../core/context/LocaleContext';
import { MahfaztiLogo } from '../../../core/components/ui/MahfaztiLogo';
import { AnimatedAuthBackground } from '../../../core/components/ui/AnimatedAuthBackground';

export const PrivacyPolicyPage: React.FC = () => {
  const { theme, toggleTheme } = useTheme();
  const { locale, dir, toggleLocale } = useLocale();
  const navigate = useNavigate();
  const [activeSection, setActiveSection] = useState<string>('collection');

  const isAr = locale === 'ar';

  const sections = [
    {
      id: 'collection',
      icon: Database,
      title: isAr ? '١. جمع البيانات والمصادر' : '1. Information We Collect',
      badge: isAr ? 'البيانات المُجمعة' : 'Data Types',
      content: isAr
        ? [
            'نقوم بجمع الحد الأدنى من المعلومات اللازمة لتقديم تجربة تتبع مالي آمنة ودقيقة:',
            'معلومات الحساب: الاسم، عنوان البريد الإلكتروني، وتفضيلات العملة عند التسجيل.',
            'بيانات المعاملات المالية: المبالغ، التصنيفات، التواريخ، والعملات التي يدخلها المستخدم يدويًا أو عبر المزامنة.',
            'بيانات مسح الفواتير بالذكاء الاصطناعي: الصور والنصوص المستخرجة من الإيصالات التي تقوم برفعها طواعية للمعالجة.',
            'البيانات الفنية والتشغيلية: عناوين IP، نوع المتصفح، نظام التشغيل، وسجلات التدقيق الأمني لضمان حماية الحساب من محاولات الاختراق.',
          ]
        : [
            'We collect the minimal amount of information required to deliver an accurate and secure financial tracking experience:',
            'Account Information: Name, email address, and preferred base currency provided during registration.',
            'Financial Transaction Records: Amounts, categories, dates, and currencies entered manually or imported by you.',
            'AI Receipt Data: Image files and parsed receipt text uploaded voluntarily for automated OCR categorization.',
            'Technical & Security Logs: IP addresses, browser agent, operating system, and authentication timestamps to safeguard against unauthorized access.',
          ],
    },
    {
      id: 'usage',
      icon: Cpu,
      title: isAr ? '٢. كيف نستخدم معلوماتك' : '2. How We Use Your Information',
      badge: isAr ? 'أغراض المعالجة' : 'Usage Scope',
      content: isAr
        ? [
            'توفير وصيانة وتحسين لوحة التحكم وتطبيق محفظتي المالي.',
            'معالجة المعاملات وحساب صافي الثروة والموازنات التقديرية بالذكاء الاصطناعي.',
            'إرسال إشعارات الأمان وتنبيهات الحساب وتحديثات الباقات أو الفواتير.',
            'الكشف الاستباقي عن محاولات الاحتيال أو انتهاكات الأمان ومنع الوصول غير المصرح به.',
            'لا نستخدم بياناتك المالية الشخصية إطلاقاً في تدريب نماذج الذكاء الاصطناعي العامة، وتظل نصوص الفواتير مشفرة ومعزولة.',
          ]
        : [
            'To operate, maintain, and enhance the Mahfazti dashboard and mobile financial companion.',
            'To calculate net worth, spending analytics, and automated budget categorization powered by secure AI.',
            'To dispatch critical security notifications, verification codes, and subscription updates.',
            'To proactively monitor, detect, and mitigate fraudulent access attempts or security breaches.',
            'We NEVER train public AI foundation models on your private financial transactions or receipt data. Your data remains strictly isolated.',
          ],
    },
    {
      id: 'security',
      icon: Lock,
      title: isAr ? '٣. الأمان والتشفير الصارم' : '3. Security & Encryption Standards',
      badge: isAr ? 'معايير بنكية' : 'Bank-Grade',
      content: isAr
        ? [
            'تشفير أثناء النقل: يتم تشفير كافة الاتصالات بين متصفحك وخوادمنا باستخدام بروتوكول TLS 1.3 مع مفاتيح تشفير قوية.',
            'تشفير في حالة السكون: يتم تشفير كلمات المرور والبيانات الحساسة باستخدام خوارزميات AES-256 مع التجزئة الآمنة (Argon2 / PBKDF2).',
            'التوافق الأمني: بنية خوادم متوافقة مع معايير SOC-2 و PCI-DSS لإدارة أمان البيانات المالية الحساسة.',
            'عزل المساحات: يتم تطبيق مبدأ العزل الصارم متعدد المستأجرين (Multi-Tenancy) لضمان عدم إمكانية وصول أي مستخدم لبيانات مستخدم آخر.',
          ]
        : [
            'Encryption In Transit: Every payload exchanged with our infrastructure is encrypted using modern TLS 1.3 cryptographic suites.',
            'Encryption At Rest: Passwords and sensitive monetary logs are stored using AES-256 encryption and state-of-the-art Argon2 / PBKDF2 hashing.',
            'Security Standards: Our backend architecture adheres to stringent SOC-2 and PCI-DSS best practices for financial data storage.',
            'Strict Tenant Isolation: Data partitioning ensures zero bleed or shared exposure between distinct tenant accounts.',
          ],
    },
    {
      id: 'sharing',
      icon: FileText,
      title: isAr ? '٤. مشاركة البيانات مع أطراف ثالثة' : '4. Third-Party Disclosures',
      badge: isAr ? 'عدم بيع البيانات' : 'No Data Selling',
      content: isAr
        ? [
            'نحن لا نبيع ولا نؤجر ولا نتاجر ببياناتك المالية أو الشخصية لأي طرف ثالث أو شبكات إعلانية بأي شكل من الأشكال.',
            'قد نشارك بيانات محدودة للغاية فقط مع مزودي الخدمة الموثوقين تحت اتفاقيات سرية صارمة:',
            'بوابات الدفع الإلكتروني المعتمدة لمعالجة اشتراكات الباقات (مع العلم أننا لا نخزن بيانات بطاقاتك الائتمانية).',
            'مزودو خدمات السحاب وحفظ الملفات المؤمّنة (مثل Microsoft Azure و AWS المعتمَدة).',
            'الامتثال القانوني: في حال صدور أمر قضائي ملزم صادر من جهة قضائية مختصة وفقاً للقانون المعمول به.',
          ]
        : [
            'We strictly do NOT sell, rent, monetize, or trade your personal or financial records with any advertising brokers or data aggregates.',
            'Limited disclosures occur solely with vetted infrastructure partners bound by rigorous non-disclosure agreements:',
            'Certified Payment Processors: For recurring subscription settlement (credit card details are never stored on our servers).',
            'Secure Cloud Infrastructure: Enterprise-grade hyperscalers (e.g., Azure / AWS) hosting encrypted application databases.',
            'Legal Compliance: Disclosures made exclusively in response to valid, legally binding court orders and regulatory summons.',
          ],
    },
    {
      id: 'rights',
      icon: UserCheck,
      title: isAr ? '٥. حقوق المستخدم والتحكم في البيانات' : '5. Your Rights & Data Sovereignty',
      badge: isAr ? 'حقوقك الكاملة' : 'Full Control',
      content: isAr
        ? [
            'حق الوصول: يمكنك عرض ومراجعة وتنزيل كافة بياناتك المالية والمعاملات المسجلة في أي وقت بصيغة JSON أو CSV.',
            'حق التصحيح: يمكنك تعديل أو تصحيح أي معلومات غير دقيقة في ملفك الشخصي أو سجلاتك المالية فوراً.',
            'حق النسيان والحذف التام: يحق لك طلب حذف حسابك نهائياً؛ وسيتم مسح كافة سجلاتك ومعاملاتك وبيانات فواتيرك بالكامل من خوادمنا النشطة خلال ٣٠ يوماً.',
            'حق التصدير وسهولة النقل: بياناتك ملكك وحدك، ويمكنك تصديرها للانتقال لأي منصة أخرى دون قيود.',
          ]
        : [
            'Right to Access: You can inspect, query, and download complete dumps of your transactions anytime in structured JSON or CSV format.',
            'Right to Rectify: Modify or rectify any outdated or inaccurate profile and financial records on the fly.',
            'Right to Erasure (Forget Me): Request complete account deletion. All associated transaction ledgers and credentials will be irrevocably purged within 30 days.',
            'Data Portability: Your financial records remain entirely your property. You are never locked in.',
          ],
    },
    {
      id: 'cookies',
      icon: Globe,
      title: isAr ? '٦. ملفات تعريف الارتباط (Cookies)' : '6. Cookies & Session Storage',
      badge: isAr ? 'جلسات آمنة فقط' : 'Essential Only',
      content: isAr
        ? [
            'نستخدم فقط ملفات تعريف ارتباط أساسية وضرورية لتسجيل الدخول والحفاظ على أمان جلستك (JWT Tokens و CSRF Tokens).',
            'نحن لا نستخدم أي ملفات تعريف ارتباط خاصة بالتتبع الإعلاني أو أدوات الطرف الثالث للتجسس السلوكي.',
            'يمكنك تعطيل ملفات تعريف الارتباط من متصفحك، ولكن قد يتطلب ذلك تسجيل الدخول في كل زيارة.',
          ]
        : [
            'We strictly utilize essential first-party cookies necessary for secure session state, token verification (JWT), and CSRF defense.',
            'We do not employ cross-site tracking cookies, behavioral ad pixels, or third-party marketing beacons.',
            'You may disable cookies via your browser settings; however, doing so will require re-authentication on each navigation cycle.',
          ],
    },
    {
      id: 'contact',
      icon: Mail,
      title: isAr ? '٧. التواصل ومسؤول حماية البيانات' : '7. Contact Data Protection Officer',
      badge: isAr ? 'تواصل مباشر' : 'Direct Line',
      content: isAr
        ? [
            'إذا كانت لديك أي أسئلة أو استفسارات أو شكاوى بخصوص سياسة الخصوصية أو كيفية معالجة بياناتك، يسعدنا تواصلك معنا:',
            'البريد الإلكتروني المخصص للخصوصية: privacy@mahfazti.app',
            'فريق الدعم الفني والأمان: security@mahfazti.app',
            'العنوان: القاهرة، جمهورية مصر العربية - شركة محفظتي للتقنيات المالية.',
          ]
        : [
            'If you have any inquiries, feedback, or grievance reports regarding this Privacy Policy or your data handling:',
            'Dedicated Privacy Officer: privacy@mahfazti.app',
            'Security & Vulnerability Reports: security@mahfazti.app',
            'Physical Headquarters: Mahfazti Financial Technologies Inc., Cairo, Egypt.',
          ],
    },
  ];

  return (
    <div
      dir={dir}
      className="relative min-h-screen w-full bg-[#f8f9fa] dark:bg-[#000000] text-zinc-900 dark:text-white transition-colors duration-200 flex flex-col justify-between overflow-x-hidden selection:bg-black selection:text-white dark:selection:bg-white dark:selection:text-black"
    >
      <AnimatedAuthBackground />

      {/* Top Navigation Header */}
      <header className="relative z-20 w-full px-6 py-5 max-w-7xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link to="/login" className="flex items-center gap-3 group">
            <MahfaztiLogo size={36} className="shadow-xs border border-zinc-200/80 dark:border-zinc-800 transition group-hover:scale-105" />
            <div className="flex flex-col text-start">
              <span className="font-extrabold text-lg tracking-tight text-zinc-950 dark:text-white">
                Mahfazti
              </span>
              <span className="text-[11px] text-zinc-500 dark:text-zinc-400 font-medium">
                {isAr ? 'الخصوصية والأمان' : 'Privacy & Security'}
              </span>
            </div>
          </Link>
        </div>

        <div className="flex items-center gap-2.5">
          {/* Back to Login Button */}
          <button
            onClick={() => navigate('/login')}
            type="button"
            className="flex h-9 items-center gap-2 px-3.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs font-semibold text-xs active:scale-95"
          >
            {dir === 'rtl' ? <ArrowRight className="h-3.5 w-3.5" /> : <ArrowLeft className="h-3.5 w-3.5" />}
            <span>{isAr ? 'العودة لتسجيل الدخول' : 'Back to Login'}</span>
          </button>

          {/* Language Switcher */}
          <button
            onClick={toggleLocale}
            type="button"
            className="flex h-9 items-center gap-1.5 px-2.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs font-semibold text-xs active:scale-95"
          >
            <Languages className="h-3.5 w-3.5" />
            <span className="font-mono text-[11px] font-bold">{locale === 'en' ? 'AR' : 'EN'}</span>
          </button>

          {/* Theme Switcher */}
          <button
            onClick={toggleTheme}
            type="button"
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs active:scale-95"
          >
            {theme === 'dark' ? <Sun className="h-4 w-4 text-white" /> : <Moon className="h-4 w-4 text-black" />}
          </button>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="relative z-10 w-full max-w-5xl mx-auto px-4 sm:px-6 py-8 flex-1">
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4 }}
          className="space-y-8"
        >
          {/* Header Banner */}
          <div className="text-start space-y-3 pb-6 border-b border-zinc-200 dark:border-zinc-800">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-xs font-semibold text-zinc-700 dark:text-zinc-300 shadow-2xs">
              <ShieldCheck className="h-3.5 w-3.5 text-emerald-500" />
              <span>{isAr ? 'سياسة حماية البيانات الصارمة' : 'Enterprise Privacy Standard'}</span>
            </div>

            <h1 className="text-3xl sm:text-4xl font-black tracking-tight text-zinc-950 dark:text-white">
              {isAr ? 'سياسة الخصوصية وحماية البيانات' : 'Privacy Policy & Data Protection'}
            </h1>

            <div className="flex flex-wrap items-center gap-4 text-xs text-zinc-500 dark:text-zinc-400">
              <span>{isAr ? 'آخر تحديث: سبتمبر ٢٠٢٦' : 'Last Updated: September 2026'}</span>
              <span>&bull;</span>
              <span>{isAr ? 'الإصدار: v2.4' : 'Version: v2.4 (Enterprise)'}</span>
              <span>&bull;</span>
              <span className="flex items-center gap-1 text-emerald-600 dark:text-emerald-400 font-semibold">
                <CheckCircle2 className="h-3.5 w-3.5" />
                {isAr ? 'متوافق مع معايير التشفير البنكية' : 'Bank-Grade AES-256 Verified'}
              </span>
            </div>
          </div>

          {/* Quick Nav Chips */}
          <div className="flex flex-wrap gap-2 pt-1">
            {sections.map((sec) => (
              <a
                key={sec.id}
                href={`#${sec.id}`}
                onClick={() => setActiveSection(sec.id)}
                className={`text-xs px-3 py-1.5 rounded-xl border transition-all ${
                  activeSection === sec.id
                    ? 'border-black bg-black text-white dark:border-white dark:bg-white dark:text-black font-semibold'
                    : 'border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900/80 text-zinc-600 dark:text-zinc-400 hover:border-zinc-400 dark:hover:border-zinc-600'
                }`}
              >
                {sec.title.split('.')[1] || sec.title}
              </a>
            ))}
          </div>

          {/* Sections List */}
          <div className="space-y-6">
            {sections.map((sec) => {
              const Icon = sec.icon;
              return (
                <div
                  key={sec.id}
                  id={sec.id}
                  className="rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#0c0c0e] p-6 sm:p-7 shadow-xs hover:border-zinc-300 dark:hover:border-zinc-700 transition"
                >
                  <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center gap-3">
                      <div className="h-9 w-9 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 flex items-center justify-center text-zinc-900 dark:text-white">
                        <Icon className="h-4.5 w-4.5" />
                      </div>
                      <h2 className="text-lg font-bold text-zinc-950 dark:text-white">
                        {sec.title}
                      </h2>
                    </div>
                    <span className="text-[11px] font-mono font-bold px-2.5 py-0.5 rounded-full border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-zinc-600 dark:text-zinc-400">
                      {sec.badge}
                    </span>
                  </div>

                  <div className="space-y-2.5 text-xs sm:text-sm text-zinc-600 dark:text-zinc-300 leading-relaxed text-start">
                    {sec.content.map((p, pIdx) => (
                      <p key={pIdx} className={pIdx === 0 ? 'font-semibold text-zinc-800 dark:text-zinc-200 mb-2' : 'flex items-start gap-2'}>
                        {pIdx > 0 && <span className="h-1.5 w-1.5 rounded-full bg-zinc-400 dark:bg-zinc-600 mt-2 shrink-0" />}
                        <span>{p}</span>
                      </p>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>

          {/* Bottom Security Assurance Banner */}
          <div className="rounded-2xl border border-emerald-500/20 bg-emerald-50/40 dark:bg-emerald-950/20 p-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 text-start">
            <div className="space-y-1">
              <h3 className="text-sm font-bold text-emerald-900 dark:text-emerald-300 flex items-center gap-2">
                <ShieldCheck className="h-4 w-4 text-emerald-500" />
                {isAr ? 'التزام محفظتي بالخصوصية المطلقة' : 'Mahfazti Zero-Compromise Privacy Promise'}
              </h3>
              <p className="text-xs text-emerald-800/80 dark:text-emerald-400/80">
                {isAr
                  ? 'سجلاتك المالية ملك لك بنسبة ١٠٠٪. لا نقوم إطلاقاً ببيع بياناتك أو مشاركتها لأغراض إعلانية.'
                  : 'Your financial ledger belongs 100% to you. We never sell your data or serve targeted third-party advertising.'}
              </p>
            </div>
            <button
              onClick={() => navigate('/support')}
              className="px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold shrink-0 transition cursor-pointer flex items-center gap-1.5 shadow-sm"
            >
              <span>{isAr ? 'مركز الدعم الفني' : 'Contact Support'}</span>
              <ExternalLink className="h-3 w-3" />
            </button>
          </div>
        </motion.div>
      </main>

      {/* Page Footer */}
      <footer className="relative z-10 w-full px-6 py-5 max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between text-xs text-zinc-500 dark:text-zinc-500 gap-3 border-t border-zinc-200/80 dark:border-zinc-900 mt-12">
        <div>
          <span>&copy; {new Date().getFullYear()} Mahfazti Inc. {isAr ? 'كافة الحقوق محفوظة.' : 'All rights reserved.'}</span>
        </div>
        <div className="flex items-center gap-5 text-[11px] font-medium">
          <Link to="/privacy" className="text-black dark:text-white font-bold transition">
            {isAr ? 'سياسة الخصوصية' : 'Privacy Policy'}
          </Link>
          <Link to="/terms" className="hover:text-black dark:hover:text-white transition">
            {isAr ? 'شروط الخدمة' : 'Terms of Service'}
          </Link>
          <Link to="/support" className="hover:text-black dark:hover:text-white transition">
            {isAr ? 'الدعم الفني' : 'Support'}
          </Link>
          <Link to="/login" className="hover:text-black dark:hover:text-white transition">
            {isAr ? 'تسجيل الدخول' : 'Sign In'}
          </Link>
        </div>
      </footer>
    </div>
  );
};
