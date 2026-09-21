import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  MoreHorizontal,
  Eye,
  Edit2,
  Copy,
  Shield,
  UserX,
  UserCheck,
  Check,
  Trash2,
} from 'lucide-react';
import { toast } from 'sonner';
import { useLocale } from '../../../core/context/LocaleContext';
import type { UserItem } from '../types';

interface UserActionsMenuProps {
  user: UserItem;
  isOpen: boolean;
  onToggle: () => void;
  onClose: () => void;
  onViewDetails: () => void;
  onEditUser?: () => void;
  onDeleteUser?: () => void;
  onToggleStatus: () => void;
  onChangeRole: (newRole: 'SuperAdmin' | 'Admin' | 'User') => void;
  isCurrentUser?: boolean;
  isNearBottom?: boolean;
}

export const UserActionsMenu: React.FC<UserActionsMenuProps> = ({
  user,
  isOpen,
  onToggle,
  onClose,
  onViewDetails,
  onEditUser,
  onDeleteUser,
  onToggleStatus,
  onChangeRole,
  isCurrentUser = false,
  isNearBottom = false,
}) => {
  const { t, isAr } = useLocale();
  const [copiedEmail, setCopiedEmail] = useState(false);
  const [isRoleSubmenuOpen, setIsRoleSubmenuOpen] = useState(false);

  const handleCopyEmail = (e: React.MouseEvent) => {
    e.stopPropagation();
    navigator.clipboard.writeText(user.email);
    setCopiedEmail(true);
    toast.success(t.users.actionsMenu.copiedToast);
    setTimeout(() => {
      setCopiedEmail(false);
      onClose();
    }, 1200);
  };

  const handleRoleSelect = (e: React.MouseEvent, role: 'SuperAdmin' | 'Admin' | 'User') => {
    e.stopPropagation();
    onChangeRole(role);
    setIsRoleSubmenuOpen(false);
    onClose();
  };

  return (
    <div className="relative inline-block text-start">
      {/* 3-Dots Trigger Button */}
      <button
        type="button"
        onClick={(e) => {
          e.stopPropagation();
          onToggle();
        }}
        title={t.users.actionsMenu.triggerTooltip}
        className={`flex h-8 w-8 items-center justify-center rounded-xl border transition-all ${
          isOpen
            ? 'border-zinc-950 dark:border-white bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
            : 'border-zinc-200 dark:border-zinc-800 bg-zinc-50 hover:bg-zinc-100 dark:bg-zinc-900 dark:hover:bg-zinc-800 text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white'
        }`}
      >
        <MoreHorizontal className="h-4 w-4" />
      </button>

      {/* Floating Dropdown Menu */}
      <AnimatePresence>
        {isOpen && (
          <>
            {/* Transparent backdrop for outside-click dismissal */}
            <div
              className="fixed inset-0 z-30"
              onClick={(e) => {
                e.stopPropagation();
                onClose();
              }}
            />

            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: isNearBottom ? 6 : -6 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: isNearBottom ? 6 : -6 }}
              transition={{ duration: 0.15, ease: 'easeOut' }}
              onClick={(e) => e.stopPropagation()}
              className={`absolute z-40 w-52 rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#18181b] p-1.5 shadow-xl text-zinc-900 dark:text-white ${
                isNearBottom ? 'bottom-full mb-2' : 'top-full mt-2'
              } ${isAr ? 'left-0' : 'right-0'}`}
            >
              {/* Menu Item: View Details */}
              <button
                type="button"
                onClick={() => {
                  onClose();
                  onViewDetails();
                }}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-zinc-700 dark:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800/80 transition-colors"
              >
                <Eye className="h-4 w-4 text-zinc-500 shrink-0" />
                <span>{t.users.actionsMenu.viewDetails}</span>
              </button>

              {/* Menu Item: Edit Profile */}
              {onEditUser && (
                <button
                  type="button"
                  onClick={() => {
                    onClose();
                    onEditUser();
                  }}
                  className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-zinc-700 dark:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800/80 transition-colors"
                >
                  <Edit2 className="h-4 w-4 text-zinc-500 shrink-0" />
                  <span>{t.users.actionsMenu.editProfile}</span>
                </button>
              )}

              {/* Menu Item: Copy Email */}
              <button
                type="button"
                onClick={handleCopyEmail}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-zinc-700 dark:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800/80 transition-colors"
              >
                {copiedEmail ? (
                  <Check className="h-4 w-4 text-emerald-500 shrink-0" />
                ) : (
                  <Copy className="h-4 w-4 text-zinc-500 shrink-0" />
                )}
                <span>{t.users.actionsMenu.copyEmail}</span>
              </button>

              {/* Menu Item: Quick Role Change Sub-trigger */}
              <div className="relative">
                <button
                  type="button"
                  onClick={() => setIsRoleSubmenuOpen(!isRoleSubmenuOpen)}
                  className="w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-semibold text-zinc-700 dark:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800/80 transition-colors"
                >
                  <div className="flex items-center gap-2.5">
                    <Shield className="h-4 w-4 text-zinc-500 shrink-0" />
                    <span>{t.users.actionsMenu.changeRole}</span>
                  </div>
                  <span className="text-[10px] font-mono text-zinc-400 dark:text-zinc-500">
                    {user.role}
                  </span>
                </button>

                {isRoleSubmenuOpen && (
                  <div className="mt-1 p-1 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 space-y-0.5">
                    {(['User', 'Admin', 'SuperAdmin'] as const).map((r) => (
                      <button
                        key={r}
                        type="button"
                        onClick={(e) => handleRoleSelect(e, r)}
                        className={`w-full flex items-center justify-between px-2.5 py-1.5 rounded-lg text-[11px] font-semibold transition-colors ${
                          user.role === r
                            ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950'
                            : 'text-zinc-600 dark:text-zinc-300 hover:bg-zinc-200/60 dark:hover:bg-zinc-800'
                        }`}
                      >
                        <span>{r}</span>
                        {user.role === r && <Check className="h-3 w-3" />}
                      </button>
                    ))}
                  </div>
                )}
              </div>

              {/* Divider */}
              <div className="my-1 border-t border-zinc-100 dark:border-zinc-800/80" />

              {/* Menu Item: Toggle Suspend / Activate */}
              <button
                type="button"
                onClick={() => {
                  onClose();
                  onToggleStatus();
                }}
                className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-bold transition-colors ${
                  user.isActive
                    ? 'text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/40'
                    : 'text-emerald-600 dark:text-emerald-400 hover:bg-emerald-50 dark:hover:bg-emerald-950/40'
                }`}
              >
                {user.isActive ? (
                  <>
                    <UserX className="h-4 w-4 shrink-0" />
                    <span>{t.users.actionsMenu.suspendAccount}</span>
                  </>
                ) : (
                  <>
                    <UserCheck className="h-4 w-4 shrink-0" />
                    <span>{t.users.actionsMenu.activateAccount}</span>
                  </>
                )}
              </button>

              {/* Menu Item: Delete User Permanently */}
              {onDeleteUser && (
                <button
                  type="button"
                  disabled={isCurrentUser}
                  onClick={() => {
                    if (isCurrentUser) return;
                    onClose();
                    onDeleteUser();
                  }}
                  title={isCurrentUser ? t.users.actionsMenu.protectedAccountTooltip : undefined}
                  className={`w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-bold transition-colors ${
                    isCurrentUser
                      ? 'opacity-40 cursor-not-allowed text-zinc-400 dark:text-zinc-600'
                      : 'text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/40'
                  }`}
                >
                  <Trash2 className="h-4 w-4 shrink-0" />
                  <span>
                    {isCurrentUser
                      ? t.users.actionsMenu.protectedAccountLabel
                      : t.users.actionsMenu.deleteAccount}
                  </span>
                </button>
              )}
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
};
