import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Trash2,
  X,
  ShieldAlert,
  Wallet,
  Coins,
  ShieldCheck,
  Calendar,
  Users as UsersIcon,
} from 'lucide-react';
import { useLocale } from '../../../core/context/LocaleContext';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { formatDate } from '../../../core/utils/formatters';
import type { UserItem } from '../types';

interface DeleteUserModalProps {
  user?: UserItem | null;
  users?: UserItem[];
  isOpen: boolean;
  onClose: () => void;
  onConfirmDelete: (userIds: string[]) => Promise<void>;
  isDeleting?: boolean;
  currentUserId?: string;
}

export const DeleteUserModal: React.FC<DeleteUserModalProps> = ({
  user,
  users,
  isOpen,
  onClose,
  onConfirmDelete,
  isDeleting = false,
  currentUserId,
}) => {
  const { t } = useLocale();

  // Normalize targets
  const targetUsers: UserItem[] = React.useMemo(() => {
    if (users && users.length > 0) return users;
    if (user) return [user];
    return [];
  }, [user, users]);

  // Filter out current user if accidentally included in bulk
  const safeTargetUsers = React.useMemo(() => {
    if (!currentUserId) return targetUsers;
    const cleanCurrent = currentUserId.replace('u-', '');
    return targetUsers.filter((u) => u.id.replace('u-', '') !== cleanCurrent);
  }, [targetUsers, currentUserId]);

  const excludedSelf = targetUsers.length > safeTargetUsers.length;

  if (!isOpen || targetUsers.length === 0) return null;

  const isMultiple = safeTargetUsers.length > 1;

  const handleConfirm = async () => {
    const ids = safeTargetUsers.map((u) => u.id);
    if (ids.length > 0) {
      await onConfirmDelete(ids);
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
        key="delete-user-backdrop"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.18 }}
        onClick={onClose}
        className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md"
      >
        <motion.div
          key="delete-user-modal"
          initial={{ opacity: 0, scale: 0.95, y: 12 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 10 }}
          transition={{ duration: 0.22, ease: [0.16, 1, 0.3, 1] }}
          onClick={(e) => e.stopPropagation()}
          className="relative w-full max-w-md rounded-3xl border border-zinc-200/80 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-2xl overflow-hidden text-zinc-900 dark:text-white"
        >
          {/* Subtle Ambient Red Glow at Top */}
          <div className="absolute top-0 inset-x-0 h-24 bg-gradient-to-b from-rose-500/10 via-rose-500/5 to-transparent pointer-events-none" />

          {/* Close button */}
          <button
            type="button"
            onClick={onClose}
            disabled={isDeleting}
            className="absolute top-4 end-4 z-10 rounded-full p-2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800/60 transition-colors"
          >
            <X className="h-4 w-4" />
          </button>

          <div className="p-6 space-y-5 text-center sm:text-start">
            {/* Header: Icon & Title */}
            <div className="flex flex-col sm:flex-row items-center sm:items-start gap-4">
              <div className="flex h-13 w-13 shrink-0 items-center justify-center rounded-2xl bg-rose-500/10 dark:bg-rose-500/15 text-rose-600 dark:text-rose-400 ring-6 ring-rose-500/5 dark:ring-rose-500/10">
                <Trash2 className="h-6 w-6" />
              </div>
              <div className="space-y-1 text-center sm:text-start">
                <h3 className="text-lg font-bold text-zinc-950 dark:text-white leading-snug">
                  {isMultiple
                    ? `(${safeTargetUsers.length}) ${t.users.deleteModal.titleMultiple}`
                    : t.users.deleteModal.titleSingle}
                </h3>
                <p className="text-xs text-zinc-500 dark:text-zinc-400 leading-relaxed">
                  {isMultiple
                    ? t.users.deleteModal.descMultiple
                    : t.users.deleteModal.descSingle}
                </p>
              </div>
            </div>

            {/* Self Exclusion Notice if applicable */}
            {excludedSelf && (
              <div className="p-2.5 rounded-xl bg-blue-50/80 dark:bg-blue-950/30 border border-blue-200/80 dark:border-blue-900/40 flex items-center gap-2 text-xs text-blue-800 dark:text-blue-300">
                <ShieldCheck className="h-4 w-4 shrink-0 text-blue-600 dark:text-blue-400" />
                <span>
                  {t.users.deleteModal.selfProtectedAlert}
                </span>
              </div>
            )}

            {/* Target Representation */}
            {safeTargetUsers.length === 0 ? (
              <div className="p-4 rounded-2xl bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-800/80 text-center text-xs text-amber-800 dark:text-amber-300">
                {t.users.deleteModal.selfProtectedAlert}
              </div>
            ) : !isMultiple && safeTargetUsers[0] ? (
              /* Single User Card */
              <div className="p-3.5 rounded-2xl bg-zinc-50 dark:bg-zinc-900/50 border border-zinc-200/80 dark:border-zinc-800/80 space-y-2.5">
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-zinc-950 dark:bg-zinc-800 text-white font-black text-sm shadow-2xs">
                    {safeTargetUsers[0].fullName.trim()
                      ? safeTargetUsers[0].fullName.trim().charAt(0).toUpperCase()
                      : '?'}
                  </div>
                  <div className="min-w-0 flex-1 text-start">
                    <div className="flex items-center gap-2">
                      <p className="text-xs font-bold text-zinc-900 dark:text-white truncate">
                        {safeTargetUsers[0].fullName}
                      </p>
                      <Badge
                        variant={getRoleBadgeVariant(safeTargetUsers[0].role)}
                        className="text-[10px] py-0 px-1.5 font-semibold"
                      >
                        {safeTargetUsers[0].role}
                      </Badge>
                    </div>
                    <p className="text-[11px] text-zinc-500 dark:text-zinc-400 font-mono truncate">
                      {safeTargetUsers[0].email}
                    </p>
                  </div>
                </div>

                <div className="pt-2 border-t border-zinc-200/60 dark:border-zinc-800 flex items-center justify-between text-[11px] text-zinc-500 dark:text-zinc-400">
                  <span className="flex items-center gap-1">
                    <Calendar className="h-3 w-3" />
                    {formatDate(safeTargetUsers[0].createdAt)}
                  </span>
                  <span className="flex items-center gap-1 font-mono font-semibold text-zinc-800 dark:text-zinc-200">
                    <Wallet className="h-3 w-3 text-blue-500" />
                    {safeTargetUsers[0].walletsCount} {t.users.table.walletsCount} &bull;{' '}
                    {safeTargetUsers[0].currency}
                  </span>
                </div>
              </div>
            ) : (
              /* Multiple Users Preview */
              <div className="p-3.5 rounded-2xl bg-zinc-50 dark:bg-zinc-900/50 border border-zinc-200/80 dark:border-zinc-800/80 space-y-2.5">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-zinc-700 dark:text-zinc-300 flex items-center gap-1.5">
                    <UsersIcon className="h-3.5 w-3.5 text-zinc-500" />
                    {t.users.deleteModal.userToDeleteLabel}
                  </span>
                  <span className="text-[11px] font-mono font-bold text-rose-600 dark:text-rose-400">
                    {safeTargetUsers.length} {t.users.pagination.users}
                  </span>
                </div>

                {/* Avatar / names preview chips */}
                <div className="max-h-28 overflow-y-auto space-y-1.5 pe-1">
                  {safeTargetUsers.map((u) => (
                    <div
                      key={u.id}
                      className="flex items-center justify-between px-2.5 py-1.5 rounded-xl bg-white dark:bg-zinc-800/60 border border-zinc-200/60 dark:border-zinc-700/60 text-xs"
                    >
                      <span className="font-semibold text-zinc-900 dark:text-zinc-100 truncate max-w-[170px]">
                        {u.fullName}
                      </span>
                      <span className="text-[10px] font-mono text-zinc-400 dark:text-zinc-500 truncate max-w-[130px]">
                        {u.email}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Permanent Impact Breakdown Checklist */}
            <div className="space-y-1.5 text-start">
              <p className="text-[11px] font-bold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                {t.users.deleteModal.cascadingWipeListTitle}
              </p>
              <div className="grid grid-cols-1 gap-1.5 text-xs text-zinc-600 dark:text-zinc-300">
                <div className="flex items-center gap-2 p-2 rounded-xl bg-rose-500/5 dark:bg-rose-500/10 border border-rose-500/10">
                  <Wallet className="h-3.5 w-3.5 text-rose-500 shrink-0" />
                  <span>{t.users.deleteModal.walletsWipe}</span>
                </div>
                <div className="flex items-center gap-2 p-2 rounded-xl bg-rose-500/5 dark:bg-rose-500/10 border border-rose-500/10">
                  <Coins className="h-3.5 w-3.5 text-rose-500 shrink-0" />
                  <span>{t.users.deleteModal.budgetsWipe}</span>
                </div>
                <div className="flex items-center gap-2 p-2 rounded-xl bg-rose-500/5 dark:bg-rose-500/10 border border-rose-500/10">
                  <ShieldAlert className="h-3.5 w-3.5 text-rose-500 shrink-0" />
                  <span>{t.users.deleteModal.userProfileWipe}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Footer Actions */}
          <div className="p-4 border-t border-zinc-200/80 dark:border-zinc-800 bg-zinc-50/70 dark:bg-zinc-900/40 flex items-center justify-end gap-2.5">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={onClose}
              disabled={isDeleting}
              className="font-semibold text-xs"
            >
              {t.users.deleteModal.cancelBtn}
            </Button>
            <Button
              type="button"
              variant="danger"
              size="sm"
              isLoading={isDeleting}
              disabled={isDeleting || safeTargetUsers.length === 0}
              onClick={handleConfirm}
              className="font-bold text-xs shadow-xs"
            >
              <Trash2 className="h-3.5 w-3.5 me-1.5" />
              <span>
                {isDeleting
                  ? t.users.deleteModal.deletingBtn
                  : safeTargetUsers.length === 0
                  ? t.users.actionsMenu.protectedAccountTooltip
                  : isMultiple
                  ? t.users.deleteModal.confirmBtnMultiple
                  : t.users.deleteModal.confirmBtnSingle}
              </span>
            </Button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
};
