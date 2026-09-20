import React from 'react';
import { ThreeDotLoader } from './ThreeDotLoader';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'outline' | 'ghost' | 'warning';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
  isLoading?: boolean;
  loadingText?: string;
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  children,
  isLoading = false,
  loadingText,
  className = '',
  disabled,
  ...props
}) => {
  const baseStyles =
    'inline-flex items-center justify-center font-medium rounded-xl transition duration-150 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed';

  const sizeStyles = {
    sm: 'px-3 py-1.5 text-xs gap-1.5 min-h-[32px]',
    md: 'px-4 py-2 text-sm gap-2 min-h-[40px]',
    lg: 'px-5 py-2.5 text-base gap-2.5 min-h-[46px]',
  };

  const variantStyles = {
    primary:
      'bg-black text-white hover:bg-zinc-800 dark:bg-white dark:text-black dark:hover:bg-zinc-200 shadow-xs border border-transparent',
    secondary:
      'bg-zinc-100 text-zinc-900 hover:bg-zinc-200 dark:bg-zinc-800 dark:text-zinc-100 dark:hover:bg-zinc-700 border border-zinc-200 dark:border-zinc-700',
    danger:
      'bg-rose-50 text-rose-600 hover:bg-rose-100 dark:bg-rose-950/60 dark:text-rose-300 dark:hover:bg-rose-950/90 border border-rose-200 dark:border-rose-900/60',
    warning:
      'bg-amber-50 text-amber-700 hover:bg-amber-100 dark:bg-amber-950/60 dark:text-amber-300 dark:hover:bg-amber-950/90 border border-amber-200 dark:border-amber-900/60',
    outline:
      'bg-transparent text-zinc-900 dark:text-zinc-100 hover:bg-zinc-100 dark:hover:bg-zinc-800 dark:hover:text-white border border-zinc-300 dark:border-zinc-700 dark:hover:border-zinc-600',
    ghost:
      'bg-transparent text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-black dark:hover:text-white',
  };

  return (
    <button
      className={`${baseStyles} ${sizeStyles[size]} ${variantStyles[variant]} ${className}`}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? (
        <span className="flex items-center justify-center py-0.5">
          <ThreeDotLoader size={size} />
          {loadingText ? <span className="sr-only">{loadingText}</span> : null}
        </span>
      ) : (
        children
      )}
    </button>
  );
};
