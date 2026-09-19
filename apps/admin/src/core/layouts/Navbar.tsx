import React from 'react';
import { useLocation } from 'react-router-dom';
import {
  Menu,
  Bell,
  Search,
  Sun,
  Moon,
  ChevronRight,
  Command,
  Languages,
} from 'lucide-react';
import { useAuth } from '../../features/auth/context/AuthContext';
import { useTheme } from '../context/ThemeContext';
import { useLocale } from '../context/LocaleContext';

interface NavbarProps {
  onToggleSidebar: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ onToggleSidebar }) => {
  const { user } = useAuth();
  const { theme, toggleTheme } = useTheme();
  const { locale, dir, toggleLocale, t } = useLocale();
  const location = useLocation();

  const currentRoute = t.navbar.routes[location.pathname] || {
    section: t.sidebar.workspaceTitle,
    title: location.pathname.replace('/', '').replace('-', ' ') || t.navbar.routes['/']?.title || 'Dashboard',
  };

  return (
    <header className="sticky top-0 z-30 flex h-16 w-full shrink-0 items-center justify-between border-b border-zinc-200/80 dark:border-zinc-800/80 bg-white/95 dark:bg-[#000000]/95 px-4 sm:px-6 lg:px-8 backdrop-blur-md transition-colors">
      {/* Start: Mobile Toggle & Breadcrumbs */}
      <div className="flex items-center gap-3 md:gap-4 min-w-0">
        <button
          onClick={onToggleSidebar}
          aria-label="Toggle navigation sidebar"
          className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 lg:hidden cursor-pointer hover:bg-zinc-100 dark:hover:bg-zinc-800 transition"
        >
          <Menu className="h-4.5 w-4.5" />
        </button>

        {/* Dynamic Breadcrumbs */}
        <div className="flex items-center gap-1.5 sm:gap-2 text-xs font-medium text-zinc-500 dark:text-zinc-400 truncate">
          <span className="hidden sm:inline font-medium text-zinc-400 dark:text-zinc-500">
            {currentRoute.section}
          </span>
          <ChevronRight className={`hidden sm:inline h-3.5 w-3.5 text-zinc-300 dark:text-zinc-700 ${dir === 'rtl' ? 'rotate-180' : ''}`} />
          <span className="font-bold text-black dark:text-white truncate">
            {currentRoute.title}
          </span>
        </div>
      </div>

      {/* End: Search, Language Switcher, Theme Switcher, Notifications & User */}
      <div className="flex items-center gap-2 sm:gap-2.5">
        {/* Search */}
        <div className="relative hidden md:flex items-center w-64 lg:w-80 2xl:w-96">
          <Search className={`absolute top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-zinc-400 dark:text-zinc-500 pointer-events-none ${
            dir === 'rtl' ? 'right-3.5' : 'left-3.5'
          }`} />
          <input
            type="text"
            placeholder={t.navbar.searchPlaceholder}
            className={`w-full rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50 dark:bg-zinc-900 py-1.5 text-xs font-medium text-black dark:text-white placeholder-zinc-400 dark:placeholder-zinc-500 focus:border-black dark:focus:border-white focus:bg-white dark:focus:bg-black focus:outline-none transition shadow-2xs ${
              dir === 'rtl' ? 'pr-9 pl-12 text-right' : 'pl-9 pr-12 text-left'
            }`}
          />
          <div className={`absolute top-1/2 -translate-y-1/2 flex items-center gap-0.5 rounded px-1.5 py-0.5 bg-zinc-200/60 dark:bg-zinc-800 border border-zinc-300/50 dark:border-zinc-700/50 text-[10px] font-mono text-zinc-500 dark:text-zinc-400 pointer-events-none ${
            dir === 'rtl' ? 'left-2.5' : 'right-2.5'
          }`}>
            <Command className="h-2.5 w-2.5" />
            <span>{t.navbar.searchShortcut}</span>
          </div>
        </div>

        {/* Language Switcher */}
        <button
          onClick={toggleLocale}
          title={t.common.switchLanguage}
          aria-label="Toggle language"
          className="flex h-9 items-center gap-1.5 px-2.5 rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs font-semibold text-xs active:scale-95"
        >
          <Languages className="h-3.5 w-3.5" />
          <span className="font-mono text-[11px] font-bold">{locale === 'en' ? 'AR' : 'EN'}</span>
        </button>

        {/* Theme Toggle Button */}
        <button
          onClick={toggleTheme}
          title={theme === 'dark' ? t.common.lightMode : t.common.darkMode}
          aria-label={t.common.toggleTheme}
          className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs active:scale-95"
        >
          {theme === 'dark' ? (
            <Sun className="h-4 w-4 text-white animate-in spin-in-180 duration-300" />
          ) : (
            <Moon className="h-4 w-4 text-black animate-in spin-in-180 duration-300" />
          )}
        </button>

        {/* Notification Bell */}
        <button
          title={t.navbar.notificationsTooltip}
          aria-label={t.navbar.notificationsTooltip}
          className="relative flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs"
        >
          <Bell className="h-4 w-4" />
          <span className={`absolute top-2 h-2 w-2 rounded-full bg-black dark:bg-white ring-2 ring-white dark:ring-black ${
            dir === 'rtl' ? 'left-2' : 'right-2'
          }`} />
        </button>

        {/* User Pill Badge */}
        <div className={`flex items-center gap-2 rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50 dark:bg-zinc-900 py-1 shadow-2xs ${
          dir === 'rtl' ? 'pr-1 pl-3' : 'pl-1 pr-3'
        }`}>
          <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-black text-white dark:bg-zinc-800 dark:text-white text-xs font-bold shadow-xs shrink-0">
            {user?.fullName?.charAt(0) || 'M'}
          </div>
          <div className="hidden sm:block text-start">
            <span className="block text-xs font-bold text-black dark:text-white leading-tight truncate">
              {user?.fullName || 'Mohamed Gasser'}
            </span>
            <span className="block text-[10px] text-zinc-400 font-mono -mt-0.5 truncate">
              {t.navbar.superAdmin}
            </span>
          </div>
        </div>
      </div>
    </header>
  );
};
