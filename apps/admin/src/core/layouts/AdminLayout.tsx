import React, { useState, useEffect, useRef } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Navbar } from './Navbar';

export const AdminLayout: React.FC = () => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const location = useLocation();
  const mainRef = useRef<HTMLElement>(null);

  // Auto-scroll to top on every page navigation
  useEffect(() => {
    if (mainRef.current) {
      mainRef.current.scrollTo({ top: 0, behavior: 'instant' });
    }
  }, [location.pathname]);

  return (
    <div className="flex h-screen max-h-screen overflow-hidden bg-[#F8F9FA] dark:bg-[#000000] text-zinc-900 dark:text-zinc-100 transition-colors duration-200">
      {/* Sidebar with responsive scalable width */}
      <Sidebar isOpen={isSidebarOpen} onClose={() => setIsSidebarOpen(false)} />

      <div className="flex flex-1 flex-col min-w-0 h-screen max-h-screen overflow-hidden">
        {/* Unified Top Navbar */}
        <Navbar onToggleSidebar={() => setIsSidebarOpen((prev) => !prev)} />

        {/* Content Container with auto-scroll and seamless page rendering */}
        <main
          ref={mainRef}
          className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8 2xl:p-10 bg-[#F8F9FA] dark:bg-[#000000] transition-colors duration-200"
        >
          <div className="mx-auto w-full max-w-[1700px] space-y-6">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
};
