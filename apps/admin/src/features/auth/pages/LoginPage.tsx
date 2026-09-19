import React, { useState } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Mail,
  Lock,
  Eye,
  EyeOff,
  ArrowRight,
  Sun,
  Moon,
  ShieldCheck,
  Zap,
  TrendingUp,
  Activity,
  CheckCircle2,
  Fingerprint,
  KeyRound,
  X,
  CreditCard,
  Check,
  Languages,
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { authApi } from '../api/authApi';
import { AuthError, type AuthErrorCode } from '../types';
import { useTheme } from '../../../core/context/ThemeContext';
import { useLocale } from '../../../core/context/LocaleContext';
import type { TranslationSchema } from '../../../core/i18n/translations';
import { MahfaztiLogo } from '../../../core/components/ui/MahfaztiLogo';
import { ThreeDotLoader } from '../../../core/components/ui/ThreeDotLoader';
import { AnimatedAuthBackground } from '../../../core/components/ui/AnimatedAuthBackground';

const getAuthErrorMessage = (code: AuthErrorCode, t: TranslationSchema): string => {
  switch (code) {
    case 'ACCESS_DENIED':
      return t.auth.errors.accessDenied;
    case 'INVALID_CREDENTIALS':
      return t.auth.errors.invalidCredentials;
    case 'MISSING_CREDENTIALS':
      return t.auth.errors.missingCredentials;
    case 'ACCOUNT_BANNED':
      return t.auth.errors.accountBanned;
    case 'ACCOUNT_LOCKED':
      return t.auth.errors.accountLocked;
    case 'NETWORK_ERROR':
      return t.auth.errors.networkError;
    case 'SERVER_ERROR':
      return t.auth.errors.serverError;
    case 'RESET_FAILED':
      return t.auth.errors.resetFailed;
    case 'UNEXPECTED_ERROR':
    default:
      return t.auth.errors.unexpectedError;
  }
};

const STATIC_SLIDE_ICONS = [
  {
    cardIcon: CreditCard,
    cardBadgeIcon: TrendingUp,
    stat1Icon: Zap,
    stat2Icon: ShieldCheck,
  },
  {
    cardIcon: Zap,
    cardBadgeIcon: Activity,
    stat1Icon: TrendingUp,
    stat2Icon: CreditCard,
  },
  {
    cardIcon: ShieldCheck,
    cardBadgeIcon: CheckCircle2,
    stat1Icon: Fingerprint,
    stat2Icon: CheckCircle2,
  },
];

export const LoginPage: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  const [errorCode, setErrorCode] = useState<AuthErrorCode | null>(null);
  const [showForgotModal, setShowForgotModal] = useState(false);
  const [forgotEmail, setForgotEmail] = useState('');
  const [resetErrorCode, setResetErrorCode] = useState<AuthErrorCode | null>(null);
  const [isSendingReset, setIsSendingReset] = useState(false);
  const [isResetSent, setIsResetSent] = useState(false);
  const [activeSlide, setActiveSlide] = useState(0);

  // Helper to restrict input strictly to English / ASCII characters
  const sanitizeEnglish = (val: string, allowSpaces = false) => {
    return allowSpaces
      ? val.replace(/[^\x20-\x7E]/g, '')
      : val.replace(/[^\x21-\x7E]/g, '');
  };

  const handleEnglishKeyDown = (
    e: React.KeyboardEvent<HTMLInputElement>,
    allowSpaces = false
  ) => {
    // Allow control keys (Backspace, Delete, Enter, Tab, Arrow keys, shortcuts)
    if (e.key.length !== 1 || e.ctrlKey || e.altKey || e.metaKey) {
      return;
    }
    if (!allowSpaces && e.key === ' ') {
      e.preventDefault();
      return;
    }
    // Block non-ASCII characters (including Arabic)
    if (/[^\x20-\x7E]/.test(e.key)) {
      e.preventDefault();
    }
  };

  const { login } = useAuth();
  const { theme, toggleTheme } = useTheme();
  const { locale, dir, toggleLocale, t } = useLocale();
  const navigate = useNavigate();
  const location = useLocation();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorCode(null);

    if (!email.trim() || !password.trim()) {
      setErrorCode('MISSING_CREDENTIALS');
      return;
    }

    setIsLoading(true);

    try {
      await login(email.trim(), password);
      const targetPath =
        (location.state as { from?: { pathname?: string } })?.from?.pathname || '/';
      navigate(targetPath, { replace: true });
    } catch (err: unknown) {
      let code: AuthErrorCode = 'UNEXPECTED_ERROR';
      if (err instanceof AuthError) {
        code = err.code;
      } else if (err instanceof Error) {
        const lower = err.message.toLowerCase();
        if (lower.includes('access denied') || lower.includes('permission')) {
          code = 'ACCESS_DENIED';
        } else if (
          lower.includes('credential') ||
          lower.includes('password') ||
          lower.includes('invalid') ||
          lower.includes('email') ||
          lower.includes('user')
        ) {
          code = 'INVALID_CREDENTIALS';
        } else if (lower.includes('banned')) {
          code = 'ACCOUNT_BANNED';
        } else if (lower.includes('lock')) {
          code = 'ACCOUNT_LOCKED';
        } else if (lower.includes('network') || lower.includes('connect')) {
          code = 'NETWORK_ERROR';
        } else if (lower.includes('server') || lower.includes('unreachable')) {
          code = 'SERVER_ERROR';
        }
      }

      setErrorCode(code);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSendResetLink = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!forgotEmail.trim()) return;
    setIsSendingReset(true);
    setResetErrorCode(null);
    try {
      await authApi.forgotPassword(forgotEmail.trim());
      setIsResetSent(true);
      setTimeout(() => {
        setShowForgotModal(false);
        setIsResetSent(false);
        setForgotEmail('');
      }, 2000);
    } catch (err: unknown) {
      const code: AuthErrorCode =
        err instanceof AuthError ? err.code : 'RESET_FAILED';
      setResetErrorCode(code);
    } finally {
      setIsSendingReset(false);
    }
  };

  const currentSlide = t.auth.slides[activeSlide];
  const currentIcons = STATIC_SLIDE_ICONS[activeSlide];
  const CardIcon = currentIcons.cardIcon;
  const CardBadgeIcon = currentIcons.cardBadgeIcon;
  const Stat1Icon = currentIcons.stat1Icon;
  const Stat2Icon = currentIcons.stat2Icon;

  return (
    <div className="relative min-h-screen w-full bg-[#f8f9fa] dark:bg-[#000000] text-zinc-900 dark:text-white transition-colors duration-200 flex flex-col justify-between overflow-x-hidden select-none">
      {/* Dynamic Animated Ambient Background */}
      <AnimatedAuthBackground />

      {/* Top Header */}
      <header className="relative z-20 w-full px-6 py-5 max-w-7xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-3">
          <MahfaztiLogo size={36} className="shadow-xs border border-zinc-200/80 dark:border-zinc-800" />
          <div className="flex flex-col text-start">
            <span className="font-extrabold text-lg tracking-tight text-zinc-950 dark:text-white">
              Mahfazti
            </span>
            <span className="text-[11px] text-zinc-500 dark:text-zinc-400 font-medium">
              {t.auth.brandSubtitle}
            </span>
          </div>
        </div>

        <div className="flex items-center gap-2.5">
          {/* Language Switcher */}
          <button
            onClick={toggleLocale}
            type="button"
            title={t.common.switchLanguage}
            aria-label="Toggle language"
            className="flex h-9 items-center gap-1.5 px-2.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs font-semibold text-xs active:scale-95"
          >
            <Languages className="h-3.5 w-3.5" />
            <span className="font-mono text-[11px] font-bold">{locale === 'en' ? 'AR' : 'EN'}</span>
          </button>

          {/* Theme Switcher Button */}
          <button
            onClick={toggleTheme}
            type="button"
            title={theme === 'dark' ? t.common.lightMode : t.common.darkMode}
            aria-label={t.common.toggleTheme}
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

      {/* Main Content */}
      <main className="relative z-10 w-full max-w-7xl mx-auto px-4 sm:px-6 py-4 lg:py-6 xl:py-10 my-auto grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-10 xl:gap-14 items-center">
        {/* Showcase Column with 3 Rotating Items (5s cycle) */}
        <div className="hidden lg:flex lg:col-span-7 flex-col justify-center space-y-5 xl:space-y-7 pe-4 min-h-[460px]">
          <AnimatePresence mode="wait">
            <motion.div
              key={activeSlide}
              initial={{ opacity: 0, y: 8, filter: 'blur(3px)' }}
              animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
              exit={{ opacity: 0, y: -8, filter: 'blur(3px)' }}
              transition={{ duration: 0.45, ease: [0.16, 1, 0.3, 1] }}
              className="space-y-6 text-start"
            >
              {/* Badge & Headline */}
              <div className="space-y-3.5">
                <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-xs font-semibold text-zinc-700 dark:text-zinc-300 shadow-2xs">
                  <span className="h-2 w-2 rounded-full bg-emerald-500" />
                  <span>{currentSlide.badge}</span>
                </div>

                <h1 className="text-3xl sm:text-4xl xl:text-5xl font-black tracking-tight text-zinc-950 dark:text-white leading-[1.18]">
                  {currentSlide.title}
                </h1>

                <p className="text-sm xl:text-base text-zinc-600 dark:text-zinc-400 max-w-xl leading-relaxed">
                  {currentSlide.description}
                </p>
              </div>

              {/* Dynamic Dashboard Metric Card */}
              <div className="space-y-4 max-w-xl">
                <div className="p-6 rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950 shadow-sm">
                  <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center gap-3">
                      <div className="h-10 w-10 rounded-xl bg-zinc-100 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 flex items-center justify-center text-zinc-900 dark:text-white">
                        <CardIcon className="h-5 w-5" />
                      </div>
                      <div className="text-start">
                        <span className="text-xs font-medium text-zinc-500 dark:text-zinc-400">
                          {currentSlide.cardLabel}
                        </span>
                        <h3 className="text-2xl font-black text-zinc-950 dark:text-white font-mono">
                          {currentSlide.cardValue}
                        </h3>
                      </div>
                    </div>

                    <span className="inline-flex items-center gap-1 text-xs font-bold px-2.5 py-1 rounded-full bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-900/60 font-mono">
                      <CardBadgeIcon className="h-3.5 w-3.5" />
                      {currentSlide.cardBadge}
                    </span>
                  </div>

                  {/* Pills Grid */}
                  <div className="grid grid-cols-4 gap-2 pt-3 border-t border-zinc-100 dark:border-zinc-900 text-xs font-mono">
                    {currentSlide.pills.map((pill, idx) => (
                      <div key={idx} className="p-2 rounded-lg bg-zinc-50 dark:bg-zinc-900/60 text-center">
                        <span className="block text-[10px] text-zinc-400">{pill.label}</span>
                        <span className="font-semibold text-zinc-800 dark:text-zinc-200">{pill.val}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Performance and Security Badges */}
                <div className="grid grid-cols-2 gap-4">
                  <div className="p-4 rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950 shadow-sm text-start">
                    <div className="flex items-center gap-2 mb-1.5 text-zinc-900 dark:text-white">
                      <Stat1Icon className="h-4 w-4 text-emerald-500 shrink-0" />
                      <span className="text-xs font-bold uppercase tracking-wider">{currentSlide.stat1.title}</span>
                    </div>
                    <div className="text-base font-bold text-zinc-950 dark:text-white font-mono">
                      {currentSlide.stat1.value}
                    </div>
                    <p className="text-[11px] text-zinc-500 dark:text-zinc-400 mt-0.5">
                      {currentSlide.stat1.desc}
                    </p>
                  </div>

                  <div className="p-4 rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950 shadow-sm text-start">
                    <div className="flex items-center gap-2 mb-1.5 text-zinc-900 dark:text-white">
                      <Stat2Icon className="h-4 w-4 text-emerald-500 shrink-0" />
                      <span className="text-xs font-bold uppercase tracking-wider">{currentSlide.stat2.title}</span>
                    </div>
                    <div className="text-base font-bold text-zinc-950 dark:text-white font-mono">
                      {currentSlide.stat2.value}
                    </div>
                    <p className="text-[11px] text-zinc-500 dark:text-zinc-400 mt-0.5">
                      {currentSlide.stat2.desc}
                    </p>
                  </div>
                </div>
              </div>
            </motion.div>
          </AnimatePresence>

          {/* Slide Indicator Pills & Compliance Badges */}
          <div className="flex items-center justify-between pt-1 max-w-xl">
            {/* 3 Indicator Pills with Progress Fill on Active */}
            <div className="flex items-center gap-2 sm:gap-2.5">
              {STATIC_SLIDE_ICONS.map((_, idx) => {
                const isActive = activeSlide === idx;
                return (
                  <button
                    key={idx}
                    type="button"
                    onClick={() => setActiveSlide(idx)}
                    className={`relative h-2 sm:h-2.5 rounded-full overflow-hidden transition-[width,background-color,border-color] duration-300 cursor-pointer focus:outline-none ${
                      isActive
                        ? 'w-10 sm:w-12 bg-zinc-200 dark:bg-zinc-800 border border-zinc-300/80 dark:border-zinc-700 shadow-2xs'
                        : 'w-2.5 sm:w-3.5 bg-zinc-300 dark:bg-zinc-600 hover:bg-zinc-400 dark:hover:bg-zinc-500 border border-transparent'
                    }`}
                    aria-label={`Slide ${idx + 1}`}
                  >
                    {isActive && (
                      <motion.div
                        key={`pill-progress-${activeSlide}`}
                        initial={{ width: '0%' }}
                        animate={{ width: '100%' }}
                        transition={{ duration: 5, ease: 'linear' }}
                        onAnimationComplete={() =>
                          setActiveSlide((prev) => (prev + 1) % STATIC_SLIDE_ICONS.length)
                        }
                        className="absolute inset-y-0 start-0 bg-black dark:bg-white rounded-full"
                      />
                    )}
                  </button>
                );
              })}
            </div>

            {/* Compliance Badges */}
            <div className="flex items-center gap-4 text-zinc-500 dark:text-zinc-400 text-xs font-medium">
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />
                PCI-DSS
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />
                SOC2
              </span>
              <span className="flex items-center gap-1.5">
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />
                ISO 27001
              </span>
            </div>
          </div>
        </div>

        {/* Right Column: Sign In Card */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.35 }}
          className="w-full lg:col-span-5 max-w-[460px] mx-auto"
        >
          <div className="rounded-3xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#0c0c0e] shadow-xl p-6 sm:p-8 text-start">
            {/* Mobile Brand Heading */}
            <div className="flex lg:hidden items-center gap-3 mb-6 pb-4 border-b border-zinc-100 dark:border-zinc-900">
              <MahfaztiLogo size={32} />
              <div>
                <h3 className="font-extrabold text-base text-zinc-950 dark:text-white">
                  Mahfazti
                </h3>
                <p className="text-xs text-zinc-500">{t.auth.brandSubtitle}</p>
              </div>
            </div>

            {/* Header */}
            <div className="mb-6">
              <h2 className="text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                {t.auth.signInTitle}
              </h2>
              <p className="mt-1.5 text-xs text-zinc-500 dark:text-zinc-400">
                {t.auth.signInSubtitle}
              </p>
            </div>

            {/* Inline Error Message */}
            {errorCode && (
              <div className="mb-4 rounded-xl border border-rose-200 dark:border-rose-900/50 bg-rose-50 dark:bg-rose-950/30 px-3.5 py-2.5 text-xs text-rose-600 dark:text-rose-400 font-medium">
                {getAuthErrorMessage(errorCode, t)}
              </div>
            )}

            {/* Login Form */}
            <form onSubmit={handleSubmit} className="space-y-4">
              {/* Email */}
              <div className="space-y-1.5">
                <label className="block text-xs font-semibold text-zinc-800 dark:text-zinc-200">
                  {t.auth.emailLabel}
                </label>
                <div className="relative group">
                  <Mail className={`absolute top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-400 group-focus-within:text-black dark:group-focus-within:text-white transition-colors pointer-events-none ${
                    dir === 'rtl' ? 'right-3.5' : 'left-3.5'
                  }`} />
                  <input
                    type="email"
                    required
                    dir="ltr"
                    lang="en"
                    autoCapitalize="none"
                    autoComplete="email"
                    spellCheck={false}
                    value={email}
                    onKeyDown={(e) => handleEnglishKeyDown(e, false)}
                    onChange={(e) => {
                      setEmail(sanitizeEnglish(e.target.value, false));
                      setErrorCode(null);
                    }}
                    placeholder={t.auth.emailPlaceholder}
                    className={`w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50/80 dark:bg-zinc-900/60 py-2.5 text-xs sm:text-sm text-zinc-950 dark:text-white placeholder-zinc-400 dark:placeholder-zinc-600 focus:border-black dark:focus:border-white focus:bg-white dark:focus:bg-black focus:outline-none focus:ring-2 focus:ring-black/5 dark:focus:ring-white/10 transition-all shadow-2xs ${
                      dir === 'rtl' ? 'pr-10 pl-3.5 text-right' : 'pl-10 pr-3.5 text-left'
                    }`}
                  />
                </div>
              </div>

              {/* Password */}
              <div className="space-y-1.5">
                <div className="flex items-center justify-between">
                  <label className="block text-xs font-semibold text-zinc-800 dark:text-zinc-200">
                    {t.auth.passwordLabel}
                  </label>
                  <button
                    type="button"
                    onClick={() => {
                      setShowForgotModal(true);
                      setResetErrorCode(null);
                    }}
                    className="text-[11px] font-medium text-zinc-500 hover:text-black dark:text-zinc-400 dark:hover:text-white underline cursor-pointer transition-colors"
                  >
                    {t.auth.forgotPassword}
                  </button>
                </div>
                <div className="relative group">
                  <Lock className={`absolute top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-400 group-focus-within:text-black dark:group-focus-within:text-white transition-colors pointer-events-none ${
                    dir === 'rtl' ? 'right-3.5' : 'left-3.5'
                  }`} />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    required
                    dir="ltr"
                    lang="en"
                    autoCapitalize="none"
                    autoComplete="current-password"
                    spellCheck={false}
                    value={password}
                    onKeyDown={(e) => handleEnglishKeyDown(e, true)}
                    onChange={(e) => {
                      setPassword(sanitizeEnglish(e.target.value, true));
                      setErrorCode(null);
                    }}
                    placeholder={t.auth.passwordPlaceholder}
                    className={`w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50/80 dark:bg-zinc-900/60 py-2.5 text-xs sm:text-sm text-zinc-950 dark:text-white placeholder-zinc-400 dark:placeholder-zinc-600 focus:border-black dark:focus:border-white focus:bg-white dark:focus:bg-black focus:outline-none focus:ring-2 focus:ring-black/5 dark:focus:ring-white/10 transition-all shadow-2xs font-mono ${
                      dir === 'rtl' ? 'pr-10 pl-10 text-right' : 'pl-10 pr-10 text-left'
                    }`}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className={`absolute top-1/2 -translate-y-1/2 flex items-center justify-center h-7 w-7 rounded-lg text-zinc-400 hover:text-black dark:hover:text-white hover:bg-zinc-100 dark:hover:bg-zinc-800 transition cursor-pointer ${
                      dir === 'rtl' ? 'left-2.5' : 'right-2.5'
                    }`}
                    title={showPassword ? t.auth.hidePassword : t.auth.showPassword}
                    aria-label={showPassword ? t.auth.hidePassword : t.auth.showPassword}
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              {/* Remember Me */}
              <div className="flex items-center justify-between pt-0.5">
                <label className="flex items-center gap-2 cursor-pointer select-none">
                  <input
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                    className="h-4 w-4 rounded border-zinc-300 dark:border-zinc-700 accent-black dark:accent-white cursor-pointer"
                  />
                  <span className="text-xs font-medium text-zinc-600 dark:text-zinc-400">
                    {t.auth.keepSignedIn}
                  </span>
                </label>
              </div>

              {/* Submit Button */}
              <button
                type="submit"
                disabled={isLoading}
                className="w-full h-11 sm:h-12 mt-2 flex items-center justify-center gap-2 rounded-xl bg-black text-white hover:bg-zinc-800 active:bg-zinc-900 dark:bg-white dark:text-black dark:hover:bg-zinc-200 dark:active:bg-zinc-300 text-xs sm:text-sm font-bold shadow-sm disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer transition-all active:scale-[0.99]"
              >
                {isLoading ? (
                  <ThreeDotLoader size="md" />
                ) : (
                  <>
                    <span>{t.auth.signInButton}</span>
                    <ArrowRight className={`h-4 w-4 ${dir === 'rtl' ? 'rotate-180' : ''}`} />
                  </>
                )}
              </button>
            </form>

            {/* Security Notice / Disclaimer */}
            <div className="mt-5 p-3.5 rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900/50 flex items-start gap-2.5 shadow-2xs">
              <ShieldCheck className="h-4 w-4 text-zinc-500 dark:text-zinc-400 shrink-0 mt-0.5" />
              <div className="text-[11px] leading-relaxed text-zinc-500 dark:text-zinc-400">
                <span className="font-semibold text-zinc-800 dark:text-zinc-200">
                  {t.auth.securityNoticeTitle}:{' '}
                </span>
                {t.auth.securityNoticeDesc}
              </div>
            </div>

            {/* Footer Note */}
            <div className="mt-6 pt-4 border-t border-zinc-100 dark:border-zinc-900 flex items-center justify-between text-[11px] text-zinc-400 font-mono">
              <span className="flex items-center gap-1.5">
                <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                TLS 1.3 Encrypted
              </span>
              <span>Mahfazti Console</span>
            </div>
          </div>
        </motion.div>
      </main>

      {/* Bottom Footer */}
      <footer className="relative z-10 w-full px-6 py-4 max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between text-xs text-zinc-500 dark:text-zinc-500 gap-2 border-t border-zinc-200/80 dark:border-zinc-900">
        <div>
          <span>&copy; {new Date().getFullYear()} Mahfazti. All rights reserved.</span>
        </div>
        <div className="flex items-center gap-4 text-[11px]">
          <Link to="/privacy" className="hover:text-black dark:hover:text-white cursor-pointer transition">
            {locale === 'ar' ? 'سياسة الخصوصية' : 'Privacy Policy'}
          </Link>
          <Link to="/terms" className="hover:text-black dark:hover:text-white cursor-pointer transition">
            {locale === 'ar' ? 'شروط الخدمة' : 'Terms of Service'}
          </Link>
          <Link to="/help" className="hover:text-black dark:hover:text-white cursor-pointer transition">
            {locale === 'ar' ? 'الدعم الفني' : 'Support'}
          </Link>
        </div>
      </footer>

      {/* Forgot Password Modal */}
      <AnimatePresence>
        {showForgotModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowForgotModal(false)}
              className="absolute inset-0 bg-black/60 backdrop-blur-xs"
            />

            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: 10 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 10 }}
              className="relative w-full max-w-md rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950 p-6 shadow-2xl z-10 text-start"
            >
              <div className="flex items-center justify-between pb-3 border-b border-zinc-100 dark:border-zinc-900">
                <div className="flex items-center gap-2">
                  <div className="p-2 rounded-lg bg-zinc-100 dark:bg-zinc-900 text-zinc-800 dark:text-zinc-200">
                    <KeyRound className="h-4 w-4" />
                  </div>
                  <h3 className="text-base font-bold text-zinc-950 dark:text-white">
                    {t.auth.resetModal.title}
                  </h3>
                </div>
                <button
                  type="button"
                  onClick={() => setShowForgotModal(false)}
                  className="flex h-8 w-8 items-center justify-center rounded-lg text-zinc-400 hover:text-black dark:hover:text-white hover:bg-zinc-100 dark:hover:bg-zinc-800 transition cursor-pointer"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              {isResetSent ? (
                <div className="my-6 p-4 rounded-xl border border-emerald-200 dark:border-emerald-900 bg-emerald-50 dark:bg-emerald-950/30 flex items-center gap-3">
                  <div className="h-8 w-8 rounded-full bg-emerald-500 text-white flex items-center justify-center shrink-0">
                    <Check className="h-4 w-4" />
                  </div>
                  <div>
                    <p className="text-xs font-semibold text-emerald-900 dark:text-emerald-200">
                      {t.auth.resetModal.successTitle}
                    </p>
                    <p className="text-[11px] text-emerald-700 dark:text-emerald-400">
                      {t.auth.resetModal.successDesc}
                    </p>
                  </div>
                </div>
              ) : (
                <>
                  <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-3 leading-relaxed">
                    {t.auth.resetModal.description}
                  </p>

                  {resetErrorCode && (
                    <div className="mt-3 rounded-xl border border-rose-200 dark:border-rose-900/50 bg-rose-50 dark:bg-rose-950/30 px-3.5 py-2.5 text-xs text-rose-600 dark:text-rose-400 font-medium">
                      {getAuthErrorMessage(resetErrorCode, t)}
                    </div>
                  )}

                  <form onSubmit={handleSendResetLink} className="mt-4 space-y-4">
                    <div>
                      <label className="block text-xs font-semibold text-zinc-700 dark:text-zinc-300 mb-1.5">
                        {t.auth.resetModal.emailLabel}
                      </label>
                      <input
                        type="email"
                        required
                        dir="ltr"
                        lang="en"
                        autoCapitalize="none"
                        autoComplete="email"
                        spellCheck={false}
                        value={forgotEmail}
                        onKeyDown={(e) => handleEnglishKeyDown(e, false)}
                        onChange={(e) => {
                          setForgotEmail(sanitizeEnglish(e.target.value, false));
                          setResetErrorCode(null);
                        }}
                        placeholder={t.auth.resetModal.emailPlaceholder}
                        className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 px-3.5 py-2.5 text-xs text-zinc-950 dark:text-white focus:border-black dark:focus:border-white focus:outline-none shadow-2xs text-start"
                      />
                    </div>

                    <div className="flex items-center justify-end gap-2 pt-2">
                      <button
                        type="button"
                        onClick={() => setShowForgotModal(false)}
                        className="px-4 py-2 rounded-xl text-xs font-semibold text-zinc-600 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition cursor-pointer"
                      >
                        {t.auth.resetModal.cancelBtn}
                      </button>
                      <button
                        type="submit"
                        disabled={isSendingReset}
                        className="px-4 py-2 rounded-xl bg-black text-white hover:bg-zinc-800 active:bg-zinc-900 dark:bg-white dark:text-black dark:hover:bg-zinc-200 text-xs font-semibold transition flex items-center justify-center min-w-[110px] cursor-pointer disabled:opacity-50"
                      >
                        {isSendingReset ? <ThreeDotLoader size="sm" /> : t.auth.resetModal.submitBtn}
                      </button>
                    </div>
                  </form>
                </>
              )}
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
};
