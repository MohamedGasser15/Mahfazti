/* eslint-disable react-refresh/only-export-components */
import React, { createContext, useContext, useEffect, useState } from 'react';
import {
  translations,
  type Locale,
  type Direction,
  type TranslationSchema,
} from '../i18n/translations';

interface LocaleContextType {
  locale: Locale;
  isAr: boolean;
  dir: Direction;
  t: TranslationSchema;
  setLocale: (locale: Locale) => void;
  toggleLocale: () => void;
}

const LocaleContext = createContext<LocaleContextType | undefined>(undefined);

export const LocaleProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [locale, setLocaleState] = useState<Locale>(() => {
    const saved = localStorage.getItem('mahfazti_admin_locale');
    if (saved === 'en' || saved === 'ar') return saved;
    return 'en';
  });

  const isAr = locale === 'ar';
  const dir: Direction = isAr ? 'rtl' : 'ltr';

  useEffect(() => {
    const root = document.documentElement;
    root.setAttribute('dir', dir);
    root.setAttribute('lang', locale);
    document.title = isAr ? 'محفظتي' : 'Mahfazti';
    localStorage.setItem('mahfazti_admin_locale', locale);
  }, [locale, dir, isAr]);

  const toggleLocale = () => {
    setLocaleState((prev) => (prev === 'en' ? 'ar' : 'en'));
  };

  const setLocale = (newLocale: Locale) => {
    setLocaleState(newLocale);
  };

  const t = translations[locale];

  return (
    <LocaleContext.Provider value={{ locale, isAr, dir, t, setLocale, toggleLocale }}>
      {children}
    </LocaleContext.Provider>
  );
};

export const useLocale = () => {
  const context = useContext(LocaleContext);
  if (!context) {
    throw new Error('useLocale must be used within a LocaleProvider');
  }
  return context;
};
