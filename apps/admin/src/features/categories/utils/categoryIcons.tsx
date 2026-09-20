import React from 'react';
import {
  Utensils,
  Car,
  ShoppingBag,
  Sparkles,
  Activity,
  Receipt,
  GraduationCap,
  Wallet,
  Gift,
  TrendingUp,
  Briefcase,
  Tag,
  Layers,
} from 'lucide-react';

export interface CategoryIconOption {
  id: string;
  labelEn: string;
  labelAr: string;
}

export const AVAILABLE_ICONS: readonly CategoryIconOption[] = [
  { id: 'utensils', labelEn: 'Dining', labelAr: 'طعام' },
  { id: 'car', labelEn: 'Transport', labelAr: 'مواصلات' },
  { id: 'shopping-bag', labelEn: 'Shopping', labelAr: 'تسوق' },
  { id: 'sparkles', labelEn: 'Leisure', labelAr: 'ترفيه' },
  { id: 'activity', labelEn: 'Health', labelAr: 'صحة' },
  { id: 'receipt', labelEn: 'Bills', labelAr: 'فواتير' },
  { id: 'graduation-cap', labelEn: 'Education', labelAr: 'تعليم' },
  { id: 'wallet', labelEn: 'Salary', labelAr: 'راتب' },
  { id: 'gift', labelEn: 'Rewards', labelAr: 'مكافآت' },
  { id: 'trending-up', labelEn: 'Invest', labelAr: 'استثمار' },
  { id: 'briefcase', labelEn: 'Work', labelAr: 'عمل' },
  { id: 'tag', labelEn: 'General', labelAr: 'عام' },
  { id: 'layers', labelEn: 'Other', labelAr: 'أخرى' },
];

export const renderCategoryIcon = (iconName: string, className = 'h-5 w-5'): React.ReactNode => {
  switch (iconName) {
    case 'utensils':
      return <Utensils className={className} />;
    case 'car':
      return <Car className={className} />;
    case 'shopping-bag':
      return <ShoppingBag className={className} />;
    case 'sparkles':
      return <Sparkles className={className} />;
    case 'activity':
      return <Activity className={className} />;
    case 'receipt':
      return <Receipt className={className} />;
    case 'graduation-cap':
      return <GraduationCap className={className} />;
    case 'wallet':
      return <Wallet className={className} />;
    case 'gift':
      return <Gift className={className} />;
    case 'trending-up':
      return <TrendingUp className={className} />;
    case 'briefcase':
      return <Briefcase className={className} />;
    case 'tag':
      return <Tag className={className} />;
    default:
      return <Layers className={className} />;
  }
};
