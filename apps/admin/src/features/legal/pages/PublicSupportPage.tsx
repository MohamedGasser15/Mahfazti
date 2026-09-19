import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  LifeBuoy,
  Mail,
  ShieldCheck,
  Send,
  HelpCircle,
  ChevronDown,
  ArrowLeft,
  ArrowRight,
  Sun,
  Moon,
  Languages,
  CheckCircle2,
  Clock,
  MessageSquare,
  Sparkles,
} from 'lucide-react';
import { useTheme } from '../../../core/context/ThemeContext';
import { useLocale } from '../../../core/context/LocaleContext';
import { MahfaztiLogo } from '../../../core/components/ui/MahfaztiLogo';
import { ThreeDotLoader } from '../../../core/components/ui/ThreeDotLoader';
import { AnimatedAuthBackground } from '../../../core/components/ui/AnimatedAuthBackground';

export const PublicSupportPage: React.FC = () => {
  const { theme, toggleTheme } = useTheme();
  const { locale, dir, toggleLocale } = useLocale();
  const navigate = useNavigate();

  const isAr = locale === 'ar';

  // Contact Form State
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [category, setCategory] = useState('account');
  const [priority, setPriority] = useState('normal');
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submittedTicket, setSubmittedTicket] = useState<{ number: string } | null>(null);

  // FAQ Accordion State
  const [expandedFaq, setExpandedFaq] = useState<number | null>(0);

  const toggleFaq = (idx: number) => {
    setExpandedFaq((prev) => (prev === idx ? null : idx));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !message.trim()) return;

    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      const generatedNumber = `TK-${Math.floor(10000 + Math.random() * 90000)}`;
      setSubmittedTicket({ number: generatedNumber });
      // Reset form
      setFullName('');
      setEmail('');
      setSubject('');
      setMessage('');
    }, 900);
  };

  const faqItems = [
    {
      q: isAr ? 'كيف يمكنني استعادة كلمة المرور إذا نسيتها؟' : 'How do I reset my password if I forget it?',
      a: isAr
        ? 'يمكنك الضغط على رابط "نسيت كلمة المرور؟" في صفحة تسجيل الدخول، وإدخال بريدك الإلكتروني. سيصلك فوراً رابط آمن ومشفر لإعادة تعيين كلمة المرور صالح لمدة ٣٠ دقيقة.'
        : 'Click the "Forgot password?" link on the login page and enter your registered email. You will promptly receive a secure, encrypted reset token valid for 30 minutes.',
    },
    {
      q: isAr ? 'هل بياناتي ومعاملاتي المالية مشفرة وآمنة تماماً؟' : 'Is my financial transaction data encrypted and confidential?',
      a: isAr
        ? 'نعم، بكل تأكيد. نستخدم معايير التشفير البنكية AES-256 للبيانات في حالة السكون و TLS 1.3 أثناء النقل. كما أننا نلتزم بمعايير SOC-2 و PCI-DSS ولا نشارك بياناتك أو نبيعها لأي طرف ثالث نهائياً.'
        : 'Yes, without exception. We enforce bank-grade AES-256 encryption at rest and TLS 1.3 in transit. Our infrastructure adheres to SOC-2 and PCI-DSS compliance, and your records are strictly never shared or sold.',
    },
    {
      q: isAr ? 'كيف يعمل مسح الفواتير بالذكاء الاصطناعي وتصنيف المصروفات؟' : 'How does the AI receipt scanner & smart categorization work?',
      a: isAr
        ? 'يقوم محرك الذكاء الاصطناعي المدمج في محفظتي بقراءة الفواتير والإيصالات المصورة واستخراج المبالغ والتواريخ واسم المتجر تلقائياً، وتصنيفها بدقة فائقة دون الحاجة لإدخال يدوي.'
        : 'Our integrated OCR and neural parser extracts the vendor name, line items, timestamps, and total amounts from uploaded receipt photos, categorizing them accurately into your ledger without manual data entry.',
    },
    {
      q: isAr ? 'هل يمكنني تصدير تقاريري المالية لتقديمها للمحاسب أو الضرائب؟' : 'Can I export my financial reports for accounting and tax audits?',
      a: isAr
        ? 'نعم، توفر المنصة إمكانية تصدير كافة سجلات المعاملات والموازنات وصافي التدفقات بصيغ Excel و CSV و PDF مفصلة ومعدة للاستخدام المحاسبي بضغطة زر واحدة.'
        : 'Yes. You can export complete ledgers, balance statements, and category breakdowns in standard Excel (.xlsx), CSV, and formatted PDF summaries ready for external auditing with one click.',
    },
    {
      q: isAr ? 'كيف يمكنني ترقية أو إلغاء باقة اشتراكي في أي وقت؟' : 'How do I upgrade, modify, or cancel my subscription plan?',
      a: isAr
        ? 'يمكنك التوجه إلى قسم "الاشتراكات والفوترة" في لوحة التحكم، واختيار الترقية الفورية أو الإلغاء. في حال الإلغاء، يظل حسابك نشطاً بخصائصه كاملة حتى انتهاء الفترة المدفوعة.'
        : 'Navigate to the "Subscriptions" module within your workspace to switch tiers or cancel auto-renewal. When canceled, your tier features remain fully accessible until the conclusion of the prepaid term.',
    },
  ];

  return (
    <div
      dir={dir}
      className="relative min-h-screen w-full bg-[#f8f9fa] dark:bg-[#000000] text-zinc-900 dark:text-white transition-colors duration-200 flex flex-col justify-between overflow-x-hidden selection:bg-black selection:text-white dark:selection:bg-white dark:selection:text-black"
    >
      <AnimatedAuthBackground />

      {/* Header */}
      <header className="relative z-20 w-full px-6 py-5 max-w-7xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link to="/login" className="flex items-center gap-3 group">
            <MahfaztiLogo size={36} className="shadow-xs border border-zinc-200/80 dark:border-zinc-800 transition group-hover:scale-105" />
            <div className="flex flex-col text-start">
              <span className="font-extrabold text-lg tracking-tight text-zinc-950 dark:text-white">
                Mahfazti
              </span>
              <span className="text-[11px] text-zinc-500 dark:text-zinc-400 font-medium">
                {isAr ? 'مركز المساعدة والدعم' : 'Help & Support Desk'}
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
          className="space-y-10"
        >
          {/* Hero Banner */}
          <div className="text-start space-y-3 pb-6 border-b border-zinc-200 dark:border-zinc-800">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-xs font-semibold text-zinc-700 dark:text-zinc-300 shadow-2xs">
              <LifeBuoy className="h-3.5 w-3.5 text-zinc-950 dark:text-white" />
              <span>{isAr ? 'دعم فني واستشارات متواصلة' : '24/7 Dedicated Support'}</span>
            </div>

            <h1 className="text-3xl sm:text-4xl font-black tracking-tight text-zinc-950 dark:text-white">
              {isAr ? 'مركز المساعدة وخدمة العملاء' : 'How can we help you today?'}
            </h1>

            <p className="text-sm text-zinc-600 dark:text-zinc-400 max-w-2xl leading-relaxed">
              {isAr
                ? 'فريق الدعم الفني والأمان في محفظتي متواجد دائماً لمساعدتك في حل أي مشكلة، أو الإجابة عن استفسارات الحساب والفوترة ومسح الفواتير بالذكاء الاصطناعي.'
                : 'Our dedicated customer success and technical operations teams are standing by to assist with access, billing, OCR diagnostics, or workspace setup.'}
            </p>
          </div>

          {/* Contact Channels Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#0c0c0e] p-5 text-start shadow-xs hover:border-zinc-300 dark:hover:border-zinc-700 transition">
              <div className="h-10 w-10 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 flex items-center justify-center text-zinc-900 dark:text-white mb-3.5">
                <Mail className="h-5 w-5" />
              </div>
              <h3 className="text-sm font-bold text-zinc-950 dark:text-white">
                {isAr ? 'الدعم العام والمساعدة' : 'General Support Desk'}
              </h3>
              <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-1 mb-3">
                {isAr ? 'للرد على الاستفسارات الفنية ومشاكل الحسابات.' : 'For account assistance and system inquiries.'}
              </p>
              <a
                href="mailto:support@mahfazti.app"
                className="text-xs font-mono font-semibold text-black dark:text-white underline underline-offset-4 hover:text-zinc-600 dark:hover:text-zinc-300"
              >
                support@mahfazti.app
              </a>
            </div>

            <div className="rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#0c0c0e] p-5 text-start shadow-xs hover:border-zinc-300 dark:hover:border-zinc-700 transition">
              <div className="h-10 w-10 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 flex items-center justify-center text-emerald-600 dark:text-emerald-400 mb-3.5">
                <ShieldCheck className="h-5 w-5" />
              </div>
              <h3 className="text-sm font-bold text-zinc-950 dark:text-white">
                {isAr ? 'فريق الأمان والحماية' : 'Security & Vulnerability'}
              </h3>
              <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-1 mb-3">
                {isAr ? 'للإبلاغ الفوري عن الثغرات أو حالات الاختراق.' : 'For urgent incident triage and vulnerability reports.'}
              </p>
              <a
                href="mailto:security@mahfazti.app"
                className="text-xs font-mono font-semibold text-black dark:text-white underline underline-offset-4 hover:text-zinc-600 dark:hover:text-zinc-300"
              >
                security@mahfazti.app
              </a>
            </div>

            <div className="rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#0c0c0e] p-5 text-start shadow-xs hover:border-zinc-300 dark:hover:border-zinc-700 transition">
              <div className="h-10 w-10 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 flex items-center justify-center text-zinc-900 dark:text-white mb-3.5">
                <Clock className="h-5 w-5" />
              </div>
              <h3 className="text-sm font-bold text-zinc-950 dark:text-white">
                {isAr ? 'ساعات العمل الرسمية' : 'Operating Hours'}
              </h3>
              <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-1 mb-2">
                {isAr ? 'الأحد – الخميس: ٩ ص – ٦ م (بتوقيت القاهرة)' : 'Sun – Thu: 9:00 AM – 6:00 PM (Cairo, UTC+3)'}
              </p>
              <div className="flex items-center gap-1.5 text-[11px] text-emerald-600 dark:text-emerald-400 font-semibold">
                <span className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
                <span>{isAr ? 'الأنظمة التشغيلية تعمل بكفاءة' : 'All systems operational'}</span>
              </div>
            </div>
          </div>

          {/* Interactive Ticket Form */}
          <div className="rounded-3xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#0c0c0e] p-6 sm:p-8 shadow-sm text-start space-y-6">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-4 border-b border-zinc-100 dark:border-zinc-900">
              <div>
                <h2 className="text-lg font-bold text-zinc-950 dark:text-white flex items-center gap-2">
                  <MessageSquare className="h-4.5 w-4.5 text-zinc-900 dark:text-white" />
                  <span>{isAr ? 'إرسال تذكرة استفسار أو دعم فني' : 'Submit a Support Ticket'}</span>
                </h2>
                <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
                  {isAr ? 'سيقوم مهندس الدعم بالرد على بريدك الإلكتروني خلال ساعات قليلة.' : 'Our engineers typically respond via email within 2-4 business hours.'}
                </p>
              </div>
              <span className="text-[11px] font-mono text-zinc-400 dark:text-zinc-500">
                SSL 256-bit Encrypted
              </span>
            </div>

            {submittedTicket ? (
              <motion.div
                initial={{ opacity: 0, scale: 0.96 }}
                animate={{ opacity: 1, scale: 1 }}
                className="p-8 rounded-2xl border border-emerald-200 dark:border-emerald-800/60 bg-emerald-50/50 dark:bg-emerald-950/20 text-center space-y-3"
              >
                <div className="h-12 w-12 rounded-2xl bg-emerald-500 text-white flex items-center justify-center mx-auto shadow-sm">
                  <CheckCircle2 className="h-6 w-6" />
                </div>
                <h3 className="text-base font-bold text-emerald-950 dark:text-emerald-300">
                  {isAr ? 'تم استلام تذكرتك بنجاح!' : 'Ticket Dispatched Successfully!'}
                </h3>
                <p className="text-xs text-emerald-800 dark:text-emerald-400 max-w-md mx-auto">
                  {isAr
                    ? `تم تسجيل تذكرتك برقم مرجعي: ${submittedTicket.number}. لقد أرسلنا تأكيداً على بريدك الإلكتروني وسيتواصل معك أحد ممثلي الدعم قريباً.`
                    : `Your inquiry has been assigned reference ID: ${submittedTicket.number}. A confirmation has been dispatched to your email and an engineer will reply shortly.`}
                </p>
                <div className="pt-2">
                  <button
                    type="button"
                    onClick={() => setSubmittedTicket(null)}
                    className="px-4 py-2 rounded-xl bg-black text-white dark:bg-white dark:text-black text-xs font-semibold hover:bg-zinc-800 dark:hover:bg-zinc-200 transition cursor-pointer"
                  >
                    {isAr ? 'إرسال استفسار آخر' : 'Send Another Inquiry'}
                  </button>
                </div>
              </motion.div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-semibold text-zinc-700 dark:text-zinc-300 mb-1.5">
                      {isAr ? 'الاسم بالكامل' : 'Full Name'}
                    </label>
                    <input
                      type="text"
                      required
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      placeholder={isAr ? 'محمد علي' : 'Alex Morgan'}
                      className="w-full h-10 px-3.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-xs text-zinc-900 dark:text-white placeholder:text-zinc-400 focus:border-black dark:focus:border-white focus:outline-none transition shadow-2xs"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-zinc-700 dark:text-zinc-300 mb-1.5">
                      {isAr ? 'البريد الإلكتروني المسجل' : 'Registered Email Address'}
                    </label>
                    <input
                      type="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="alex@example.com"
                      className="w-full h-10 px-3.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-xs text-zinc-900 dark:text-white placeholder:text-zinc-400 focus:border-black dark:focus:border-white focus:outline-none transition shadow-2xs"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-semibold text-zinc-700 dark:text-zinc-300 mb-1.5">
                      {isAr ? 'تصنيف الاستفسار' : 'Category'}
                    </label>
                    <select
                      value={category}
                      onChange={(e) => setCategory(e.target.value)}
                      className="w-full h-10 px-3.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-xs text-zinc-900 dark:text-white focus:border-black dark:focus:border-white focus:outline-none transition shadow-2xs"
                    >
                      <option value="account">{isAr ? 'الوصول للحساب وتسجيل الدخول' : 'Account Access & Credentials'}</option>
                      <option value="billing">{isAr ? 'الفوترة والباقات والدفع' : 'Billing & Subscription Tiers'}</option>
                      <option value="ai">{isAr ? 'مسح الفواتير بالذكاء الاصطناعي (AI OCR)' : 'AI Receipt Scanning'}</option>
                      <option value="bug">{isAr ? 'الإبلاغ عن خلل تقني' : 'Technical Issue or Bug Report'}</option>
                      <option value="other">{isAr ? 'استفسار عام أو اقتراح' : 'General Suggestion / Inquiry'}</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-zinc-700 dark:text-zinc-300 mb-1.5">
                      {isAr ? 'درجة الأولوية' : 'Priority Level'}
                    </label>
                    <select
                      value={priority}
                      onChange={(e) => setPriority(e.target.value)}
                      className="w-full h-10 px-3.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-xs text-zinc-900 dark:text-white focus:border-black dark:focus:border-white focus:outline-none transition shadow-2xs"
                    >
                      <option value="normal">{isAr ? 'عادي (خلال ٢٤ ساعة)' : 'Normal (Within 24h)'}</option>
                      <option value="high">{isAr ? 'مرتفع (خلال ٤ ساعات)' : 'High (Within 4h)'}</option>
                      <option value="urgent">{isAr ? 'عاجل (خلال ساعة)' : 'Urgent (Within 1h)'}</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-zinc-700 dark:text-zinc-300 mb-1.5">
                    {isAr ? 'عنوان المشكلة أو الاستفسار' : 'Subject'}
                  </label>
                  <input
                    type="text"
                    required
                    value={subject}
                    onChange={(e) => setSubject(e.target.value)}
                    placeholder={isAr ? 'مثال: تعذر مسح إيصال أو تحديث كلمة المرور' : 'e.g. Issue scanning grocery receipt or password reset'}
                    className="w-full h-10 px-3.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-xs text-zinc-900 dark:text-white placeholder:text-zinc-400 focus:border-black dark:focus:border-white focus:outline-none transition shadow-2xs"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-zinc-700 dark:text-zinc-300 mb-1.5">
                    {isAr ? 'تفاصيل المشكلة والرسالة' : 'Detailed Message'}
                  </label>
                  <textarea
                    required
                    rows={4}
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    placeholder={isAr ? 'يرجى كتابة التفاصيل الدقيقة للمشكلة لمساعدتك في أسرع وقت...' : 'Please describe your request in detail to help us assist you swiftly...'}
                    className="w-full p-3.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-xs text-zinc-900 dark:text-white placeholder:text-zinc-400 focus:border-black dark:focus:border-white focus:outline-none transition shadow-2xs resize-none"
                  />
                </div>

                <div className="flex items-center justify-end pt-2">
                  <button
                    type="submit"
                    disabled={isSubmitting}
                    className="px-6 py-2.5 rounded-xl bg-black text-white hover:bg-zinc-800 dark:bg-white dark:text-black dark:hover:bg-zinc-200 text-xs font-bold transition flex items-center justify-center min-w-[130px] cursor-pointer shadow-xs disabled:opacity-50"
                  >
                    {isSubmitting ? (
                      <ThreeDotLoader size="sm" />
                    ) : (
                      <>
                        <span>{isAr ? 'إرسال التذكرة' : 'Submit Ticket'}</span>
                        <Send className={`h-3.5 w-3.5 ${dir === 'rtl' ? 'rotate-180' : ''}`} />
                      </>
                    )}
                  </button>
                </div>
              </form>
            )}
          </div>

          {/* FAQ Accordion Section */}
          <div className="space-y-4 text-start">
            <div className="flex items-center gap-2.5 pb-2">
              <HelpCircle className="h-5 w-5 text-zinc-900 dark:text-white" />
              <h2 className="text-xl font-bold tracking-tight text-zinc-950 dark:text-white">
                {isAr ? 'الأسئلة الأكثر شيوعاً' : 'Frequently Asked Questions'}
              </h2>
            </div>

            <div className="space-y-3">
              {faqItems.map((item, idx) => {
                const isOpen = expandedFaq === idx;
                return (
                  <div
                    key={idx}
                    className="rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#0c0c0e] overflow-hidden shadow-2xs transition"
                  >
                    <button
                      type="button"
                      onClick={() => toggleFaq(idx)}
                      className="w-full p-4 sm:p-5 flex items-center justify-between gap-4 text-start font-semibold text-xs sm:text-sm text-zinc-950 dark:text-white hover:bg-zinc-50 dark:hover:bg-zinc-900/50 transition cursor-pointer"
                    >
                      <span className="flex items-center gap-2.5">
                        <Sparkles className="h-4 w-4 text-zinc-400 dark:text-zinc-500 shrink-0" />
                        <span>{item.q}</span>
                      </span>
                      <ChevronDown
                        className={`h-4 w-4 shrink-0 text-zinc-400 transition-transform duration-200 ${
                          isOpen ? 'rotate-180 text-black dark:text-white' : ''
                        }`}
                      />
                    </button>

                    <AnimatePresence initial={false}>
                      {isOpen && (
                        <motion.div
                          initial={{ height: 0, opacity: 0 }}
                          animate={{ height: 'auto', opacity: 1 }}
                          exit={{ height: 0, opacity: 0 }}
                          transition={{ duration: 0.25 }}
                          className="overflow-hidden"
                        >
                          <div className="p-4 sm:p-5 pt-0 text-xs sm:text-sm text-zinc-600 dark:text-zinc-400 leading-relaxed border-t border-zinc-100 dark:border-zinc-900/80">
                            {item.a}
                          </div>
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </div>
                );
              })}
            </div>
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
          <Link to="/terms" className="hover:text-black dark:hover:text-white transition">
            {isAr ? 'شروط الخدمة' : 'Terms of Service'}
          </Link>
          <Link to="/support" className="text-black dark:text-white font-bold transition">
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
