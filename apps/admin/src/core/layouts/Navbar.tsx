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
} from 'lucide-react';
import { useAuth } from '../../features/auth/context/AuthContext';
import { useTheme } from '../context/ThemeContext';

interface NavbarProps {
  onToggleSidebar: () => void;
}

const routeNames: Record<string, { section: string; title: string }> = {
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
};

export const Navbar: React.FC<NavbarProps> = ({ onToggleSidebar }) => {
  const { user } = useAuth();
  const { theme, toggleTheme } = useTheme();
  const location = useLocation();

  const currentRoute = routeNames[location.pathname] || {
    section: 'Admin',
    title: location.pathname.replace('/', '').replace('-', ' ') || 'Dashboard',
  };

  return (
    <header className="sticky top-0 z-30 flex h-16 w-full shrink-0 items-center justify-between border-b border-zinc-200/80 dark:border-zinc-800/80 bg-white/95 dark:bg-[#000000]/95 px-4 sm:px-6 lg:px-8 backdrop-blur-md transition-colors">
      {/* Left: Mobile Toggle & Breadcrumbs */}
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
          <ChevronRight className="hidden sm:inline h-3.5 w-3.5 text-zinc-300 dark:text-zinc-700" />
          <span className="font-bold text-black dark:text-white truncate">
            {currentRoute.title}
          </span>
        </div>
      </div>

      {/* Right: Search, Live Status, Theme Switcher & User */}
      <div className="flex items-center gap-2.5 sm:gap-3">
        {/* Search */}
        <div className="relative hidden md:flex items-center w-64 lg:w-80 2xl:w-96">
          <Search className="absolute left-3.5 h-3.5 w-3.5 text-zinc-400 dark:text-zinc-500 pointer-events-none" />
          <input
            type="text"
            placeholder="Search anything (users, txs, logs)..."
            className="w-full rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50 dark:bg-zinc-900 py-1.5 pr-12 pl-9 text-xs font-medium text-black dark:text-white placeholder-zinc-400 dark:placeholder-zinc-500 focus:border-black dark:focus:border-white focus:bg-white dark:focus:bg-black focus:outline-none transition shadow-2xs"
          />
          <div className="absolute right-2.5 flex items-center gap-0.5 rounded px-1.5 py-0.5 bg-zinc-200/60 dark:bg-zinc-800 border border-zinc-300/50 dark:border-zinc-700/50 text-[10px] font-mono text-zinc-500 dark:text-zinc-400">
            <Command className="h-2.5 w-2.5" />
            <span>K</span>
          </div>
        </div>

        {/* Theme Toggle Button */}
        <button
          onClick={toggleTheme}
          title={theme === 'dark' ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
          className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs"
        >
          {theme === 'dark' ? (
            <Sun className="h-4 w-4 text-white animate-in spin-in-180 duration-300" />
          ) : (
            <Moon className="h-4 w-4 text-black animate-in spin-in-180 duration-300" />
          )}
        </button>

        {/* Notification Bell */}
        <button
          title="Notifications"
          className="relative flex h-9 w-9 shrink-0 items-center justify-center rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white transition cursor-pointer shadow-2xs"
        >
          <Bell className="h-4 w-4" />
          <span className="absolute top-2 right-2 h-2 w-2 rounded-full bg-black dark:bg-white ring-2 ring-white dark:ring-black" />
        </button>

        {/* User Pill Badge */}
        <div className="flex items-center gap-2 rounded-xl border border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50 dark:bg-zinc-900 py-1 pr-3 pl-1 shadow-2xs">
          <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-black text-white dark:bg-zinc-800 dark:text-white text-xs font-bold shadow-xs">
            {user?.fullName?.charAt(0) || 'M'}
          </div>
          <div className="hidden sm:block text-left">
            <span className="block text-xs font-bold text-black dark:text-white leading-tight">
              {user?.fullName || 'Mohamed Gasser'}
            </span>
            <span className="block text-[10px] text-zinc-400 font-mono -mt-0.5">
              Super Admin
            </span>
          </div>
        </div>
      </div>
    </header>
  );
};
