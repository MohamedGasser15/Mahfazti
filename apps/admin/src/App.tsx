import React from 'react';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider, useTheme } from './core/context/ThemeContext';
import { LocaleProvider, useLocale } from './core/context/LocaleContext';
import { AuthProvider } from './features/auth/context/AuthContext';
import { AppRoutes } from './routes/AppRoutes';
import { Toaster } from 'sonner';
import { CheckCircle2, AlertCircle, AlertTriangle, Info, Loader2 } from 'lucide-react';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

const ThemedToaster: React.FC = () => {
  const { theme } = useTheme();
  const { dir } = useLocale();
  return (
    <Toaster
      position="top-center"
      theme={theme}
      dir={dir}
      duration={3200}
      offset="24px"
      toastOptions={{
        classNames: {
          toast:
            'group !bg-white/95 dark:!bg-[#0c0c0e]/95 !backdrop-blur-xl !border !border-zinc-200/90 dark:!border-zinc-800/90 !shadow-xl !shadow-black/10 dark:!shadow-[0_20px_45px_-10px_rgba(0,0,0,0.8)] !font-sans transition-all',
          title: '!text-xs sm:!text-sm !font-bold !text-zinc-950 dark:!text-white !tracking-tight',
          description: '!text-[11px] sm:!text-xs !text-zinc-500 dark:!text-zinc-400 !font-normal !mt-0.5 leading-relaxed',
          actionButton:
            '!bg-black dark:!bg-white !text-white dark:!text-black !rounded-xl !text-xs !font-bold !px-3.5 !py-1.5 hover:opacity-90 transition shadow-2xs',
          cancelButton:
            '!bg-zinc-100 dark:!bg-zinc-900 !text-zinc-700 dark:!text-zinc-300 !rounded-xl !text-xs !font-semibold !px-3 !py-1.5 hover:bg-zinc-200 dark:hover:bg-zinc-800 transition',
        },
      }}
      icons={{
        success: <CheckCircle2 className="h-4 w-4" />,
        error: <AlertCircle className="h-4 w-4" />,
        warning: <AlertTriangle className="h-4 w-4" />,
        info: <Info className="h-4 w-4" />,
        loading: <Loader2 className="h-4 w-4 animate-spin" />,
      }}
    />
  );
};

export const App: React.FC = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        <LocaleProvider>
          <BrowserRouter>
            <AuthProvider>
              <AppRoutes />
              <ThemedToaster />
            </AuthProvider>
          </BrowserRouter>
        </LocaleProvider>
      </ThemeProvider>
    </QueryClientProvider>
  );
};

export default App;

