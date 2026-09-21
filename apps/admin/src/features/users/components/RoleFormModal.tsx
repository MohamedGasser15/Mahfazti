import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Key, Check, AlertCircle, ShieldCheck } from 'lucide-react';
import { Button } from '../../../core/components/ui/Button';
import type { RoleDefinition } from '../types';

interface RoleFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (formData: { name: string; description: string }) => Promise<void>;
  roleToEdit?: RoleDefinition | null;
  isSubmitting: boolean;
  isAr: boolean;
}

export const RoleFormModal: React.FC<RoleFormModalProps> = ({
  isOpen,
  onClose,
  onSubmit,
  roleToEdit,
  isSubmitting,
  isAr,
}) => {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [error, setError] = useState<string | null>(null);

  const isEditing = Boolean(roleToEdit);
  const isSystem = roleToEdit?.isSystem || false;

  const [prevIsOpen, setPrevIsOpen] = useState(false);
  const [prevRoleToEdit, setPrevRoleToEdit] = useState(roleToEdit);

  if (isOpen !== prevIsOpen || roleToEdit !== prevRoleToEdit) {
    setPrevIsOpen(isOpen);
    setPrevRoleToEdit(roleToEdit);
    if (isOpen) {
      if (roleToEdit) {
        setName(roleToEdit.name);
        setDescription(roleToEdit.description || '');
      } else {
        setName('');
        setDescription('');
      }
      setError(null);
    }
  }

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      setError(isAr ? 'يرجى كتابة اسم الرتبة' : 'Role name is required');
      return;
    }

    try {
      await onSubmit({
        name: name.trim(),
        description: description.trim(),
      });
      onClose();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      setError(msg || (isAr ? 'حدث خطأ أثناء حفظ الرتبة' : 'Failed to save role'));
    }
  };

  return (
    <AnimatePresence>
      <motion.div
        key="role-form-modal-backdrop"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.2 }}
        onClick={onClose}
        className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 bg-black/70 backdrop-blur-xs overflow-y-auto"
      >
        {/* Wide Landscape Rectangle Modal (max-w-3xl) */}
        <motion.div
          key="role-form-modal-container"
          initial={{ opacity: 0, scale: 0.95, y: 14 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 10 }}
          transition={{ duration: 0.24, ease: [0.16, 1, 0.3, 1] }}
          onClick={(e) => e.stopPropagation()}
          className="relative w-full max-w-3xl bg-white dark:bg-[#121215] rounded-3xl border border-zinc-200 dark:border-zinc-800 shadow-2xl overflow-hidden flex flex-col z-10"
        >
          {/* Header */}
          <div className="flex items-center justify-between px-6 py-4.5 border-b border-zinc-200 dark:border-zinc-800 bg-zinc-50/60 dark:bg-zinc-900/50">
            <div className="flex items-center gap-3">
              <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-sm">
                <Key className="h-5 w-5" />
              </div>
              <div>
                <h2 className="text-base font-bold text-zinc-950 dark:text-white">
                  {isEditing
                    ? isAr
                      ? `تعديل بيانات الرتبة: ${roleToEdit?.name || ''}`
                      : `Edit Role: ${roleToEdit?.name || ''}`
                    : isAr
                    ? 'إنشاء رتبة إدارية جديدة'
                    : 'Create New Administrative Role'}
                </h2>
                <p className="text-xs text-zinc-500 dark:text-zinc-400">
                  {isAr
                    ? 'تعريف مسمى الرتبة والوصف العام للمسؤوليات الإدارية'
                    : 'Define role naming and general administrative responsibilities'}
                </p>
              </div>
            </div>

            <button
              type="button"
              onClick={onClose}
              className="rounded-xl p-1.5 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition cursor-pointer"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          {/* Form Body - Wide Rectangle Layout */}
          <form onSubmit={handleSubmit} className="p-6 space-y-5">
            {error && (
              <div className="p-3.5 rounded-2xl bg-rose-50 dark:bg-rose-950/40 border border-rose-200 dark:border-rose-900/60 text-rose-700 dark:text-rose-300 text-xs flex items-center gap-2">
                <AlertCircle className="h-4 w-4 shrink-0" />
                <span>{error}</span>
              </div>
            )}

            <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
              {/* Role Name */}
              <div className="space-y-1.5">
                <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300">
                  {isAr ? 'اسم الرتبة الإدارية' : 'Role Name'} <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  disabled={isSystem}
                  placeholder="e.g. FinanceManager, SupportLead"
                  className={`w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900 px-3.5 py-2.5 text-xs font-semibold text-zinc-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-zinc-900 dark:focus:ring-white transition ${
                    isSystem ? 'opacity-60 cursor-not-allowed bg-zinc-100 dark:bg-zinc-800' : ''
                  }`}
                />
                {isSystem ? (
                  <span className="text-[11px] text-amber-600 dark:text-amber-400 block pt-0.5">
                    {isAr
                      ? 'رتبة أساسية: مسمى الرتبة محمي بنظام التشغيل ولا يمكن تغييره'
                      : 'System default role: name is immutable'}
                  </span>
                ) : (
                  <span className="text-[11px] text-zinc-400 block pt-0.5">
                    {isAr
                      ? 'اختر اسماً بالإنجليزية مميزاً للرتبة بدون مسافات'
                      : 'Unique role identifier (e.g. OperationsLead)'}
                  </span>
                )}
              </div>

              {/* Description */}
              <div className="space-y-1.5">
                <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300">
                  {isAr ? 'الوصف ومجال المسؤولية' : 'Description'}
                </label>
                <textarea
                  rows={3}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder={
                    isAr
                      ? 'اكتب نبذة توضيحية عن طبيعة المهام والمسؤوليات المنوطة بحاملي هذه الرتبة...'
                      : 'Brief description of roles, duties, and operational scope...'
                  }
                  className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900 px-3.5 py-2 text-xs text-zinc-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-zinc-900 dark:focus:ring-white transition resize-none"
                />
              </div>
            </div>

            {/* Dedicated Claims Notice */}
            <div className="p-4 rounded-2xl bg-blue-50/60 dark:bg-blue-950/30 border border-blue-200/70 dark:border-blue-900/50 flex items-start gap-3">
              <ShieldCheck className="h-5 w-5 text-blue-600 dark:text-blue-400 shrink-0 mt-0.5" />
              <div className="text-xs">
                <p className="font-bold text-blue-950 dark:text-blue-200">
                  {isAr ? 'إدارة مصفوفة الصلاحيات كإجراء منفصل' : 'Granular Claims Managed Separately'}
                </p>
                <p className="text-blue-700 dark:text-blue-400 text-[11px] mt-0.5 leading-relaxed">
                  {isAr
                    ? 'تم فصل الصلاحيات والـ Claims في إجراء مخصص ومستقل؛ يمكنك تحديد وتخصيص الصلاحيات الـ 23 في أي وقت عبر زر "إدارة الصلاحيات" في جدول أو كروت الرتب.'
                    : 'Permissions and claims are configured independently via the dedicated "Manage Permissions" action in the table or cards.'}
                </p>
              </div>
            </div>

            {/* Footer Actions */}
            <div className="pt-4 border-t border-zinc-200 dark:border-zinc-800 flex items-center justify-end gap-2.5">
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={onClose}
                disabled={isSubmitting}
              >
                {isAr ? 'إلغاء' : 'Cancel'}
              </Button>

              <Button
                type="submit"
                variant="primary"
                size="sm"
                isLoading={isSubmitting}
                className="font-bold shadow-xs px-5"
              >
                <Check className="h-4 w-4 me-1.5" />
                <span>
                  {isEditing
                    ? isAr
                      ? 'حفظ التعديلات'
                      : 'Save Changes'
                    : isAr
                    ? 'إنشاء الرتبة'
                    : 'Create Role'}
                </span>
              </Button>
            </div>
          </form>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
};
