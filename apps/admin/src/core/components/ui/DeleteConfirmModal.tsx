import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Trash2, X, AlertTriangle } from 'lucide-react';
import { useLocale } from '../../context/LocaleContext';

interface DeleteConfirmModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => Promise<void> | void;
  title?: string;
  description?: string;
  itemName?: string;
  itemBadge?: string;
  impactWarnings?: string[];
  confirmText?: string;
  cancelText?: string;
  isDeleting?: boolean;
}

export const DeleteConfirmModal: React.FC<DeleteConfirmModalProps> = ({
  isOpen,
  onClose,
  onConfirm,
  title,
  description,
  itemName,
  itemBadge,
  impactWarnings = [],
  confirmText,
  cancelText,
  isDeleting = false,
}) => {
  const { isAr } = useLocale();

  if (!isOpen) return null;

  const defaultTitle = isAr ? 'تأكيد الحذف' : 'Confirm Deletion';
  const defaultDesc = isAr
    ? 'هل أنت متأكد من رغبتك في حذف هذا العنصر؟ لا يمكن التراجع عن هذا الإجراء.'
    : 'Are you sure you want to delete this item? This action cannot be undone.';
  const defaultConfirmText = isAr ? 'نعم، احذف' : 'Yes, Delete';
  const defaultCancelText = isAr ? 'إلغاء' : 'Cancel';

  return (
    <AnimatePresence>
      <motion.div
        key="delete-modal-backdrop"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.18 }}
        onClick={onClose}
        className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-md"
      >
        <motion.div
          key="delete-modal-box"
          initial={{ opacity: 0, scale: 0.95, y: 12 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 10 }}
          transition={{ duration: 0.22, ease: [0.16, 1, 0.3, 1] }}
          onClick={(e) => e.stopPropagation()}
          className="relative w-full max-w-md rounded-2xl border border-zinc-200/90 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-2xl overflow-hidden text-zinc-900 dark:text-white"
        >
          {/* Subtle Ambient Red Glow */}
          <div className="absolute top-0 inset-x-0 h-20 bg-gradient-to-b from-rose-500/10 via-rose-500/5 to-transparent pointer-events-none" />

          {/* Close button */}
          <button
            type="button"
            onClick={onClose}
            disabled={isDeleting}
            className="absolute top-4 end-4 z-10 rounded-full p-2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors cursor-pointer"
          >
            <X className="h-4 w-4" />
          </button>

          <div className="p-6 space-y-5">
            {/* Header: Icon & Title */}
            <div className="flex items-start gap-4">
              <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-rose-500/10 text-rose-600 dark:text-rose-400 ring-6 ring-rose-500/5">
                <Trash2 className="h-6 w-6" />
              </div>
              <div className="space-y-1">
                <h3 className="text-lg font-bold text-zinc-950 dark:text-white leading-snug">
                  {title || defaultTitle}
                </h3>
                <p className="text-xs text-zinc-500 dark:text-zinc-400 leading-relaxed">
                  {description || defaultDesc}
                </p>
              </div>
            </div>

            {/* Target Item Highlight */}
            {itemName && (
              <div className="p-3.5 rounded-xl bg-zinc-50 dark:bg-zinc-900/60 border border-zinc-200/80 dark:border-zinc-800 flex items-center justify-between">
                <div className="flex items-center gap-2.5 min-w-0">
                  <div className="h-2 w-2 rounded-full bg-rose-500 shrink-0" />
                  <span className="font-bold text-sm text-zinc-950 dark:text-white truncate">
                    {itemName}
                  </span>
                </div>
                {itemBadge && (
                  <span className="text-[11px] font-semibold px-2 py-0.5 rounded-md bg-zinc-200 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 shrink-0">
                    {itemBadge}
                  </span>
                )}
              </div>
            )}

            {/* Impact warnings checklist if provided */}
            {impactWarnings.length > 0 && (
              <div className="space-y-1.5">
                <p className="text-[11px] font-bold text-zinc-400 uppercase tracking-wider">
                  {isAr ? 'الآثار المترتبة:' : 'Consequences:'}
                </p>
                <div className="space-y-1 text-xs text-zinc-600 dark:text-zinc-400">
                  {impactWarnings.map((warn, i) => (
                    <div key={i} className="flex items-start gap-2 p-2 rounded-lg bg-rose-500/5 border border-rose-500/10">
                      <AlertTriangle className="h-3.5 w-3.5 text-rose-500 shrink-0 mt-0.5" />
                      <span>{warn}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Footer Actions */}
          <div className="p-4 border-t border-zinc-100 dark:border-zinc-800 bg-zinc-50/70 dark:bg-zinc-900/40 flex items-center justify-end gap-2.5">
            <button
              type="button"
              onClick={onClose}
              disabled={isDeleting}
              className="px-4 py-2 text-xs font-semibold rounded-xl bg-white dark:bg-zinc-900 hover:bg-zinc-100 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-200 border border-zinc-200 dark:border-zinc-700 transition cursor-pointer"
            >
              {cancelText || defaultCancelText}
            </button>
            <button
              type="button"
              disabled={isDeleting}
              onClick={onConfirm}
              className="flex items-center gap-1.5 px-5 py-2 text-xs font-bold rounded-xl bg-rose-600 hover:bg-rose-700 text-white shadow-md hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed transition cursor-pointer"
            >
              {isDeleting ? (
                <span className="h-3.5 w-3.5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              ) : (
                <Trash2 className="h-3.5 w-3.5" />
              )}
              <span>{isDeleting ? (isAr ? 'جاري الحذف...' : 'Deleting...') : (confirmText || defaultConfirmText)}</span>
            </button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
};
