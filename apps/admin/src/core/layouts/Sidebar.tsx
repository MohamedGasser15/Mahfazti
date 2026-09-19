import React, { useState, useEffect } from 'react';
import { NavLink, useLocation, useNavigate } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  Layers,
  ArrowLeftRight,
  LogOut,
  CreditCard,
  Bell,
  ChevronDown,
  Activity,
} from 'lucide-react';
import { useAuth } from '../../features/auth/context/AuthContext';
import { useLocale } from '../context/LocaleContext';
import { MahfaztiLogo } from '../components/ui/MahfaztiLogo';
import { toast } from 'sonner';

interface SidebarProps {
  isOpen: boolean;
  onClose?: () => void;
}

interface NavChild {
  label: string;
  path: string;
  badge?: string;
}

interface NavGroup {
  id: string;
  label: string;
  icon: React.ElementType;
  children: NavChild[];
}

export const Sidebar: React.FC<SidebarProps> = ({ isOpen, onClose }) => {
  const { logout, user } = useAuth();
  const { dir, t } = useLocale();
  const navigate = useNavigate();
  const location = useLocation();

  const navGroups: NavGroup[] = [
    {
      id: 'finance',
      label: t.sidebar.groups.finance.label,
      icon: ArrowLeftRight,
      children: [
        { label: t.sidebar.groups.finance.transactions, path: '/transactions' },
        { label: t.sidebar.groups.finance.currencies, path: '/currencies' },
      ],
    },
    {
      id: 'users',
      label: t.sidebar.groups.users.label,
      icon: Users,
      children: [
        { label: t.sidebar.groups.users.directory, path: '/users' },
        { label: t.sidebar.groups.users.roles, path: '/roles', badge: 'RBAC' },
      ],
    },
    {
      id: 'monetization',
      label: t.sidebar.groups.monetization.label,
      icon: CreditCard,
      children: [
        { label: t.sidebar.groups.monetization.subscriptions, path: '/subscriptions', badge: 'MRR' },
        { label: t.sidebar.groups.monetization.plans, path: '/plans' },
        { label: t.sidebar.groups.monetization.payments, path: '/payments' },
        { label: t.sidebar.groups.monetization.promoCodes, path: '/promo-codes' },
      ],
    },
    {
      id: 'engagement',
      label: t.sidebar.groups.engagement.label,
      icon: Bell,
      children: [
        { label: t.sidebar.groups.engagement.notifications, path: '/notifications' },
        { label: t.sidebar.groups.engagement.support, path: '/support', badge: '3 Open' },
      ],
    },
    {
      id: 'system',
      label: t.sidebar.groups.system.label,
      icon: Layers,
      children: [
        { label: t.sidebar.groups.system.aiLogs, path: '/ai-logs', badge: 'Live' },
        { label: t.sidebar.groups.system.categories, path: '/categories' },
        { label: t.sidebar.groups.system.auditLogs, path: '/audit-logs' },
      ],
    },
    {
      id: 'dev_ops',
      label: t.sidebar.groups.devOps.label,
      icon: Activity,
      children: [
        { label: t.sidebar.groups.devOps.webhooks, path: '/webhooks' },
        { label: t.sidebar.groups.devOps.health, path: '/health' },
        { label: t.sidebar.groups.devOps.settings, path: '/settings' },
      ],
    },
  ];

  const getInitialOpenState = () => ({
    finance: true,
    users: true,
    monetization: true,
    engagement: true,
    system: true,
    dev_ops: true,
  });

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
    toast.info(t.sidebar.signedOutToast);
    navigate('/login');
  };

  const handleNavClick = () => {
    if (window.innerWidth < 1024 && onClose) {
      onClose();
    }
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

      {/* Dynamic Sidebar: 100% Height Locked with Pinned Header & Footer */}
      <aside
        className={`fixed top-0 z-50 flex h-screen max-h-screen w-64 lg:w-72 2xl:w-80 shrink-0 flex-col overflow-hidden bg-white dark:bg-[#000000] text-zinc-900 dark:text-white transition-transform duration-200 lg:static lg:translate-x-0 select-none shadow-xs ${
          dir === 'rtl'
            ? 'right-0 border-l border-zinc-200/80 dark:border-zinc-800/80'
            : 'left-0 border-r border-zinc-200/80 dark:border-zinc-800/80'
        } ${
          isOpen
            ? 'translate-x-0'
            : dir === 'rtl'
              ? 'translate-x-full lg:translate-x-0'
              : '-translate-x-full lg:translate-x-0'
        }`}
      >
        {/* Tier 1: Pinned Workspace Brand Header */}
        <div className="shrink-0 p-3 lg:p-4 pb-2 border-b border-zinc-100/90 dark:border-zinc-900/90">
          <div className="flex items-center gap-3 rounded-2xl bg-zinc-50/95 dark:bg-zinc-900/70 border border-zinc-200/80 dark:border-zinc-800/80 p-3 shadow-2xs">
            <MahfaztiLogo size={40} className="shadow-xs shrink-0" />
            <div className="flex flex-col min-w-0 text-start">
              <span className="text-sm font-extrabold text-zinc-950 dark:text-white truncate leading-tight tracking-tight">
                {t.sidebar.workspaceTitle}
              </span>
              <span className="text-[11px] text-zinc-500 dark:text-zinc-400 font-medium truncate mt-0.5">
                {t.sidebar.workspaceSubtitle}
              </span>
            </div>
          </div>
        </div>

        {/* Tier 2: Scrollable Navigation List (Strictly Bounded) */}
        <div className="flex-1 min-h-0 overflow-y-auto overscroll-y-contain p-3 lg:p-4 space-y-1">
          {/* Overview Direct Link */}
          <NavLink
            to="/"
            end
            onClick={handleNavClick}
            className={({ isActive }) =>
              `group flex items-center justify-between rounded-xl px-3 py-2 text-xs font-semibold select-none cursor-pointer border ${
                isActive
                  ? 'bg-black text-white border-black dark:bg-zinc-800 dark:text-white dark:border-zinc-700/60 shadow-xs'
                  : 'border-transparent text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-900 hover:text-black dark:hover:text-white'
              }`
            }
          >
            <div className="flex items-center gap-3">
              <LayoutDashboard className="h-4 w-4 shrink-0" />
              <span>{t.sidebar.overview}</span>
            </div>
          </NavLink>

          <div className="pt-3 pb-1">
            <p className="px-3 text-[10px] font-bold uppercase tracking-wider text-zinc-400 dark:text-zinc-500 text-start">
              {t.sidebar.modulesTitle}
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
                  className={`group flex w-full items-center justify-between rounded-xl px-3 py-2 text-xs font-semibold select-none cursor-pointer border border-transparent ${
                    isAnyChildActive
                      ? 'text-black dark:text-white font-bold'
                      : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-900 hover:text-black dark:hover:text-white'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <Icon
                      className={`h-4 w-4 shrink-0 ${
                        isAnyChildActive
                          ? 'text-black dark:text-white'
                          : 'text-zinc-400 dark:text-zinc-500 group-hover:text-zinc-700 dark:group-hover:text-zinc-300'
                      }`}
                    />
                    <span>{group.label}</span>
                  </div>
                  <ChevronDown
                    className={`h-3.5 w-3.5 text-zinc-400 dark:text-zinc-500 transition-transform duration-200 ${
                      isExpanded
                        ? 'rotate-0'
                        : dir === 'rtl'
                          ? 'rotate-90 opacity-60'
                          : '-rotate-90 opacity-60'
                    }`}
                  />
                </button>

                {/* Dropdown Children Rail */}
                {isExpanded && (
                  <div
                    className={`relative space-y-1 py-1 ${
                      dir === 'rtl'
                        ? 'mr-4 pr-3.5 before:absolute before:right-0 before:top-1 before:bottom-1 before:w-[1px] before:bg-zinc-200/60 dark:before:bg-zinc-800/60'
                        : 'ml-4 pl-3.5 before:absolute before:left-0 before:top-1 before:bottom-1 before:w-[1px] before:bg-zinc-200/60 dark:before:bg-zinc-800/60'
                    }`}
                  >
                    {group.children.map((child) => (
                      <NavLink
                        key={child.path}
                        to={child.path}
                        onClick={handleNavClick}
                        className={({ isActive }) =>
                          `group flex items-center justify-between rounded-xl px-2.5 py-1.5 text-xs font-medium select-none cursor-pointer transition-colors duration-150 ${
                            isActive
                              ? 'bg-zinc-200/70 text-black font-bold dark:bg-zinc-800/90 dark:text-white shadow-2xs'
                              : 'text-zinc-500 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-900 hover:text-zinc-900 dark:hover:text-zinc-200'
                          }`
                        }
                      >
                        {({ isActive }) => (
                          <>
                            <span className="truncate">{child.label}</span>

                            {child.badge && (
                              <span
                                className={`text-[10px] font-mono font-semibold px-1.5 py-0.5 rounded-md ${
                                  isActive
                                    ? 'bg-black text-white dark:bg-white dark:text-black'
                                    : 'bg-zinc-100 text-zinc-600 dark:bg-zinc-800 dark:text-zinc-400'
                                }`}
                              >
                                {child.badge}
                              </span>
                            )}
                          </>
                        )}
                      </NavLink>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* Tier 3: Pinned User Footer Profile (Never scrolls or shifts) */}
        <div className="shrink-0 p-3 lg:p-4 border-t border-zinc-100/90 dark:border-zinc-900/90 bg-white dark:bg-[#000000]">
          <div className="flex items-center justify-between rounded-2xl bg-zinc-50/95 dark:bg-zinc-900/70 border border-zinc-200/80 dark:border-zinc-800/80 p-3 shadow-2xs">
            <div className="flex items-center gap-3 overflow-hidden">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-black text-white dark:bg-zinc-800 dark:text-white text-sm font-bold border border-zinc-700/60 shadow-xs">
                {user?.fullName?.charAt(0) || 'M'}
              </div>
              <div className="overflow-hidden text-start">
                <p className="truncate text-sm font-bold text-zinc-950 dark:text-white leading-tight">
                  {user?.fullName || 'Mohamed Gasser'}
                </p>
                <p className="truncate text-[11px] text-zinc-500 dark:text-zinc-400 font-mono mt-0.5">
                  {user?.email || 'admin@mahfazti.app'}
                </p>
              </div>
            </div>

            <button
              onClick={handleLogout}
              title={t.sidebar.signOutTooltip}
              aria-label={t.sidebar.signOutTooltip}
              className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg text-zinc-400 hover:text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/40 transition-colors duration-150 cursor-pointer"
            >
              <LogOut className={`h-4 w-4 ${dir === 'rtl' ? 'rotate-180' : ''}`} />
            </button>
          </div>
        </div>
      </aside>
    </>
  );
};
