import React, { useState, useEffect } from 'react';
import { X, Plus, Trash2, Sparkles, CheckCircle2, ShieldCheck } from 'lucide-react';
import type { PricingPlan, CreatePricingPlanPayload, UpdatePricingPlanPayload } from '../types';
import { useLocale } from '../../../core/context/LocaleContext';
import {
  sanitizeEnglishInput,
  sanitizeArabicInput,
  handleEnglishOnlyKeyDown,
  handleArabicOnlyKeyDown,
} from '../../../core/utils/sanitizers';

interface PlanModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (payload: CreatePricingPlanPayload | UpdatePricingPlanPayload) => Promise<void>;
  initialPlan?: PricingPlan | null;
  isLoading?: boolean;
}

interface FeatureItem {
  en: string;
  ar: string;
}

export const PlanModal: React.FC<PlanModalProps> = ({
  isOpen,
  onClose,
  onSubmit,
  initialPlan,
  isLoading = false,
}) => {
  const { t } = useLocale();
  const mI18n = t.subscriptions.plans.modal;
  const isEdit = !!initialPlan;

  const [name, setName] = useState('');
  const [nameAr, setNameAr] = useState('');
  const [priceEgp, setPriceEgp] = useState<number>(0);
  const [billingCycle, setBillingCycle] = useState<'Monthly' | 'Yearly' | 'Lifetime'>('Monthly');
  const [description, setDescription] = useState('');
  const [descriptionAr, setDescriptionAr] = useState('');

  // Paired bilingual features
  const [featureList, setFeatureList] = useState<FeatureItem[]>([]);
  const [featEnInput, setFeatEnInput] = useState('');
  const [featArInput, setFeatArInput] = useState('');

  const [isPopular, setIsPopular] = useState(false);
  const [isActive, setIsActive] = useState(true);
  const [maxWallets, setMaxWallets] = useState<number>(1);
  const [maxAiRequestsPerMonth, setMaxAiRequestsPerMonth] = useState<number>(15);
  const [canExportReports, setCanExportReports] = useState(false);
  const [canUseMultiCurrency, setCanUseMultiCurrency] = useState(false);

  useEffect(() => {
    if (initialPlan) {
      setName(initialPlan.name || '');
      setNameAr(initialPlan.nameAr || '');
      setPriceEgp(initialPlan.priceEgp || 0);
      setBillingCycle(initialPlan.billingCycle || 'Monthly');
      setDescription(initialPlan.description || '');
      setDescriptionAr(initialPlan.descriptionAr || '');

      const enFeats = initialPlan.features || [];
      const arFeats = initialPlan.featuresAr || [];
      const maxLen = Math.max(enFeats.length, arFeats.length);
      const paired: FeatureItem[] = [];
      for (let i = 0; i < maxLen; i++) {
        paired.push({
          en: enFeats[i] || '',
          ar: arFeats[i] || '',
        });
      }
      setFeatureList(paired);

      setIsPopular(initialPlan.isPopular || false);
      setIsActive(initialPlan.isActive !== false);
      setMaxWallets(initialPlan.maxWallets || 1);
      setMaxAiRequestsPerMonth(initialPlan.maxAiRequestsPerMonth || 15);
      setCanExportReports(initialPlan.canExportReports || false);
      setCanUseMultiCurrency(initialPlan.canUseMultiCurrency || false);
    } else {
      setName('');
      setNameAr('');
      setPriceEgp(0);
      setBillingCycle('Monthly');
      setDescription('');
      setDescriptionAr('');
      setFeatureList([
        { en: '1 Cash Wallet', ar: 'محفظة نقدية واحدة' },
        { en: '15 AI Voice Expenses / Month', ar: '15 معاملة صوتية بالذكاء الاصطناعي شهرياً' },
        { en: 'Standard Analytics', ar: 'تحليلات وتقارير مالية قياسية' },
      ]);
      setIsPopular(false);
      setIsActive(true);
      setMaxWallets(1);
      setMaxAiRequestsPerMonth(15);
      setCanExportReports(false);
      setCanUseMultiCurrency(false);
    }
  }, [initialPlan, isOpen]);

  if (!isOpen) return null;

  const handleAddFeature = () => {
    const cleanEn = sanitizeEnglishInput(featEnInput).trim();
    const cleanAr = sanitizeArabicInput(featArInput).trim();
    if (!cleanEn && !cleanAr) return;

    setFeatureList([...featureList, { en: cleanEn, ar: cleanAr }]);
    setFeatEnInput('');
    setFeatArInput('');
  };

  const handleRemoveFeature = (idx: number) => {
    setFeatureList(featureList.filter((_, i) => i !== idx));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const enFeatures = featureList.map((f) => f.en).filter(Boolean);
    const arFeatures = featureList.map((f) => f.ar).filter(Boolean);

    await onSubmit({
      name: sanitizeEnglishInput(name).trim(),
      nameAr: sanitizeArabicInput(nameAr).trim(),
      priceEgp: Number(priceEgp),
      billingCycle,
      description: sanitizeEnglishInput(description).trim(),
      descriptionAr: sanitizeArabicInput(descriptionAr).trim(),
      features: enFeatures,
      featuresAr: arFeatures,
      isPopular,
      isActive,
      maxWallets: Number(maxWallets),
      maxAiRequestsPerMonth: Number(maxAiRequestsPerMonth),
      canExportReports,
      canUseMultiCurrency,
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-xs p-4 sm:p-6 overflow-y-auto">
      <div className="relative w-full max-w-4xl rounded-xl bg-white dark:bg-zinc-950 shadow-2xl border border-zinc-200 dark:border-zinc-800 my-auto overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-zinc-100 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900/40">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-600 text-white shadow-xs">
              <Sparkles className="h-5 w-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-zinc-950 dark:text-white">
                {isEdit ? mI18n.editTitle : mI18n.createTitle}
              </h2>
              <p className="text-xs text-zinc-500 dark:text-zinc-400">
                {isEdit ? mI18n.editSubtitle : mI18n.createSubtitle}
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

        {/* Form Body: Wide 2-Column Landscape Layout */}
        <form onSubmit={handleSubmit} className="flex flex-col">
          <div className="p-6 grid grid-cols-1 lg:grid-cols-12 gap-6 max-h-[70vh] overflow-y-auto">
            {/* Column 1: Core Details & Limits (7 cols) */}
            <div className="lg:col-span-7 space-y-4">
              {/* Names */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                    {mI18n.nameEn} *
                  </label>
                  <input
                    type="text"
                    required
                    value={name}
                    onChange={(e) => setName(sanitizeEnglishInput(e.target.value))}
                    onKeyDown={(e) => handleEnglishOnlyKeyDown(e)}
                    placeholder={mI18n.nameEnPlaceholder}
                    className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 font-sans"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                    {mI18n.nameAr} *
                  </label>
                  <input
                    type="text"
                    required
                    value={nameAr}
                    onChange={(e) => setNameAr(sanitizeArabicInput(e.target.value))}
                    onKeyDown={(e) => handleArabicOnlyKeyDown(e)}
                    placeholder={mI18n.nameArPlaceholder}
                    dir="rtl"
                    className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 font-arabic"
                  />
                </div>
              </div>

              {/* Price & Billing Cycle */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                    {mI18n.priceEgp} *
                  </label>
                  <input
                    type="number"
                    min="0"
                    step="0.01"
                    required
                    value={priceEgp}
                    onChange={(e) => setPriceEgp(Number(e.target.value))}
                    className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 font-mono"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                    {mI18n.billingCycle} *
                  </label>
                  <select
                    value={billingCycle}
                    onChange={(e) => setBillingCycle(e.target.value as any)}
                    className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 cursor-pointer"
                  >
                    <option value="Monthly">{mI18n.monthlyOption}</option>
                    <option value="Yearly">{mI18n.yearlyOption}</option>
                    <option value="Lifetime">{mI18n.lifetimeOption}</option>
                  </select>
                </div>
              </div>

              {/* Descriptions */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                    {mI18n.descriptionEn}
                  </label>
                  <textarea
                    rows={2}
                    value={description}
                    onChange={(e) => setDescription(sanitizeEnglishInput(e.target.value))}
                    onKeyDown={(e) => handleEnglishOnlyKeyDown(e)}
                    placeholder={mI18n.descriptionEnPlaceholder}
                    className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 font-sans"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                    {mI18n.descriptionAr}
                  </label>
                  <textarea
                    rows={2}
                    value={descriptionAr}
                    onChange={(e) => setDescriptionAr(sanitizeArabicInput(e.target.value))}
                    onKeyDown={(e) => handleArabicOnlyKeyDown(e)}
                    placeholder={mI18n.descriptionArPlaceholder}
                    dir="rtl"
                    className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 font-arabic"
                  />
                </div>
              </div>

              {/* Limits */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                    {mI18n.maxWallets}
                  </label>
                  <input
                    type="number"
                    min="1"
                    required
                    value={maxWallets}
                    onChange={(e) => setMaxWallets(Number(e.target.value))}
                    className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 font-mono"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-zinc-700 dark:text-zinc-300 mb-1">
                    {mI18n.maxAiRequests}
                  </label>
                  <input
                    type="number"
                    min="0"
                    required
                    value={maxAiRequestsPerMonth}
                    onChange={(e) => setMaxAiRequestsPerMonth(Number(e.target.value))}
                    className="w-full bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 font-mono"
                  />
                </div>
              </div>

              {/* Toggles */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800 text-xs">
                <label className="flex items-center gap-2 p-2 rounded-lg bg-zinc-50 dark:bg-zinc-900 border border-zinc-200/70 dark:border-zinc-800/80 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={isPopular}
                    onChange={(e) => setIsPopular(e.target.checked)}
                    className="h-4 w-4 rounded text-blue-600 focus:ring-blue-500"
                  />
                  <span className="font-bold text-zinc-900 dark:text-zinc-100">
                    {mI18n.highlightPopular}
                  </span>
                </label>

                <label className="flex items-center gap-2 p-2 rounded-lg bg-zinc-50 dark:bg-zinc-900 border border-zinc-200/70 dark:border-zinc-800/80 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={isActive}
                    onChange={(e) => setIsActive(e.target.checked)}
                    className="h-4 w-4 rounded text-emerald-600 focus:ring-emerald-500"
                  />
                  <span className="font-bold text-zinc-900 dark:text-zinc-100">
                    {mI18n.activeAvailable}
                  </span>
                </label>

                <label className="flex items-center gap-2 p-2 rounded-lg bg-zinc-50 dark:bg-zinc-900 border border-zinc-200/70 dark:border-zinc-800/80 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={canExportReports}
                    onChange={(e) => setCanExportReports(e.target.checked)}
                    className="h-4 w-4 rounded text-blue-600 focus:ring-blue-500"
                  />
                  <span className="text-zinc-700 dark:text-zinc-300">
                    {mI18n.allowExport}
                  </span>
                </label>

                <label className="flex items-center gap-2 p-2 rounded-lg bg-zinc-50 dark:bg-zinc-900 border border-zinc-200/70 dark:border-zinc-800/80 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={canUseMultiCurrency}
                    onChange={(e) => setCanUseMultiCurrency(e.target.checked)}
                    className="h-4 w-4 rounded text-blue-600 focus:ring-blue-500"
                  />
                  <span className="text-zinc-700 dark:text-zinc-300">
                    {mI18n.allowMultiCurrency}
                  </span>
                </label>
              </div>
            </div>

            {/* Column 2: Bilingual Features Manager (5 cols) */}
            <div className="lg:col-span-5 flex flex-col rounded-lg border border-zinc-200 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900/40 p-4 space-y-3">
              <div className="flex items-center justify-between pb-2 border-b border-zinc-200/60 dark:border-zinc-800/60">
                <div className="flex items-center gap-2">
                  <ShieldCheck className="h-4 w-4 text-blue-500" />
                  <label className="text-xs font-bold text-zinc-900 dark:text-zinc-100">
                    {mI18n.featuresSectionTitle}
                  </label>
                </div>
                <span className="text-[11px] font-bold text-blue-600 dark:text-blue-400 bg-blue-500/10 px-2 py-0.5 rounded-md">
                  {featureList.length} {mI18n.featuresCountSuffix}
                </span>
              </div>

              {/* Add feature row with strict language sanitization */}
              <div className="space-y-2">
                <input
                  type="text"
                  value={featEnInput}
                  onChange={(e) => setFeatEnInput(sanitizeEnglishInput(e.target.value))}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      handleAddFeature();
                    } else {
                      handleEnglishOnlyKeyDown(e);
                    }
                  }}
                  placeholder={mI18n.featureEnPlaceholder}
                  className="w-full bg-white dark:bg-zinc-950 border border-zinc-200 dark:border-zinc-700 rounded-lg px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 font-sans"
                />
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={featArInput}
                    onChange={(e) => setFeatArInput(sanitizeArabicInput(e.target.value))}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') {
                        e.preventDefault();
                        handleAddFeature();
                      } else {
                        handleArabicOnlyKeyDown(e);
                      }
                    }}
                    dir="rtl"
                    placeholder={mI18n.featureArPlaceholder}
                    className="flex-1 bg-white dark:bg-zinc-950 border border-zinc-200 dark:border-zinc-700 rounded-lg px-3 py-2 text-xs text-zinc-900 dark:text-white focus:outline-hidden focus:ring-2 focus:ring-blue-500 font-arabic"
                  />
                  <button
                    type="button"
                    onClick={handleAddFeature}
                    className="flex items-center gap-1 px-3.5 py-2 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold shadow-xs transition cursor-pointer shrink-0"
                  >
                    <Plus className="h-4 w-4" />
                    <span>{mI18n.addFeature}</span>
                  </button>
                </div>
              </div>

              {/* Features List */}
              <div className="flex-1 min-h-[160px] max-h-[260px] overflow-y-auto space-y-2 pe-1 pt-1">
                {featureList.length > 0 ? (
                  featureList.map((feat, idx) => (
                    <div
                      key={idx}
                      className="flex items-center justify-between gap-2.5 bg-white dark:bg-zinc-950 px-3 py-2 rounded-lg border border-zinc-200 dark:border-zinc-800 text-xs shadow-2xs"
                    >
                      <div className="flex items-start gap-2 flex-1 min-w-0">
                        <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500 shrink-0 mt-0.5" />
                        <div className="flex-1 min-w-0 space-y-0.5">
                          <p className="text-zinc-800 dark:text-zinc-200 font-medium truncate font-sans">
                            {feat.en || <span className="text-zinc-400 italic">{mI18n.noEnFeature}</span>}
                          </p>
                          <p className="text-zinc-500 dark:text-zinc-400 font-arabic text-[11px] truncate" dir="rtl">
                            {feat.ar || <span className="text-zinc-400 italic">{mI18n.noArFeature}</span>}
                          </p>
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={() => handleRemoveFeature(idx)}
                        className="p-1 rounded-md text-zinc-400 hover:text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/30 transition cursor-pointer shrink-0"
                        title={mI18n.removeFeature}
                      >
                        <Trash2 className="h-3.5 w-3.5" />
                      </button>
                    </div>
                  ))
                ) : (
                  <div className="h-full flex flex-col items-center justify-center text-center p-4 text-zinc-400 text-xs">
                    <p>{mI18n.noFeaturesYet}</p>
                    <p className="text-[11px] text-zinc-500 mt-1">
                      {mI18n.noFeaturesHelper}
                    </p>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Sticky Rectangular Footer Bar */}
          <div className="flex items-center justify-end gap-3 px-6 py-4 border-t border-zinc-100 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900/40">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-xs font-semibold rounded-lg bg-white dark:bg-zinc-900 hover:bg-zinc-100 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-200 border border-zinc-200 dark:border-zinc-700 transition cursor-pointer"
            >
              {mI18n.cancel}
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="px-6 py-2 text-xs font-bold rounded-lg bg-blue-600 hover:bg-blue-700 text-white shadow-md hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed transition cursor-pointer flex items-center gap-2"
            >
              {isLoading && <span className="h-3.5 w-3.5 border-2 border-white border-t-transparent rounded-full animate-spin" />}
              <span>
                {isLoading
                  ? mI18n.saving
                  : isEdit
                  ? mI18n.saveChanges
                  : mI18n.createPlan}
              </span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
