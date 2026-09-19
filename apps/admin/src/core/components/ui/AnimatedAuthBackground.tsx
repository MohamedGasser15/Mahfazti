import React, { useEffect, useRef } from 'react';
import { useTheme } from '../../context/ThemeContext';

export const AnimatedAuthBackground: React.FC = () => {
  const { theme } = useTheme();
  const isDark = theme === 'dark';
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Hardware-accelerated mouse tracking without React re-renders
    let rafId: number;
    const handleMouseMove = (e: MouseEvent) => {
      cancelAnimationFrame(rafId);
      rafId = requestAnimationFrame(() => {
        if (!containerRef.current) return;
        containerRef.current.style.setProperty('--mouse-x', `${e.clientX}px`);
        containerRef.current.style.setProperty('--mouse-y', `${e.clientY}px`);
      });
    };

    window.addEventListener('mousemove', handleMouseMove, { passive: true });
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      cancelAnimationFrame(rafId);
    };
  }, []);

  return (
    <div
      ref={containerRef}
      className="pointer-events-none fixed inset-0 z-0 overflow-hidden select-none"
      style={
        {
          '--mouse-x': '50vw',
          '--mouse-y': '38vh',
        } as React.CSSProperties
      }
    >
      {/* Keyframe animation for drifting dots and horizon pulse */}
      <style>{`
        @keyframes gentleDriftDots {
          0% {
            background-position: 0 0;
          }
          100% {
            background-position: 280px 280px;
          }
        }
        @keyframes horizonPulse {
          0%, 100% {
            opacity: 0.65;
            transform: scaleX(0.96);
          }
          50% {
            opacity: 1;
            transform: scaleX(1.04);
          }
        }
      `}</style>

      {/* 1. Base Monochrome Canvas */}
      <div
        className="absolute inset-0 transition-colors duration-300"
        style={{
          backgroundColor: isDark ? '#000000' : '#f8f9fa',
        }}
      />

      {/* 2. Top Horizon Line (Subtle breathing pulse) */}
      <div className="absolute top-0 inset-x-0 h-px flex justify-center pointer-events-none">
        <div
          className="w-2/3 max-w-3xl h-full transition-opacity duration-300"
          style={{
            background: isDark
              ? 'linear-gradient(90deg, transparent 0%, rgba(255, 255, 255, 0.45) 50%, transparent 100%)'
              : 'linear-gradient(90deg, transparent 0%, rgba(0, 0, 0, 0.22) 50%, transparent 100%)',
            boxShadow: isDark
              ? '0 0 16px 1px rgba(255, 255, 255, 0.25)'
              : '0 0 12px 1px rgba(0, 0, 0, 0.08)',
            animation: 'horizonPulse 6s ease-in-out infinite',
          }}
        />
      </div>

      {/* 3. Base Moving Dot Grid (Gentle Drift in Monochrome) */}
      <div
        className="absolute inset-0 pointer-events-none transition-opacity duration-300"
        style={{
          backgroundImage: isDark
            ? 'radial-gradient(rgba(255, 255, 255, 0.13) 1.2px, transparent 1.2px)'
            : 'radial-gradient(rgba(0, 0, 0, 0.1) 1.2px, transparent 1.2px)',
          backgroundSize: '28px 28px',
          animation: 'gentleDriftDots 35s linear infinite',
          maskImage: 'radial-gradient(ellipse 90% 85% at 50% 50%, black 50%, transparent 95%)',
          WebkitMaskImage: 'radial-gradient(ellipse 90% 85% at 50% 50%, black 50%, transparent 95%)',
        }}
      />

      {/* 4. Interactive Spotlight Moving Dots (Perfect Synchronized Drift) */}
      <div
        className="absolute inset-0 pointer-events-none transition-opacity duration-200"
        style={{
          backgroundImage: isDark
            ? 'radial-gradient(rgba(255, 255, 255, 0.7) 1.4px, transparent 1.4px)'
            : 'radial-gradient(rgba(0, 0, 0, 0.4) 1.4px, transparent 1.4px)',
          backgroundSize: '28px 28px',
          animation: 'gentleDriftDots 35s linear infinite',
          maskImage:
            'radial-gradient(450px circle at var(--mouse-x) var(--mouse-y), black 0%, transparent 100%)',
          WebkitMaskImage:
            'radial-gradient(450px circle at var(--mouse-x) var(--mouse-y), black 0%, transparent 100%)',
        }}
      />

      {/* 5. Subtle Ambient Monochrome Spotlight Glow */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background: isDark
            ? 'radial-gradient(500px circle at var(--mouse-x) var(--mouse-y), rgba(255, 255, 255, 0.04) 0%, transparent 75%)'
            : 'radial-gradient(500px circle at var(--mouse-x) var(--mouse-y), rgba(0, 0, 0, 0.025) 0%, transparent 75%)',
        }}
      />
    </div>
  );
};
