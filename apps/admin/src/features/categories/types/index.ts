export interface CategoryItem {
  id: string;
  name: string;
  nameAr: string;
  icon: string;
  color: string;
  type: 'Expense' | 'Income';
  isDefault: boolean;
}
