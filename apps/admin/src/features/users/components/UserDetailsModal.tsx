import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  X,
  Edit2,
  Shield,
  UserCheck,
  UserX,
  Mail,
  Wallet,
  Calendar,
  Clock,
  Coins,
  Copy,
  Check,
  CheckCircle2,
  AlertCircle,
  Trash2,
} from 'lucide-react';
import { toast } from 'sonner';
import { useLocale } from '../../../core/context/LocaleContext';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatDate } from '../../../core/utils/formatters';
import type { UserItem } from '../types';

interface UserDetailsModalProps {
  user: UserItem | null;
  isOpen: boolean;
  onClose: () => void;
  onToggleStatus: (userId: string) => Promise<void>;
  onChangeRole: (userId: string, role: 'SuperAdmin' | 'Admin' | 'User') => Promise<void>;
  onEdit?: (user: UserItem) => void;
  onDelete?: (user: UserItem) => void;
  isCurrentUser?: boolean;
}

export const UserDetailsModal: React.FC<UserDetailsModalProps> = ({
  user,
  isOpen,
  onClose,
  onToggleStatus,
  onChangeRole,
  onEdit,
  onDelete,
  isCurrentUser = false,
}) => {
  const { t } = useLocale();
  const [copied, setCopied] = useState(false);
  const [isUpdatingStatus, setIsUpdatingStatus] = useState(false);
  const [isUpdatingRole, setIsUpdatingRole] = useState(false);

  if (!isOpen || !user) return null;

  const handleCopyId = () => {
    navigator.clipboard.writeText(user.id);
    setCopied(true);
    toast.success(t.users.detailsModal.idCopiedToast);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleStatusToggle = async () => {
    setIsUpdatingStatus(true);
    try {
      await onToggleStatus(user.id);
      toast.success(
        user.isActive
          ? t.users.toasts.userSuspended
          : t.users.toasts.userActivated
      );
    } catch {
      toast.error(t.users.toasts.statusFailed);
    } finally {
      setIsUpdatingStatus(false);
    }
  };

  const handleRoleChange = async (newRole: 'SuperAdmin' | 'Admin' | 'User') => {
    if (newRole === user.role) return;
    setIsUpdatingRole(true);
    try {
      await onChangeRole(user.id, newRole);
      toast.success(`${t.users.toasts.roleUpdated}: ${newRole}`);
    } catch {
      toast.error(t.users.toasts.statusFailed);
    } finally {
      setIsUpdatingRole(false);
    }
  };

  const getRoleBadgeVariant = (role: string) => {
    switch (role) {
      case 'SuperAdmin':
        return 'purple';
      case 'Admin':
        return 'info';
      default:
        return 'default';
    }
  };

  return (
    <AnimatePresence>
      <motion.div
        key="user-details-modal-backdrop"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.2 }}
        onClick={onClose}
        className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-xs"
      >
        <motion.div
          key="user-details-modal-container"
          initial={{ opacity: 0, scale: 0.94, y: 16 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.94, y: 10 }}
          transition={{ duration: 0.24, ease: [0.16, 1, 0.3, 1] }}
          onClick={(e) => e.stopPropagation()}
          className="relative w-full max-w-2xl rounded-3xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-2xl overflow-hidden text-zinc-900 dark:text-white"
        >
          {/* Header Banner */}
          <div className="relative p-6 border-b border-zinc-200/80 dark:border-zinc-800 bg-zinc-50/70 dark:bg-zinc-900/50 flex items-start justify-between gap-4">
            <div className="flex items-center gap-4">
              <div className="relative flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-zinc-950 dark:bg-zinc-800 text-white font-black text-2xl shadow-md border border-zinc-800">
                {user.fullName.charAt(0).toUpperCase()}
                <span
                  className={`absolute -bottom-1 -right-1 h-4 w-4 rounded-full border-2 border-white dark:border-zinc-900 ${
                    user.isActive ? 'bg-emerald-500' : 'bg-rose-500'
                  }`}
                />
              </div>
              <div>
                <div className="flex items-center gap-2 flex-wrap">
                  <h2 className="text-xl font-bold tracking-tight text-zinc-950 dark:text-white">
                    {user.fullName}
                  </h2>
                  <Badge variant={getRoleBadgeVariant(user.role)} className="gap-1 font-semibold">
                    {user.role === 'SuperAdmin' && <Shield className="h-3 w-3" />}
                    {user.role}
                  </Badge>
                </div>
                <div className="flex items-center gap-3 mt-1 text-xs text-zinc-500 dark:text-zinc-400 flex-wrap">
                  <span className="flex items-center gap-1 font-mono">
                    <Mail className="h-3.5 w-3.5" />
                    {user.email}
                  </span>
                  <span className="text-zinc-300 dark:text-zinc-700">&bull;</span>
                  <button
                    type="button"
                    onClick={handleCopyId}
                    className="inline-flex items-center gap-1 font-mono hover:text-zinc-800 dark:hover:text-zinc-200 transition-colors"
                  >
                    <span>ID: {user.id}</span>
                    {copied ? <Check className="h-3 w-3 text-emerald-500" /> : <Copy className="h-3 w-3" />}
                  </button>
                </div>
              </div>
            </div>

            <button
              type="button"
              onClick={onClose}
              className="flex h-9 w-9 items-center justify-center rounded-xl bg-zinc-100 hover:bg-zinc-200 dark:bg-zinc-800 dark:hover:bg-zinc-700 text-zinc-600 dark:text-zinc-300 transition-colors"
            >
              <X className="h-4 w-4" />
            </button>
          </div>

          {/* Content Body */}
          <div className="p-6 space-y-6 max-h-[75vh] overflow-y-auto">
            {/* Quick Metrics Grid */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
              {/* Account Status */}
              <div className="p-3.5 rounded-2xl bg-zinc-50 dark:bg-zinc-900/60 border border-zinc-200/80 dark:border-zinc-800 flex flex-col justify-between">
                <span className="text-[11px] font-semibold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                  {t.users.detailsModal.accountStatusLabel}
                </span>
                <div className="mt-2 flex items-center gap-1.5">
                  <span
                    className={`h-2 w-2 rounded-full ${
                      user.isActive ? 'bg-emerald-500' : 'bg-rose-500'
                    }`}
                  />
                  <span className={`text-xs font-bold ${user.isActive ? 'text-emerald-600 dark:text-emerald-400' : 'text-rose-600 dark:text-rose-400'}`}>
                    {user.isActive ? t.users.detailsModal.activeStatus : t.users.detailsModal.suspendedStatus}
                  </span>
                </div>
              </div>

              {/* Email Verification */}
              <div className="p-3.5 rounded-2xl bg-zinc-50 dark:bg-zinc-900/60 border border-zinc-200/80 dark:border-zinc-800 flex flex-col justify-between">
                <span className="text-[11px] font-semibold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                  {t.users.table.emailStatus}
                </span>
                <div className="mt-2 flex items-center gap-1.5">
                  {user.emailConfirmed ? (
                    <span className="inline-flex items-center gap-1 text-xs font-bold text-emerald-600 dark:text-emerald-400">
                      <CheckCircle2 className="h-3.5 w-3.5" />
                      {t.users.table.verified}
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 text-xs font-bold text-amber-600 dark:text-amber-400">
                      <AlertCircle className="h-3.5 w-3.5" />
                      {t.users.table.unverified}
                    </span>
                  )}
                </div>
              </div>

              {/* Wallets */}
              <div className="p-3.5 rounded-2xl bg-zinc-50 dark:bg-zinc-900/60 border border-zinc-200/80 dark:border-zinc-800 flex flex-col justify-between">
                <span className="text-[11px] font-semibold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                  {t.users.detailsModal.walletsCountLabel}
                </span>
                <div className="mt-2 flex items-center gap-1.5 text-xs font-bold text-zinc-900 dark:text-white">
                  <Wallet className="h-3.5 w-3.5 text-blue-500" />
                  <span>
                    {user.walletsCount} {t.users.table.walletsCount}
                  </span>
                </div>
              </div>

              {/* Currency */}
              <div className="p-3.5 rounded-2xl bg-zinc-50 dark:bg-zinc-900/60 border border-zinc-200/80 dark:border-zinc-800 flex flex-col justify-between">
                <span className="text-[11px] font-semibold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                  {t.users.detailsModal.currencyLabel}
                </span>
                <div className="mt-2 flex items-center gap-1.5 text-xs font-bold text-zinc-900 dark:text-white font-mono">
                  <Coins className="h-3.5 w-3.5 text-amber-500" />
                  <span>{user.currency}</span>
                </div>
              </div>
            </div>

            {/* Dates info box */}
            <div className="p-4 rounded-2xl bg-zinc-50/80 dark:bg-zinc-900/40 border border-zinc-200/80 dark:border-zinc-800 grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              <div className="flex items-center gap-2.5">
                <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-zinc-200/60 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300">
                  <Calendar className="h-4 w-4" />
                </div>
                <div>
                  <span className="text-zinc-400 dark:text-zinc-500 block text-[11px]">
                    {t.users.detailsModal.joinedDateLabel}
                  </span>
                  <span className="font-semibold text-zinc-800 dark:text-zinc-200">
                    {formatDate(user.createdAt)}
                  </span>
                </div>
              </div>

              <div className="flex items-center gap-2.5">
                <div className="flex h-8 w-8 items-center justify-center rounded-xl bg-zinc-200/60 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300">
                  <Clock className="h-4 w-4" />
                </div>
                <div>
                  <span className="text-zinc-400 dark:text-zinc-500 block text-[11px]">
                    {t.users.detailsModal.lastLoginLabel}
                  </span>
                  <span className="font-semibold text-zinc-800 dark:text-zinc-200">
                    {user.lastLoginAt ? formatDate(user.lastLoginAt) : t.users.detailsModal.neverLoggedIn}
                  </span>
                </div>
              </div>
            </div>

            {/* Role Management Card */}
            <div className="space-y-2.5">
              <label className="text-xs font-bold text-zinc-900 dark:text-white flex items-center gap-1.5">
                <Shield className="h-3.5 w-3.5 text-zinc-500" />
                {t.users.detailsModal.roleSectionTitle}
              </label>

              <div className="grid grid-cols-3 gap-2.5">
                {(['User', 'Admin', 'SuperAdmin'] as const).map((roleOption) => {
                  const isSelected = user.role === roleOption;
                  return (
                    <button
                      key={roleOption}
                      type="button"
                      disabled={isUpdatingRole}
                      onClick={() => handleRoleChange(roleOption)}
                      className={`p-3 rounded-2xl border text-center transition-all flex flex-col items-center gap-1.5 ${
                        isSelected
                          ? 'border-zinc-950 dark:border-white bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 font-bold shadow-xs'
                          : 'border-zinc-200 dark:border-zinc-800 bg-zinc-50/70 dark:bg-zinc-900/50 hover:bg-zinc-100 dark:hover:bg-zinc-800/80 text-zinc-700 dark:text-zinc-300'
                      }`}
                    >
                      <Shield className="h-4 w-4" />
                      <span className="text-xs">{roleOption}</span>
                      <span className="text-[10px] opacity-70">
                        {roleOption === 'SuperAdmin'
                          ? t.users.detailsModal.roleDescriptions.superAdmin
                          : roleOption === 'Admin'
                          ? t.users.detailsModal.roleDescriptions.admin
                          : t.users.detailsModal.roleDescriptions.user}
                      </span>
                    </button>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Action Footer */}
          <div className="p-4 border-t border-zinc-200/80 dark:border-zinc-800 bg-zinc-50/60 dark:bg-zinc-900/30 flex items-center justify-between gap-3">
            <div className="flex items-center gap-2">
              {onEdit && (
                <Button
                  type="button"
                  variant="primary"
                  size="sm"
                  onClick={() => {
                    onClose();
                    onEdit(user);
                  }}
                  className="font-bold"
                >
                  <Edit2 className="h-4 w-4 me-1.5" />
                  <span>{t.users.actionsMenu.editProfile}</span>
                </Button>
              )}

              <Button
                type="button"
                variant={user.isActive ? 'danger' : 'outline'}
                size="sm"
                onClick={handleStatusToggle}
                isLoading={isUpdatingStatus}
                className="font-bold"
              >
                {user.isActive ? (
                  <>
                    <UserX className="h-4 w-4 me-1.5" />
                    <span>{t.users.actionsMenu.suspendAccount}</span>
                  </>
                ) : (
                  <>
                    <UserCheck className="h-4 w-4 me-1.5" />
                    <span>{t.users.actionsMenu.activateAccount}</span>
                  </>
                )}
              </Button>

              {!isCurrentUser && onDelete && (
                <Button
                  type="button"
                  variant="danger"
                  size="sm"
                  onClick={() => {
                    onClose();
                    onDelete(user);
                  }}
                  className="font-bold"
                >
                  <Trash2 className="h-4 w-4 me-1.5" />
                  <span>{t.users.actionsMenu.deleteAccount}</span>
                </Button>
              )}
            </div>

            <Button type="button" variant="outline" size="sm" onClick={onClose}>
              {t.users.detailsModal.closeBtn}
            </Button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
};
