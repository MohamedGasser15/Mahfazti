import { apiClient } from '../../../api/client';
import type {
  CategoryDto,
  CreateCategoryDto,
  UpdateCategoryDto,
  CategoryItem,
  BulkDeleteResultDto,
} from '../types';

const LUXURY_PALETTE = [
  '#6366f1', // Indigo
  '#8b5cf6', // Violet
  '#ec4899', // Pink
  '#f97316', // Orange
  '#06b6d4', // Cyan
  '#10b981', // Emerald
  '#3b82f6', // Blue
  '#eab308', // Yellow
  '#14b8a6', // Teal
  '#64748b', // Slate
];

/**
 * Maps raw backend CategoryDto into a rich UI presentation item
 */
export const mapDtoToCategoryItem = (dto: CategoryDto): CategoryItem => {
  const en = (dto.nameEn || '').trim().toLowerCase();
  const ar = (dto.nameAr || '').trim().toLowerCase();

  let defaultIcon = 'tag';
  let defaultColor = LUXURY_PALETTE[Math.abs(dto.id) % LUXURY_PALETTE.length];
  let defaultType: 'Expense' | 'Income' = 'Expense';

  if (en.includes('food') || ar.includes('طعام') || ar.includes('شراب')) {
    defaultIcon = 'utensils';
    defaultColor = '#f97316';
    defaultType = 'Expense';
  } else if (en.includes('transport') || ar.includes('مواصلات') || ar.includes('وقود')) {
    defaultIcon = 'car';
    defaultColor = '#6366f1';
    defaultType = 'Expense';
  } else if (en.includes('shop') || ar.includes('تسوق')) {
    defaultIcon = 'shopping-bag';
    defaultColor = '#ec4899';
    defaultType = 'Expense';
  } else if (en.includes('entertain') || ar.includes('ترفيه')) {
    defaultIcon = 'sparkles';
    defaultColor = '#8b5cf6';
    defaultType = 'Expense';
  } else if (en.includes('health') || en.includes('medic') || ar.includes('صحة') || ar.includes('علاج')) {
    defaultIcon = 'activity';
    defaultColor = '#10b981';
    defaultType = 'Expense';
  } else if (en.includes('bill') || en.includes('util') || ar.includes('فواتير') || ar.includes('اشتراك')) {
    defaultIcon = 'receipt';
    defaultColor = '#06b6d4';
    defaultType = 'Expense';
  } else if (en.includes('edu') || ar.includes('تعليم')) {
    defaultIcon = 'graduation-cap';
    defaultColor = '#3b82f6';
    defaultType = 'Expense';
  } else if (en.includes('salary') || ar.includes('راتب')) {
    defaultIcon = 'wallet';
    defaultColor = '#10b981';
    defaultType = 'Income';
  } else if (en.includes('bonus') || ar.includes('مكافأة') || ar.includes('حافز')) {
    defaultIcon = 'gift';
    defaultColor = '#eab308';
    defaultType = 'Income';
  } else if (en.includes('invest') || ar.includes('استثمار')) {
    defaultIcon = 'trending-up';
    defaultColor = '#3b82f6';
    defaultType = 'Income';
  } else if (en.includes('income') || ar.includes('دخل') || ar.includes('إيراد')) {
    defaultIcon = 'trending-up';
    defaultColor = '#14b8a6';
    defaultType = 'Income';
  } else if (en.includes('freelance') || ar.includes('عمل حر')) {
    defaultIcon = 'briefcase';
    defaultColor = '#f59e0b';
    defaultType = 'Income';
  }

  // Prioritize explicit backend type & icon when provided
  const type: 'Expense' | 'Income' =
    dto.type === 'Income' || dto.type === 'Expense'
      ? dto.type
      : defaultType;

  const icon: string = dto.icon && dto.icon.trim() !== ''
    ? dto.icon
    : defaultIcon;

  // Icon-specific color palette for visual harmony
  const iconColorMap: Record<string, string> = {
    utensils: '#f97316',
    car: '#6366f1',
    'shopping-bag': '#ec4899',
    sparkles: '#8b5cf6',
    activity: '#10b981',
    receipt: '#06b6d4',
    'graduation-cap': '#3b82f6',
    wallet: '#10b981',
    gift: '#eab308',
    'trending-up': '#3b82f6',
    briefcase: '#f59e0b',
    tag: '#64748b',
    layers: '#6366f1',
  };

  const color = iconColorMap[icon] || (type === 'Income' ? '#10b981' : defaultColor);

  return {
    id: dto.id,
    name: dto.nameEn || dto.nameAr || 'Category',
    nameEn: dto.nameEn || '',
    nameAr: dto.nameAr || '',
    icon,
    color,
    type,
    isActive: dto.isActive !== false,
    transactionCount: dto.transactionCount || 0,
    isDefault: true,
  };
};

export const categoriesService = {
  /**
   * Fetches all categories from GET /api/Category
   */
  getCategories: async (): Promise<CategoryItem[]> => {
    const response = await apiClient.get<CategoryDto[]>('/Category');
    const rawData = response.data;
    const items: CategoryDto[] = Array.isArray(rawData)
      ? rawData
      : (rawData as unknown as { data?: CategoryDto[] })?.data || [];
    return items.map(mapDtoToCategoryItem);
  },

  /**
   * Fetches single category by ID from GET /api/Category/{id}
   */
  getCategoryById: async (id: number): Promise<CategoryItem> => {
    const response = await apiClient.get<CategoryDto>(`/Category/${id}`);
    const rawData = response.data;
    const item: CategoryDto =
      (rawData as unknown as { data?: CategoryDto })?.data || rawData;
    return mapDtoToCategoryItem(item);
  },

  /**
   * Creates a new category via POST /api/Category
   */
  createCategory: async (dto: CreateCategoryDto): Promise<CategoryItem> => {
    const response = await apiClient.post<CategoryDto>('/Category', dto);
    const rawData = response.data;
    const item: CategoryDto =
      (rawData as unknown as { data?: CategoryDto })?.data || rawData;
    return mapDtoToCategoryItem(item);
  },

  /**
   * Updates an existing category via PUT /api/Category/{id}
   */
  updateCategory: async (id: number, dto: UpdateCategoryDto): Promise<CategoryItem> => {
    const response = await apiClient.put<CategoryDto>(`/Category/${id}`, dto);
    const rawData = response.data;
    const item: CategoryDto =
      (rawData as unknown as { data?: CategoryDto })?.data || rawData;
    return mapDtoToCategoryItem(item);
  },

  /**
   * Deletes a category safely via DELETE /api/Category/{id}
   * (Archives if transactions exist, or hard deletes if 0 transactions)
   */
  deleteCategory: async (id: number): Promise<void> => {
    await apiClient.delete(`/Category/${id}`);
  },

  /**
   * Restores an archived category via POST /api/Category/{id}/restore
   */
  restoreCategory: async (id: number): Promise<void> => {
    await apiClient.post(`/Category/${id}/restore`);
  },

  /**
   * Bulk deletes categories via POST /api/Category/bulk-delete
   */
  bulkDeleteCategories: async (ids: number[]): Promise<BulkDeleteResultDto> => {
    const response = await apiClient.post<BulkDeleteResultDto>('/Category/bulk-delete', ids);
    return response.data;
  },

  /**
   * Bulk restores archived categories via POST /api/Category/bulk-restore
   */
  bulkRestoreCategories: async (ids: number[]): Promise<{ success: boolean; restoredCount: number; message: string }> => {
    const response = await apiClient.post<{ success: boolean; restoredCount: number; message: string }>('/Category/bulk-restore', ids);
    return response.data;
  },
};
