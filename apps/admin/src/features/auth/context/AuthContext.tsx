import React, { createContext, useContext, useState } from 'react';
import type { AdminUser } from '../types';

interface AuthContextType {
  user: AdminUser | null;
  isAuthenticated: boolean;
  login: (email?: string, password?: string) => void;
  logout: () => void;
}

const mockDefaultAdmin: AdminUser = {
  id: 'admin-1',
  email: 'admin@mahfazti.app',
  fullName: 'Mohamed Gasser',
  role: 'SuperAdmin',
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AdminUser | null>(() => {
    const saved = localStorage.getItem('mahfazti_admin_session');
    return saved ? JSON.parse(saved) : mockDefaultAdmin;
  });

  const login = (email?: string) => {
    const adminSession: AdminUser = {
      ...mockDefaultAdmin,
      email: email || mockDefaultAdmin.email,
    };
    localStorage.setItem('mahfazti_admin_session', JSON.stringify(adminSession));
    setUser(adminSession);
  };

  const logout = () => {
    localStorage.removeItem('mahfazti_admin_session');
    setUser(null);
  };

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
