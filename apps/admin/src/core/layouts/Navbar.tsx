import React from 'react';
import { Menu, Bell, Search, Sun, Moon } from 'lucide-react';
import { useAuth } from '../../features/auth/context/AuthContext';
import { useTheme } from '../context/ThemeContext';

interface NavbarProps {
  onToggleSidebar: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ onToggleSidebar }) => {
  const { user } = useAuth();
  const { theme, toggleTheme } = useTheme();

  return (
    <header className="sticky top-0 z-30 flex h-16 w-full items-center justify-between border-b border-zinc-100 dark:border-zinc-900 bg-white/80 dark:bg-black/80 px-6 backdrop-blur-md transition-colors">
      <div className="flex items-center gap-3">
        <button
          onClick={onToggleSidebar}
          className="flex h-9 w-9 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 lg:hidden cursor-pointer"
        >
          <Menu className="h-4.5 w-4.5" />
        </button>

        {/* Search Bar */}
        <div className="relative hidden md:block w-72">
          <Search className="absolute top-1/2 left-3.5 h-3.5 w-3.5 -translate-y-1/2 text-zinc-400 dark:text-zinc-500" />
          <input
            type="text"
            placeholder="Search transactions, users..."
            className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 py-1.5 pr-4 pl-9 text-xs font-medium text-black dark:text-white placeholder-zinc-400 dark:placeholder-zinc-500 focus:border-black dark:focus:border-white focus:outline-none transition"
          />
        </div>
      </div>

      <div className="flex items-center gap-2.5">
        {/* Theme Switcher Button */}
        <button
          onClick={toggleTheme}
          title={theme === 'dark' ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
          className="flex h-8.5 w-8.5 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition cursor-pointer shadow-xs"
        >
          {theme === 'dark' ? (
            <Sun className="h-4 w-4 text-amber-400 animate-in spin-in-180 duration-300" />
          ) : (
            <Moon className="h-4 w-4 text-zinc-800 animate-in spin-in-180 duration-300" />
          )}
        </button>

        {/* Notification Bell */}
        <button className="relative flex h-8.5 w-8.5 items-center justify-center rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition cursor-pointer">
          <Bell className="h-4 w-4" />
          <span className="absolute top-2 right-2 h-1.5 w-1.5 rounded-full bg-emerald-500 ring-2 ring-white dark:ring-black" />
        </button>

        {/* Profile Pill Badge */}
        <div className="flex items-center gap-2.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 py-1 pr-3 pl-1 shadow-xs">
          <div className="flex h-6.5 w-6.5 items-center justify-center rounded-lg bg-black dark:bg-white text-[11px] font-bold text-white dark:text-black">
            {user?.fullName?.charAt(0) || 'A'}
          </div>
          <div className="hidden sm:block text-left">
            <span className="block text-xs font-bold text-black dark:text-white leading-tight">
              {user?.fullName || 'Admin'}
            </span>
          </div>
        </div>
      </div>
    </header>
  );
};
