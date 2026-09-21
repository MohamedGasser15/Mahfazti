import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  X,
  Edit2,
  Mail,
  User,
  Shield,
  Coins,
  CheckCircle2,
  AlertCircle,
  Sparkles,
  Save,
} from 'lucide-react';
import { toast } from 'sonner';
import { useLocale } from '../../../core/context/LocaleContext';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import { SUPPORTED_CURRENCIES } from '../../../core/constants/currencies';
import type { UserItem } from '../types';
import type { UpdateUserData } from '../services/usersService';

interface EditUserModalProps {
  user: UserItem | null;
  isOpen: boolean;
  onClose: () => void;
  onUpdateUser: (userId: string, data: UpdateUserData) => Promise<void>;
}

interface EditUserDialogProps {
  user: UserItem;
  onClose: () => void;
  onUpdateUser: (userId: string, data: UpdateUserData) => Promise<void>;
}

const EditUserDialog: React.FC<EditUserDialogProps> = ({
  user,
  onClose,
  onUpdateUser,
}) => {
  const { t } = useLocale();

  const [fullName, setFullName] = useState(user.fullName);
  const [email, setEmail] = useState(user.email);
  const [role, setRole] = useState<'SuperAdmin' | 'Admin' | 'User'>((user.role as 'SuperAdmin' | 'Admin' | 'User') || 'User');
  const [currency, setCurrency] = useState(user.currency || 'EGP');
  const [emailConfirmed, setEmailConfirmed] = useState(user.emailConfirmed);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setEmailError(null);

    if (!fullName.trim()) {
      toast.error(t.users.editModal.nameRequired);
      return;
    }
    if (!email.trim() || !email.includes('@')) {
      setEmailError(t.users.editModal.emailInvalid);
      toast.error(t.users.editModal.emailInvalid);
      return;
    }

    setIsSubmitting(true);
    try {
      await onUpdateUser(user.id, {
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        role,
        currency,
        emailConfirmed,
      });
      toast.success(t.users.editModal.successToast);
      setEmailError(null);
      onClose();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      const isDuplicate =
        msg.includes('already exists') ||
        msg.includes('مسجل بالفعل') ||
        msg.includes('Duplicate') ||
        msg.includes('already taken') ||
        msg.includes('مستخدم آخر');

      if (isDuplicate) {
        const errorText = t.users.editModal.emailDuplicate;
        setEmailError(errorText);
        toast.error(errorText);
      } else {
        toast.error(msg || t.users.editModal.errorToast);
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <motion.div
      key="edit-user-backdrop"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.2 }}
      onClick={onClose}
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-xs"
    >
        <motion.div
          key="edit-user-modal-container"
          initial={{ opacity: 0, scale: 0.94, y: 16 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.94, y: 10 }}
          transition={{ duration: 0.24, ease: [0.16, 1, 0.3, 1] }}
          onClick={(e) => e.stopPropagation()}
          className="relative w-full max-w-4xl rounded-3xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-2xl overflow-hidden text-zinc-900 dark:text-white"
        >
          {/* Header */}
          <div className="p-6 border-b border-zinc-200/80 dark:border-zinc-800 bg-zinc-50/70 dark:bg-zinc-900/50 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs font-bold">
                <Edit2 className="h-5 w-5" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="text-base font-bold text-zinc-950 dark:text-white">
                    {t.users.editModal.title}
                  </h3>
                  <span className="text-xs font-mono text-zinc-400 dark:text-zinc-500">
                    #{user.id}
                  </span>
                </div>
                <p className="text-xs text-zinc-500 dark:text-zinc-400">
                  {t.users.editModal.subtitle}
                </p>
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

          {/* Form Content */}
          <form onSubmit={handleSubmit}>
            <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6 max-h-[75vh] overflow-y-auto">
              {/* Left Column: Personal & Account info */}
              <div className="space-y-4">
                <div>
                  <label className="text-xs font-bold text-zinc-800 dark:text-zinc-200 flex items-center gap-1.5 mb-1.5">
                    <User className="h-3.5 w-3.5 text-zinc-400" />
                    {t.users.editModal.fullNameLabel}
                  </label>
                  <input
                    type="text"
                    required
                    placeholder={t.users.editModal.fullNamePlaceholder}
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 px-3.5 py-2.5 text-xs text-zinc-900 dark:text-white placeholder-zinc-400 dark:placeholder-zinc-500 focus:border-zinc-950 dark:focus:border-white focus:outline-none transition-colors"
                  />
                </div>

                <div>
                  <label className="text-xs font-bold text-zinc-800 dark:text-zinc-200 flex items-center gap-1.5 mb-1.5">
                    <Mail className="h-3.5 w-3.5 text-zinc-400" />
                    {t.users.editModal.emailLabel}
                  </label>
                  <input
                    type="email"
                    required
                    placeholder="name@example.com"
                    value={email}
                    onChange={(e) => {
                      setEmail(e.target.value);
                      if (emailError) setEmailError(null);
                    }}
                    className={`w-full rounded-xl border ${
                      emailError
                        ? 'border-rose-500 bg-rose-50/40 dark:bg-rose-950/20 text-rose-950 dark:text-rose-200 focus:border-rose-600'
                        : 'border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-zinc-900 dark:text-white focus:border-zinc-950 dark:focus:border-white'
                    } px-3.5 py-2.5 text-xs placeholder-zinc-400 dark:placeholder-zinc-500 focus:outline-none transition-colors font-mono`}
                  />
                  {emailError && (
                    <p className="mt-1 text-[11px] font-semibold text-rose-600 dark:text-rose-400 flex items-center gap-1">
                      <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                      <span>{emailError}</span>
                    </p>
                  )}
                </div>

                <div>
                  <label className="text-xs font-bold text-zinc-800 dark:text-zinc-200 flex items-center gap-1.5 mb-1.5">
                    <Coins className="h-3.5 w-3.5 text-zinc-400" />
                    {t.users.editModal.currencyLabel}
                  </label>
                  <select
                    value={currency}
                    onChange={(e) => setCurrency(e.target.value)}
                    className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 px-3.5 py-2.5 text-xs text-zinc-900 dark:text-white focus:border-zinc-950 dark:focus:border-white focus:outline-none transition-colors"
                  >
                    {SUPPORTED_CURRENCIES.map((cur) => (
                      <option key={cur} value={cur}>
                        {cur}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="pt-2">
                  <label className="flex items-center gap-2.5 p-3 rounded-2xl bg-zinc-50 dark:bg-zinc-900/50 border border-zinc-200/80 dark:border-zinc-800 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={emailConfirmed}
                      onChange={(e) => setEmailConfirmed(e.target.checked)}
                      className="h-4 w-4 rounded-md border-zinc-300 text-zinc-950 focus:ring-zinc-950 cursor-pointer"
                    />
                    <div>
                      <span className="text-xs font-bold text-zinc-900 dark:text-white block">
                        {t.users.editModal.verifiedLabel}
                      </span>
                      <span className="text-[11px] text-zinc-500 dark:text-zinc-400 block">
                        {t.users.editModal.verifiedDesc}
                      </span>
                    </div>
                  </label>
                </div>
              </div>

              {/* Right Column: Role selection & Live preview */}
              <div className="space-y-4">
                <div>
                  <label className="text-xs font-bold text-zinc-800 dark:text-zinc-200 flex items-center gap-1.5 mb-1.5">
                    <Shield className="h-3.5 w-3.5 text-zinc-400" />
                    {t.users.editModal.roleLabel}
                  </label>
                  <div className="grid grid-cols-3 gap-2">
                    {(['User', 'Admin', 'SuperAdmin'] as const).map((r) => (
                      <button
                        key={r}
                        type="button"
                        onClick={() => setRole(r)}
                        className={`p-2.5 rounded-2xl border text-center transition-all flex flex-col items-center gap-1 ${
                          role === r
                            ? 'border-zinc-950 dark:border-white bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 font-bold shadow-xs'
                            : 'border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800'
                        }`}
                      >
                        <Shield className="h-3.5 w-3.5" />
                        <span className="text-xs">{r}</span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Live Preview Card */}
                <div>
                  <span className="text-xs font-bold text-zinc-800 dark:text-zinc-200 flex items-center gap-1.5 mb-1.5">
                    <Sparkles className="h-3.5 w-3.5 text-amber-500" />
                    {t.users.editModal.livePreview}
                  </span>
                  <div className="p-4 rounded-2xl bg-zinc-50/80 dark:bg-zinc-900/60 border border-zinc-200 dark:border-zinc-800 space-y-3">
                    <div className="flex items-center gap-3">
                      <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-zinc-950 dark:bg-zinc-800 text-white font-black text-sm">
                        {fullName.trim() ? fullName.trim().charAt(0).toUpperCase() : '?'}
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center gap-1.5">
                          <p className="text-xs font-bold text-zinc-900 dark:text-white truncate">
                            {fullName.trim() || user.fullName}
                          </p>
                          <Badge
                            variant={role === 'SuperAdmin' ? 'purple' : role === 'Admin' ? 'info' : 'default'}
                            className="text-[10px] py-0 px-1.5 font-semibold"
                          >
                            {role}
                          </Badge>
                        </div>
                        <p className="text-[11px] text-zinc-500 dark:text-zinc-400 font-mono truncate">
                          {email.trim() || user.email}
                        </p>
                      </div>
                    </div>

                    <div className="pt-2 border-t border-zinc-200/80 dark:border-zinc-800 flex items-center justify-between text-[11px] text-zinc-500 dark:text-zinc-400">
                      <span>
                        {t.users.editModal.currencyPreviewLabel} <strong className="text-zinc-800 dark:text-zinc-200">{currency}</strong>
                      </span>
                      <span className="inline-flex items-center gap-1 text-emerald-600 dark:text-emerald-400 font-semibold">
                        <CheckCircle2 className="h-3 w-3" />
                        {emailConfirmed ? t.users.table.verified : t.users.table.unverified}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Footer */}
            <div className="p-4 border-t border-zinc-200/80 dark:border-zinc-800 bg-zinc-50/60 dark:bg-zinc-900/30 flex items-center justify-end gap-2">
              <Button type="button" variant="outline" size="sm" onClick={onClose} disabled={isSubmitting}>
                {t.users.editModal.cancelBtn}
              </Button>
              <Button type="submit" variant="primary" size="sm" isLoading={isSubmitting} className="font-bold">
                <Save className="h-4 w-4 me-1.5" />
                <span>{isSubmitting ? t.users.editModal.submittingBtn : t.users.editModal.submitBtn}</span>
              </Button>
            </div>
          </form>
        </motion.div>
      </motion.div>
  );
};

export const EditUserModal: React.FC<EditUserModalProps> = ({
  user,
  isOpen,
  onClose,
  onUpdateUser,
}) => {
  return (
    <AnimatePresence>
      {isOpen && user && (
        <EditUserDialog
          key={user.id}
          user={user}
          onClose={onClose}
          onUpdateUser={onUpdateUser}
        />
      )}
    </AnimatePresence>
  );
};
