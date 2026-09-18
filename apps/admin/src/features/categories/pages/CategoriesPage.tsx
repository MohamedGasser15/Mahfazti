import React from 'react';
import { Plus, Edit2, Layers, Tag } from 'lucide-react';
import { useCategories } from '../hooks/useCategories';
import { Card } from '../../../core/components/ui/Card';
import { Badge } from '../../../core/components/ui/Badge';
import { Button } from '../../../core/components/ui/Button';

export const CategoriesPage: React.FC = () => {
  const { categories, activeTab, setActiveTab, isLoading } = useCategories();

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-white">System Categories</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400">
            Manage global predefined categories provided automatically to all user wallets.
          </p>
        </div>
        <Button>
          <Plus className="h-4 w-4" />
          <span>New System Category</span>
        </Button>
      </div>

      {/* Tabs */}
      <div className="flex items-center gap-2 border-b border-slate-200 dark:border-slate-800 pb-2">
        {(['all', 'Expense', 'Income'] as const).map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`rounded-xl px-4 py-2 text-sm font-semibold transition cursor-pointer ${
              activeTab === tab
                ? 'bg-blue-50 text-blue-600 dark:bg-blue-600/20 dark:text-blue-400 border border-blue-200 dark:border-blue-500/30'
                : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-400 dark:hover:bg-slate-800/60 dark:hover:text-slate-200'
            }`}
          >
            {tab === 'all' ? 'All Categories' : tab === 'Expense' ? 'Expenses (مصاريف)' : 'Income (دخل)'}
          </button>
        ))}
      </div>

      {/* Categories Grid */}
      {isLoading ? (
        <div className="p-8 text-center text-slate-400">Loading categories...</div>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {categories.map((category) => (
            <Card key={category.id} className="group relative">
              <div className="flex items-start justify-between">
                <div
                  className="flex h-12 w-12 items-center justify-center rounded-2xl shadow-md text-white font-bold"
                  style={{ backgroundColor: category.color }}
                >
                  <Layers className="h-6 w-6" />
                </div>
                <Badge variant={category.type === 'Income' ? 'success' : 'info'}>
                  {category.type}
                </Badge>
              </div>

              <div className="mt-4">
                <h3 className="font-bold text-slate-900 dark:text-slate-100">{category.name}</h3>
                <p className="text-xs text-slate-500 dark:text-slate-400 font-arabic mt-0.5">{category.nameAr}</p>
              </div>

              <div className="mt-4 flex items-center justify-between border-t border-slate-100 dark:border-slate-800/80 pt-3 text-xs text-slate-400">
                <span className="flex items-center gap-1 text-slate-500 dark:text-slate-400">
                  <Tag className="h-3 w-3" />
                  Default System
                </span>
                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition">
                  <button className="rounded p-1 text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 hover:text-slate-900 dark:hover:text-slate-200 cursor-pointer">
                    <Edit2 className="h-3.5 w-3.5" />
                  </button>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};
