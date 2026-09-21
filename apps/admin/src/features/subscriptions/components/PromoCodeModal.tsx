import React, { useState } from 'react';
import { X, Tag } from 'lucide-react';
import type { CreatePromoCodePayload } from '../types';
import { useLocale } from '../../../core/context/LocaleContext';
import { sanitizeEnglishInput, handleEnglishOnlyKeyDown } from '../../../core/utils/sanitizers';

interface PromoCodeModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (payload: CreatePromoCodePayload) => Promise<void>;
  isLoading?: boolean;
}

export const PromoCodeModal: React.FC<PromoCodeModalProps> = ({
  isOpen,
  onClose,
  onSubmit,
  isLoading = false,
}) => {
  const { isAr } = useLocale();
  const [code, setCode] = useState('');
  const [discountPercentage, setDiscountPercentage] = useState<number>(25);
  const [maxUses, setMaxUses] = useState<number>(100);
  const [expiresAt, setExpiresAt] = useState<string>('');
  const [isActive, setIsActive] = useState<boolean>(true);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await onSubmit({
      code: code.trim().toUpperCase(),
      discountPercentage: Number(discountPercentage),
      maxUses: Number(maxUses),
      expiresAt: expiresAt ? new Date(expiresAt).toISOString() : undefined,
      isActive,
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-xs p-4">
      <div className="relative w-full max-w-lg rounded-xl bg-white dark:bg-zinc-950 p-6 shadow-2xl border border-zinc-200 dark:border-zinc-800 my-auto">
        <div className="flex items-center justify-between pb-4 border-b border-zinc-100 dark:border-zinc-800">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20">
              <Tag className="h-5 w-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-zinc-950 dark:text-white">
                {isAr ? 'إنشاء كود خصم جديد' : 'Create Promo Code'}
              </h2>
              <p className="text-xs text-zinc-500 dark:text-zinc-400">
                {isAr ? 'قسيمة خصم مئوية على الاشتراكات' : 'Discount voucher for subscriptions'}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-zinc-400 hover:text-zinc-700 dark:hover:text-white hover:bg-zinc-100 dark:hover:bg-zinc-800 transition cursor-pointer"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="mt-5 space-y-4">
          <div>
            <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
              {isAr ? 'كود الخصم (Promo Code)' : 'Promo Code'} *
            </label>
            <input
              type="text"
              required
              value={code}
              onChange={(e) => setCode(sanitizeEnglishInput(e.target.value, false).toUpperCase())}
              onKeyDown={(e) => handleEnglishOnlyKeyDown(e, false)}
              placeholder="e.g. SUMMER50"
              className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl px-3 py-2 text-xs text-zinc-900 dark:text-white font-mono uppercase tracking-wider focus:outline-hidden focus:ring-2 focus:ring-amber-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                {isAr ? 'نسبة الخصم (%)' : 'Discount (%)'} *
              </label>
              <input
                type="number"
                min="1"
                max="100"
                required
                value={discountPercentage}
                onChange={(e) => setDiscountPercentage(Number(e.target.value))}
                className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl px-3 py-2 text-xs text-zinc-900 dark:text-white font-mono focus:outline-hidden focus:ring-2 focus:ring-amber-500"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                {isAr ? 'أقصى عدد مرات استخدام' : 'Max Uses'} *
              </label>
              <input
                type="number"
                min="1"
                required
                value={maxUses}
                onChange={(e) => setMaxUses(Number(e.target.value))}
                className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl px-3 py-2 text-xs text-zinc-900 dark:text-white font-mono focus:outline-hidden focus:ring-2 focus:ring-amber-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
              {isAr ? 'تاريخ الانتهاء (اختياري)' : 'Expiry Date (Optional)'}
            </label>
            <input
              type="datetime-local"
              value={expiresAt}
              onChange={(e) => setExpiresAt(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-amber-500"
            />
          </div>

          <label className="flex items-center gap-2.5 p-2 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-200/70 dark:border-zinc-800/80 cursor-pointer">
            <input
              type="checkbox"
              checked={isActive}
              onChange={(e) => setIsActive(e.target.checked)}
              className="h-4 w-4 rounded text-amber-600 focus:ring-amber-500"
            />
            <span className="text-xs font-bold text-zinc-900 dark:text-zinc-100">
              {isAr ? 'تفعيل الكود فوراً' : 'Active immediately'}
            </span>
          </label>

          <div className="flex items-center justify-end gap-3 pt-4 border-t border-zinc-100 dark:border-zinc-800">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-xs font-semibold rounded-xl bg-zinc-100 hover:bg-zinc-200 dark:bg-zinc-800 dark:hover:bg-zinc-700 text-zinc-700 dark:text-zinc-200 border border-zinc-200 dark:border-zinc-700 transition cursor-pointer"
            >
              {isAr ? 'إلغاء' : 'Cancel'}
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="px-5 py-2 text-xs font-bold rounded-xl bg-amber-600 hover:bg-amber-700 text-white shadow-md hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed transition cursor-pointer flex items-center gap-2"
            >
              {isLoading && <span className="h-3.5 w-3.5 border-2 border-white border-t-transparent rounded-full animate-spin" />}
              <span>{isLoading ? (isAr ? 'جاري الإنشاء...' : 'Creating...') : (isAr ? 'إنشاء كود الخصم' : 'Create Promo Code')}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
