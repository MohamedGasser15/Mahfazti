import React from 'react';
import { AlertTriangle, Trash2, X, ShieldAlert } from 'lucide-react';
import { Button } from '../../../core/components/ui/Button';
import type { RoleDefinition } from '../types';

interface DeleteRoleModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: (role: RoleDefinition) => Promise<void>;
  roleToDelete: RoleDefinition | null;
  isSubmitting: boolean;
  isAr: boolean;
}

export const DeleteRoleModal: React.FC<DeleteRoleModalProps> = ({
  isOpen,
  onClose,
  onConfirm,
  roleToDelete,
  isSubmitting,
  isAr,
}) => {
  if (!isOpen || !roleToDelete) return null;

  const isSystem = roleToDelete.isSystem;
  const hasUsers = roleToDelete.usersCount > 0;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/60 backdrop-blur-xs transition-opacity"
        onClick={onClose}
      />

      {/* Modal Box */}
      <div className="relative w-full max-w-md bg-white dark:bg-[#121215] rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-2xl overflow-hidden z-10 p-6 space-y-4">
        <div className="flex items-start justify-between">
          <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-rose-50 dark:bg-rose-950/50 text-rose-600 dark:text-rose-400">
            {isSystem ? <ShieldAlert className="h-6 w-6" /> : <AlertTriangle className="h-6 w-6" />}
          </div>

          <button
            type="button"
            onClick={onClose}
            className="rounded-xl p-1 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 transition cursor-pointer"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div>
          <h3 className="text-base font-bold text-zinc-950 dark:text-white">
            {isSystem
              ? isAr
                ? 'لا يمكن حذف هذه الرتبة'
                : 'Protected System Role'
              : isAr
              ? `تأكيد حذف رتبة: ${roleToDelete.name}`
              : `Delete Role: ${roleToDelete.name}`}
          </h3>
          <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-1.5 leading-relaxed">
            {isSystem
              ? isAr
                ? `الرتبة "${roleToDelete.name}" هي رتبة نظام أساسية ومحمية بشكل دائم لمنع توقف الصلاحيات والتحكم.`
                : `The role "${roleToDelete.name}" is a core system role and cannot be deleted.`
              : hasUsers
              ? isAr
                ? `هذه الرتبة مسندة حالياً إلى ${roleToDelete.usersCount} مستخدم(ين). يجب إعادة تعيين رتب هؤلاء المستخدمين أولاً قبل حذف الرتبة نهائياً.`
                : `This role is currently assigned to ${roleToDelete.usersCount} user(s). You must reassign them to another role before deleting.`
              : isAr
              ? `هل أنت متأكد من رغبتك في حذف الرتبة "${roleToDelete.name}" نهائياً من مصفوفة الصلاحيات؟ هذا الإجراء لا يمكن التراجع عنه.`
              : `Are you sure you want to permanently delete "${roleToDelete.name}"? This action cannot be undone.`}
          </p>
        </div>

        {/* Footer Actions */}
        <div className="pt-3 border-t border-zinc-100 dark:border-zinc-800 flex items-center justify-end gap-2">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={onClose}
            disabled={isSubmitting}
          >
            {isAr ? 'إلغاء' : 'Cancel'}
          </Button>

          {!isSystem && !hasUsers && (
            <Button
              type="button"
              variant="danger"
              size="sm"
              isLoading={isSubmitting}
              onClick={() => onConfirm(roleToDelete)}
              className="font-bold shadow-xs"
            >
              <Trash2 className="h-4 w-4 me-1.5" />
              <span>{isAr ? 'تأكيد الحذف' : 'Confirm Delete'}</span>
            </Button>
          )}
        </div>
      </div>
    </div>
  );
};
