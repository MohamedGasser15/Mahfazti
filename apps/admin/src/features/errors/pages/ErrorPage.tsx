import React from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
  ArrowLeft,
  ArrowRight,
  Home,
  LogIn,
  RefreshCw,
  LifeBuoy,
  Sun,
  Moon,
  Languages,
} from 'lucide-react';
import { useTheme } from '../../../core/context/ThemeContext';
import { useLocale } from '../../../core/context/LocaleContext';
import { useAuth } from '../../auth/context/AuthContext';
import { MahfaztiLogo } from '../../../core/components/ui/MahfaztiLogo';
import { AnimatedAuthBackground } from '../../../core/components/ui/AnimatedAuthBackground';

export interface ErrorPageProps {
  code?: '404' | '403' | '500' | '503' | string;
  title?: string;
  description?: string;
  showRetry?: boolean;
  onRetry?: () => void;
  showSupport?: boolean;
  backUrl?: string;
}

export const ErrorPage: React.FC<ErrorPageProps> = ({
  code = '404',
  title,
  description,
  showRetry = false,
  onRetry,
  showSupport = true,
  backUrl,
}) => {
  const { theme, toggleTheme } = useTheme();
  const { locale, dir, toggleLocale } = useLocale();
  const { isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const isAr = locale === 'ar';

  const defaultMeta = {
    '404': {
      title: isAr ? 'عفواً، هذه الصفحة غير موجودة' : 'Lost in the digital vault',
      desc: isAr
        ? 'الصفحة التي تحاول الوصول إليها غير موجودة، قد يكون تم نقلها أو حذفها أو تمت كتابة الرابط بشكل غير صحيح.'
        : 'The page or asset you are searching for might have been moved, renamed, or is temporarily unavailable.',
    },
    '401': {
      title: isAr ? 'مطلوب تسجيل الدخول للمتابعة' : 'Authentication Required',
      desc: isAr
        ? 'انتهت صلاحية جلسة تسجيل الدخول الحالية، أو أنك تحاول الوصول لمورد يتطلب مصادقة أمنية نشطة.'
        : 'Your session has expired, or you need to authenticate with valid administrative credentials to continue.',
    },
    '403': {
      title: isAr ? 'ليس لديك صلاحية للوصول' : 'Restricted Security Clearance',
      desc: isAr
        ? 'حسابك الحالي لا يمتلك الصلاحيات الإدارية الكافية (RBAC) للوصول إلى هذا القسم المحمي.'
        : 'Your administrative profile lacks the required RBAC permissions to inspect or execute operations in this sector.',
    },
    '500': {
      title: isAr ? 'حدث خطأ غير متوقع في الخادم' : 'Unexpected Core Service Interruption',
      desc: isAr
        ? 'تعذر على خوادمنا معالجة طلبك حالياً. تم تسجيل الخطأ في سجلات المراقبة وجاري العمل على حله.'
        : 'An anomalous runtime fault occurred within our API gateway. The error has been captured and routed to engineering triage.',
    },
    '503': {
      title: isAr ? 'النظام يخضع لصيانة مجدولة' : 'Scheduled System Maintenance',
      desc: isAr
        ? 'نجري حالياً تحسينات أمنية دورية لترقية البنية التحتية. يرجى معاودة الزيارة خلال دقائق معدودة.'
        : 'We are deploying cryptographic infrastructure upgrades. Operations will resume normally within a few minutes.',
    },
  }[code] || {
    title: isAr ? 'حدث خطأ غير متوقع' : 'Unexpected Error Occurred',
    desc: isAr
      ? 'حدث خطأ غير متوقع أثناء معالجة الصفحة. يرجى المحاولة لاحقاً.'
      : 'An unforeseen condition was encountered. Please retry or contact technical support.',
  };

  const resolvedTitle = title || defaultMeta.title;
  const resolvedDescription = description || defaultMeta.desc;

  const handleRetry = () => {
    if (onRetry) {
      onRetry();
    } else {
      window.location.reload();
    }
  };

  const is401 = code === '401';
  const primaryTarget = backUrl || (is401 ? '/login' : isAuthenticated ? '/' : '/login');
  const primaryLabel = is401 || !isAuthenticated
    ? isAr
      ? 'تسجيل الدخول إلى النظام'
      : 'Sign In to Console'
    : isAr
    ? 'العودة للوحة التحكم'
    : 'Back to Dashboard';

  return (
    <div
      dir={dir}
      className="relative min-h-screen w-full bg-[#f8f9fa] dark:bg-[#000000] text-zinc-900 dark:text-white transition-colors duration-200 flex flex-col justify-between overflow-x-hidden selection:bg-black selection:text-white dark:selection:bg-white dark:selection:text-black"
    >
      <AnimatedAuthBackground />

      {/* Top Header */}
      <header className="relative z-20 w-full px-6 py-5 max-w-7xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link
            to={isAuthenticated ? '/' : '/login'}
            className="flex items-center gap-3 group"
          >
            <MahfaztiLogo
              size={36}
              className="shadow-xs border border-zinc-200/80 dark:border-zinc-800 transition group-hover:scale-105"
            />
            <div className="flex flex-col text-start">
              <span className="font-extrabold text-lg tracking-tight text-zinc-950 dark:text-white">
                Mahfazti
              </span>
              <span className="text-[11px] text-zinc-500 dark:text-zinc-400 font-medium">
                {isAr ? 'بوابة إدارة العمليات' : 'Management Console'}
              </span>
            </div>
          </Link>
        </div>

        <div className="flex items-center gap-2.5">
          {/* Language Switcher */}
          <button
            onClick={toggleLocale}
            type="button"
            className="flex h-9 items-center gap-1.5 px-2.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs font-semibold text-xs active:scale-95"
          >
            <Languages className="h-3.5 w-3.5" />
            <span className="font-mono text-[11px] font-bold">
              {locale === 'en' ? 'AR' : 'EN'}
            </span>
          </button>

          {/* Theme Switcher */}
          <button
            onClick={toggleTheme}
            type="button"
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs active:scale-95"
          >
            {theme === 'dark' ? (
              <Sun className="h-4 w-4 text-white" />
            ) : (
              <Moon className="h-4 w-4 text-black" />
            )}
          </button>
        </div>
      </header>

      {/* Center Error Card & Numerical Display */}
      <main className="relative z-10 w-full max-w-2xl mx-auto px-4 sm:px-6 py-12 my-auto text-center flex-1 flex flex-col justify-center items-center">
        <motion.div
          initial={{ opacity: 0, scale: 0.95, y: 14 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
          className="space-y-6 w-full"
        >
          {/* Huge Monospace Code with Ambient Glow */}
          <div className="relative inline-flex items-center justify-center mb-1">
            {/* Background Glow */}
            <div className="absolute -inset-6 rounded-full bg-zinc-200/50 dark:bg-zinc-800/30 blur-2xl -z-10" />

            <div className="font-mono font-black text-7xl sm:text-9xl tracking-tighter text-zinc-950 dark:text-white select-none opacity-90 drop-shadow-sm">
              {code}
            </div>
          </div>

          {/* Heading and Description */}
          <div className="space-y-2.5 max-w-lg mx-auto">
            <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-zinc-950 dark:text-white">
              {resolvedTitle}
            </h1>
            <p className="text-xs sm:text-sm text-zinc-600 dark:text-zinc-400 leading-relaxed">
              {resolvedDescription}
            </p>
          </div>

          {/* Action Buttons */}
          <div className="flex flex-wrap items-center justify-center gap-3 pt-4">
            {/* Primary Action */}
            <button
              type="button"
              onClick={() => navigate(primaryTarget, { state: location.state })}
              className="px-5 py-2.5 rounded-xl bg-black text-white hover:bg-zinc-800 active:bg-zinc-900 dark:bg-white dark:text-black dark:hover:bg-zinc-200 text-xs font-bold transition flex items-center gap-2 cursor-pointer shadow-xs active:scale-95"
            >
              {is401 || !isAuthenticated ? (
                <LogIn className="h-4 w-4" />
              ) : (
                <Home className="h-4 w-4" />
              )}
              <span>{primaryLabel}</span>
            </button>

            {/* Optional Retry Button (for 500 / network) */}
            {showRetry && (
              <button
                type="button"
                onClick={handleRetry}
                className="px-4 py-2.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-800 dark:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800 text-xs font-semibold transition flex items-center gap-2 cursor-pointer shadow-2xs active:scale-95"
              >
                <RefreshCw className="h-3.5 w-3.5" />
                <span>{isAr ? 'إعادة المحاولة' : 'Try Again'}</span>
              </button>
            )}

            {/* Back Button */}
            <button
              type="button"
              onClick={() => navigate(-1)}
              className="px-4 py-2.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-800 dark:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800 text-xs font-semibold transition flex items-center gap-2 cursor-pointer shadow-2xs active:scale-95"
            >
              {dir === 'rtl' ? (
                <ArrowRight className="h-3.5 w-3.5" />
              ) : (
                <ArrowLeft className="h-3.5 w-3.5" />
              )}
              <span>{isAr ? 'الصفحة السابقة' : 'Go Back'}</span>
            </button>

            {/* Support Link */}
            {showSupport && (
              <button
                type="button"
                onClick={() => navigate('/help')}
                className="px-4 py-2.5 rounded-xl border border-zinc-200/80 dark:border-zinc-800 bg-transparent text-zinc-500 hover:text-black dark:text-zinc-400 dark:hover:text-white text-xs font-semibold transition flex items-center gap-1.5 cursor-pointer"
              >
                <LifeBuoy className="h-3.5 w-3.5" />
                <span>{isAr ? 'مركز الدعم الفني' : 'Help Desk'}</span>
              </button>
            )}
          </div>

          {/* Quick Helpful Links Card */}
          <div className="pt-6 max-w-md mx-auto">
            <div className="p-4 rounded-2xl border border-zinc-200/70 dark:border-zinc-800/80 bg-white/60 dark:bg-[#0c0c0e]/60 backdrop-blur-md text-start space-y-2.5">
              <span className="text-[11px] font-bold text-zinc-400 uppercase tracking-wider block">
                {isAr ? 'روابط سريعة قد تفيدك:' : 'Helpful Destinations:'}
              </span>
              <div className="grid grid-cols-2 gap-2 text-xs">
                <Link
                  to={isAuthenticated ? '/' : '/login'}
                  className="p-2 rounded-lg hover:bg-zinc-100 dark:hover:bg-zinc-900 transition flex items-center justify-between text-zinc-700 dark:text-zinc-300"
                >
                  <span>
                    {isAuthenticated
                      ? isAr
                        ? 'لوحة التحكم'
                        : 'Dashboard'
                      : isAr
                      ? 'تسجيل الدخول'
                      : 'Sign In'}
                  </span>
                  <span className="text-zinc-400">&rarr;</span>
                </Link>
                <Link
                  to="/help"
                  className="p-2 rounded-lg hover:bg-zinc-100 dark:hover:bg-zinc-900 transition flex items-center justify-between text-zinc-700 dark:text-zinc-300"
                >
                  <span>{isAr ? 'الدعم والاستفسارات' : 'Support Center'}</span>
                  <span className="text-zinc-400">&rarr;</span>
                </Link>
                <Link
                  to="/privacy"
                  className="p-2 rounded-lg hover:bg-zinc-100 dark:hover:bg-zinc-900 transition flex items-center justify-between text-zinc-700 dark:text-zinc-300"
                >
                  <span>{isAr ? 'سياسة الخصوصية' : 'Privacy Policy'}</span>
                  <span className="text-zinc-400">&rarr;</span>
                </Link>
                <Link
                  to="/terms"
                  className="p-2 rounded-lg hover:bg-zinc-100 dark:hover:bg-zinc-900 transition flex items-center justify-between text-zinc-700 dark:text-zinc-300"
                >
                  <span>{isAr ? 'شروط الخدمة' : 'Terms of Service'}</span>
                  <span className="text-zinc-400">&rarr;</span>
                </Link>
              </div>
            </div>
          </div>
        </motion.div>
      </main>

      {/* Footer */}
      <footer className="relative z-10 w-full px-6 py-4 max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between text-xs text-zinc-500 dark:text-zinc-500 gap-2 border-t border-zinc-200/80 dark:border-zinc-900">
        <div>
          <span>
            &copy; {new Date().getFullYear()} Mahfazti Inc.{' '}
            {isAr ? 'كافة الحقوق محفوظة.' : 'All rights reserved.'}
          </span>
        </div>
        <div className="flex items-center gap-4 text-[11px]">
          <Link
            to="/privacy"
            className="hover:text-black dark:hover:text-white transition"
          >
            {isAr ? 'الخصوصية' : 'Privacy'}
          </Link>
          <Link
            to="/terms"
            className="hover:text-black dark:hover:text-white transition"
          >
            {isAr ? 'الشروط' : 'Terms'}
          </Link>
          <Link
            to="/help"
            className="hover:text-black dark:hover:text-white transition"
          >
            {isAr ? 'الدعم' : 'Support'}
          </Link>
        </div>
      </footer>
    </div>
  );
};
