export interface CategoryDto {
  id: number;
  nameAr: string;
  nameEn: string;
  type?: 'Expense' | 'Income' | string;
  icon?: string;
  isActive?: boolean;
  transactionCount?: number;
}

export interface CreateCategoryDto {
  nameAr: string;
  nameEn: string;
  type: 'Expense' | 'Income';
  icon: string;
}

export interface UpdateCategoryDto {
  id: number;
  nameAr: string;
  nameEn: string;
  type: 'Expense' | 'Income';
  icon: string;
}

export interface CategoryItem {
  id: number;
  name: string;
  nameEn: string;
  nameAr: string;
  icon: string;
  color: string;
  type: 'Expense' | 'Income';
  isActive: boolean;
  transactionCount: number;
  isDefault?: boolean;
}

export interface BulkDeleteResultDto {
  totalRequested: number;
  deletedCount: number;
  archivedCount: number;
  processedIds: number[];
  message: string;
}

