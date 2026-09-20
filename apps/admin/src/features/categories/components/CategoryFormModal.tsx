import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  X,
  Plus,
  Edit2,
  Check,
  TrendingDown,
  TrendingUp,
} from 'lucide-react';
import { useLocale } from '../../../core/context/LocaleContext';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import type { CategoryItem } from '../types';
import { AVAILABLE_ICONS, renderCategoryIcon } from '../utils/categoryIcons';

const sanitizeEnglishInput = (value: string): string => {
  return value.replace(/[^a-zA-Z0-9\s&/\-,'".()_]/g, '');
};

const sanitizeArabicInput = (value: string): string => {
  return value.replace(/[^ \u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF0-9\u0660-\u0669&/\-،؛؟.'"()_]/g, '');
};

interface CategoryFormModalProps {
  isOpen: boolean;
  mode: 'create' | 'edit';
  category?: CategoryItem | null;
  onClose: () => void;
  onSubmit: (formData: {
    nameEn: string;
    nameAr: string;
    type: 'Expense' | 'Income';
    icon: string;
  }) => Promise<void>;
  isSubmitting: boolean;
}

export const CategoryFormModal: React.FC<CategoryFormModalProps> = ({
  isOpen,
  mode,
  category,
  onClose,
  onSubmit,
  isSubmitting,
}) => {
  const { locale } = useLocale();
  const isAr = locale === 'ar';

  const [formNameEn, setFormNameEn] = useState(category ? category.nameEn : '');
  const [formNameAr, setFormNameAr] = useState(category ? category.nameAr : '');
  const [formType, setFormType] = useState<'Expense' | 'Income'>(
    category ? category.type : 'Expense'
  );
  const [formIcon, setFormIcon] = useState<string>(
    category ? category.icon || 'tag' : 'tag'
  );
  const [formErrors, setFormErrors] = useState<{ nameEn?: string; nameAr?: string }>({});

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose]);

  const handleEnglishKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.ctrlKey || e.metaKey || e.altKey || e.key.length > 1) return;
    if (!/[a-zA-Z0-9\s&/\-,'".()_]/.test(e.key)) {
      e.preventDefault();
    }
  };

  const handleArabicKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.ctrlKey || e.metaKey || e.altKey || e.key.length > 1) return;
    if (
      /[a-zA-Z]/.test(e.key) ||
      !/[ \u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF0-9\u0660-\u0669&/\-،؛؟.'"()_]/.test(e.key)
    ) {
      e.preventDefault();
    }
  };

  const handleNameEnChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const sanitized = sanitizeEnglishInput(e.target.value);
    setFormNameEn(sanitized);
    if (formErrors.nameEn) {
      setFormErrors((prev) => ({ ...prev, nameEn: undefined }));
    }
  };

  const handleNameArChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const sanitized = sanitizeArabicInput(e.target.value);
    setFormNameAr(sanitized);
    if (formErrors.nameAr) {
      setFormErrors((prev) => ({ ...prev, nameAr: undefined }));
    }
  };

  const validateForm = (): boolean => {
    const errors: { nameEn?: string; nameAr?: string } = {};
    const cleanEn = formNameEn.trim();
    const cleanAr = formNameAr.trim();

    if (!cleanEn) {
      errors.nameEn = isAr
        ? 'الاسم بالإنجليزية مطلوب'
        : 'English name is required';
    } else if (!/[a-zA-Z]/.test(cleanEn)) {
      errors.nameEn = isAr
        ? 'يجب أن يحتوي الاسم بالإنجليزية على أحرف إنجليزية'
        : 'English name must contain English letters';
    } else if (/[\u0600-\u06FF]/.test(cleanEn)) {
      errors.nameEn = isAr
        ? 'ممنوع كتابة أحرف عربية في حقل الإنجليزية'
        : 'Arabic characters are not allowed in English field';
    }

    if (!cleanAr) {
      errors.nameAr = isAr
        ? 'الاسم بالعربية مطلوب'
        : 'Arabic name is required';
    } else if (!/[\u0600-\u06FF]/.test(cleanAr)) {
      errors.nameAr = isAr
        ? 'يجب أن يحتوي الاسم بالعربية على أحرف عربية'
        : 'Arabic name must contain Arabic letters';
    } else if (/[a-zA-Z]/.test(cleanAr)) {
      errors.nameAr = isAr
        ? 'ممنوع كتابة أحرف إنجليزية في حقل العربية'
        : 'English characters are not allowed in Arabic field';
    }

    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) return;

    await onSubmit({
      nameEn: formNameEn.trim(),
      nameAr: formNameAr.trim(),
      type: formType,
      icon: formIcon,
    });
  };

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <motion.div
        key="category-form-modal-backdrop"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.2, ease: 'easeOut' }}
        onClick={onClose}
        className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-xs"
      >
        <motion.div
          key="category-form-modal-content"
          initial={{ opacity: 0, scale: 0.95, y: 14 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 10 }}
          transition={{ duration: 0.24, ease: [0.16, 1, 0.3, 1] }}
          onClick={(e) => e.stopPropagation()}
          className="relative w-full max-w-3xl rounded-3xl border border-zinc-200/90 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-2xl overflow-hidden text-zinc-900 dark:text-white max-h-[92vh] flex flex-col"
        >
          {/* Header */}
          <div className="px-6 py-4.5 sm:px-7 sm:py-5 border-b border-zinc-200/90 dark:border-zinc-800/80 flex items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <div
                className={`h-11 w-11 rounded-2xl flex items-center justify-center shadow-xs border ${
                  mode === 'create'
                    ? 'bg-zinc-950 text-white border-zinc-950 dark:bg-white dark:text-zinc-950 dark:border-white'
                    : 'bg-zinc-100 text-zinc-900 border-zinc-200 dark:bg-zinc-800 dark:text-zinc-100 dark:border-zinc-700'
                }`}
              >
                {mode === 'create' ? (
                  <Plus className="h-5 w-5" />
                ) : (
                  <Edit2 className="h-5 w-5" />
                )}
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h2 className="text-base sm:text-lg font-bold text-zinc-950 dark:text-white">
                    {mode === 'create'
                      ? isAr
                        ? 'إضافة تصنيف مالي جديد'
                        : 'New System Category'
                      : isAr
                      ? 'تعديل بيانات التصنيف'
                      : 'Edit Category'}
                  </h2>
                  {category && (
                    <span className="text-xs font-mono font-bold text-zinc-600 dark:text-zinc-300 bg-zinc-100 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 px-2 py-0.5 rounded-md">
                      #{category.id}
                    </span>
                  )}
                </div>
                <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5 font-medium">
                  {mode === 'create'
                    ? isAr
                      ? 'أدخل بيانات التصنيف باللغتين وحدد النوع المالي والأيقونة'
                      : 'Enter bilingual names, select financial flow, and pick an icon'
                    : isAr
                    ? 'تحديث بيانات ومظهر التصنيف المالي الحالي'
                    : 'Update name, financial flow, and icon for this category'}
                </p>
              </div>
            </div>

            <button
              type="button"
              onClick={onClose}
              className="rounded-xl p-2 text-zinc-400 hover:text-zinc-800 dark:hover:text-white hover:bg-zinc-100 dark:hover:bg-zinc-800 transition cursor-pointer"
            >
              <X className="h-4 w-4" />
            </button>
          </div>

          {/* Form Content - 2 Columns Grid */}
          <form onSubmit={handleSubmit} className="flex flex-col flex-1 overflow-hidden">
            <div className="p-6 sm:p-7 overflow-y-auto max-h-[calc(90vh-140px)]">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-start">
                {/* Column 1: Basic Information & Type */}
                <div className="space-y-4.5">
                  {/* English Name Input */}
                  <div>
                    <label className="block text-xs font-bold text-zinc-800 dark:text-zinc-200 mb-1.5">
                      {isAr ? 'الاسم بالإنجليزية (English Name)' : 'English Name'}
                      <span className="text-rose-500 ms-1">*</span>
                    </label>
                    <input
                      type="text"
                      value={formNameEn}
                      onChange={handleNameEnChange}
                      onKeyDown={handleEnglishKeyDown}
                      placeholder="e.g. Food & Dining"
                      dir="ltr"
                      autoFocus={mode === 'create'}
                      className={`w-full rounded-xl border ${
                        formErrors.nameEn
                          ? 'border-rose-500'
                          : 'border-zinc-300 dark:border-zinc-700 focus:border-zinc-950 dark:focus:border-white'
                      } bg-zinc-50/80 dark:bg-zinc-950 focus:bg-white dark:focus:bg-zinc-950 px-3.5 py-2.5 text-xs text-zinc-900 dark:text-white placeholder:text-zinc-400 dark:placeholder:text-zinc-500 focus:outline-hidden focus:ring-1 focus:ring-zinc-950 dark:focus:ring-white transition shadow-2xs`}
                    />
                    {formErrors.nameEn && (
                      <p className="text-[11px] text-rose-500 dark:text-rose-400 mt-1 font-semibold">
                        {formErrors.nameEn}
                      </p>
                    )}
                  </div>

                  {/* Arabic Name Input */}
                  <div>
                    <label className="block text-xs font-bold text-zinc-800 dark:text-zinc-200 mb-1.5">
                      {isAr ? 'الاسم بالعربية (Arabic Name)' : 'Arabic Name'}
                      <span className="text-rose-500 ms-1">*</span>
                    </label>
                    <input
                      type="text"
                      value={formNameAr}
                      onChange={handleNameArChange}
                      onKeyDown={handleArabicKeyDown}
                      placeholder="مثال: مطاعم ومأكولات"
                      dir="rtl"
                      className={`w-full rounded-xl border ${
                        formErrors.nameAr
                          ? 'border-rose-500'
                          : 'border-zinc-300 dark:border-zinc-700 focus:border-zinc-950 dark:focus:border-white'
                      } bg-zinc-50/80 dark:bg-zinc-950 focus:bg-white dark:focus:bg-zinc-950 px-3.5 py-2.5 text-xs text-zinc-900 dark:text-white placeholder:text-zinc-400 dark:placeholder:text-zinc-500 focus:outline-hidden focus:ring-1 focus:ring-zinc-950 dark:focus:ring-white transition shadow-2xs`}
                    />
                    {formErrors.nameAr && (
                      <p className="text-[11px] text-rose-500 dark:text-rose-400 mt-1 font-semibold">
                        {formErrors.nameAr}
                      </p>
                    )}
                  </div>

                  {/* Category Type Toggle (Cards) */}
                  <div>
                    <label className="block text-xs font-bold text-zinc-800 dark:text-zinc-200 mb-1.5">
                      {isAr ? 'نوع التصنيف المالي' : 'Financial Type'}
                      <span className="text-rose-500 ms-1">*</span>
                    </label>
                    <div className="grid grid-cols-2 gap-3">
                      {/* Expense Card */}
                      <button
                        type="button"
                        onClick={() => setFormType('Expense')}
                        className={`p-3 rounded-2xl border transition flex items-center justify-between text-start cursor-pointer shadow-2xs ${
                          formType === 'Expense'
                            ? 'bg-rose-50/90 dark:bg-rose-950/30 border-rose-300 dark:border-rose-800 ring-2 ring-rose-500/20'
                            : 'bg-white dark:bg-zinc-900/40 border-zinc-200 dark:border-zinc-800 hover:bg-zinc-50 dark:hover:bg-zinc-850 hover:border-zinc-300 dark:hover:border-zinc-700'
                        }`}
                      >
                        <div className="flex items-center gap-2.5">
                          <div
                            className={`h-8 w-8 rounded-xl flex items-center justify-center ${
                              formType === 'Expense'
                                ? 'bg-rose-500 text-white shadow-xs'
                                : 'bg-zinc-100 dark:bg-zinc-800 text-zinc-500 dark:text-zinc-400'
                            }`}
                          >
                            <TrendingDown className="h-4 w-4" />
                          </div>
                          <div>
                            <div
                              className={`text-xs font-bold ${
                                formType === 'Expense'
                                  ? 'text-rose-700 dark:text-rose-400'
                                  : 'text-zinc-800 dark:text-zinc-200'
                              }`}
                            >
                              {isAr ? 'مصروف' : 'Expense'}
                            </div>
                            <div
                              className={`text-[10px] ${
                                formType === 'Expense'
                                  ? 'text-rose-600/80 dark:text-rose-300/70'
                                  : 'text-zinc-500 dark:text-zinc-400'
                              }`}
                            >
                              {isAr ? 'نفقات ومدفوعات' : 'Outflow / Cost'}
                            </div>
                          </div>
                        </div>
                        {formType === 'Expense' && (
                          <div className="h-2 w-2 rounded-full bg-rose-500" />
                        )}
                      </button>

                      {/* Income Card */}
                      <button
                        type="button"
                        onClick={() => setFormType('Income')}
                        className={`p-3 rounded-2xl border transition flex items-center justify-between text-start cursor-pointer shadow-2xs ${
                          formType === 'Income'
                            ? 'bg-emerald-50/90 dark:bg-emerald-950/30 border-emerald-300 dark:border-emerald-800 ring-2 ring-emerald-500/20'
                            : 'bg-white dark:bg-zinc-900/40 border-zinc-200 dark:border-zinc-800 hover:bg-zinc-50 dark:hover:bg-zinc-850 hover:border-zinc-300 dark:hover:border-zinc-700'
                        }`}
                      >
                        <div className="flex items-center gap-2.5">
                          <div
                            className={`h-8 w-8 rounded-xl flex items-center justify-center ${
                              formType === 'Income'
                                ? 'bg-emerald-500 text-white shadow-xs'
                                : 'bg-zinc-100 dark:bg-zinc-800 text-zinc-500 dark:text-zinc-400'
                            }`}
                          >
                            <TrendingUp className="h-4 w-4" />
                          </div>
                          <div>
                            <div
                              className={`text-xs font-bold ${
                                formType === 'Income'
                                  ? 'text-emerald-700 dark:text-emerald-400'
                                  : 'text-zinc-800 dark:text-zinc-200'
                              }`}
                            >
                              {isAr ? 'دخل' : 'Income'}
                            </div>
                            <div
                              className={`text-[10px] ${
                                formType === 'Income'
                                  ? 'text-emerald-600/80 dark:text-emerald-300/70'
                                  : 'text-zinc-500 dark:text-zinc-400'
                              }`}
                            >
                              {isAr ? 'أرباح وإيرادات' : 'Inflow / Earning'}
                            </div>
                          </div>
                        </div>
                        {formType === 'Income' && (
                          <div className="h-2 w-2 rounded-full bg-emerald-500" />
                        )}
                      </button>
                    </div>
                  </div>
                </div>

                {/* Column 2: Icon Selection & Live Preview */}
                <div className="space-y-4.5">
                  {/* Category Icon Selector */}
                  <div>
                    <div className="flex items-center justify-between mb-1.5">
                      <label className="block text-xs font-bold text-zinc-800 dark:text-zinc-200">
                        {isAr ? 'أيقونة التصنيف' : 'Category Icon'}
                      </label>
                      <span className="text-[10px] text-zinc-500 dark:text-zinc-400 font-mono">
                        {AVAILABLE_ICONS.length} {isAr ? 'أيقونة متاحة' : 'icons'}
                      </span>
                    </div>

                    <div className="grid grid-cols-4 sm:grid-cols-5 gap-1.5 p-2 rounded-2xl bg-zinc-50/90 dark:bg-zinc-950 border border-zinc-200 dark:border-zinc-800 max-h-40 overflow-y-auto">
                      {AVAILABLE_ICONS.map((item) => {
                        const isSelected = formIcon === item.id;
                        return (
                          <button
                            key={item.id}
                            type="button"
                            onClick={() => setFormIcon(item.id)}
                            title={isAr ? item.labelAr : item.labelEn}
                            className={`flex flex-col items-center justify-center py-2 px-1 rounded-xl transition cursor-pointer ${
                              isSelected
                                ? 'bg-zinc-950 text-white dark:bg-white dark:text-zinc-950 shadow-xs ring-2 ring-zinc-950 dark:ring-white ring-offset-1 ring-offset-white dark:ring-offset-zinc-900 font-bold'
                                : 'text-zinc-600 dark:text-zinc-400 hover:bg-white dark:hover:bg-zinc-800 hover:text-zinc-950 dark:hover:text-white border border-transparent hover:border-zinc-200 dark:hover:border-zinc-700 shadow-2xs'
                            }`}
                          >
                            {renderCategoryIcon(item.id, 'h-4 w-4')}
                            <span className="text-[9px] mt-1 truncate max-w-full font-medium opacity-90">
                              {isAr ? item.labelAr : item.labelEn}
                            </span>
                          </button>
                        );
                      })}
                    </div>
                  </div>

                  {/* Live Appearance Preview */}
                  <div>
                    <div className="flex items-center justify-between mb-1.5">
                      <span className="text-xs font-bold text-zinc-800 dark:text-zinc-200">
                        {isAr ? 'معاينة المظهر المباشر' : 'Live Appearance Preview'}
                      </span>
                      <Badge
                        variant={formType === 'Expense' ? 'danger' : 'success'}
                        className="text-[10px] font-semibold"
                      >
                        {formType === 'Expense' ? (isAr ? 'مصروف' : 'Expense') : (isAr ? 'دخل' : 'Income')}
                      </Badge>
                    </div>

                    <div className="p-4 rounded-2xl border-2 border-dashed border-zinc-200 dark:border-zinc-800 bg-zinc-50/90 dark:bg-zinc-900/40 flex items-center gap-3.5">
                      <div className="h-11 w-11 rounded-2xl bg-zinc-950 dark:bg-zinc-100 text-white dark:text-zinc-950 flex items-center justify-center font-bold shadow-xs shrink-0">
                        {renderCategoryIcon(formIcon, 'h-5 w-5')}
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="text-xs font-bold text-zinc-950 dark:text-white truncate">
                          {formNameEn || (isAr ? 'اسم التصنيف بالإنجليزي' : 'Category Name (En)')}
                        </div>
                        <div className="text-[11px] text-zinc-600 dark:text-zinc-400 font-semibold font-arabic truncate mt-0.5">
                          {formNameAr || (isAr ? 'اسم التصنيف بالعربي' : 'Category Name (Ar)')}
                        </div>
                      </div>
                      <span className="text-[10px] font-mono font-medium px-2 py-0.5 rounded-md bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-500/10 dark:text-emerald-400 dark:border-emerald-500/20 shrink-0">
                        {isAr ? 'نشط' : 'Active'}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Footer */}
            <div className="px-6 py-4 sm:px-7 bg-zinc-50 dark:bg-zinc-900/60 border-t border-zinc-200/90 dark:border-zinc-800/80 flex items-center justify-between gap-3 mt-auto">
              <span className="text-[11px] text-zinc-500 dark:text-zinc-400 font-medium">
                {isAr ? '* الحقول المؤشرة إلزامية' : '* Required fields'}
              </span>

              <div className="flex items-center gap-2.5">
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
                  size="sm"
                  isLoading={isSubmitting}
                  className="gap-1.5"
                >
                  <Check className="h-3.5 w-3.5" />
                  <span>
                    {mode === 'create'
                      ? isAr
                        ? 'إضافة التصنيف'
                        : 'Create Category'
                      : isAr
                      ? 'حفظ التعديلات'
                      : 'Save Changes'}
                  </span>
                </Button>
              </div>
            </div>
          </form>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
};
