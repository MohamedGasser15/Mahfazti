import React from 'react';
import logoLight from '../../../assets/mahfazti-logo-light.png';
import logoDark from '../../../assets/mahfazti-logo-dark.png';

interface MahfaztiLogoProps {
  size?: number | string;
  className?: string;
}

export const MahfaztiLogo: React.FC<MahfaztiLogoProps> = ({
  size = 36,
  className = '',
}) => {
  return (
    <div
      className={`relative inline-flex items-center justify-center shrink-0 overflow-hidden rounded-xl ${className}`}
      style={{ width: size, height: size }}
    >
      {/* Light Mode Logo (Black on White) */}
      <img
        src={logoLight}
        alt="Mahfazti Logo"
        className="w-full h-full object-contain dark:hidden"
      />
      {/* Dark Mode Logo (White on Black) */}
      <img
        src={logoDark}
        alt="Mahfazti Logo"
        className="w-full h-full object-contain hidden dark:block"
      />
    </div>
  );
};
