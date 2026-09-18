import type { CategoryItem } from '../types';

let mockCategories: CategoryItem[] = [
  { id: 'cat-1', name: 'Food & Dining', nameAr: 'طعام ومشروبات', icon: 'utensils', color: '#6366f1', type: 'Expense', isDefault: true },
  { id: 'cat-2', name: 'Transport & Fuel', nameAr: 'مواصلات ووقود', icon: 'car', color: '#8b5cf6', type: 'Expense', isDefault: true },
  { id: 'cat-3', name: 'Shopping', nameAr: 'تسوق', icon: 'shopping-bag', color: '#ec4899', type: 'Expense', isDefault: true },
  { id: 'cat-4', name: 'Bills & Utilities', nameAr: 'فواتير واشتراكات', icon: 'receipt', color: '#06b6d4', type: 'Expense', isDefault: true },
  { id: 'cat-5', name: 'Health & Medical', nameAr: 'صحة وعلاج', icon: 'activity', color: '#10b981', type: 'Expense', isDefault: true },
  { id: 'cat-6', name: 'Salary', nameAr: 'راتب شهري', icon: 'wallet', color: '#10b981', type: 'Income', isDefault: true },
  { id: 'cat-7', name: 'Freelance & Business', nameAr: 'عمل حر وأعمال', icon: 'briefcase', color: '#f59e0b', type: 'Income', isDefault: true },
  { id: 'cat-8', name: 'Investments', nameAr: 'استثمارات', icon: 'trending-up', color: '#3b82f6', type: 'Income', isDefault: true },
];

export const categoriesService = {
  getCategories: async (): Promise<CategoryItem[]> => {
    return new Promise((resolve) => {
      setTimeout(() => resolve([...mockCategories]), 100);
    });
  },
};
