import React from 'react';

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  children: React.ReactNode;
  className?: string;
}

export const Card: React.FC<CardProps> = ({ children, className = '', ...props }) => {
  return (
    <div
      className={`rounded-3xl border border-zinc-200/90 dark:border-zinc-800/80 bg-gradient-to-br from-white to-zinc-50/50 dark:from-zinc-900/95 dark:to-zinc-950/95 p-6 shadow-sm transition-all duration-200 hover:border-zinc-300 dark:hover:border-zinc-700/80 ${className}`}
      {...props}
    >
      {children}
    </div>
  );
};
