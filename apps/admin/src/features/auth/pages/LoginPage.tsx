import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Wallet2, Lock, Mail, ArrowRight, ShieldCheck, Sun, Moon } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../../../core/context/ThemeContext';
import { Button } from '../../../core/components/ui/Button';

export const LoginPage: React.FC = () => {
  const [email, setEmail] = useState('admin@mahfazti.app');
  const [password, setPassword] = useState('password123');
  const { login } = useAuth();
  const { theme, toggleTheme } = useTheme();
  const navigate = useNavigate();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    login(email, password);
    navigate('/');
  };

  return (
    <div className="relative flex min-h-screen items-center justify-center bg-slate-50 dark:bg-slate-950 p-4 transition-colors">
      {/* Theme Switcher in Corner */}
      <button
        onClick={toggleTheme}
        className="absolute top-6 right-6 flex h-10 w-10 items-center justify-center rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 text-slate-600 dark:text-amber-400 shadow-sm hover:bg-slate-100 dark:hover:bg-slate-800 cursor-pointer transition"
      >
        {theme === 'dark' ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5 text-slate-700" />}
      </button>

      <div className="w-full max-w-md overflow-hidden rounded-3xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900/90 p-8 shadow-xl dark:shadow-2xl backdrop-blur-xl">
        {/* Brand Header */}
        <div className="mb-8 text-center">
          <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-blue-600 shadow-lg shadow-blue-600/30">
            <Wallet2 className="h-7 w-7 text-white" />
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">Mahfazti Admin</h1>
          <p className="mt-1 text-sm text-slate-500 dark:text-slate-400">Management & Control Portal</p>
        </div>

        {/* Mock Dev Mode Notice */}
        <div className="mb-6 flex items-center gap-2.5 rounded-xl border border-blue-500/20 bg-blue-50 dark:bg-blue-600/10 p-3.5 text-xs text-blue-700 dark:text-blue-300">
          <ShieldCheck className="h-4 w-4 shrink-0 text-blue-600 dark:text-blue-400" />
          <span>Dev Mode: Click Sign In below to access the dashboard directly.</span>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-slate-700 dark:text-slate-300">
              Admin Email
            </label>
            <div className="relative">
              <Mail className="absolute top-1/2 left-3.5 h-4.5 w-4.5 -translate-y-1/2 text-slate-400 dark:text-slate-500" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@mahfazti.app"
                className="w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/80 py-2.5 pr-4 pl-10 text-sm text-slate-900 dark:text-white placeholder-slate-400 dark:placeholder-slate-500 transition focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20"
              />
            </div>
          </div>

          <div>
            <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-slate-700 dark:text-slate-300">
              Password
            </label>
            <div className="relative">
              <Lock className="absolute top-1/2 left-3.5 h-4.5 w-4.5 -translate-y-1/2 text-slate-400 dark:text-slate-500" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/80 py-2.5 pr-4 pl-10 text-sm text-slate-900 dark:text-white placeholder-slate-400 dark:placeholder-slate-500 transition focus:border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-600/20"
              />
            </div>
          </div>

          <Button type="submit" size="lg" className="w-full mt-2 bg-blue-600 hover:bg-blue-500 shadow-blue-600/25">
            <span>Sign In to Dashboard</span>
            <ArrowRight className="h-4 w-4" />
          </Button>
        </form>

        <div className="mt-8 text-center text-xs text-slate-400 dark:text-slate-500">
          Mahfazti Management Portal &copy; {new Date().getFullYear()}
        </div>
      </div>
    </div>
  );
};
