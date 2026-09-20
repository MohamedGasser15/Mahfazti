import React from 'react';

interface BadgeProps {
  children: React.ReactNode;
  variant?: 'success' | 'danger' | 'warning' | 'info' | 'default';
  className?: string;
}

export const Badge: React.FC<BadgeProps> = ({
  children,
  variant = 'default',
  className = '',
}) => {
  const variantStyles = {
    success:
      'border-emerald-500/40 bg-emerald-50 text-emerald-700 dark:border-emerald-500/50 dark:bg-emerald-950/80 dark:text-emerald-300 shadow-2xs',
    danger:
      'border-rose-500/40 bg-rose-50 text-rose-700 dark:border-rose-500/50 dark:bg-rose-950/80 dark:text-rose-300 shadow-2xs',
    warning:
      'border-amber-500/40 bg-amber-50 text-amber-700 dark:border-amber-500/50 dark:bg-amber-950/80 dark:text-amber-300 shadow-2xs',
    info: 'border-blue-500/40 bg-blue-50 text-blue-700 dark:border-blue-500/50 dark:bg-blue-950/80 dark:text-blue-300 shadow-2xs',
    default:
      'border-zinc-200 bg-zinc-100 text-zinc-800 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-200 shadow-2xs',
  };

  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full border px-2.5 py-0.5 text-xs font-semibold ${variantStyles[variant]} ${className}`}
    >
      {children}
    </span>
  );
};
