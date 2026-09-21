import React from 'react';
import {
  Edit2,
  Trash2,
  RotateCcw,
  Archive,
  Check,
  Receipt,
} from 'lucide-react';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import type { CategoryItem } from '../types';
import { renderCategoryIcon } from '../utils/categoryIcons';

export interface CategoriesTableProps {
  categories: CategoryItem[];
  selectedIds: Set<number>;
  onToggleSelect: (id: number) => void;
  onSelectAll: () => void;
  onClearSelection: () => void;
  isAllSelected: boolean;
  onEdit: (category: CategoryItem) => void;
  onDelete: (category: CategoryItem) => void;
  onRestore: (category: CategoryItem) => void;
  isAr: boolean;
}

export const CategoriesTable: React.FC<CategoriesTableProps> = ({
  categories,
  selectedIds,
  onToggleSelect,
  onSelectAll,
  onClearSelection,
  isAllSelected,
  onEdit,
  onDelete,
  onRestore,
  isAr,
}) => {
  return (
    <Card className="p-0 overflow-hidden bg-white dark:bg-[#121215] border-zinc-200 dark:border-zinc-800/80 shadow-2xs min-h-[380px]">
      <div className="overflow-x-auto">
        <table className="w-full text-left rtl:text-right text-xs">
          <thead className="border-b border-zinc-200 dark:border-zinc-800 bg-zinc-50/80 dark:bg-zinc-900/50 text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
            <tr>
              {/* Select All Checkbox */}
              <th className="py-3.5 px-4 w-10 text-center">
                <button
                  type="button"
                  onClick={() => (isAllSelected ? onClearSelection() : onSelectAll())}
                  className={`h-4 w-4 rounded-md flex items-center justify-center transition-all cursor-pointer border mx-auto ${
                    isAllSelected
                      ? 'bg-zinc-950 text-white dark:bg-white dark:text-zinc-950 border-zinc-950 dark:border-white shadow-2xs'
                      : 'border-zinc-300 dark:border-zinc-700 bg-zinc-50/60 dark:bg-zinc-800 hover:bg-zinc-100 hover:border-zinc-400 dark:hover:border-zinc-500'
                  }`}
                  title={
                    isAllSelected
                      ? isAr
                        ? 'إلغاء تحديد الكل'
                        : 'Deselect All'
                      : isAr
                      ? 'تحديد الكل'
                      : 'Select All'
                  }
                >
                  {isAllSelected && <Check className="h-3 w-3 stroke-[3]" />}
                </button>
              </th>
              <th className="py-3.5 px-6">{isAr ? 'التصنيف' : 'Category'}</th>
              <th className="py-3.5 px-6">{isAr ? 'النوع' : 'Type'}</th>
              <th className="py-3.5 px-6">{isAr ? 'الحالة' : 'Status'}</th>
              <th className="py-3.5 px-6">{isAr ? 'المعاملات المرتبطة' : 'Transactions'}</th>
              <th className="py-3.5 px-6 text-center">{isAr ? 'الإجراءات' : 'Actions'}</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-zinc-200/70 dark:divide-zinc-800/60 text-zinc-700 dark:text-zinc-300">
            {categories.map((category) => {
              const isIncome = category.type === 'Income';
              const isSelected = selectedIds.has(category.id);
              const isArchived = !category.isActive;

              return (
                <tr
                  key={category.id}
                  className={`hover:bg-zinc-50/80 dark:hover:bg-zinc-800/40 transition-colors ${
                    isSelected ? 'bg-zinc-50/90 dark:bg-zinc-800/30' : ''
                  }`}
                >
                  {/* Checkbox */}
                  <td className="py-3.5 px-4 text-center">
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        onToggleSelect(category.id);
                      }}
                      className={`h-4 w-4 rounded-md flex items-center justify-center transition-all cursor-pointer border mx-auto ${
                        isSelected
                          ? 'bg-zinc-950 text-white dark:bg-white dark:text-zinc-950 border-zinc-950 dark:border-white shadow-2xs scale-105'
                          : 'border-zinc-300 dark:border-zinc-700 bg-zinc-50/60 dark:bg-zinc-800 hover:bg-zinc-100 hover:border-zinc-400 dark:hover:border-zinc-500'
                      }`}
                      title={
                        isSelected
                          ? isAr
                            ? 'إلغاء التحديد'
                            : 'Deselect'
                          : isAr
                          ? 'تحديد'
                          : 'Select'
                      }
                    >
                      {isSelected && <Check className="h-3 w-3 stroke-[3]" />}
                    </button>
                  </td>

                  {/* Icon & Category Names */}
                  <td className="py-3.5 px-6">
                    <div className="flex items-center gap-3">
                      <div
                        className="flex h-10 w-10 shrink-0 items-center justify-center rounded-2xl shadow-xs text-white"
                        style={{
                          backgroundColor: category.color,
                          boxShadow: `0 3px 10px 0 ${category.color}40`,
                        }}
                      >
                        {renderCategoryIcon(category.icon, 'h-5 w-5')}
                      </div>
                      <div>
                        <p className="font-bold text-zinc-950 dark:text-white">
                          {category.nameEn}
                        </p>
                        <p className="text-xs text-zinc-500 dark:text-zinc-400 font-semibold font-arabic">
                          {category.nameAr}
                        </p>
                      </div>
                    </div>
                  </td>

                  {/* Type Badge */}
                  <td className="py-3.5 px-6">
                    <Badge
                      variant={isIncome ? 'success' : 'danger'}
                      className="text-[11px] font-bold tracking-wide"
                    >
                      {isIncome
                        ? isAr
                          ? 'إيراد'
                          : 'Income'
                        : isAr
                        ? 'مصروف'
                        : 'Expense'}
                    </Badge>
                  </td>

                  {/* Status Badge */}
                  <td className="py-3.5 px-6">
                    {isArchived ? (
                      <Badge variant="warning" className="text-[11px] font-bold tracking-wide gap-1">
                        <Archive className="h-3 w-3" />
                        <span>{isAr ? 'مؤرشف' : 'Archived'}</span>
                      </Badge>
                    ) : (
                      <Badge variant="success" className="text-[11px] font-bold tracking-wide">
                        {isAr ? 'نشط' : 'Active'}
                      </Badge>
                    )}
                  </td>

                  {/* Transaction Count Indicator */}
                  <td className="py-3.5 px-6">
                    <span
                      className={`inline-flex items-center gap-1.5 text-[11px] font-mono px-2.5 py-1 rounded-md border ${
                        category.transactionCount > 0
                          ? 'bg-zinc-100 dark:bg-zinc-800/80 text-zinc-800 dark:text-zinc-200 border-zinc-200 dark:border-zinc-700/60 font-semibold'
                          : 'bg-zinc-50 dark:bg-zinc-900/50 text-zinc-500 dark:text-zinc-400 border-zinc-200/60 dark:border-zinc-800'
                      }`}
                    >
                      <Receipt className="h-3.5 w-3.5 opacity-75" />
                      <span>
                        {category.transactionCount}{' '}
                        {isAr
                          ? 'معاملة'
                          : category.transactionCount === 1
                          ? 'transaction'
                          : 'transactions'}
                      </span>
                    </span>
                  </td>

                  {/* Actions */}
                  <td className="py-3.5 px-6 text-center">
                    <div className="flex items-center justify-center gap-1">
                      {isArchived ? (
                        <>
                          <button
                            type="button"
                            onClick={() => onRestore(category)}
                            className="rounded-lg px-2.5 py-1 text-xs font-semibold text-emerald-700 dark:text-emerald-300 bg-emerald-50 dark:bg-emerald-950/60 hover:bg-emerald-100 dark:hover:bg-emerald-900/60 border border-emerald-200 dark:border-emerald-800/80 transition cursor-pointer flex items-center gap-1 shadow-2xs"
                            title={isAr ? 'استعادة وتفعيل التصنيف' : 'Restore & Activate Category'}
                          >
                            <RotateCcw className="h-3 w-3" />
                            <span>{isAr ? 'استرجاع' : 'Restore'}</span>
                          </button>

                          {category.transactionCount === 0 && (
                            <button
                              type="button"
                              onClick={() => onDelete(category)}
                              className="rounded-lg p-1.5 text-zinc-400 hover:bg-rose-50 dark:hover:bg-rose-950/60 hover:text-rose-600 dark:hover:text-rose-300 border border-transparent hover:border-rose-200 dark:hover:border-rose-900/60 transition cursor-pointer"
                              title={isAr ? 'حذف نهائي من الأرشيف' : 'Delete permanently from archive'}
                            >
                              <Trash2 className="h-3.5 w-3.5" />
                            </button>
                          )}
                        </>
                      ) : (
                        <>
                          <button
                            type="button"
                            onClick={() => onEdit(category)}
                            className="rounded-lg p-1.5 text-zinc-500 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-white border border-transparent hover:border-zinc-200 dark:hover:border-zinc-700 transition cursor-pointer"
                            title={isAr ? 'تعديل التصنيف' : 'Edit Category'}
                          >
                            <Edit2 className="h-3.5 w-3.5" />
                          </button>
                          <button
                            type="button"
                            onClick={() => onDelete(category)}
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
                              <Archive className="h-3.5 w-3.5 text-amber-500" />
                            ) : (
                              <Trash2 className="h-3.5 w-3.5" />
                            )}
                          </button>
                        </>
                      )}
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </Card>
  );
};
