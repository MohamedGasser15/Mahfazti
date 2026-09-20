/* eslint-disable react-refresh/only-export-components */
import React, { createContext, useContext, useState } from 'react';
import type { AdminUser } from '../types';
import { authApi } from '../api/authApi';

interface AuthContextType {
  user: AdminUser | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AdminUser | null>(() => {
    try {
      const token = localStorage.getItem('mahfazti_admin_access_token');
      const saved = localStorage.getItem('mahfazti_admin_session');
      if (token && saved) {
        return JSON.parse(saved);
      }
    } catch {
      // In case localStorage is unavailable or corrupted
    }
    return null;
  });

  const login = async (email: string, password: string): Promise<void> => {
    const data = await authApi.login({ email, password });

    if (data.token) {
      localStorage.setItem('mahfazti_admin_access_token', data.token);
    }
    if (data.refreshToken) {
      localStorage.setItem('mahfazti_admin_refresh_token', data.refreshToken);
    }

    const backendUser = data.user;
    const adminSession: AdminUser = {
      id: backendUser?.id || 'admin',
      email: backendUser?.email || email,
      fullName: backendUser?.fullName || 'Administrator',
      userName: backendUser?.userName || email,
      role: backendUser?.role || 'Admin',
      currency: backendUser?.currency,
      preferredLanguage: backendUser?.preferredLanguage,
      avatarUrl: backendUser?.imagePath,
      phoneNumber: backendUser?.phoneNumber,
    };

    localStorage.setItem('mahfazti_admin_session', JSON.stringify(adminSession));
    setUser(adminSession);
  };

  const logout = () => {
    localStorage.removeItem('mahfazti_admin_access_token');
    localStorage.removeItem('mahfazti_admin_refresh_token');
    localStorage.removeItem('mahfazti_admin_session');
    setUser(null);
  };

  // Cross-tab security synchronization (instant logout propagation across all open tabs)
  React.useEffect(() => {
    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === 'mahfazti_admin_session' || e.key === 'mahfazti_admin_access_token') {
        if (!e.newValue) {
          setUser(null);
        } else if (e.key === 'mahfazti_admin_session' && e.newValue) {
          try {
            setUser(JSON.parse(e.newValue));
          } catch {
            setUser(null);
          }
        }
      }
    };

    window.addEventListener('storage', handleStorageChange);
    return () => window.removeEventListener('storage', handleStorageChange);
  }, []);

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
