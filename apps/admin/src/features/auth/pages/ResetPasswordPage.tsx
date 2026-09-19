import React, { useState } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Lock,
  Eye,
  EyeOff,
  ArrowRight,
  ArrowLeft,
  Sun,
  Moon,
  ShieldCheck,
  Zap,
  TrendingUp,
  Activity,
  CheckCircle2,
  Fingerprint,
  KeyRound,
  CreditCard,
  Languages,
  AlertCircle,
  Mail,
} from 'lucide-react';
import { authApi } from '../api/authApi';
import { AuthError } from '../types';
import { useTheme } from '../../../core/context/ThemeContext';
import { useLocale } from '../../../core/context/LocaleContext';
import { MahfaztiLogo } from '../../../core/components/ui/MahfaztiLogo';
import { ThreeDotLoader } from '../../../core/components/ui/ThreeDotLoader';
import { AnimatedAuthBackground } from '../../../core/components/ui/AnimatedAuthBackground';

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

export const ResetPasswordPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const emailParam = searchParams.get('email') || '';
  const tokenParam = searchParams.get('token') || '';

  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isSuccess, setIsSuccess] = useState(false);
  const [activeSlide, setActiveSlide] = useState(0);

  const { theme, toggleTheme } = useTheme();
  const { locale, dir, toggleLocale, t } = useLocale();
  const navigate = useNavigate();

  // English-only input restrictions
  const sanitizeEnglish = (val: string) => {
    return val.replace(/[^\x21-\x7E]/g, '');
  };

  const handleEnglishKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key.length !== 1 || e.ctrlKey || e.altKey || e.metaKey) {
      return;
    }
    if (e.key === ' ' || /[^\x20-\x7E]/.test(e.key)) {
      e.preventDefault();
    }
  };

  const currentSlide = t.auth.slides[activeSlide];
  const CardIcon = STATIC_SLIDE_ICONS[activeSlide].cardIcon;
  const CardBadgeIcon = STATIC_SLIDE_ICONS[activeSlide].cardBadgeIcon;
  const Stat1Icon = STATIC_SLIDE_ICONS[activeSlide].stat1Icon;
  const Stat2Icon = STATIC_SLIDE_ICONS[activeSlide].stat2Icon;

  const isInvalidLink = !emailParam.trim() || !tokenParam.trim();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);

    if (newPassword.length < 8) {
      setErrorMessage(t.auth.resetPasswordPage.passwordTooShort);
      return;
    }

    if (newPassword !== confirmPassword) {
      setErrorMessage(t.auth.resetPasswordPage.passwordMismatch);
      return;
    }

    setIsLoading(true);

    try {
      await authApi.resetPassword({
        email: emailParam.trim(),
        token: tokenParam.trim(),
        newPassword,
        confirmPassword,
      });

      setIsSuccess(true);
    } catch (err: unknown) {
      if (err instanceof AuthError) {
        if (err.code === 'ACCESS_DENIED') {
          setErrorMessage(t.auth.errors.accessDenied);
        } else if (err.code === 'NETWORK_ERROR') {
          setErrorMessage(t.auth.errors.networkError);
        } else if (err.code === 'SERVER_ERROR') {
          setErrorMessage(t.auth.errors.serverError);
        } else {
          setErrorMessage(t.auth.errors.resetFailed);
        }
      } else {
        setErrorMessage(t.auth.errors.resetFailed);
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div
      dir={dir}
      className="relative min-h-screen w-full bg-[#f8f9fa] dark:bg-[#000000] text-zinc-900 dark:text-zinc-100 transition-colors duration-200 flex flex-col justify-between overflow-x-hidden select-none selection:bg-zinc-200 dark:selection:bg-zinc-800"
    >
      {/* Dynamic Animated Ambient Background */}
      <AnimatedAuthBackground />

      {/* Top Header */}
      <header className="relative z-10 w-full max-w-7xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between">
        {/* Platform Brand */}
        <div
          onClick={() => navigate('/login')}
          className="flex items-center gap-3 cursor-pointer group select-none"
        >
          <MahfaztiLogo size={36} />
          <div className="text-start">
            <span className="font-extrabold text-lg text-zinc-950 dark:text-white tracking-tight leading-none block">
              Mahfazti
            </span>
            <span className="text-[10px] font-mono tracking-widest text-zinc-600 dark:text-zinc-300 uppercase block mt-1 font-bold">
              Console
            </span>
          </div>
        </div>

        {/* Locale & Theme Controls */}
        <div className="flex items-center gap-2">
          {/* Language Toggle Button */}
          <button
            onClick={toggleLocale}
            type="button"
            title={t.common.switchLanguage}
            aria-label={t.common.switchLanguage}
            className="flex h-9 items-center gap-1.5 px-3 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs active:scale-95"
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
        {/* Showcase Column with 3 Rotating Items (Identical to LoginPage) */}
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

        {/* Right Column: Reset Password Card */}
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

            {/* Case 1: Invalid / Missing Link */}
            {isInvalidLink ? (
              <div className="space-y-5 text-center py-4">
                <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-amber-50 dark:bg-amber-950/40 border border-amber-200 dark:border-amber-900/60 text-amber-600 dark:text-amber-400">
                  <AlertCircle className="h-7 w-7" />
                </div>
                <div className="space-y-2">
                  <h3 className="text-xl font-bold text-zinc-950 dark:text-white">
                    {t.auth.resetPasswordPage.invalidLinkTitle}
                  </h3>
                  <p className="text-xs text-zinc-500 dark:text-zinc-400 leading-relaxed max-w-sm mx-auto">
                    {t.auth.resetPasswordPage.invalidLinkDesc}
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => navigate('/login')}
                  className="w-full h-11 rounded-xl bg-zinc-900 dark:bg-white text-white dark:text-zinc-950 font-bold text-xs hover:bg-zinc-800 dark:hover:bg-zinc-100 transition shadow-sm cursor-pointer flex items-center justify-center gap-2"
                >
                  <span>{t.auth.resetPasswordPage.requestNewLink}</span>
                  {dir === 'rtl' ? <ArrowLeft className="h-4 w-4" /> : <ArrowRight className="h-4 w-4" />}
                </button>
              </div>
            ) : isSuccess ? (
              /* Case 2: Successful Password Reset */
              <div className="space-y-5 text-center py-4">
                <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-emerald-50 dark:bg-emerald-950/40 border border-emerald-200 dark:border-emerald-900/60 text-emerald-600 dark:text-emerald-400">
                  <CheckCircle2 className="h-7 w-7" />
                </div>
                <div className="space-y-2">
                  <h3 className="text-xl font-bold text-zinc-950 dark:text-white">
                    {t.auth.resetPasswordPage.successTitle}
                  </h3>
                  <p className="text-xs text-zinc-500 dark:text-zinc-400 leading-relaxed max-w-sm mx-auto">
                    {t.auth.resetPasswordPage.successDesc}
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => navigate('/login')}
                  className="w-full h-11 rounded-xl bg-zinc-900 dark:bg-white text-white dark:text-zinc-950 font-bold text-xs hover:bg-zinc-800 dark:hover:bg-zinc-100 transition shadow-sm cursor-pointer flex items-center justify-center gap-2"
                >
                  <span>{t.auth.resetPasswordPage.goToLogin}</span>
                  {dir === 'rtl' ? <ArrowLeft className="h-4 w-4" /> : <ArrowRight className="h-4 w-4" />}
                </button>
              </div>
            ) : (
              /* Case 3: Form to Reset Password */
              <>
                {/* Header */}
                <div className="mb-6">
                  <h2 className="text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                    {t.auth.resetPasswordPage.title}
                  </h2>
                  <p className="mt-1.5 text-xs text-zinc-500 dark:text-zinc-400">
                    {t.auth.resetPasswordPage.subtitle}
                  </p>
                </div>

                {/* Account Email Badge */}
                <div className="mb-5 flex items-center gap-2.5 px-3 py-2 rounded-xl bg-zinc-50 dark:bg-zinc-900/60 border border-zinc-200 dark:border-zinc-800 text-xs">
                  <Mail className="h-4 w-4 text-zinc-400 shrink-0" />
                  <div className="truncate">
                    <span className="text-zinc-500 dark:text-zinc-400 block text-[10px]">
                      {t.auth.resetPasswordPage.emailLabel}
                    </span>
                    <span className="font-mono font-semibold text-zinc-900 dark:text-zinc-200 truncate block">
                      {emailParam}
                    </span>
                  </div>
                </div>

                {/* Inline Error Message */}
                {errorMessage && (
                  <div className="mb-4 rounded-xl border border-rose-200 dark:border-rose-900/50 bg-rose-50 dark:bg-rose-950/30 px-3.5 py-2.5 text-xs text-rose-600 dark:text-rose-400 font-medium">
                    {errorMessage}
                  </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-4">
                  {/* New Password Field */}
                  <div className="space-y-1.5 text-start">
                    <label
                      htmlFor="new-password"
                      className="block text-xs font-semibold text-zinc-700 dark:text-zinc-300"
                    >
                      {t.auth.resetPasswordPage.newPasswordLabel}
                    </label>
                    <div className="relative">
                      <div className="absolute inset-y-0 start-0 flex items-center ps-3.5 pointer-events-none text-zinc-400 dark:text-zinc-500">
                        <Lock className="h-4 w-4" />
                      </div>
                      <input
                        id="new-password"
                        type={showNewPassword ? 'text' : 'password'}
                        value={newPassword}
                        onChange={(e) => {
                          setNewPassword(sanitizeEnglish(e.target.value));
                          if (errorMessage) setErrorMessage(null);
                        }}
                        onKeyDown={handleEnglishKeyDown}
                        placeholder={t.auth.resetPasswordPage.newPasswordPlaceholder}
                        required
                        dir="ltr"
                        disabled={isLoading}
                        className="w-full h-11 ps-10 pe-10 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-900 dark:text-white placeholder:text-zinc-400 dark:placeholder:text-zinc-600 text-xs focus:outline-none focus:ring-2 focus:ring-black dark:focus:ring-white transition disabled:opacity-50"
                      />
                      <button
                        type="button"
                        onClick={() => setShowNewPassword(!showNewPassword)}
                        aria-label={showNewPassword ? t.auth.hidePassword : t.auth.showPassword}
                        className="absolute inset-y-0 end-0 flex items-center pe-3 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-300 transition cursor-pointer"
                      >
                        {showNewPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                      </button>
                    </div>
                  </div>

                  {/* Confirm Password Field */}
                  <div className="space-y-1.5 text-start">
                    <label
                      htmlFor="confirm-password"
                      className="block text-xs font-semibold text-zinc-700 dark:text-zinc-300"
                    >
                      {t.auth.resetPasswordPage.confirmPasswordLabel}
                    </label>
                    <div className="relative">
                      <div className="absolute inset-y-0 start-0 flex items-center ps-3.5 pointer-events-none text-zinc-400 dark:text-zinc-500">
                        <KeyRound className="h-4 w-4" />
                      </div>
                      <input
                        id="confirm-password"
                        type={showConfirmPassword ? 'text' : 'password'}
                        value={confirmPassword}
                        onChange={(e) => {
                          setConfirmPassword(sanitizeEnglish(e.target.value));
                          if (errorMessage) setErrorMessage(null);
                        }}
                        onKeyDown={handleEnglishKeyDown}
                        placeholder={t.auth.resetPasswordPage.confirmPasswordPlaceholder}
                        required
                        dir="ltr"
                        disabled={isLoading}
                        className="w-full h-11 ps-10 pe-10 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 text-zinc-900 dark:text-white placeholder:text-zinc-400 dark:placeholder:text-zinc-600 text-xs focus:outline-none focus:ring-2 focus:ring-black dark:focus:ring-white transition disabled:opacity-50"
                      />
                      <button
                        type="button"
                        onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                        aria-label={showConfirmPassword ? t.auth.hidePassword : t.auth.showPassword}
                        className="absolute inset-y-0 end-0 flex items-center pe-3 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-300 transition cursor-pointer"
                      >
                        {showConfirmPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                      </button>
                    </div>
                  </div>

                  {/* Submit Button */}
                  <button
                    type="submit"
                    disabled={isLoading || !newPassword || !confirmPassword}
                    className="w-full h-11 rounded-xl bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 font-bold text-xs hover:bg-zinc-800 dark:hover:bg-zinc-100 transition shadow-sm cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 active:scale-[0.99] mt-2"
                  >
                    {isLoading ? (
                      <ThreeDotLoader size="md" />
                    ) : (
                      <>
                        <span>{t.auth.resetPasswordPage.submitBtn}</span>
                        {dir === 'rtl' ? <ArrowLeft className="h-4 w-4" /> : <ArrowRight className="h-4 w-4" />}
                      </>
                    )}
                  </button>
                </form>

                {/* Back to Login Link */}
                <div className="mt-6 pt-5 border-t border-zinc-100 dark:border-zinc-900 text-center">
                  <button
                    type="button"
                    onClick={() => navigate('/login')}
                    className="inline-flex items-center gap-1.5 text-xs font-semibold text-zinc-500 hover:text-zinc-950 dark:text-zinc-400 dark:hover:text-white transition cursor-pointer"
                  >
                    {dir === 'rtl' ? <ArrowRight className="h-3.5 w-3.5" /> : <ArrowLeft className="h-3.5 w-3.5" />}
                    <span>{t.auth.resetPasswordPage.backToLogin}</span>
                  </button>
                </div>
              </>
            )}

            {/* Security Compliance Footer Notice */}
            <div className="mt-6 pt-5 border-t border-zinc-100 dark:border-zinc-900">
              <div className="flex items-start gap-2.5">
                <ShieldCheck className="h-4 w-4 text-zinc-400 dark:text-zinc-500 shrink-0 mt-0.5" />
                <div>
                  <h4 className="text-[11px] font-bold text-zinc-800 dark:text-zinc-200">
                    {t.auth.securityNoticeTitle}
                  </h4>
                  <p className="text-[10px] text-zinc-500 dark:text-zinc-400 leading-normal mt-0.5">
                    {t.auth.securityNoticeDesc}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </motion.div>
      </main>

      {/* Footer */}
      <footer className="relative z-10 w-full max-w-7xl mx-auto px-4 sm:px-6 py-4 flex flex-col sm:flex-row items-center justify-between gap-2 border-t border-zinc-200/60 dark:border-zinc-800/60 text-xs text-zinc-400 dark:text-zinc-400">
        <p className="text-zinc-500 dark:text-zinc-300 font-medium">
          © {new Date().getFullYear()} Mahfazti Financial Technologies Inc. All rights reserved.
        </p>
        <div className="flex items-center gap-4 text-[11px]">
          <Link to="/privacy" className="hover:text-black dark:hover:text-white transition cursor-pointer">
            {locale === 'ar' ? 'سياسة الخصوصية' : 'Privacy Policy'}
          </Link>
          <Link to="/terms" className="hover:text-black dark:hover:text-white transition cursor-pointer">
            {locale === 'ar' ? 'شروط الخدمة' : 'Terms of Service'}
          </Link>
          <Link to="/help" className="hover:text-black dark:hover:text-white transition cursor-pointer">
            {locale === 'ar' ? 'الدعم الفني' : 'Support'}
          </Link>
        </div>
      </footer>
    </div>
  );
};
