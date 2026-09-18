import React, { useState } from 'react';
import { Save, Shield, Key, Check } from 'lucide-react';
import { useAuth } from '../../auth/context/AuthContext';
import { Card } from '../../../core/components/ui/Card';
import { Button } from '../../../core/components/ui/Button';

export const SettingsPage: React.FC = () => {
  const { user } = useAuth();
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">Admin Settings</h1>
        <p className="text-sm text-slate-500 dark:text-slate-400">
          Configure security policies, API connections, and notification preferences.
        </p>
      </div>

      <form onSubmit={handleSave} className="space-y-6">
        {/* Profile Card */}
        <Card className="space-y-4 p-6">
          <div className="flex items-center gap-3 border-b border-slate-100 dark:border-slate-800 pb-4">
            <Shield className="h-5 w-5 text-blue-600 dark:text-blue-400" />
            <div>
              <h2 className="text-base font-bold text-slate-900 dark:text-white">Admin Profile</h2>
              <p className="text-xs text-slate-500 dark:text-slate-400">Account identity and administrator role</p>
            </div>
          </div>

          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider text-slate-700 dark:text-slate-300 mb-1.5">
                Full Name
              </label>
              <input
                type="text"
                defaultValue={user?.fullName || 'Administrator'}
                className="w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/80 px-3.5 py-2.5 text-sm text-slate-900 dark:text-white focus:border-blue-600 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider text-slate-700 dark:text-slate-300 mb-1.5">
                Email Address
              </label>
              <input
                type="email"
                disabled
                defaultValue={user?.email || 'admin@mahfazti.app'}
                className="w-full rounded-xl border border-slate-200 dark:border-slate-800 bg-slate-100 dark:bg-slate-900 px-3.5 py-2.5 text-sm text-slate-500 cursor-not-allowed"
              />
            </div>
          </div>
        </Card>

        {/* Security & Token Settings */}
        <Card className="space-y-4 p-6">
          <div className="flex items-center gap-3 border-b border-slate-100 dark:border-slate-800 pb-4">
            <Key className="h-5 w-5 text-blue-600 dark:text-blue-400" />
            <div>
              <h2 className="text-base font-bold text-slate-900 dark:text-white">Security & Tokens</h2>
              <p className="text-xs text-slate-500 dark:text-slate-400">JWT validity, refresh token policies, and session timeout</p>
            </div>
          </div>

          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider text-slate-700 dark:text-slate-300 mb-1.5">
                Access Token Lifetime
              </label>
              <select className="w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/80 px-3.5 py-2.5 text-sm text-slate-800 dark:text-slate-200 focus:border-blue-600 focus:outline-none">
                <option value="60">60 Minutes (Default)</option>
                <option value="120">2 Hours</option>
                <option value="1440">24 Hours</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider text-slate-700 dark:text-slate-300 mb-1.5">
                Refresh Token Lifetime
              </label>
              <select className="w-full rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/80 px-3.5 py-2.5 text-sm text-slate-800 dark:text-slate-200 focus:border-blue-600 focus:outline-none">
                <option value="7">7 Days (Default)</option>
                <option value="30">30 Days</option>
                <option value="90">90 Days</option>
              </select>
            </div>
          </div>
        </Card>

        {/* Save Button */}
        <div className="flex items-center justify-end gap-3">
          {saved && (
            <span className="flex items-center gap-1.5 text-xs font-semibold text-emerald-600 dark:text-emerald-400">
              <Check className="h-4 w-4" />
              Settings saved successfully
            </span>
          )}
          <Button type="submit">
            <Save className="h-4 w-4" />
            <span>Save Changes</span>
          </Button>
        </div>
      </form>
    </div>
  );
};
