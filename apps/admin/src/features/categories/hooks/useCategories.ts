import { useState, useEffect, useMemo, useCallback } from 'react';
import type {
  CategoryItem,
  CreateCategoryDto,
  UpdateCategoryDto,
  BulkDeleteResultDto,
} from '../types';
import { categoriesService } from '../services/categoriesService';

export type CategoryTabType = 'all' | 'Expense' | 'Income' | 'Archived';

export const useCategories = () => {
  const [categories, setCategories] = useState<CategoryItem[]>([]);
  const [activeTab, setActiveTab] = useState<CategoryTabType>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set());
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 20;

  const loadCategories = useCallback(() => {
    categoriesService
      .getCategories()
      .then((data) => {
        setCategories(data);
        setError(null);
      })
      .catch((err: unknown) => {
        const msg = err instanceof Error ? err.message : 'Failed to load categories';
        setError(msg);
      })
      .finally(() => {
        setIsLoading(false);
      });
  }, []);

  useEffect(() => {
    loadCategories();
  }, [loadCategories]);

  const handleTabChange = useCallback((tab: CategoryTabType) => {
    setActiveTab(tab);
    setSelectedIds(new Set());
    setCurrentPage(1);
  }, []);

  const handleSearchChange = useCallback((query: string) => {
    setSearchQuery(query);
    setCurrentPage(1);
  }, []);

  const refetch = useCallback(async () => {
    setIsLoading(true);
    loadCategories();
  }, [loadCategories]);

  const createCategory = async (dto: CreateCategoryDto): Promise<CategoryItem> => {
    setIsSubmitting(true);
    try {
      const created = await categoriesService.createCategory(dto);
      setCategories((prev) => [created, ...prev]);
      return created;
    } finally {
      setIsSubmitting(false);
    }
  };

  const updateCategory = async (
    id: number,
    dto: UpdateCategoryDto
  ): Promise<CategoryItem> => {
    setIsSubmitting(true);
    try {
      const updated = await categoriesService.updateCategory(id, dto);
      setCategories((prev) =>
        prev.map((c) =>
          c.id === id
            ? { ...updated, transactionCount: updated.transactionCount || c.transactionCount }
            : c
        )
      );
      return updated;
    } finally {
      setIsSubmitting(false);
    }
  };

  const deleteCategory = async (id: number): Promise<void> => {
    setIsSubmitting(true);
    try {
      await categoriesService.deleteCategory(id);
      // If it had transactions, it got archived; otherwise removed
      setCategories((prev) => {
        const target = prev.find((c) => c.id === id);
        if (target && target.transactionCount > 0) {
          return prev.map((c) => (c.id === id ? { ...c, isActive: false } : c));
        }
        return prev.filter((c) => c.id !== id);
      });
      setSelectedIds((prev) => {
        const next = new Set(prev);
        next.delete(id);
        return next;
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const restoreCategory = async (id: number): Promise<void> => {
    setIsSubmitting(true);
    try {
      await categoriesService.restoreCategory(id);
      setCategories((prev) =>
        prev.map((c) => (c.id === id ? { ...c, isActive: true } : c))
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  const bulkDelete = async (ids: number[]): Promise<BulkDeleteResultDto> => {
    setIsSubmitting(true);
    try {
      const result = await categoriesService.bulkDeleteCategories(ids);
      // Reload categories to guarantee 100% sync with backend
      await refetch();
      setSelectedIds(new Set());
      return result;
    } finally {
      setIsSubmitting(false);
    }
  };

  const bulkRestore = async (ids: number[]): Promise<number> => {
    setIsSubmitting(true);
    try {
      const res = await categoriesService.bulkRestoreCategories(ids);
      await refetch();
      setSelectedIds(new Set());
      return res.restoredCount;
    } finally {
      setIsSubmitting(false);
    }
  };

  // Selection helpers
  const toggleSelect = (id: number) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  };

  const clearSelection = () => {
    setSelectedIds(new Set());
  };

  // Filtered categories based on search query and active tab
  const filteredCategories = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();

    return categories.filter((c) => {
      // Tab filter
      if (activeTab === 'Archived') {
        if (c.isActive) return false;
      } else {
        // 'all', 'Expense', 'Income' only show active categories by default
        if (!c.isActive) return false;
        if (activeTab !== 'all' && c.type !== activeTab) {
          return false;
        }
      }

      // Search query filter
      if (!query) return true;

      const matchesEn = (c.nameEn || c.name || '').toLowerCase().includes(query);
      const matchesAr = (c.nameAr || '').toLowerCase().includes(query);
      return matchesEn || matchesAr;
    });
  }, [categories, activeTab, searchQuery]);

  // Pagination calculations
  const totalPages = Math.max(1, Math.ceil(filteredCategories.length / pageSize));
  const validCurrentPage = Math.min(Math.max(1, currentPage), totalPages);

  const paginatedCategories = useMemo(() => {
    const start = (validCurrentPage - 1) * pageSize;
    return filteredCategories.slice(start, start + pageSize);
  }, [filteredCategories, validCurrentPage, pageSize]);

  const goToPage = useCallback((page: number) => {
    setCurrentPage(page);
  }, []);

  const nextPage = useCallback(() => {
    setCurrentPage((p) => Math.min(p + 1, totalPages));
  }, [totalPages]);

  const prevPage = useCallback(() => {
    setCurrentPage((p) => Math.max(p - 1, 1));
  }, []);

  const selectAll = () => {
    const pageIds = paginatedCategories.map((c) => c.id);
    setSelectedIds(new Set(pageIds));
  };

  const isAllSelected =
    paginatedCategories.length > 0 &&
    paginatedCategories.every((c) => selectedIds.has(c.id));

  // Statistics
  const counts = useMemo(() => {
    let expenses = 0;
    let income = 0;
    let archived = 0;
    let activeTotal = 0;

    for (const c of categories) {
      if (!c.isActive) {
        archived++;
      } else {
        activeTotal++;
        if (c.type === 'Income') income++;
        else expenses++;
      }
    }

    return {
      all: activeTotal,
      expenses,
      income,
      archived,
      totalCount: categories.length,
    };
  }, [categories]);

  return {
    categories: paginatedCategories,
    rawCategories: categories,
    totalFilteredCount: filteredCategories.length,
    counts,
    activeTab,
    setActiveTab: handleTabChange,
    searchQuery,
    setSearchQuery: handleSearchChange,
    selectedIds,
    toggleSelect,
    selectAll,
    clearSelection,
    isAllSelected,
    // Pagination exports
    currentPage: validCurrentPage,
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
  };
};
