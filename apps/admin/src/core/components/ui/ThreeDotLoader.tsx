import React from 'react';
import { motion } from 'framer-motion';

interface ThreeDotLoaderProps {
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export const ThreeDotLoader: React.FC<ThreeDotLoaderProps> = ({
  size = 'md',
  className = '',
}) => {
  const dotSizes = {
    sm: 'h-1.5 w-1.5',
    md: 'h-2 w-2',
    lg: 'h-2.5 w-2.5',
  };

  return (
    <span
      className={`inline-flex items-center justify-center gap-1.5 select-none ${className}`}
      aria-label="Loading"
      role="status"
    >
      {[0, 1, 2].map((i) => (
        <motion.span
          key={i}
          className={`${dotSizes[size]} rounded-full bg-current`}
          initial={{ scale: 0.6, opacity: 0.35 }}
          animate={{
            scale: [0.6, 1.15, 0.6],
            opacity: [0.35, 1, 0.35],
          }}
          transition={{
            duration: 1.1,
            repeat: Infinity,
            ease: 'easeInOut',
            delay: i * 0.18,
          }}
        />
      ))}
    </span>
  );
};
