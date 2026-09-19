import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
  FileText,
  Scale,
  CreditCard,
  AlertTriangle,
  ShieldCheck,
  Clock,
  Mail,
  ArrowLeft,
  ArrowRight,
  Sun,
  Moon,
  Languages,
  CheckCircle2,
  ExternalLink,
  BookOpen,
} from 'lucide-react';
import { useTheme } from '../../../core/context/ThemeContext';
import { useLocale } from '../../../core/context/LocaleContext';
import { MahfaztiLogo } from '../../../core/components/ui/MahfaztiLogo';
import { AnimatedAuthBackground } from '../../../core/components/ui/AnimatedAuthBackground';

export const TermsOfServicePage: React.FC = () => {
  const { theme, toggleTheme } = useTheme();
  const { locale, dir, toggleLocale } = useLocale();
  const navigate = useNavigate();
  const [activeSection, setActiveSection] = useState<string>('agreement');

  const isAr = locale === 'ar';

  const sections = [
    {
      id: 'agreement',
      icon: Scale,
      title: isAr ? '١. قبول الشروط والأهلية القانونية' : '1. Acceptance & Eligibility',
      badge: isAr ? 'اتفاق ملزم' : 'Binding Agreement',
      content: isAr
        ? [
            'باستخدامك لمنصة وتطبيق ولوحة تحكم "محفظتي" (Mahfazti)، فإنك تقر وتوافق على الالتزام الكامل بهذه الشروط والأحكام.',
            'يجب أن تكون قد بلغت السن القانونية (١٨ عاماً أو السن المعمول به في نطاقك القضائي) لإنشاء حساب واستخدام خدماتنا.',
            'إذا كنت تستخدم المنصة نيابة عن شركة أو مؤسسة، فإنك تقر بامتلاكك التفويض القانوني اللازم لإلزام الكيان بهذه الشروط.',
          ]
        : [
            'By accessing or utilizing the Mahfazti platform, administrative console, and services, you enter into a legally binding agreement under these Terms of Service.',
            'You must be at least 18 years of age or the legal age of majority in your jurisdiction to establish an account and use the service.',
            'If accessing on behalf of a corporate entity, you represent and warrant that you hold full legal authority to bind said entity to these terms.',
          ],
    },
    {
      id: 'nature',
      icon: BookOpen,
      title: isAr ? '٢. طبيعة الخدمة وإخلاء المسؤولية المصرفية' : '2. Service Scope & Financial Disclaimer',
      badge: isAr ? 'أداة تتبع مالي' : 'Management Tool',
      content: isAr
        ? [
            'منصة محفظتي هي أداة برمجية ذكية لإدارة الموازنات وتتبع المصروفات والإيرادات وتحليل البيانات المالية للمستخدمين والمؤسسات.',
            'محفظتي ليست بنكاً أو مؤسسة إيداع مالي أو وسيطاً استثمارياً مرخصاً؛ ونحن لا نحتفظ بأموالك ولا نقوم بتحويل ودائع حقيقية بالنيابة عنك.',
            'كافة التحليلات والتوقعات الصادرة عن نماذج الذكاء الاصطناعي هي لغرض استرشادي وتنظيمي فقط، ولا تشكل استشارة مالية أو ضريبية أو استثمارية معتمدة.',
          ]
        : [
            'Mahfazti provides software tools for budget intelligence, expense tracking, multi-currency ledger management, and receipt analytics.',
            'Mahfazti is strictly a financial tracking platform and SaaS technology provider—NOT a bank, depository institution, or licensed investment advisor. We do not hold custodial deposits.',
            'All forecasts, automated categorizations, and insights produced by our AI engine are strictly informational and do not constitute formal fiduciary, tax, or investment advice.',
          ],
    },
    {
      id: 'accounts',
      icon: ShieldCheck,
      title: isAr ? '٣. مسؤولية الحساب وأمان بيانات الاعتماد' : '3. Account Security & Credentials',
      badge: isAr ? 'أمان الحساب' : 'Zero-Trust',
      content: isAr
        ? [
            'أنت مسؤول بشكل كامل عن الحفاظ على سرية كلمة المرور ومفاتيح المصادقة الثنائية (2FA) الخاصة بحسابك.',
            'تتحمل المسؤولية القانونية عن كافة الأنشطة والمعاملات التي تتم من خلال حسابك.',
            'يجب عليك إخطار فريق أمان محفظتي فوراً على security@mahfazti.app عند الاشتباه في أي وصول غير مصرح به أو اختراق أمني.',
            'يحظر مشاركة بيانات تسجيل الدخول للمدراء (Admin Credentials) مع أي أفراد غير مصرح لهم.',
          ]
        : [
            'You remain solely responsible for safeguarding your credentials, tokens, and multi-factor authentication (2FA) mechanisms.',
            'You assume full accountability for all actions and transactions executed under your authenticated sessions.',
            'You must notify the Mahfazti security team without undue delay at security@mahfazti.app upon discovering any suspected unauthorized intrusion or breach.',
            'Sharing administrative credentials or API tokens with unauthorized third parties is strictly prohibited and constitutes cause for immediate revocation.',
          ],
    },
    {
      id: 'billing',
      icon: CreditCard,
      title: isAr ? '٤. الاشتراكات والفوترة وسياسة الإلغاء' : '4. Subscriptions, Payments & Refunds',
      badge: isAr ? 'دفع آمن' : 'Transparent Billing',
      content: isAr
        ? [
            'الاشتراكات المدفوعة (Pro و Enterprise) تتجدد تلقائياً في نهاية كل فترة فوترة (شهرية أو سنوية) ما لم تقم بالإلغاء قبل موعد التجديد.',
            'يمكنك إلغاء اشتراكك في أي وقت مباشرة من لوحة الإعدادات، وسيظل حسابك نشطاً حتى نهاية الفترة المدفوعة بالفعل.',
            'سياسة الاسترداد: نقدم ضمان استرداد الأموال بنسبة ١٠٠٪ خلال ١٤ يوماً من أول اشتراك في حال عدم رضاك عن الخدمة.',
            'تخضع الأسعار لضريبة القيمة المضافة أو الضرائب المحلية المعمول بها في بلدك عند السداد.',
          ]
        : [
            'Paid plans (Pro and Enterprise) renew automatically on a recurring cadence (monthly or annually) unless canceled prior to the renewal timestamp.',
            'You may cancel subscriptions at any time via your workspace settings; access privileges remain active until the conclusion of the prepaid period.',
            'Refund Policy: We provide an unconditional 14-day refund window on initial subscription purchases upon written request.',
            'Prices listed are exclusive of applicable Value-Added Tax (VAT) or local statutory withholding unless expressly indicated otherwise.',
          ],
    },
    {
      id: 'prohibitions',
      icon: AlertTriangle,
      title: isAr ? '٥. الاستخدام المقبول والمحظورات الصارمة' : '5. Acceptable Use & Prohibited Conduct',
      badge: isAr ? 'النزاهة والأمان' : 'Fair Use',
      content: isAr
        ? [
            'يحظر استخدام المنصة لأي أغراض غير قانونية مثل غسيل الأموال أو تمويل الأنشطة المحظورة دولياً أو محلياً.',
            'يحظر إجراء أي هندسة عكسية (Reverse Engineering) أو تفكيك أو محاولة نسخ الكود المصدري لمنصة محفظتي.',
            'يحظر إرسال استعلامات ضخمة أو هجمات حرمان من الخدمة (DDoS) أو استغلال واجهات برمجة التطبيقات (APIs) بشكل مفرط.',
            'يحظر رفع أي ملفات إيصالات خبيثة أو نصوص تحتوي على برمجيات ضارة أو فيروسات عبر محرك مسح الفواتير بالذكاء الاصطناعي.',
          ]
        : [
            'You must not utilize the platform in connection with unlawful schemes, anti-money laundering (AML) violations, or illicit financial trafficking.',
            'You agree not to decompile, reverse engineer, disassemble, or extract underlying source code or proprietary AI models powering Mahfazti.',
            'Automated high-frequency scraping, denial-of-service attempts, or deliberate API endpoint saturations are strictly prohibited.',
            'Uploading malicious file formats, exploits, or payload injections through the AI OCR scanning portal is grounds for permanent ban and legal prosecution.',
          ],
    },
    {
      id: 'ip',
      icon: FileText,
      title: isAr ? '٦. حقوق الملكية الفكرية والعلامات التجارية' : '6. Intellectual Property Rights',
      badge: isAr ? 'حقوق ملكية' : 'Proprietary IP',
      content: isAr
        ? [
            'كافة حقوق الملكية الفكرية للبرمجيات والتصميمات والشعارات والخوارزميات ونماذج التحليل مملوكة حصرياً لشركة محفظتي.',
            'نمنحك ترخيصاً محدوداً وقابلاً للإلغاء وغير حصري لاستخدام المنصة وفقاً لباقة اشتراكك طوال فترة سريان العقد.',
            'البيانات والمعاملات والفواتير التي تقوم بإدخالها تظل ملكاً خالصاً لك ولا تدعي محفظتي أي ملكية لها.',
          ]
        : [
            'All software architectures, visual designs, trademarks, algorithms, and analytical pipelines remain the exclusive intellectual property of Mahfazti Inc.',
            'We grant you a revocable, non-exclusive, non-transferable license to access the platform in conformity with your active tier.',
            'You retain absolute proprietary ownership of all raw financial figures, ledger records, and customer receipts provided to the platform.',
          ],
    },
    {
      id: 'liability',
      icon: Clock,
      title: isAr ? '٧. حدود المسؤولية والضمانات' : '7. Limitation of Liability',
      badge: isAr ? 'شروط قانونية' : 'Legal Disclaimer',
      content: isAr
        ? [
            'يتم تقديم خدمات محفظتي على أساس "كما هي" و"حسب توفرها" دون أي ضمانات صريحة أو ضمنية بنسبة توافر ١٠٠٪ دون انقطاع.',
            'لا تتحمل محفظتي أي مسؤولية عن أي خسائر مالية أو تجارية أو أرباح فائتة ناتجة عن قرارات اتخذها المستخدم بناءً على تحليلات المنصة.',
            'في جميع الأحوال، يقتصر الحد الأقصى للمسؤولية القانونية لمحفظتي تجاهك على إجمالي المبالغ التي دفعتها للمنصة خلال الـ ١٢ شهراً السابقة للمطالبة.',
          ]
        : [
            'Mahfazti provides its SaaS platform on an "AS IS" and "AS AVAILABLE" basis, without warranties of uninterrupted uptime or error-free processing.',
            'Mahfazti shall not be liable for indirect, incidental, consequential, or punitive damages resulting from business decisions made based on system output.',
            'In all circumstances, our cumulative liability for any verified claim arising under these terms shall not exceed the aggregate fees paid by you in the preceding 12 months.',
          ],
    },
    {
      id: 'law',
      icon: Mail,
      title: isAr ? '٨. القانون المعمول به والتواصل القانوني' : '8. Governing Law & Dispute Resolution',
      badge: isAr ? 'الاختصاص القضائي' : 'Jurisdiction',
      content: isAr
        ? [
            'تخضع هذه الشروط والأحكام وتُفسر وفقاً للقوانين واللوائح المعمول بها في جمهورية مصر العربية والولاية القضائية المعتمدة.',
            'يتم حل أي نزاع ينشأ عن هذه الاتفاقية ودياً في البداية؛ وفي حال تعذر ذلك، تختص المحاكم الاقتصادية في القاهرة بالنظر في النزاع.',
            'لأي استفسارات قانونية أو إخطارات رسمية، يمكنك التواصل معنا عبر: legal@mahfazti.app',
          ]
        : [
            'These Terms of Service are governed by and construed under the laws and regulations of the designated legal domicile of Mahfazti Financial Technologies Inc.',
            'Parties shall make good-faith efforts to resolve disputes amicably prior to initiating formal arbitration or proceedings in the competent Commercial Courts of Cairo.',
            'Formal legal summons and contractual inquiries must be served in writing to: legal@mahfazti.app.',
          ],
    },
  ];

  return (
    <div
      dir={dir}
      className="relative min-h-screen w-full bg-[#f8f9fa] dark:bg-[#000000] text-zinc-900 dark:text-white transition-colors duration-200 flex flex-col justify-between overflow-x-hidden selection:bg-black selection:text-white dark:selection:bg-white dark:selection:text-black"
    >
      <AnimatedAuthBackground />

      {/* Top Header */}
      <header className="relative z-20 w-full px-6 py-5 max-w-7xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link to="/login" className="flex items-center gap-3 group">
            <MahfaztiLogo size={36} className="shadow-xs border border-zinc-200/80 dark:border-zinc-800 transition group-hover:scale-105" />
            <div className="flex flex-col text-start">
              <span className="font-extrabold text-lg tracking-tight text-zinc-950 dark:text-white">
                Mahfazti
              </span>
              <span className="text-[11px] text-zinc-500 dark:text-zinc-400 font-medium">
                {isAr ? 'الاتفاقيات القانونية' : 'Legal Agreements'}
              </span>
            </div>
          </Link>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={() => navigate('/login')}
            type="button"
            className="flex h-9 items-center gap-2 px-3.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs font-semibold text-xs active:scale-95"
          >
            {dir === 'rtl' ? <ArrowRight className="h-3.5 w-3.5" /> : <ArrowLeft className="h-3.5 w-3.5" />}
            <span>{isAr ? 'العودة لتسجيل الدخول' : 'Back to Login'}</span>
          </button>

          <button
            onClick={toggleLocale}
            type="button"
            className="flex h-9 items-center gap-1.5 px-2.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs font-semibold text-xs active:scale-95"
          >
            <Languages className="h-3.5 w-3.5" />
            <span className="font-mono text-[11px] font-bold">{locale === 'en' ? 'AR' : 'EN'}</span>
          </button>

          <button
            onClick={toggleTheme}
            type="button"
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs active:scale-95"
          >
            {theme === 'dark' ? <Sun className="h-4 w-4 text-white" /> : <Moon className="h-4 w-4 text-black" />}
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="relative z-10 w-full max-w-5xl mx-auto px-4 sm:px-6 py-8 flex-1">
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4 }}
          className="space-y-8"
        >
          {/* Hero Banner */}
          <div className="text-start space-y-3 pb-6 border-b border-zinc-200 dark:border-zinc-800">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-xs font-semibold text-zinc-700 dark:text-zinc-300 shadow-2xs">
              <Scale className="h-3.5 w-3.5 text-zinc-900 dark:text-white" />
              <span>{isAr ? 'عقد الاستخدام والخدمة' : 'User Terms Agreement'}</span>
            </div>

            <h1 className="text-3xl sm:text-4xl font-black tracking-tight text-zinc-950 dark:text-white">
              {isAr ? 'شروط وأحكام الخدمة' : 'Terms of Service'}
            </h1>

            <div className="flex flex-wrap items-center gap-4 text-xs text-zinc-500 dark:text-zinc-400">
              <span>{isAr ? 'تاريخ السريان: سبتمبر ٢٠٢٦' : 'Effective Date: September 2026'}</span>
              <span>&bull;</span>
              <span>{isAr ? 'الإصدار: v3.1' : 'Version: v3.1'}</span>
              <span>&bull;</span>
              <span className="flex items-center gap-1 text-zinc-700 dark:text-zinc-300 font-medium">
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />
                {isAr ? 'اتفاقية رسمية ملزمة قانوناً' : 'Legally Binding Agreement'}
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

          {/* Contact Legal Section */}
          <div className="rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950 p-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 text-start shadow-xs">
            <div className="space-y-1">
              <h3 className="text-sm font-bold text-zinc-900 dark:text-white flex items-center gap-2">
                <Mail className="h-4 w-4 text-zinc-500" />
                {isAr ? 'استفسارات العقود والشروط القانونية' : 'Legal & Contract Inquiries'}
              </h3>
              <p className="text-xs text-zinc-500 dark:text-zinc-400">
                {isAr
                  ? 'إذا كان لديك أي سؤال بشأن بنود الخدمة أو ترغب في توقيع اتفاقية مخصصة للشركات، يرجى التواصل مع فريق الشؤون القانونية.'
                  : 'For questions regarding these terms or custom corporate enterprise agreements, reach out to our legal department.'}
              </p>
            </div>
            <a
              href="mailto:legal@mahfazti.app"
              className="px-4 py-2 rounded-xl bg-black text-white dark:bg-white dark:text-black text-xs font-semibold shrink-0 hover:bg-zinc-800 dark:hover:bg-zinc-200 transition flex items-center gap-1.5 shadow-xs"
            >
              <span>legal@mahfazti.app</span>
              <ExternalLink className="h-3 w-3" />
            </a>
          </div>
        </motion.div>
      </main>

      {/* Footer */}
      <footer className="relative z-10 w-full px-6 py-5 max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between text-xs text-zinc-500 dark:text-zinc-500 gap-3 border-t border-zinc-200/80 dark:border-zinc-900 mt-12">
        <div>
          <span>&copy; {new Date().getFullYear()} Mahfazti Inc. {isAr ? 'كافة الحقوق محفوظة.' : 'All rights reserved.'}</span>
        </div>
        <div className="flex items-center gap-5 text-[11px] font-medium">
          <Link to="/privacy" className="hover:text-black dark:hover:text-white transition">
            {isAr ? 'سياسة الخصوصية' : 'Privacy Policy'}
          </Link>
          <Link to="/terms" className="text-black dark:text-white font-bold transition">
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
