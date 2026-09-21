import React, { useState, useEffect, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Plus,
  Edit2,
  Trash2,
  Layers,
  Search,
  X,
  AlertTriangle,
  RotateCcw,
  Archive,
  ShieldAlert,
  Check,
  Receipt,
  ChevronLeft,
  ChevronRight,
  LayoutList,
  LayoutGrid,
} from 'lucide-react';
import { toast } from 'sonner';
import { useLocale } from '../../../core/context/LocaleContext';
import { useViewMode } from '../../../core/context/ViewModeContext';
import { useCategories } from '../hooks/useCategories';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';
import type { CategoryItem, UpdateCategoryDto } from '../types';
import { CategoryFormModal } from '../components/CategoryFormModal';
import { CategoriesTable } from '../components/CategoriesTable';
import { CategoriesSkeleton } from '../components/CategoriesSkeleton';
import { CategoriesKpiCards } from '../components/CategoriesKpiCards';
import { renderCategoryIcon } from '../utils/categoryIcons';

export const CategoriesPage: React.FC = () => {
  const { locale, dir } = useLocale();
  const isAr = locale === 'ar';
  const { viewMode, setViewMode } = useViewMode();

  const {
    categories,
    rawCategories,
    counts,
    activeTab,
    setActiveTab,
    searchQuery,
    setSearchQuery,
    selectedIds,
    toggleSelect,
    selectAll,
    clearSelection,
    isAllSelected,
    totalFilteredCount,
    currentPage,
    pageSize,
    totalPages,
    goToPage,
    nextPage,
    prevPage,
    isLoading,
    isSubmitting,
    error,
    refetch,
    createCategory,
    updateCategory,
    deleteCategory,
    restoreCategory,
    bulkDelete,
    bulkRestore,
  } = useCategories();

  // Modal States
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState<CategoryItem | null>(null);
  const [deletingCategory, setDeletingCategory] = useState<CategoryItem | null>(null);
  const [isBulkDeleteModalOpen, setIsBulkDeleteModalOpen] = useState(false);

  const closeModals = () => {
    setIsCreateModalOpen(false);
    setEditingCategory(null);
    setDeletingCategory(null);
    setIsBulkDeleteModalOpen(false);
  };

  // Close modals on Escape key
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        closeModals();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  const openCreateModal = () => {
    setIsCreateModalOpen(true);
  };

  const openEditModal = (category: CategoryItem) => {
    setEditingCategory(category);
  };

  const handleCreateSubmit = async (formData: {
    nameEn: string;
    nameAr: string;
    type: 'Expense' | 'Income';
    icon: string;
  }) => {
    try {
      await createCategory(formData);
      toast.success(
        isAr ? 'تمت إضافة التصنيف بنجاح' : 'Category created successfully'
      );
      closeModals();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to create category';
      toast.error(msg);
    }
  };

  const handleEditSubmit = async (formData: {
    nameEn: string;
    nameAr: string;
    type: 'Expense' | 'Income';
    icon: string;
  }) => {
    if (!editingCategory) return;

    try {
      const dto: UpdateCategoryDto = {
        id: editingCategory.id,
        ...formData,
      };
      await updateCategory(editingCategory.id, dto);
      toast.success(
        isAr ? 'تم تحديث التصنيف بنجاح' : 'Category updated successfully'
      );
      closeModals();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to update category';
      toast.error(msg);
    }
  };

  const handleDeleteSubmit = async () => {
    if (!deletingCategory) return;

    try {
      const hasTransactions = deletingCategory.transactionCount > 0;
      await deleteCategory(deletingCategory.id);
      if (hasTransactions) {
        toast.success(
          isAr
            ? `تمت أرشفة التصنيف بنجاح لوجود ${deletingCategory.transactionCount} معاملة مالية مرتبطة به`
            : `Category archived successfully to protect ${deletingCategory.transactionCount} associated transactions`
        );
      } else {
        toast.success(
          isAr ? 'تم حذف التصنيف نهائياً بنجاح' : 'Category permanently deleted successfully'
        );
      }
      closeModals();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to delete category';
      toast.error(msg);
    }
  };

  const handleRestore = async (category: CategoryItem) => {
    try {
      await restoreCategory(category.id);
      toast.success(
        isAr
          ? `تم استرجاع وتفعيل تصنيف "${category.nameAr || category.nameEn}" بنجاح`
          : `Category "${category.nameEn}" restored successfully`
      );
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to restore category';
      toast.error(msg);
    }
  };

  // Bulk Delete Submission
  const handleBulkDeleteSubmit = async () => {
    if (selectedIds.size === 0) return;

    try {
      const ids = Array.from(selectedIds);
      const res = await bulkDelete(ids);
      closeModals();

      if (res.archivedCount > 0 && res.deletedCount > 0) {
        toast.success(
          isAr
            ? `تم حذف ${res.deletedCount} تصنيف نهائياً وأرشفة ${res.archivedCount} تصنيف مرتبط بمعاملات سابقة`
            : `Permanently deleted ${res.deletedCount} and archived ${res.archivedCount} categories with transactions`
        );
      } else if (res.archivedCount > 0) {
        toast.success(
          isAr
            ? `تمت أرشفة ${res.archivedCount} تصنيف للحفاظ على سلامة العمليات المالية`
            : `Archived ${res.archivedCount} categories to preserve transaction history`
        );
      } else {
        toast.success(
          isAr
            ? `تم حذف ${res.deletedCount} تصنيف نهائياً بنجاح`
            : `Permanently deleted ${res.deletedCount} categories`
        );
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to bulk delete categories';
      toast.error(msg);
    }
  };

  const handleBulkRestore = async () => {
    if (selectedIds.size === 0) return;

    try {
      const ids = Array.from(selectedIds);
      const count = await bulkRestore(ids);
      toast.success(
        isAr
          ? `تم استرجاع وتفعيل ${count} تصنيف بنجاح`
          : `Successfully restored ${count} categories`
      );
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to bulk restore categories';
      toast.error(msg);
    }
  };

  // Compute stats of selected categories for bulk modal
  const selectedStats = useMemo(() => {
    const selectedList = rawCategories.filter((c) => selectedIds.has(c.id));
    const withTx = selectedList.filter((c) => c.transactionCount > 0);
    const withoutTx = selectedList.filter((c) => c.transactionCount === 0);
    return {
      total: selectedList.length,
      withTxCount: withTx.length,
      withoutTxCount: withoutTx.length,
    };
  }, [rawCategories, selectedIds]);

  const startRecord = totalFilteredCount === 0 ? 0 : (currentPage - 1) * pageSize + 1;
  const endRecord = Math.min(currentPage * pageSize, totalFilteredCount);

  return (
    <div dir={dir} className="space-y-6">
      {/* 1. Page Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2.5">
            <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 font-bold shadow-xs">
              <Layers className="h-5 w-5" />
            </div>
            <div>
              <h1 className="text-xl sm:text-2xl font-black tracking-tight text-zinc-950 dark:text-white">
                {isAr ? 'تصنيفات النظام المالية' : 'System Financial Categories'}
              </h1>
              <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
                {isAr
                  ? 'إدارة وتخصيص التصنيفات المالية المعتمدة لكافة محافظ ومعاملات المستخدمين في محفظتي'
                  : 'Manage and customize global predefined categories provisioned across user wallets and transactions'}
              </p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => refetch()}
            disabled={isLoading}
            className="font-bold border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300"
          >
            <RotateCcw className={`h-4 w-4 ${isLoading ? 'animate-spin' : ''} me-1.5`} />
            <span>{isAr ? 'تحديث البيانات' : 'Refresh Feed'}</span>
          </Button>

          <Button
            type="button"
            variant="primary"
            size="sm"
            onClick={openCreateModal}
            className="font-bold shadow-xs"
          >
            <Plus className="h-4 w-4 me-1.5" />
            <span>{isAr ? 'إضافة تصنيف جديد' : 'New Category'}</span>
          </Button>
        </div>
      </div>

      {/* 2. Top KPI Metrics Summary Cards */}
      <CategoriesKpiCards
        stats={counts}
        isLoading={isLoading}
        hasCategories={rawCategories.length > 0}
        isAr={isAr}
      />

      {/* 3. Filter Tabs & Search Bar */}
      <div className="space-y-3">
        {/* Status Tabs Bar & View Mode Toggle */}
        <div className="flex items-center justify-between gap-2 overflow-x-auto pb-1">
          <div className="flex items-center gap-1.5 p-1 rounded-2xl bg-zinc-200/50 dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800">
            {(
              [
                { id: 'all', label: isAr ? 'كافة التصنيفات' : 'All Categories', count: counts.all },
                { id: 'Expense', label: isAr ? 'مصاريف' : 'Expenses', count: counts.expenses },
                { id: 'Income', label: isAr ? 'إيرادات ودخل' : 'Income', count: counts.income },
                { id: 'Archived', label: isAr ? 'المؤرشفة' : 'Archived', count: counts.archived },
              ] as const
            ).map((tab) => {
              const isActive = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  type="button"
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center gap-2 px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer ${
                    isActive
                      ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                      : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white hover:bg-zinc-200/60 dark:hover:bg-zinc-800/60'
                  }`}
                >
                  <span>{tab.label}</span>
                  <span
                    className={`px-1.5 py-0.2 rounded-full text-[10px] font-mono ${
                      isActive
                        ? 'bg-zinc-800 dark:bg-zinc-200 text-zinc-100 dark:text-zinc-900'
                        : 'bg-zinc-300/60 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-400'
                    }`}
                  >
                    {tab.count}
                  </span>
                </button>
              );
            })}
          </div>

          {/* View Mode Toggle (Table / Cards) */}
          <div className="flex items-center gap-1 p-1 rounded-2xl bg-zinc-200/50 dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800">
            <button
              type="button"
              onClick={() => setViewMode('table')}
              title={isAr ? 'عرض الجدول' : 'Table View'}
              className={`p-1.5 rounded-xl text-xs transition-all cursor-pointer ${
                viewMode === 'table'
                  ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                  : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white'
              }`}
            >
              <LayoutList className="h-4 w-4" />
            </button>
            <button
              type="button"
              onClick={() => setViewMode('cards')}
              title={isAr ? 'عرض الكروت' : 'Cards View'}
              className={`p-1.5 rounded-xl text-xs transition-all cursor-pointer ${
                viewMode === 'cards'
                  ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                  : 'text-zinc-600 dark:text-zinc-400 hover:text-zinc-950 dark:hover:text-white'
              }`}
            >
              <LayoutGrid className="h-4 w-4" />
            </button>
          </div>
        </div>

        {/* Search & Selection Bar */}
        <Card className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-3 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
          <div className="relative flex-1">
            <Search className="absolute top-1/2 start-3.5 h-4 w-4 -translate-y-1/2 text-zinc-400 dark:text-zinc-500" />
            <input
              type="text"
              placeholder={isAr ? 'بحث بالاسم العربي أو الإنجليزي...' : 'Search categories...'}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900/80 py-2 ps-10 pe-9 text-xs text-zinc-900 dark:text-white placeholder-zinc-400 dark:placeholder-zinc-500 focus:border-zinc-950 dark:focus:border-white focus:outline-none transition-colors"
            />
            {searchQuery && (
              <button
                type="button"
                onClick={() => setSearchQuery('')}
                className="absolute top-1/2 end-3 -translate-y-1/2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 cursor-pointer"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>

          {categories.length > 0 && (
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => (isAllSelected ? clearSelection() : selectAll())}
              className={`text-xs font-semibold px-3 py-2 shadow-2xs border ${
                isAllSelected
                  ? 'bg-zinc-950 text-white dark:bg-white dark:text-zinc-950 border-zinc-950 dark:border-white'
                  : 'border-zinc-200 dark:border-zinc-700 text-zinc-700 dark:text-zinc-200'
              }`}
            >
              <div
                className={`h-4 w-4 rounded-md flex items-center justify-center transition-colors border me-1.5 ${
                  isAllSelected
                    ? 'bg-white text-zinc-950 dark:bg-zinc-950 dark:text-white border-transparent'
                    : 'border-zinc-400 dark:border-zinc-500 bg-transparent'
                }`}
              >
                {isAllSelected && <Check className="h-3 w-3 stroke-[3]" />}
              </div>
              <span>
                {isAllSelected
                  ? isAr
                    ? 'إلغاء التحديد'
                    : 'Deselect All'
                  : isAr
                  ? 'تحديد الكل'
                  : 'Select All'}
              </span>
            </Button>
          )}
        </Card>
      </div>

      {/* Error Banner */}
      {error && (
        <div className="p-4 rounded-2xl border border-rose-200 dark:border-rose-900/60 bg-rose-50/80 dark:bg-rose-950/40 text-rose-700 dark:text-rose-300 text-xs flex items-center justify-between shadow-2xs">
          <div className="flex items-center gap-2.5">
            <AlertTriangle className="h-5 w-5 shrink-0 text-rose-600 dark:text-rose-400" />
            <span className="font-semibold">{error}</span>
          </div>
          <Button size="sm" variant="danger" onClick={() => refetch()}>
            {isAr ? 'إعادة المحاولة' : 'Try Again'}
          </Button>
        </div>
      )}

      {/* Categories Grid, Table, or Skeletons */}
      {isLoading ? (
        <CategoriesSkeleton count={pageSize} viewMode={viewMode} isAr={isAr} />
      ) : categories.length === 0 ? (
        <div className="p-12 text-center rounded-3xl border border-dashed border-zinc-200 dark:border-zinc-800 bg-white/60 dark:bg-zinc-900/60 backdrop-blur-xs">
          <Layers className="h-12 w-12 text-zinc-300 dark:text-zinc-600 mx-auto mb-3" />
          <h3 className="text-base font-bold text-zinc-900 dark:text-white">
            {activeTab === 'Archived'
              ? isAr
                ? 'لا توجد تصنيفات مؤرشفة'
                : 'No Archived Categories'
              : isAr
              ? 'لم يتم العثور على تصنيفات'
              : 'No Categories Found'}
          </h3>
          <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-1 max-w-sm mx-auto leading-relaxed">
            {activeTab === 'Archived'
              ? isAr
                ? 'كافة التصنيفات نشطة ولا توجد تصنيفات مؤرشفة حالياً.'
                : 'All categories are active. No categories have been archived.'
              : searchQuery
              ? isAr
                ? `لا توجد نتائج مطابقة لبحثك عن "${searchQuery}". جرب كلمة بحث أخرى.`
                : `No categories match "${searchQuery}". Try a different keyword.`
              : isAr
              ? 'لم تتم إضافة أي تصنيفات في النظام بعد. ابدأ بإضافة أول تصنيف مالي.'
              : 'No system categories have been created yet. Get started by adding one.'}
          </p>
          {searchQuery ? (
            <Button
              variant="outline"
              size="sm"
              onClick={() => setSearchQuery('')}
              className="mt-4 shadow-2xs"
            >
              {isAr ? 'مسح البحث' : 'Clear Search'}
            </Button>
          ) : activeTab !== 'Archived' ? (
            <Button size="sm" onClick={openCreateModal} className="mt-4 shadow-xs">
              <Plus className="h-3.5 w-3.5" />
              <span>{isAr ? 'إضافة أول تصنيف' : 'Create First Category'}</span>
            </Button>
          ) : null}
        </div>
      ) : viewMode === 'table' ? (
        <CategoriesTable
          categories={categories}
          selectedIds={selectedIds}
          onToggleSelect={toggleSelect}
          onSelectAll={selectAll}
          onClearSelection={clearSelection}
          isAllSelected={isAllSelected}
          onEdit={openEditModal}
          onDelete={(category) => setDeletingCategory(category)}
          onRestore={handleRestore}
          isAr={isAr}
        />
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {categories.map((category) => {
            const isIncome = category.type === 'Income';
            const isSelected = selectedIds.has(category.id);
            const isArchived = !category.isActive;

            return (
              <Card
                key={category.id}
                className={`group relative transition-all duration-200 p-5 flex flex-col justify-between bg-white dark:bg-zinc-900/90 border border-zinc-200/90 dark:border-zinc-800/90 shadow-2xs ${
                  isSelected
                    ? 'ring-2 ring-zinc-950 dark:ring-white border-zinc-950 dark:border-white shadow-md bg-zinc-50/80 dark:bg-zinc-800/40'
                    : 'hover:shadow-md hover:border-zinc-300 dark:hover:border-zinc-700'
                } ${isArchived ? 'opacity-85' : ''}`}
              >
                <div>
                  <div className="flex items-start justify-between gap-3">
                    {/* Category Icon */}
                    <div
                      className="flex h-12 w-12 items-center justify-center rounded-2xl shadow-xs text-white transition-transform group-hover:scale-105 shrink-0"
                      style={{
                        backgroundColor: category.color,
                        boxShadow: `0 4px 14px 0 ${category.color}40`,
                      }}
                    >
                      {renderCategoryIcon(category.icon, 'h-6 w-6')}
                    </div>

                    {/* Status & Type Badges + Checkbox */}
                    <div className="flex items-center gap-2">
                      {isArchived ? (
                        <Badge variant="warning" className="text-[10px] font-bold tracking-wide">
                          <Archive className="h-3 w-3 inline me-0.5" />
                          {isAr ? 'مؤرشف' : 'Archived'}
                        </Badge>
                      ) : (
                        <Badge
                          variant={isIncome ? 'success' : 'danger'}
                          className="text-xs font-bold tracking-wide"
                        >
                          {isIncome
                            ? isAr
                              ? 'إيراد'
                              : 'Income'
                            : isAr
                            ? 'مصروف'
                            : 'Expense'}
                        </Badge>
                      )}

                      {/* Clean Dedicated Selection Checkbox */}
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          toggleSelect(category.id);
                        }}
                        className={`h-5 w-5 rounded-md flex items-center justify-center transition-all cursor-pointer border ${
                          isSelected
                            ? 'bg-zinc-950 text-white dark:bg-white dark:text-zinc-950 border-zinc-950 dark:border-white shadow-2xs scale-105'
                            : 'border-zinc-300 dark:border-zinc-700 bg-zinc-50/60 dark:bg-zinc-800 hover:bg-zinc-100 hover:border-zinc-400 dark:hover:border-zinc-500'
                        }`}
                        title={isSelected ? (isAr ? 'إلغاء التحديد' : 'Deselect') : (isAr ? 'تحديد' : 'Select')}
                      >
                        {isSelected && <Check className="h-3.5 w-3.5 stroke-[3]" />}
                      </button>
                    </div>
                  </div>

                  <div className="mt-4 space-y-1">
                    <h3 className="font-bold text-base text-zinc-950 dark:text-white tracking-tight">
                      {category.nameEn}
                    </h3>
                    <p className="text-xs text-zinc-600 dark:text-zinc-300 font-semibold font-arabic">
                      {category.nameAr}
                    </p>
                  </div>
                </div>

                <div className="mt-5 flex items-center justify-between border-t border-zinc-200/80 dark:border-zinc-800/90 pt-3 text-xs">
                  {/* Transaction Count Indicator */}
                  <span
                    className={`inline-flex items-center gap-1 text-[11px] font-mono px-2 py-0.5 rounded-md border ${
                      category.transactionCount > 0
                        ? 'bg-zinc-100 dark:bg-zinc-800/80 text-zinc-800 dark:text-zinc-200 border-zinc-200 dark:border-zinc-700/60 font-semibold'
                        : 'bg-zinc-50 dark:bg-zinc-900/50 text-zinc-500 dark:text-zinc-400 border-zinc-200/60 dark:border-zinc-800'
                    }`}
                    title={
                      isAr
                        ? `${category.transactionCount} معاملة مالية مسجلة بهذا التصنيف`
                        : `${category.transactionCount} transactions recorded in this category`
                    }
                  >
                    <Receipt className="h-3 w-3 opacity-75" />
                    <span>
                      {category.transactionCount}{' '}
                      {isAr
                        ? 'معاملة'
                        : category.transactionCount === 1
                        ? 'transaction'
                        : 'transactions'}
                    </span>
                  </span>

                  {/* Actions */}
                  <div className="flex items-center gap-1">
                    {isArchived ? (
                      /* ARCHIVED: ONLY show Restore button (+ optional permanent delete if 0 transactions) */
                      <>
                        <button
                          onClick={() => handleRestore(category)}
                          className="rounded-lg px-2.5 py-1 text-xs font-semibold text-emerald-700 dark:text-emerald-300 bg-emerald-50 dark:bg-emerald-950/60 hover:bg-emerald-100 dark:hover:bg-emerald-900/60 border border-emerald-200 dark:border-emerald-800/80 transition cursor-pointer flex items-center gap-1 shadow-2xs"
                          title={isAr ? 'استعادة وتفعيل التصنيف' : 'Restore & Activate Category'}
                        >
                          <RotateCcw className="h-3 w-3" />
                          <span>{isAr ? 'استرجاع' : 'Restore'}</span>
                        </button>

                        {category.transactionCount === 0 && (
                          <button
                            onClick={() => setDeletingCategory(category)}
                            className="rounded-lg p-1.5 text-zinc-400 hover:bg-rose-50 dark:hover:bg-rose-950/60 hover:text-rose-600 dark:hover:text-rose-300 border border-transparent hover:border-rose-200 dark:hover:border-rose-900/60 transition cursor-pointer"
                            title={isAr ? 'حذف نهائي من الأرشيف' : 'Delete permanently from archive'}
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                          </button>
                        )}
                      </>
                    ) : (
                      /* ACTIVE: Edit and Delete/Archive buttons */
                      <>
                        <button
                          onClick={() => openEditModal(category)}
                          className="rounded-lg p-1.5 text-zinc-500 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-white border border-transparent hover:border-zinc-200 dark:hover:border-zinc-700 transition cursor-pointer"
                          title={isAr ? 'تعديل التصنيف' : 'Edit Category'}
                        >
                          <Edit2 className="h-3.5 w-3.5" />
                        </button>
                        <button
                          onClick={() => setDeletingCategory(category)}
                          className="rounded-lg p-1.5 text-zinc-500 dark:text-zinc-400 hover:bg-rose-50 dark:hover:bg-rose-950/60 hover:text-rose-600 dark:hover:text-rose-300 border border-transparent hover:border-rose-200 dark:hover:border-rose-900/60 transition cursor-pointer"
                          title={
                            category.transactionCount > 0
                              ? isAr
                                ? 'أرشفة التصنيف'
                                : 'Archive Category'
                              : isAr
                              ? 'حذف التصنيف'
                              : 'Delete Category'
                          }
                        >
                          {category.transactionCount > 0 ? (
                            <Archive className="h-3.5 w-3.5 text-amber-600 dark:text-amber-400" />
                          ) : (
                            <Trash2 className="h-3.5 w-3.5" />
                          )}
                        </button>
                      </>
                    )}
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      {/* 5. Pagination Toolbar */}
      {!isLoading && totalFilteredCount > 0 && (
        <Card className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 p-3.5 bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs">
          <p className="text-xs text-zinc-500 dark:text-zinc-400 text-center sm:text-start">
            {isAr ? (
              <>
                عرض <strong className="text-zinc-900 dark:text-white font-mono">{startRecord}</strong> إلى{' '}
                <strong className="text-zinc-900 dark:text-white font-mono">{endRecord}</strong> من أصل{' '}
                <strong className="text-zinc-900 dark:text-white font-mono">{totalFilteredCount}</strong> تصنيف
              </>
            ) : (
              <>
                Showing <strong className="text-zinc-900 dark:text-white font-mono">{startRecord}</strong> to{' '}
                <strong className="text-zinc-900 dark:text-white font-mono">{endRecord}</strong> of{' '}
                <strong className="text-zinc-900 dark:text-white font-mono">{totalFilteredCount}</strong> categories
              </>
            )}
          </p>

          <div className="flex items-center justify-center gap-1.5">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={prevPage}
              disabled={currentPage === 1}
              className="text-xs font-bold px-2.5"
            >
              {isAr ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
              <span className="ms-1">{isAr ? 'السابق' : 'Prev'}</span>
            </Button>

            <div className="flex items-center gap-1">
              {Array.from({ length: totalPages }, (_, i) => i + 1)
                .filter((p) => p === 1 || p === totalPages || Math.abs(p - currentPage) <= 1)
                .map((p, idx, arr) => {
                  const prevP = arr[idx - 1];
                  const showEllipsis = prevP && p - prevP > 1;

                  return (
                    <React.Fragment key={p}>
                      {showEllipsis && <span className="px-1 text-zinc-400 font-mono">...</span>}
                      <button
                        type="button"
                        onClick={() => goToPage(p)}
                        className={`h-8 w-8 rounded-xl text-xs font-bold transition-colors cursor-pointer ${
                          currentPage === p
                            ? 'bg-zinc-950 dark:bg-white text-white dark:text-zinc-950 shadow-xs'
                            : 'border border-zinc-200 dark:border-zinc-800 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800'
                        }`}
                      >
                        {p}
                      </button>
                    </React.Fragment>
                  );
                })}
            </div>

            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={nextPage}
              disabled={currentPage === totalPages}
              className="text-xs font-bold px-2.5"
            >
              <span className="me-1">{isAr ? 'التالي' : 'Next'}</span>
              {isAr ? <ChevronLeft className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
            </Button>
          </div>
        </Card>
      )}

      {/* Floating Bulk Actions Bar */}
      <AnimatePresence>
        {selectedIds.size > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 30, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 30, scale: 0.95 }}
            transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
            className="fixed bottom-6 inset-x-0 mx-auto max-w-lg z-40 px-4"
          >
            <div className="flex items-center justify-between gap-3 px-5 py-3 rounded-2xl bg-zinc-950/95 dark:bg-zinc-900/95 backdrop-blur-md text-white border border-zinc-800 shadow-2xl">
              <div className="flex items-center gap-3">
                <span className="flex h-7 w-7 items-center justify-center rounded-xl bg-white/15 text-xs font-mono font-bold">
                  {selectedIds.size}
                </span>
                <span className="text-xs font-semibold">
                  {isAr
                    ? `تم تحديد ${selectedIds.size} تصنيف`
                    : `${selectedIds.size} categories selected`}
                </span>
              </div>

              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={clearSelection}
                  className="rounded-xl px-2.5 py-1.5 text-xs text-zinc-300 hover:text-white hover:bg-white/10 transition cursor-pointer font-medium"
                >
                  {isAr ? 'إلغاء التحديد' : 'Clear'}
                </button>
                {activeTab === 'Archived' ? (
                  <>
                    <Button
                      size="sm"
                      onClick={handleBulkRestore}
                      isLoading={isSubmitting}
                      className="bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs shadow-xs border-transparent cursor-pointer"
                    >
                      <RotateCcw className="h-3.5 w-3.5 me-1" />
                      <span>{isAr ? 'استرجاع وتفعيل المحدد' : 'Restore Selected'}</span>
                    </Button>
                    {selectedStats.withoutTxCount > 0 && (
                      <Button
                        size="sm"
                        variant="danger"
                        onClick={() => setIsBulkDeleteModalOpen(true)}
                        className="shadow-xs font-bold text-xs"
                      >
                        <Trash2 className="h-3.5 w-3.5 me-1" />
                        <span>{isAr ? 'حذف نهائي للمحدد' : 'Delete'}</span>
                      </Button>
                    )}
                  </>
                ) : (
                  <Button
                    size="sm"
                    variant="danger"
                    onClick={() => setIsBulkDeleteModalOpen(true)}
                    className="shadow-xs font-bold text-xs"
                  >
                    <Trash2 className="h-3.5 w-3.5 me-1" />
                    <span>{isAr ? 'حذف / أرشفة المحدد' : 'Delete Selected'}</span>
                  </Button>
                )}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Wide Rectangular Category Form Modal (Add & Edit) */}
      <CategoryFormModal
        key={editingCategory ? `edit-${editingCategory.id}` : 'create'}
        isOpen={isCreateModalOpen || Boolean(editingCategory)}
        mode={editingCategory ? 'edit' : 'create'}
        category={editingCategory}
        onClose={closeModals}
        onSubmit={editingCategory ? handleEditSubmit : handleCreateSubmit}
        isSubmitting={isSubmitting}
      />



      {/* Smart Single Delete / Archive Modal */}
      <AnimatePresence>
        {deletingCategory && (
          <motion.div
            key="delete-modal-backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2, ease: 'easeOut' }}
            onClick={closeModals}
            className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-xs"
          >
            <motion.div
              key="delete-modal-content"
              initial={{ opacity: 0, scale: 0.94, y: 14 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.94, y: 10 }}
              transition={{ duration: 0.24, ease: [0.16, 1, 0.3, 1] }}
              onClick={(e) => e.stopPropagation()}
              className="relative w-full max-w-md rounded-3xl border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-[#121215] p-6 shadow-2xl space-y-4 text-zinc-900 dark:text-white"
            >
              {deletingCategory.transactionCount > 0 ? (
                /* Archive Confirmation View */
                <>
                  <div className="flex items-center gap-3">
                    <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-amber-100 dark:bg-amber-950 text-amber-700 dark:text-amber-300 border border-amber-200 dark:border-amber-800/60 shadow-xs">
                      <Archive className="h-5 w-5" />
                    </div>
                    <div>
                      <h3 className="text-sm font-bold text-zinc-950 dark:text-white">
                        {isAr ? 'أرشفة التصنيف المالي' : 'Archive Financial Category'}
                      </h3>
                      <p className="text-xs text-amber-700 dark:text-amber-400 font-semibold">
                        {isAr ? 'حماية بيانات المعاملات المالية' : 'Financial Data Protection'}
                      </p>
                    </div>
                  </div>

                  <div className="p-3.5 rounded-2xl bg-amber-50/80 dark:bg-amber-950/40 border border-amber-200/80 dark:border-amber-900/50 space-y-2 text-xs">
                    <div className="flex items-start gap-2 text-amber-800 dark:text-amber-300">
                      <ShieldAlert className="h-4 w-4 shrink-0 mt-0.5" />
                      <p className="leading-relaxed">
                        {isAr
                          ? `هذا التصنيف مرتبط بـ (${deletingCategory.transactionCount}) معاملة مالية فعلية. للحفاظ على دقة التقارير وحسابات المستخدمين، سيتم نقل التصنيف إلى "الأرشيف" وإخفاؤه من قوائم الإدخال الجديدة دون مس المعاملات السابقة.`
                          : `This category is linked to (${deletingCategory.transactionCount}) actual transactions. To preserve financial audit accuracy, it will be moved to the archive and hidden from new entry lists without deleting historical data.`}
                      </p>
                    </div>
                  </div>

                  <div className="p-3.5 rounded-2xl bg-zinc-50 dark:bg-zinc-950/80 border border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
                    <div>
                      <p className="text-xs font-bold text-zinc-900 dark:text-white">
                        {deletingCategory.nameEn} ({deletingCategory.nameAr})
                      </p>
                      <p className="text-[11px] text-zinc-500 dark:text-zinc-400 font-mono">
                        ID: #{deletingCategory.id}
                      </p>
                    </div>
                    <Badge variant="warning" className="text-xs font-mono font-bold">
                      {deletingCategory.transactionCount}{' '}
                      {isAr
                        ? 'معاملة'
                        : deletingCategory.transactionCount === 1
                        ? 'transaction'
                        : 'transactions'}
                    </Badge>
                  </div>

                  <div className="flex items-center justify-end gap-2 pt-2">
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      onClick={closeModals}
                      disabled={isSubmitting}
                    >
                      {isAr ? 'إلغاء' : 'Cancel'}
                    </Button>
                    <Button
                      type="button"
                      variant="warning"
                      size="sm"
                      onClick={handleDeleteSubmit}
                      isLoading={isSubmitting}
                      className="font-bold"
                    >
                      <Archive className="h-4 w-4 me-1" />
                      <span>{isAr ? 'أرشفة التصنيف' : 'Archive Category'}</span>
                    </Button>
                  </div>
                </>
              ) : (
                /* Permanent Delete Confirmation View */
                <>
                  <div className="flex items-center gap-3">
                    <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-rose-100 dark:bg-rose-950 text-rose-600 dark:text-rose-400 border border-rose-200 dark:border-rose-900/60 shadow-xs">
                      <Trash2 className="h-5 w-5" />
                    </div>
                    <div>
                      <h3 className="text-sm font-bold text-zinc-950 dark:text-white">
                        {isAr ? 'تأكيد الحذف النهائي' : 'Permanent Delete'}
                      </h3>
                      <p className="text-xs text-rose-600 dark:text-rose-400">
                        {isAr ? 'هذا الإجراء لا يمكن التراجع عنه.' : 'This action cannot be undone.'}
                      </p>
                    </div>
                  </div>

                  <p className="text-xs text-zinc-600 dark:text-zinc-300 leading-relaxed">
                    {isAr
                      ? 'لا توجد أي معاملات مالية مرتبطة بهذا التصنيف، لذلك سيتم حذفه نهائياً من قاعدة البيانات.'
                      : 'There are no transactions associated with this category. It will be permanently removed from the database.'}
                  </p>

                  <div className="p-3.5 rounded-2xl bg-zinc-50 dark:bg-zinc-950/80 border border-zinc-200 dark:border-zinc-800">
                    <p className="text-xs font-bold text-zinc-900 dark:text-white">
                      {deletingCategory.nameEn} ({deletingCategory.nameAr})
                    </p>
                    <p className="text-[11px] text-zinc-500 dark:text-zinc-400 mt-1 font-mono">
                      ID: #{deletingCategory.id}
                    </p>
                  </div>

                  <div className="flex items-center justify-end gap-2 pt-2">
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      onClick={closeModals}
                      disabled={isSubmitting}
                    >
                      {isAr ? 'إلغاء' : 'Cancel'}
                    </Button>
                    <Button
                      type="button"
                      variant="danger"
                      size="sm"
                      onClick={handleDeleteSubmit}
                      isLoading={isSubmitting}
                    >
                      {isAr ? 'حذف نهائي' : 'Delete Permanently'}
                    </Button>
                  </div>
                </>
              )}
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Bulk Delete Confirmation Modal */}
      <AnimatePresence>
        {isBulkDeleteModalOpen && (
          <motion.div
            key="bulk-delete-modal-backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2, ease: 'easeOut' }}
            onClick={closeModals}
            className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-xs"
          >
            <motion.div
              key="bulk-delete-modal-content"
              initial={{ opacity: 0, scale: 0.94, y: 14 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.94, y: 10 }}
              transition={{ duration: 0.24, ease: [0.16, 1, 0.3, 1] }}
              onClick={(e) => e.stopPropagation()}
              className="relative w-full max-w-md rounded-3xl border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-[#121215] p-6 shadow-2xl space-y-4 text-zinc-900 dark:text-white"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-2xl bg-rose-100 dark:bg-rose-950 text-rose-600 dark:text-rose-400 border border-rose-200 dark:border-rose-900/60 shadow-xs">
                  <Trash2 className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-zinc-950 dark:text-white">
                    {isAr ? 'تأكيد الحذف الجماعي والتصنيف' : 'Bulk Delete & Protection'}
                  </h3>
                  <p className="text-xs text-zinc-500 dark:text-zinc-400">
                    {isAr
                      ? `تم تحديد ${selectedStats.total} تصنيف للإجراء`
                      : `${selectedStats.total} categories selected for action`}
                  </p>
                </div>
              </div>

              <div className="space-y-2.5">
                {selectedStats.withTxCount > 0 && (
                  <div className="p-3 rounded-2xl bg-amber-50/80 dark:bg-amber-950/40 border border-amber-200/80 dark:border-amber-900/50 flex items-start gap-2.5 text-xs text-amber-800 dark:text-amber-300">
                    <Archive className="h-4 w-4 shrink-0 mt-0.5 text-amber-600 dark:text-amber-400" />
                    <div>
                      <p className="font-bold">
                        {isAr
                          ? `أرشفة آمنة (${selectedStats.withTxCount}) تصنيف:`
                          : `Safe Archive (${selectedStats.withTxCount}) categories:`}
                      </p>
                      <p className="text-[11px] leading-relaxed mt-0.5 opacity-90">
                        {isAr
                          ? 'تحتوي على معاملات مالية سابقة، سيتم أرشفتها لحماية سجلات المستخدمين والتقارير.'
                          : 'Linked to previous transactions; they will be safely archived to protect user records.'}
                      </p>
                    </div>
                  </div>
                )}

                {selectedStats.withoutTxCount > 0 && (
                  <div className="p-3 rounded-2xl bg-rose-50/80 dark:bg-rose-950/40 border border-rose-200/80 dark:border-rose-900/50 flex items-start gap-2.5 text-xs text-rose-800 dark:text-rose-300">
                    <Trash2 className="h-4 w-4 shrink-0 mt-0.5 text-rose-600 dark:text-rose-400" />
                    <div>
                      <p className="font-bold">
                        {isAr
                          ? `حذف نهائي (${selectedStats.withoutTxCount}) تصنيف:`
                          : `Permanent Delete (${selectedStats.withoutTxCount}) categories:`}
                      </p>
                      <p className="text-[11px] leading-relaxed mt-0.5 opacity-90">
                        {isAr
                          ? 'لا ترتبط بأي معاملات مالية، سيتم حذفها نهائياً من قاعدة البيانات.'
                          : 'No transactions linked; they will be permanently removed from the database.'}
                      </p>
                    </div>
                  </div>
                )}
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-zinc-200/80 dark:border-zinc-800">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={closeModals}
                  disabled={isSubmitting}
                >
                  {isAr ? 'إلغاء' : 'Cancel'}
                </Button>
                <Button
                  type="button"
                  variant="danger"
                  size="sm"
                  onClick={handleBulkDeleteSubmit}
                  isLoading={isSubmitting}
                  className="font-bold"
                >
                  {isAr ? 'تأكيد التنفيذ' : 'Confirm Action'}
                </Button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};
