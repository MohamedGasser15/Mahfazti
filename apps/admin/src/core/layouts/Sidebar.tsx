import React, { useState, useEffect } from 'react';
import { NavLink, useLocation, useNavigate } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  Layers,
  ArrowLeftRight,
  LogOut,
  Wallet,
  CreditCard,
  Bell,
  ChevronDown,
  Activity,
} from 'lucide-react';
import { useAuth } from '../../features/auth/context/AuthContext';

interface SidebarProps {
  isOpen: boolean;
  onClose?: () => void;
}

interface NavChild {
  label: string;
  path: string;
  badge?: string;
  badgeVariant?: 'default' | 'success' | 'warning' | 'info' | 'purple';
}

interface NavGroup {
  id: string;
  label: string;
  icon: React.ElementType;
  children: NavChild[];
}

export const Sidebar: React.FC<SidebarProps> = ({ isOpen, onClose }) => {
  const { logout, user } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const navGroups: NavGroup[] = [
    {
      id: 'finance',
      label: 'Finance & Banking',
      icon: ArrowLeftRight,
      children: [
        { label: 'All Transactions', path: '/transactions' },
        { label: 'Currencies & Rates', path: '/currencies' },
      ],
    },
    {
      id: 'users',
      label: 'Users & Team',
      icon: Users,
      children: [
        { label: 'User Directory', path: '/users' },
        { label: 'Roles & Permissions', path: '/roles', badge: 'RBAC', badgeVariant: 'info' },
      ],
    },
    {
      id: 'monetization',
      label: 'Billing & Plans',
      icon: CreditCard,
      children: [
        { label: 'Subscriptions', path: '/subscriptions', badge: 'MRR', badgeVariant: 'purple' },
        { label: 'Plans & Limits', path: '/plans' },
        { label: 'Payment Logs', path: '/payments' },
        { label: 'Promo Codes', path: '/promo-codes', badge: 'Sale', badgeVariant: 'warning' },
      ],
    },
    {
      id: 'engagement',
      label: 'Engagement & Support',
      icon: Bell,
      children: [
        { label: 'Push Notifications', path: '/notifications', badge: 'FCM', badgeVariant: 'info' },
        { label: 'Support Tickets', path: '/support', badge: '3 Open', badgeVariant: 'success' },
      ],
    },
    {
      id: 'system',
      label: 'System & Intelligence',
      icon: Layers,
      children: [
        { label: 'AI Voice Transcripts', path: '/ai-logs', badge: 'Live', badgeVariant: 'info' },
        { label: 'System Categories', path: '/categories' },
        { label: 'Audit Trail', path: '/audit-logs' },
      ],
    },
    {
      id: 'dev_ops',
      label: 'Developer & Health',
      icon: Activity,
      children: [
        { label: 'Webhooks & Gateways', path: '/webhooks' },
        { label: 'System Status & AI', path: '/health', badge: '99.9%', badgeVariant: 'success' },
        { label: 'General Settings', path: '/settings' },
      ],
    },
  ];

  const getInitialOpenState = () => {
    const state: Record<string, boolean> = {
      finance: true,
      users: true,
      monetization: true,
      engagement: true,
      system: true,
      dev_ops: true,
    };
    return state;
  };

  const [expandedGroups, setExpandedGroups] = useState<Record<string, boolean>>(getInitialOpenState);

  useEffect(() => {
    navGroups.forEach((group) => {
      if (
        group.children.some(
          (child) =>
            location.pathname === child.path ||
            (child.path !== '/' && location.pathname.startsWith(child.path))
        )
      ) {
        setExpandedGroups((prev) => ({ ...prev, [group.id]: true }));
      }
    });
  }, [location.pathname]);

  const toggleGroup = (groupId: string) => {
    setExpandedGroups((prev) => ({
      ...prev,
      [groupId]: !prev[groupId],
    }));
  };

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const renderBadge = (badge?: string, variant?: string) => {
    if (!badge) return null;
    let colorClasses = 'bg-zinc-100 text-zinc-600 dark:bg-zinc-800 dark:text-zinc-400';
    if (variant === 'purple')
      colorClasses =
        'bg-purple-50 text-purple-600 dark:bg-purple-950/70 dark:text-purple-300 border border-purple-200/60 dark:border-purple-800/50';
    if (variant === 'warning')
      colorClasses =
        'bg-amber-50 text-amber-600 dark:bg-amber-950/70 dark:text-amber-300 border border-amber-200/60 dark:border-amber-800/50';
    if (variant === 'success')
      colorClasses =
        'bg-emerald-50 text-emerald-600 dark:bg-emerald-950/70 dark:text-emerald-300 border border-emerald-200/60 dark:border-emerald-800/50';
    if (variant === 'info')
      colorClasses =
        'bg-blue-50 text-blue-600 dark:bg-blue-950/70 dark:text-blue-300 border border-blue-200/60 dark:border-blue-800/50';

    return (
      <span
        className={`text-[10px] font-bold px-1.5 py-0.5 rounded-md leading-none shadow-2xs ${colorClasses}`}
      >
        {badge}
      </span>
    );
  };

  return (
    <>
      {/* Mobile Backdrop */}
      {isOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/60 backdrop-blur-xs lg:hidden"
          onClick={onClose}
        />
      )}

      <aside
        className={`fixed top-0 left-0 z-50 flex h-screen w-72 flex-col justify-between border-r border-zinc-200/70 dark:border-zinc-800/80 bg-white dark:bg-[#09090b] transition-transform duration-200 lg:static lg:translate-x-0 select-none shadow-xs ${
          isOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="flex flex-col flex-1 overflow-y-auto no-scrollbar">
          {/* Sleek Brand Header */}
          <div className="flex h-16 shrink-0 items-center justify-between px-4 border-b border-zinc-100 dark:border-zinc-800/70">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-gradient-to-tr from-blue-600 to-blue-400 text-white shadow-sm shadow-blue-500/20">
                <Wallet className="h-5 w-5" />
              </div>
              <div className="flex flex-col">
                <div className="flex items-center gap-1.5">
                  <span className="text-sm font-bold tracking-tight text-zinc-900 dark:text-white">
                    Mahfazti
                  </span>
                  <span className="flex h-1.5 w-1.5 rounded-full bg-emerald-500 ring-2 ring-emerald-500/20" />
                </div>
                <span className="text-[11px] text-zinc-400 dark:text-zinc-500 font-medium">
                  Admin Console
                </span>
              </div>
            </div>

            <span className="text-[10px] font-mono font-semibold px-1.5 py-0.5 rounded bg-zinc-100 dark:bg-zinc-800/90 border border-zinc-200/60 dark:border-zinc-700/60 text-zinc-500 dark:text-zinc-400">
              v1.2
            </span>
          </div>

          {/* Navigation Links */}
          <div className="p-3 space-y-1 flex-1">
            {/* Direct Dashboard Link */}
            <NavLink
              to="/"
              end
              onClick={onClose}
              className={({ isActive }) =>
                `group flex items-center justify-between rounded-xl px-3 py-2.5 text-xs font-semibold transition-all ${
                  isActive
                    ? 'bg-zinc-900 text-white dark:bg-white dark:text-zinc-950 shadow-xs'
                    : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100/80 dark:hover:bg-zinc-800/60 hover:text-zinc-900 dark:hover:text-white'
                }`
              }
            >
              <div className="flex items-center gap-3">
                <LayoutDashboard className="h-4 w-4 shrink-0 transition-transform group-hover:scale-105" />
                <span>Overview Dashboard</span>
              </div>
              <span className="text-[10px] font-bold px-1.5 py-0.5 rounded bg-zinc-200/60 dark:bg-zinc-800 text-zinc-500 dark:text-zinc-400">
                Live
              </span>
            </NavLink>

            <div className="pt-3 pb-1">
              <p className="px-3 text-[10px] font-bold uppercase tracking-wider text-zinc-400 dark:text-zinc-500">
                Operations & Management
              </p>
            </div>

            {/* Collapsible Dropdown Groups */}
            {navGroups.map((group) => {
              const Icon = group.icon;
              const isExpanded = !!expandedGroups[group.id];
              const isAnyChildActive = group.children.some(
                (child) =>
                  location.pathname === child.path ||
                  (child.path !== '/' && location.pathname.startsWith(child.path))
              );

              return (
                <div key={group.id} className="space-y-0.5">
                  {/* Dropdown Header Button */}
                  <button
                    type="button"
                    onClick={() => toggleGroup(group.id)}
                    className={`group flex w-full items-center justify-between rounded-xl px-3 py-2 text-xs font-semibold transition cursor-pointer ${
                      isAnyChildActive
                        ? 'text-blue-600 dark:text-blue-400 bg-blue-50/50 dark:bg-blue-950/20 font-bold'
                        : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100/70 dark:hover:bg-zinc-800/40 hover:text-zinc-900 dark:hover:text-zinc-200'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <Icon
                        className={`h-4 w-4 shrink-0 transition-colors ${
                          isAnyChildActive
                            ? 'text-blue-600 dark:text-blue-400'
                            : 'text-zinc-400 group-hover:text-zinc-600 dark:group-hover:text-zinc-300'
                        }`}
                      />
                      <span>{group.label}</span>
                    </div>
                    <ChevronDown
                      className={`h-3.5 w-3.5 text-zinc-400 transition-transform duration-200 ${
                        isExpanded ? 'rotate-0' : '-rotate-90 opacity-60'
                      }`}
                    />
                  </button>

                  {/* Dropdown Menu Items */}
                  {isExpanded && (
                    <div className="ml-4 pl-3.5 border-l border-zinc-200/80 dark:border-zinc-800/90 space-y-0.5 py-1">
                      {group.children.map((child) => (
                        <NavLink
                          key={child.path}
                          to={child.path}
                          onClick={onClose}
                          className={({ isActive }) =>
                            `flex items-center justify-between rounded-lg px-2.5 py-1.5 text-xs transition-all ${
                              isActive
                                ? 'bg-zinc-900 text-white dark:bg-white dark:text-black font-semibold shadow-xs'
                                : 'text-zinc-500 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800/60 hover:text-zinc-900 dark:hover:text-zinc-100 font-medium'
                            }`
                          }
                        >
                          <span className="truncate">{child.label}</span>
                          {child.badge && renderBadge(child.badge, child.badgeVariant)}
                        </NavLink>
                      ))}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* User Footer Profile */}
        <div className="p-3 border-t border-zinc-100 dark:border-zinc-800/70 shrink-0">
          <div className="flex items-center justify-between rounded-xl bg-zinc-50/80 dark:bg-zinc-900/60 border border-zinc-200/60 dark:border-zinc-800/60 p-2.5">
            <div className="flex items-center gap-2.5 overflow-hidden">
              <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-blue-600 text-xs font-bold text-white shadow-xs">
                {user?.fullName?.charAt(0) || 'A'}
              </div>
              <div className="overflow-hidden">
                <div className="flex items-center gap-1.5">
                  <p className="truncate text-xs font-bold text-zinc-900 dark:text-zinc-100 leading-tight">
                    {user?.fullName || 'Mohamed Gasser'}
                  </p>
                  <span className="text-[9px] font-bold px-1 rounded bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-300">
                    Admin
                  </span>
                </div>
                <p className="truncate text-[10px] text-zinc-400 dark:text-zinc-500 font-mono">
                  {user?.email || 'admin@mahfazti.app'}
                </p>
              </div>
            </div>

            <button
              onClick={handleLogout}
              title="Sign Out"
              className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg text-zinc-400 hover:text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 transition cursor-pointer"
            >
              <LogOut className="h-4 w-4" />
            </button>
          </div>
        </div>
      </aside>
    </>
  );
};
