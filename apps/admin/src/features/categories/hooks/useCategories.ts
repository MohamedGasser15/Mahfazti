import { useState, useEffect } from 'react';
import type { CategoryItem } from '../types';
import { categoriesService } from '../services/categoriesService';

export const useCategories = () => {
  const [categories, setCategories] = useState<CategoryItem[]>([]);
  const [activeTab, setActiveTab] = useState<'all' | 'Expense' | 'Income'>('all');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    categoriesService.getCategories().then((res) => {
      setCategories(res);
      setIsLoading(false);
    });
  }, []);

  const filtered = categories.filter((c) =>
    activeTab === 'all' ? true : c.type === activeTab
  );

  return {
    categories: filtered,
    activeTab,
    setActiveTab,
    isLoading,
  };
};
