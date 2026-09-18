import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AdminLayout } from '../core/layouts/AdminLayout';
import { PrivateRoute } from './PrivateRoute';
import { LoginPage } from '../features/auth/pages/LoginPage';
import { DashboardPage } from '../features/dashboard/pages/DashboardPage';
import { UsersPage } from '../features/users/pages/UsersPage';
import { RolesPage } from '../features/users/pages/RolesPage';
import { CategoriesPage } from '../features/categories/pages/CategoriesPage';
import { TransactionsPage } from '../features/transactions/pages/TransactionsPage';
import { AiLogsPage } from '../features/ai-logs/pages/AiLogsPage';
import { SettingsPage } from '../features/settings/pages/SettingsPage';
import { SubscriptionsPage } from '../features/subscriptions/pages/SubscriptionsPage';
import { PlansPage } from '../features/subscriptions/pages/PlansPage';
import { PaymentsPage } from '../features/subscriptions/pages/PaymentsPage';
import { PromoCodesPage } from '../features/subscriptions/pages/PromoCodesPage';
import { NotificationsPage } from '../features/notifications/pages/NotificationsPage';
import { SupportPage } from '../features/support/pages/SupportPage';
import { CurrenciesPage } from '../features/currencies/pages/CurrenciesPage';
import { AuditLogsPage } from '../features/audit-logs/pages/AuditLogsPage';
import { WebhooksPage } from '../features/developer/pages/WebhooksPage';
import { SystemHealthPage } from '../features/developer/pages/SystemHealthPage';

export const AppRoutes: React.FC = () => {
  return (
    <Routes>
      {/* Public Route */}
      <Route path="/login" element={<LoginPage />} />

      {/* Protected Admin Routes */}
      <Route element={<PrivateRoute />}>
        <Route element={<AdminLayout />}>
          <Route path="/" element={<DashboardPage />} />
          <Route path="/users" element={<UsersPage />} />
          <Route path="/roles" element={<RolesPage />} />
          <Route path="/transactions" element={<TransactionsPage />} />
          
          {/* Monetization & Billing */}
          <Route path="/subscriptions" element={<SubscriptionsPage />} />
          <Route path="/plans" element={<PlansPage />} />
          <Route path="/payments" element={<PaymentsPage />} />
          <Route path="/promo-codes" element={<PromoCodesPage />} />

          {/* Engagement & Support */}
          <Route path="/notifications" element={<NotificationsPage />} />
          <Route path="/support" element={<SupportPage />} />

          {/* System & AI */}
          <Route path="/categories" element={<CategoriesPage />} />
          <Route path="/currencies" element={<CurrenciesPage />} />
          <Route path="/ai-logs" element={<AiLogsPage />} />
          <Route path="/audit-logs" element={<AuditLogsPage />} />
          <Route path="/webhooks" element={<WebhooksPage />} />
          <Route path="/health" element={<SystemHealthPage />} />
          <Route path="/settings" element={<SettingsPage />} />
        </Route>
      </Route>

      {/* Catch-all Redirect */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
};
