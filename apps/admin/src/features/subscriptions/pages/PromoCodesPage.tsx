import React, { useState } from 'react';
import { Plus, Tag, RefreshCw, Trash2, Clock, CheckCircle, XCircle } from 'lucide-react';
import { useSubscriptions } from '../hooks/useSubscriptions';
import { Card } from '../../../core/components/ui/Card';
import { formatDate } from '../../../core/utils/formatters';
import { PromoCodeModal } from '../components/PromoCodeModal';
import { DeleteConfirmModal } from '../../../core/components/ui/DeleteConfirmModal';
import { useLocale } from '../../../core/context/LocaleContext';
import type { PromoCode, CreatePromoCodePayload } from '../types';

export const PromoCodesPage: React.FC = () => {
  const { isAr, t } = useLocale();
  const i18n = t.subscriptions.promoCodes;

  const {
    promoCodes,
    isLoadingPromoCodes,
    createPromoCode,
    isCreatingPromoCode,
    togglePromoCode,
    isTogglingPromoCode,
    deletePromoCode,
    isDeletingPromoCode,
    refetchPromoCodes,
  } = useSubscriptions();

  const [isModalOpen, setIsModalOpen] = useState(false);

  // Delete modal state
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [promoToDelete, setPromoToDelete] = useState<PromoCode | null>(null);

  const handleCreateSubmit = async (payload: CreatePromoCodePayload) => {
    await createPromoCode(payload);
  };

  const handleOpenDelete = (promo: PromoCode) => {
    setPromoToDelete(promo);
    setIsDeleteModalOpen(true);
  };

  const handleConfirmDelete = async () => {
    if (promoToDelete) {
      await deletePromoCode(promoToDelete.id);
      setIsDeleteModalOpen(false);
      setPromoToDelete(null);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-zinc-950 dark:text-white flex items-center gap-2.5">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-500/15 text-amber-600 dark:text-amber-400 border border-amber-500/20">
              <Tag className="h-5 w-5" />
            </div>
            <span>{i18n.pageTitle}</span>
          </h1>
          <p className="text-xs sm:text-sm text-zinc-500 dark:text-zinc-400 mt-1 font-medium">
            {i18n.pageSubtitle}
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <button
            onClick={() => refetchPromoCodes()}
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-semibold bg-white dark:bg-zinc-900 hover:bg-zinc-100 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-200 border border-zinc-200 dark:border-zinc-700 shadow-2xs transition cursor-pointer"
          >
            <RefreshCw className={`h-3.5 w-3.5 ${isLoadingPromoCodes ? 'animate-spin' : ''}`} />
            <span>{i18n.refresh}</span>
          </button>

          <button
            onClick={() => setIsModalOpen(true)}
            className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-amber-600 hover:bg-amber-700 text-white shadow-md hover:shadow-lg transition cursor-pointer"
          >
            <Plus className="h-4 w-4" />
            <span>{i18n.newPromoCode}</span>
          </button>
        </div>
      </div>

      {/* Grid */}
      {isLoadingPromoCodes ? (
        <div className="p-16 text-center text-zinc-400 text-xs font-medium flex flex-col items-center justify-center gap-3">
          <RefreshCw className="h-6 w-6 animate-spin text-amber-500" />
          <span>{i18n.loading}</span>
        </div>
      ) : promoCodes.length === 0 ? (
        <Card className="p-12 text-center text-zinc-400 border-dashed border-2">
          <Tag className="h-12 w-12 mx-auto text-zinc-300 dark:text-zinc-700 mb-3" />
          <p className="text-sm font-bold text-zinc-700 dark:text-zinc-300">
            {i18n.emptyTitle}
          </p>
          <button
            onClick={() => setIsModalOpen(true)}
            className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-amber-600 hover:bg-amber-700 text-white shadow-md transition cursor-pointer"
          >
            <Plus className="h-4 w-4" />
            <span>{i18n.createFirst}</span>
          </button>
        </Card>
      ) : (
        <div className="grid grid-cols-1 gap-5 md:grid-cols-2 lg:grid-cols-3">
          {promoCodes.map((promo) => {
            const usagePercent = promo.maxUses > 0 ? Math.round((promo.usedCount / promo.maxUses) * 100) : 0;

            return (
              <Card
                key={promo.id}
                className={`p-5 rounded-2xl border transition-all duration-200 ${
                  promo.isActive
                    ? 'border-zinc-200 dark:border-zinc-800 bg-white dark:bg-[#121215] shadow-xs'
                    : 'border-zinc-200/60 dark:border-zinc-800/60 bg-zinc-50/50 dark:bg-zinc-900/20 opacity-75'
                }`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20">
                      <Tag className="h-5 w-5" />
                    </div>
                    <div>
                      <span className="font-mono text-base font-black tracking-wider text-zinc-950 dark:text-white">
                        {promo.code}
                      </span>
                      <p className="text-xs font-bold text-emerald-600 dark:text-emerald-400">
                        {promo.discountPercentage}% {i18n.card.discountOff}
                      </p>
                    </div>
                  </div>

                  {/* Toggle Status Button */}
                  <button
                    onClick={() => togglePromoCode(promo.id)}
                    disabled={isTogglingPromoCode}
                    className={`flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-bold border transition cursor-pointer ${
                      promo.isActive
                        ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/20 hover:bg-emerald-500/20'
                        : 'bg-zinc-100 dark:bg-zinc-800 text-zinc-500 border-zinc-200 dark:border-zinc-700 hover:bg-zinc-200'
                    }`}
                    title={i18n.card.toggleStatus}
                  >
                    {promo.isActive ? (
                      <>
                        <CheckCircle className="h-3 w-3" />
                        <span>{i18n.card.active}</span>
                      </>
                    ) : (
                      <>
                        <XCircle className="h-3 w-3" />
                        <span>{i18n.card.disabled}</span>
                      </>
                    )}
                  </button>
                </div>

                {/* Progress bar */}
                <div className="mt-5 space-y-1.5">
                  <div className="flex items-center justify-between text-xs text-zinc-500 font-medium">
                    <span>{i18n.card.redemptions}</span>
                    <span className="font-mono font-bold text-zinc-900 dark:text-white">
                      {promo.usedCount} / {promo.maxUses} ({usagePercent}%)
                    </span>
                  </div>
                  <div className="h-2 w-full bg-zinc-100 dark:bg-zinc-800 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-amber-500 rounded-full transition-all duration-500"
                      style={{ width: `${Math.min(100, usagePercent)}%` }}
                    />
                  </div>
                </div>

                {/* Footer details & Action */}
                <div className="mt-4 pt-3.5 border-t border-zinc-100 dark:border-zinc-800 flex items-center justify-between text-xs">
                  <div className="flex items-center gap-1.5 text-zinc-400 truncate">
                    <Clock className="h-3.5 w-3.5" />
                    <span>
                      {promo.expiresAt
                        ? `${i18n.card.expires} ${formatDate(promo.expiresAt)}`
                        : i18n.card.neverExpires}
                    </span>
                  </div>

                  <button
                    onClick={() => handleOpenDelete(promo)}
                    className="flex items-center gap-1 px-2 py-1 rounded-lg text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/40 border border-transparent hover:border-rose-200 dark:hover:border-rose-900/60 transition cursor-pointer"
                    title={i18n.card.delete}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                    <span>{i18n.card.delete}</span>
                  </button>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      {/* Promo Code Modal */}
      <PromoCodeModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSubmit={handleCreateSubmit}
        isLoading={isCreatingPromoCode}
      />

      {/* Dedicated Delete Confirmation Modal */}
      <DeleteConfirmModal
        isOpen={isDeleteModalOpen}
        onClose={() => {
          setIsDeleteModalOpen(false);
          setPromoToDelete(null);
        }}
        onConfirm={handleConfirmDelete}
        title={isAr ? 'حذف كود الخصم' : 'Delete Promo Code'}
        description={
          isAr
            ? 'هل أنت متأكد من رغبتك في حذف هذا الكود الترويجي؟ لن يتمكن المستخدمون من استخدامه بعد الحذف.'
            : 'Are you sure you want to delete this promotional voucher? Users will no longer be able to redeem it.'
        }
        itemName={promoToDelete?.code}
        itemBadge={promoToDelete ? `${promoToDelete.discountPercentage}% OFF` : undefined}
        impactWarnings={[
          isAr
            ? 'سيتم تعطيل الكود فوراً ومنع أي عمليات دفع مستقبلية باستخدامه.'
            : 'The code will be immediately deactivated and blocked from future checkouts.',
          isAr
            ? 'الاشتراكات السابقة التي استخدمت هذا الكود لن تتأثر.'
            : 'Previous subscriptions that already redeemed this voucher will not be affected.',
        ]}
        confirmText={isAr ? 'نعم، احذف الكود' : 'Yes, Delete Code'}
        cancelText={i18n.modal.cancel}
        isDeleting={isDeletingPromoCode}
      />
    </div>
  );
};
