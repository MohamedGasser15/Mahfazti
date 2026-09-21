export interface CurrencyExtraInfo {
  region: 'arab' | 'global' | 'other';
  flag: string;
  gradient: string;
  badgeColor: string;
}

export const CURRENCY_EXTRAS: Record<string, CurrencyExtraInfo> = {
  EGP: { region: 'arab', flag: '🇪🇬', gradient: 'from-amber-500/20 to-red-500/10', badgeColor: 'bg-amber-500/10 text-amber-600 dark:text-amber-400' },
  SAR: { region: 'arab', flag: '🇸🇦', gradient: 'from-emerald-500/20 to-teal-500/10', badgeColor: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400' },
  AED: { region: 'arab', flag: '🇦🇪', gradient: 'from-emerald-500/20 to-red-500/10', badgeColor: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400' },
  KWD: { region: 'arab', flag: '🇰🇼', gradient: 'from-blue-500/20 to-emerald-500/10', badgeColor: 'bg-blue-500/10 text-blue-600 dark:text-blue-400' },
  QAR: { region: 'arab', flag: '🇶🇦', gradient: 'from-rose-500/20 to-purple-500/10', badgeColor: 'bg-rose-500/10 text-rose-600 dark:text-rose-400' },
  BHD: { region: 'arab', flag: '🇧🇭', gradient: 'from-red-500/20 to-rose-500/10', badgeColor: 'bg-red-500/10 text-red-600 dark:text-red-400' },
  OMR: { region: 'arab', flag: '🇴🇲', gradient: 'from-red-500/20 to-emerald-500/10', badgeColor: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400' },
  JOD: { region: 'arab', flag: '🇯🇴', gradient: 'from-green-500/20 to-red-500/10', badgeColor: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400' },
  MAD: { region: 'arab', flag: '🇲🇦', gradient: 'from-red-500/20 to-emerald-500/10', badgeColor: 'bg-red-500/10 text-red-600 dark:text-red-400' },
  DZD: { region: 'arab', flag: '🇩🇿', gradient: 'from-emerald-500/20 to-red-500/10', badgeColor: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400' },
  TND: { region: 'arab', flag: '🇹🇳', gradient: 'from-red-500/20 to-rose-500/10', badgeColor: 'bg-red-500/10 text-red-600 dark:text-red-400' },
  LYD: { region: 'arab', flag: '🇱🇾', gradient: 'from-emerald-500/20 to-black/10', badgeColor: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400' },
  IQD: { region: 'arab', flag: '🇮🇶', gradient: 'from-red-500/20 to-emerald-500/10', badgeColor: 'bg-red-500/10 text-red-600 dark:text-red-400' },
  LBP: { region: 'arab', flag: '🇱🇧', gradient: 'from-red-500/20 to-green-500/10', badgeColor: 'bg-red-500/10 text-red-600 dark:text-red-400' },
  SDG: { region: 'arab', flag: '🇸🇩', gradient: 'from-red-500/20 to-emerald-500/10', badgeColor: 'bg-red-500/10 text-red-600 dark:text-red-400' },

  USD: { region: 'global', flag: '🇺🇸', gradient: 'from-emerald-500/20 to-blue-500/10', badgeColor: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400' },
  EUR: { region: 'global', flag: '🇪🇺', gradient: 'from-blue-500/20 to-indigo-500/10', badgeColor: 'bg-blue-500/10 text-blue-600 dark:text-blue-400' },
  GBP: { region: 'global', flag: '🇬🇧', gradient: 'from-indigo-500/20 to-red-500/10', badgeColor: 'bg-indigo-500/10 text-indigo-600 dark:text-indigo-400' },
  CAD: { region: 'global', flag: '🇨🇦', gradient: 'from-red-500/20 to-rose-500/10', badgeColor: 'bg-red-500/10 text-red-600 dark:text-red-400' },
  CHF: { region: 'global', flag: '🇨🇭', gradient: 'from-red-500/20 to-zinc-500/10', badgeColor: 'bg-rose-500/10 text-rose-600 dark:text-rose-400' },
  JPY: { region: 'global', flag: '🇯🇵', gradient: 'from-red-500/20 to-rose-500/10', badgeColor: 'bg-red-500/10 text-red-600 dark:text-red-400' },
  CNY: { region: 'global', flag: '🇨🇳', gradient: 'from-yellow-500/20 to-red-500/10', badgeColor: 'bg-amber-500/10 text-amber-600 dark:text-amber-400' },
  TRY: { region: 'global', flag: '🇹🇷', gradient: 'from-red-500/20 to-rose-500/10', badgeColor: 'bg-red-500/10 text-red-600 dark:text-red-400' },
  AUD: { region: 'global', flag: '🇦🇺', gradient: 'from-blue-500/20 to-red-500/10', badgeColor: 'bg-blue-500/10 text-blue-600 dark:text-blue-400' },
  INR: { region: 'global', flag: '🇮🇳', gradient: 'from-orange-500/20 to-emerald-500/10', badgeColor: 'bg-orange-500/10 text-orange-600 dark:text-orange-400' },
  RUB: { region: 'global', flag: '🇷🇺', gradient: 'from-blue-500/20 to-red-500/10', badgeColor: 'bg-blue-500/10 text-blue-600 dark:text-blue-400' },
  BRL: { region: 'global', flag: '🇧🇷', gradient: 'from-emerald-500/20 to-yellow-500/10', badgeColor: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400' },
};

export const getCurrencyExtra = (code: string): CurrencyExtraInfo => {
  return (
    CURRENCY_EXTRAS[code.toUpperCase()] || {
      region: 'other',
      flag: '🌐',
      gradient: 'from-zinc-500/20 to-transparent',
      badgeColor: 'bg-zinc-500/10 text-zinc-600 dark:text-zinc-400',
    }
  );
};
