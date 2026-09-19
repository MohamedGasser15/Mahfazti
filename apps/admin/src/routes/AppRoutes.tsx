import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AdminLayout } from '../core/layouts/AdminLayout';
import { PrivateRoute } from './PrivateRoute';
import { LoginPage } from '../features/auth/pages/LoginPage';
import { ResetPasswordPage } from '../features/auth/pages/ResetPasswordPage';
import { PrivacyPolicyPage } from '../features/legal/pages/PrivacyPolicyPage';
import { TermsOfServicePage } from '../features/legal/pages/TermsOfServicePage';
import { PublicSupportPage } from '../features/legal/pages/PublicSupportPage';
import { NotFoundPage } from '../features/errors/pages/NotFoundPage';
import { UnauthorizedPage } from '../features/errors/pages/UnauthorizedPage';
import { AccessDeniedPage } from '../features/errors/pages/AccessDeniedPage';
import { ServerErrorPage } from '../features/errors/pages/ServerErrorPage';
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
      {/* Public Routes */}
      <Route path="/login" element={<LoginPage />} />
      <Route path="/reset-password" element={<ResetPasswordPage />} />
      <Route path="/privacy" element={<PrivacyPolicyPage />} />
      <Route path="/privacy-policy" element={<Navigate to="/privacy" replace />} />
      <Route path="/terms" element={<TermsOfServicePage />} />
      <Route path="/terms-of-service" element={<Navigate to="/terms" replace />} />
      <Route path="/help" element={<PublicSupportPage />} />
      <Route path="/contact" element={<PublicSupportPage />} />

      {/* Error Routes */}
      <Route path="/404" element={<NotFoundPage />} />
      <Route path="/401" element={<UnauthorizedPage />} />
      <Route path="/403" element={<AccessDeniedPage />} />
      <Route path="/500" element={<ServerErrorPage />} />

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

      {/* Catch-all Route -> 404 Not Found Page */}
      <Route path="*" element={<NotFoundPage />} />
    </Routes>
  );
};
