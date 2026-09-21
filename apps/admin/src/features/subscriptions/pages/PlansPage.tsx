import React, { useState, useEffect } from 'react';
import { Check, Plus, Sparkles, Edit2, Trash2, Shield, RefreshCw, GripVertical, ArrowUpDown, Loader2 } from 'lucide-react';
import { Reorder } from 'framer-motion';
import { useSubscriptions } from '../hooks/useSubscriptions';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { formatCurrency } from '../../../core/utils/formatters';
import { PlanModal } from '../components/PlanModal';
import { DeleteConfirmModal } from '../../../core/components/ui/DeleteConfirmModal';
import { useLocale } from '../../../core/context/LocaleContext';
import type { PricingPlan, CreatePricingPlanPayload, UpdatePricingPlanPayload } from '../types';

export const PlansPage: React.FC = () => {
  const { isAr, t } = useLocale();
  const i18n = t.subscriptions.plans;

  const {
    plans,
    isLoadingPlans,
    createPlan,
    isCreatingPlan,
    updatePlan,
    isUpdatingPlan,
    deletePlan,
    isDeletingPlan,
    reorderPlans,
    isReorderingPlans,
    refetchPlans,
  } = useSubscriptions();

  // Local state for interactive drag-and-drop
  const [orderedPlans, setOrderedPlans] = useState<PricingPlan[]>([]);
  const reorderTimerRef = React.useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    if (plans && plans.length > 0) {
      // Sort initially by displayOrder (if set) or price
      const sorted = [...plans].sort((a, b) => (a.displayOrder ?? 0) - (b.displayOrder ?? 0) || a.priceEgp - b.priceEgp);
      setOrderedPlans(sorted);
    } else {
      setOrderedPlans([]);
    }
  }, [plans]);

  // Clean up timer on unmount
  useEffect(() => {
    return () => {
      if (reorderTimerRef.current) {
        clearTimeout(reorderTimerRef.current);
      }
    };
  }, []);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState<PricingPlan | null>(null);

  // Delete modal state
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [planToDelete, setPlanToDelete] = useState<PricingPlan | null>(null);

  const handleOpenCreate = () => {
    setSelectedPlan(null);
    setIsModalOpen(true);
  };

  const handleOpenEdit = (plan: PricingPlan) => {
    setSelectedPlan(plan);
    setIsModalOpen(true);
  };

  const handleSubmitModal = async (
    payload: CreatePricingPlanPayload | UpdatePricingPlanPayload
  ) => {
    if (selectedPlan) {
      await updatePlan({ id: selectedPlan.id, payload: payload as UpdatePricingPlanPayload });
    } else {
      await createPlan(payload as CreatePricingPlanPayload);
    }
  };

  const handleOpenDelete = (plan: PricingPlan) => {
    setPlanToDelete(plan);
    setIsDeleteModalOpen(true);
  };

  const handleConfirmDelete = async () => {
    if (planToDelete) {
      await deletePlan(planToDelete.id);
      setIsDeleteModalOpen(false);
      setPlanToDelete(null);
    }
  };

  // Smooth drag and drop reordering with debounce to prevent UI stutter/hangs
  const handleReorder = (newOrder: PricingPlan[]) => {
    setOrderedPlans(newOrder);

    if (reorderTimerRef.current) {
      clearTimeout(reorderTimerRef.current);
    }

    reorderTimerRef.current = setTimeout(() => {
      reorderPlans(newOrder.map((p) => p.id));
    }, 400);
  };

  const handleDragEnd = () => {
    if (reorderTimerRef.current) {
      clearTimeout(reorderTimerRef.current);
    }
    reorderPlans(orderedPlans.map((p) => p.id));
  };

  // Quick action: Sort by cheapest first
  const handleSortByCheapest = async () => {
    if (reorderTimerRef.current) {
      clearTimeout(reorderTimerRef.current);
    }
    const sorted = [...orderedPlans].sort((a, b) => a.priceEgp - b.priceEgp);
    setOrderedPlans(sorted);
    await reorderPlans(sorted.map((p) => p.id));
  };

  // Check if count is odd (3, 5, etc.) to elevate the middle card
  const isOddCount = orderedPlans.length % 2 !== 0 && orderedPlans.length >= 3;
  const middleIndex = isOddCount ? Math.floor(orderedPlans.length / 2) : -1;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-950 dark:text-white flex items-center gap-2.5">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-600 text-white shadow-md">
              <Shield className="h-5 w-5" />
            </div>
            <span>{i18n.pageTitle}</span>
          </h1>
          <p className="text-xs sm:text-sm text-zinc-500 dark:text-zinc-400 mt-1 font-medium">
            {i18n.pageSubtitle}
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={handleSortByCheapest}
            disabled={isReorderingPlans || orderedPlans.length <= 1}
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold bg-white dark:bg-zinc-900 hover:bg-zinc-100 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-200 border border-zinc-200 dark:border-zinc-700 shadow-2xs transition cursor-pointer disabled:opacity-50"
            title={i18n.sortByPrice}
          >
            {isReorderingPlans ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin text-blue-600" />
            ) : (
              <ArrowUpDown className="h-3.5 w-3.5 text-blue-600 dark:text-blue-400" />
            )}
            <span>{i18n.sortByPrice}</span>
          </button>

          <button
            onClick={() => refetchPlans()}
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold bg-white dark:bg-zinc-900 hover:bg-zinc-100 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-200 border border-zinc-200 dark:border-zinc-700 shadow-2xs transition cursor-pointer"
          >
            <RefreshCw className={`h-3.5 w-3.5 ${isLoadingPlans ? 'animate-spin' : ''}`} />
            <span>{i18n.refresh}</span>
          </button>

          <button
            onClick={handleOpenCreate}
            className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-blue-600 hover:bg-blue-700 text-white shadow-md hover:shadow-lg transition cursor-pointer"
          >
            <Plus className="h-4 w-4" />
            <span>{i18n.newPlan}</span>
          </button>
        </div>
      </div>

      {/* Drag & Drop Instructions Banner */}
      {orderedPlans.length > 1 && (
        <div className="flex items-center justify-between px-4 py-2.5 rounded-xl bg-blue-50/70 dark:bg-blue-950/20 border border-blue-200/60 dark:border-blue-800/40 text-blue-900 dark:text-blue-300 text-xs font-medium">
          <div className="flex items-center gap-2">
            <GripVertical className="h-4 w-4 text-blue-600 dark:text-blue-400 shrink-0" />
            <span>{i18n.dragHint}</span>
          </div>
          {isReorderingPlans && (
            <span className="flex items-center gap-1.5 text-xs text-blue-600 dark:text-blue-400 font-bold">
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
              <span>{isAr ? 'جاري حفظ الترتيب...' : 'Saving order...'}</span>
            </span>
          )}
        </div>
      )}

      {/* Plans Grid / Reorder List */}
      {isLoadingPlans ? (
        <div className="p-16 text-center text-zinc-400 text-xs font-medium flex flex-col items-center justify-center gap-3">
          <RefreshCw className="h-6 w-6 animate-spin text-blue-500" />
          <span>{i18n.loading}</span>
        </div>
      ) : orderedPlans.length === 0 ? (
        <Card className="p-12 text-center text-zinc-400 border-dashed border-2">
          <Shield className="h-12 w-12 mx-auto text-zinc-300 dark:text-zinc-700 mb-3" />
          <p className="text-sm font-bold text-zinc-700 dark:text-zinc-300">
            {i18n.emptyTitle}
          </p>
          <button
            onClick={handleOpenCreate}
            className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-blue-600 hover:bg-blue-700 text-white shadow-md transition cursor-pointer"
          >
            <Plus className="h-4 w-4" />
            <span>{i18n.createFirst}</span>
          </button>
        </Card>
      ) : (
        <Reorder.Group
          as="div"
          values={orderedPlans}
          onReorder={handleReorder}
          className="grid grid-cols-1 gap-6 md:grid-cols-3 items-stretch md:pt-6 md:pb-6"
        >
          {orderedPlans.map((plan, index) => {
            const isMiddle = isOddCount && index === middleIndex;
            // Strict Bilingual Resolution
            const title = isAr ? (plan.nameAr || plan.name) : plan.name;
            const desc = isAr ? (plan.descriptionAr || plan.description) : plan.description;
            const currentFeatures = isAr
              ? (plan.featuresAr && plan.featuresAr.length > 0 ? plan.featuresAr : plan.features)
              : plan.features;

            const cycleLabel =
              plan.billingCycle === 'Monthly'
                ? i18n.card.monthly
                : plan.billingCycle === 'Yearly'
                ? i18n.card.yearly
                : i18n.card.lifetime;

            const cyclePeriod =
              plan.billingCycle === 'Monthly' ? i18n.card.perMonth : i18n.card.perYear;

            return (
              <Reorder.Item
                key={plan.id}
                value={plan}
                as="div"
                onDragEnd={handleDragEnd}
                className={`h-full cursor-grab active:cursor-grabbing select-none transition-all duration-300 ${
                  isMiddle ? 'md:-translate-y-4 md:scale-[1.03] z-20' : 'z-10'
                }`}
                whileDrag={{
                  scale: 1.05,
                  zIndex: 50,
                  boxShadow: '0 25px 30px -5px rgb(0 0 0 / 0.25)',
                }}
              >
                <Card
                  className={`relative flex flex-col justify-between p-6 rounded-2xl transition-all duration-300 border h-full ${
                    isMiddle
                      ? 'border-blue-500/90 dark:border-blue-400/90 bg-gradient-to-b from-blue-500/[0.08] to-blue-500/[0.01] shadow-2xl ring-2 ring-blue-500/40 dark:ring-blue-400/40 md:py-8'
                      : plan.isPopular
                      ? 'border-blue-500/60 dark:border-blue-500/50 bg-gradient-to-b from-blue-500/[0.04] to-transparent shadow-lg ring-1 ring-blue-500/20'
                      : 'border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-xs hover:border-zinc-300 dark:hover:border-zinc-700'
                  } ${!plan.isActive ? 'opacity-65' : ''}`}
                >
                  <div>
                    {/* Top Badges & Drag Handle */}
                    <div className="flex items-center justify-between mb-3.5">
                      <div className="flex items-center gap-2">
                        <div
                          className="p-1 rounded-md text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition"
                          title={isAr ? 'اسحب لإعادة الترتيب' : 'Drag to reorder'}
                        >
                          <GripVertical className="h-4 w-4" />
                        </div>
                        <Badge variant={isMiddle || plan.isPopular ? 'info' : 'default'} className="text-[11px] font-semibold px-2.5 py-0.5">
                          {cycleLabel}
                        </Badge>
                      </div>

                      {(isMiddle || plan.isPopular) && (
                        <span className="flex items-center gap-1.5 text-[11px] font-bold text-blue-600 dark:text-blue-400 bg-blue-500/10 dark:bg-blue-500/20 px-2.5 py-0.5 rounded-full border border-blue-500/30">
                          <Sparkles className="h-3.5 w-3.5" />
                          {i18n.card.mostPopular}
                        </span>
                      )}
                    </div>

                    {/* Plan Name */}
                    <h3 className={`text-lg font-black text-zinc-950 dark:text-white ${isAr ? 'font-arabic' : ''}`}>
                      {title}
                    </h3>

                    {/* Description */}
                    <p className={`mt-2 text-xs text-zinc-600 dark:text-zinc-400 leading-relaxed min-h-[36px] ${isAr ? 'font-arabic' : ''}`}>
                      {desc || (
                        <span className="text-zinc-400 italic">
                          {i18n.card.noDescription}
                        </span>
                      )}
                    </p>

                    {/* Price */}
                    <div className="mt-4 mb-5 pb-4 border-b border-zinc-100 dark:border-zinc-800">
                      <div className="flex items-baseline gap-1 font-mono">
                        <span className="text-3xl font-black text-zinc-950 dark:text-white">
                          {plan.priceEgp === 0
                            ? i18n.card.free
                            : formatCurrency(plan.priceEgp, 'EGP', isAr)}
                        </span>
                        {plan.priceEgp > 0 && (
                          <span className="text-xs font-bold text-zinc-400 font-sans">
                            {cyclePeriod}
                          </span>
                        )}
                      </div>
                    </div>

                    {/* Entitlements / Limits Summary */}
                    <div className="mb-4 grid grid-cols-2 gap-2 text-[11px] bg-zinc-50 dark:bg-zinc-900/60 p-2.5 rounded-xl border border-zinc-100 dark:border-zinc-800/80">
                      <div>
                        <span className="text-zinc-400 block">{i18n.card.wallets}</span>
                        <span className="font-bold text-zinc-800 dark:text-zinc-200">
                          {plan.maxWallets >= 999 ? i18n.card.unlimited : plan.maxWallets}
                        </span>
                      </div>
                      <div>
                        <span className="text-zinc-400 block">{i18n.card.aiRequests}</span>
                        <span className="font-bold text-zinc-800 dark:text-zinc-200">
                          {plan.maxAiRequestsPerMonth >= 9999 ? i18n.card.unlimited : plan.maxAiRequestsPerMonth}
                        </span>
                      </div>
                    </div>

                    {/* Limits & Feature Checklist */}
                    <div className="space-y-2.5">
                      <p className="text-[11px] font-bold uppercase tracking-wider text-zinc-400">
                        {i18n.card.includedFeatures}
                      </p>
                      {currentFeatures && currentFeatures.length > 0 ? (
                        currentFeatures.map((feature, idx) => (
                          <div key={idx} className="flex items-start gap-2 text-xs text-zinc-700 dark:text-zinc-300">
                            <div className="flex h-4 w-4 shrink-0 items-center justify-center rounded-full bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 mt-0.5">
                              <Check className="h-3 w-3" />
                            </div>
                            <span className={`leading-snug ${isAr ? 'font-arabic' : ''}`}>{feature}</span>
                          </div>
                        ))
                      ) : (
                        <p className="text-xs text-zinc-400 italic">
                          {i18n.card.noFeatures}
                        </p>
                      )}
                    </div>
                  </div>

                  {/* Card Footer with Action Buttons */}
                  <div className="mt-8 pt-4 border-t border-zinc-100 dark:border-zinc-800 flex items-center justify-between">
                    <span
                      className={`inline-flex items-center gap-1.5 text-xs font-bold ${
                        plan.isActive ? 'text-emerald-600 dark:text-emerald-400' : 'text-zinc-400'
                      }`}
                    >
                      <span className={`h-2 w-2 rounded-full ${plan.isActive ? 'bg-emerald-500' : 'bg-zinc-400'}`} />
                      {plan.isActive ? i18n.card.active : i18n.card.archived}
                    </span>

                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          handleOpenEdit(plan);
                        }}
                        className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold bg-zinc-100 hover:bg-zinc-200 dark:bg-zinc-800 dark:hover:bg-zinc-700 text-zinc-800 dark:text-zinc-100 border border-zinc-200 dark:border-zinc-700 transition cursor-pointer shadow-2xs"
                        title={i18n.card.edit}
                      >
                        <Edit2 className="h-3.5 w-3.5 text-zinc-600 dark:text-zinc-300" />
                        <span>{i18n.card.edit}</span>
                      </button>

                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          handleOpenDelete(plan);
                        }}
                        className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold bg-rose-50 hover:bg-rose-100 dark:bg-rose-950/40 dark:hover:bg-rose-900/60 text-rose-600 dark:text-rose-300 border border-rose-200 dark:border-rose-900/60 transition cursor-pointer shadow-2xs"
                        title={i18n.card.delete}
                      >
                        <Trash2 className="h-3.5 w-3.5 text-rose-500" />
                        <span>{i18n.card.delete}</span>
                      </button>
                    </div>
                  </div>
                </Card>
              </Reorder.Item>
            );
          })}
        </Reorder.Group>
      )}

      {/* Plan Modal */}
      <PlanModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSubmit={handleSubmitModal}
        initialPlan={selectedPlan}
        isLoading={isCreatingPlan || isUpdatingPlan}
      />

      {/* Dedicated Animated Delete Confirmation Modal */}
      <DeleteConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => {
          setIsDeleteModalOpen(false);
          setPlanToDelete(null);
        }}
        onConfirm={handleConfirmDelete}
        title={isAr ? 'حذف / أرشفة باقة الاشتراك' : 'Delete / Archive Pricing Plan'}
        description={
          isAr
            ? 'هل أنت متأكد من حذف هذه الباقة؟ إذا كان هناك مشتركون حاليون، فسيتم نقل الباقة إلى الأرشيف بأمان لضمان استمرار صلاحياتهم.'
            : 'Are you sure you want to delete this plan? If active subscribers exist, it will be safely archived to preserve their entitlements.'
        }
        itemName={isAr ? (planToDelete?.nameAr || planToDelete?.name) : planToDelete?.name}
        itemBadge={planToDelete?.billingCycle}
        impactWarnings={[
          isAr
            ? 'لن يتمكن أي مستخدم جديد من الاشتراك في هذه الباقة.'
            : 'New users will no longer be able to select or subscribe to this plan tier.',
          isAr
            ? 'سيحتفظ المشتركون الحاليون باشتراكاتهم حتى انتهاء فترتهم.'
            : 'Current active subscribers will maintain their benefits until expiration.',
        ]}
        confirmText={isAr ? 'نعم، احذف الباقة' : 'Yes, Delete Plan'}
        cancelText={i18n.modal.cancel}
        isDeleting={isDeletingPlan}
      />
    </div>
  );
};
