import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { UserCheck, UserX, Trash2 } from 'lucide-react';
import { useLocale } from '../../../core/context/LocaleContext';
import { Button } from '../../../core/components/ui/Button';
import type { UserItem } from '../types';

interface UsersBulkBarProps {
  selectedIds: string[];
  selectedUsers: UserItem[];
  isBulkProcessing: boolean;
  isDeletingUser: boolean;
  hasSuspendedSelected: boolean;
  hasActiveSelected: boolean;
  activeSelectedCount: number;
  suspendedSelectedCount: number;
  onBulkStatusChange: (activate: boolean) => void;
  onStartBulkDelete: () => void;
  onClearSelection: () => void;
}

export const UsersBulkBar: React.FC<UsersBulkBarProps> = ({
  selectedIds,
  selectedUsers,
  isBulkProcessing,
  isDeletingUser,
  hasSuspendedSelected,
  hasActiveSelected,
  activeSelectedCount,
  suspendedSelectedCount,
  onBulkStatusChange,
  onStartBulkDelete,
  onClearSelection,
}) => {
  const { t, isAr } = useLocale();

  return (
    <AnimatePresence>
      {selectedIds.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 30, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: 30, scale: 0.95 }}
          transition={{ duration: 0.2 }}
          className="fixed bottom-6 inset-x-0 z-40 flex justify-center px-4 pointer-events-none"
        >
          <div className="pointer-events-auto flex items-center gap-3 px-5 py-3 rounded-2xl bg-zinc-950 dark:bg-zinc-900 border border-zinc-800 shadow-2xl text-white">
            <span className="text-xs font-bold">
              {isAr
                ? `تم تحديد (${selectedIds.length}) ${t.users.bulk.selectedCount}`
                : `(${selectedIds.length}) ${t.users.bulk.selectedCount}`}
            </span>

            <div className="h-4 w-px bg-zinc-700" />

            {/* Show Activate button ONLY if there are suspended users selected */}
            {hasSuspendedSelected && (
              <Button
                type="button"
                variant="primary"
                size="sm"
                disabled={isBulkProcessing}
                onClick={() => onBulkStatusChange(true)}
                className="bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs"
              >
                <UserCheck className="h-3.5 w-3.5 me-1" />
                <span>
                  {hasActiveSelected
                    ? `${t.users.bulk.activateInactive} (${suspendedSelectedCount})`
                    : t.users.bulk.activateSelected}
                </span>
              </Button>
            )}

            {/* Show Suspend button ONLY if there are active users selected */}
            {hasActiveSelected && (
              <Button
                type="button"
                variant="danger"
                size="sm"
                disabled={isBulkProcessing}
                onClick={() => onBulkStatusChange(false)}
                className="font-bold text-xs"
              >
                <UserX className="h-3.5 w-3.5 me-1" />
                <span>
                  {hasSuspendedSelected
                    ? `${t.users.bulk.suspendActive} (${activeSelectedCount})`
                    : t.users.bulk.suspendSelected}
                </span>
              </Button>
            )}

            {/* Bulk Delete button */}
            <Button
              type="button"
              variant="danger"
              size="sm"
              disabled={isBulkProcessing || isDeletingUser}
              onClick={onStartBulkDelete}
              className="font-bold text-xs bg-rose-600 hover:bg-rose-700 text-white"
            >
              <Trash2 className="h-3.5 w-3.5 me-1" />
              <span>
                {t.users.bulk.deleteSelected} ({selectedUsers.length})
              </span>
            </Button>

            <button
              type="button"
              onClick={onClearSelection}
              className="text-xs text-zinc-400 hover:text-white ms-1 underline underline-offset-2"
            >
              {t.users.bulk.deselect}
            </button>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};
