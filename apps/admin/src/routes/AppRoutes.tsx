import React, { Suspense, lazy } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AdminLayout } from '../core/layouts/AdminLayout';
import { PrivateRoute } from './PrivateRoute';
import { ThreeDotLoader } from '../core/components/ui/ThreeDotLoader';
import { ServerErrorPage } from '../features/errors/pages/ServerErrorPage';

// Luxury Minimalist Loading Fallback
const PageLoader: React.FC = () => (
  <div className="flex h-full min-h-[60vh] w-full items-center justify-center p-8 text-zinc-400 dark:text-zinc-600">
    <ThreeDotLoader size="lg" />
  </div>
);

// Public Pages (Lazy Loaded)
const LoginPage = lazy(() => import('../features/auth/pages/LoginPage').then((m) => ({ default: m.LoginPage })));
const ResetPasswordPage = lazy(() => import('../features/auth/pages/ResetPasswordPage').then((m) => ({ default: m.ResetPasswordPage })));
const PrivacyPolicyPage = lazy(() => import('../features/legal/pages/PrivacyPolicyPage').then((m) => ({ default: m.PrivacyPolicyPage })));
const TermsOfServicePage = lazy(() => import('../features/legal/pages/TermsOfServicePage').then((m) => ({ default: m.TermsOfServicePage })));
const PublicSupportPage = lazy(() => import('../features/legal/pages/PublicSupportPage').then((m) => ({ default: m.PublicSupportPage })));

// Error Pages (Lazy Loaded)
const NotFoundPage = lazy(() => import('../features/errors/pages/NotFoundPage').then((m) => ({ default: m.NotFoundPage })));
const UnauthorizedPage = lazy(() => import('../features/errors/pages/UnauthorizedPage').then((m) => ({ default: m.UnauthorizedPage })));
const AccessDeniedPage = lazy(() => import('../features/errors/pages/AccessDeniedPage').then((m) => ({ default: m.AccessDeniedPage })));

// Protected Admin Pages (Lazy Loaded)
const DashboardPage = lazy(() => import('../features/dashboard/pages/DashboardPage').then((m) => ({ default: m.DashboardPage })));
const UsersPage = lazy(() => import('../features/users/pages/UsersPage').then((m) => ({ default: m.UsersPage })));
const RolesPage = lazy(() => import('../features/users/pages/RolesPage').then((m) => ({ default: m.RolesPage })));
const CategoriesPage = lazy(() => import('../features/categories/pages/CategoriesPage').then((m) => ({ default: m.CategoriesPage })));
const TransactionsPage = lazy(() => import('../features/transactions/pages/TransactionsPage').then((m) => ({ default: m.TransactionsPage })));
const AiLogsPage = lazy(() => import('../features/ai-logs/pages/AiLogsPage').then((m) => ({ default: m.AiLogsPage })));
const SettingsPage = lazy(() => import('../features/settings/pages/SettingsPage').then((m) => ({ default: m.SettingsPage })));
const SubscriptionsPage = lazy(() => import('../features/subscriptions/pages/SubscriptionsPage').then((m) => ({ default: m.SubscriptionsPage })));
const PlansPage = lazy(() => import('../features/subscriptions/pages/PlansPage').then((m) => ({ default: m.PlansPage })));
const PaymentsPage = lazy(() => import('../features/subscriptions/pages/PaymentsPage').then((m) => ({ default: m.PaymentsPage })));
const PromoCodesPage = lazy(() => import('../features/subscriptions/pages/PromoCodesPage').then((m) => ({ default: m.PromoCodesPage })));
const NotificationsPage = lazy(() => import('../features/notifications/pages/NotificationsPage').then((m) => ({ default: m.NotificationsPage })));
const SupportPage = lazy(() => import('../features/support/pages/SupportPage').then((m) => ({ default: m.SupportPage })));
const CurrenciesPage = lazy(() => import('../features/currencies/pages/CurrenciesPage').then((m) => ({ default: m.CurrenciesPage })));
const AuditLogsPage = lazy(() => import('../features/audit-logs/pages/AuditLogsPage').then((m) => ({ default: m.AuditLogsPage })));
const WebhooksPage = lazy(() => import('../features/developer/pages/WebhooksPage').then((m) => ({ default: m.WebhooksPage })));
const SystemHealthPage = lazy(() => import('../features/developer/pages/SystemHealthPage').then((m) => ({ default: m.SystemHealthPage })));

export const AppRoutes: React.FC = () => {
  return (
    <Suspense fallback={<PageLoader />}>
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
    </Suspense>
  );
};
