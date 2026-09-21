using System.Collections.Generic;

namespace Mahfazti.Core.Constants
{
    public static class Permissions
    {
        public const string ClaimType = "Permission";

        // Users
        public const string UsersView = "users.view";
        public const string UsersCreate = "users.create";
        public const string UsersEdit = "users.edit";
        public const string UsersDelete = "users.delete";
        public const string UsersRoles = "users.roles";

        // Categories
        public const string CategoriesView = "categories.view";
        public const string CategoriesCreate = "categories.create";
        public const string CategoriesEdit = "categories.edit";
        public const string CategoriesDelete = "categories.delete";

        // Transactions
        public const string TransactionsView = "transactions.view";
        public const string TransactionsExport = "transactions.export";

        // Subscriptions & Plans
        public const string SubscriptionsView = "subscriptions.view";
        public const string SubscriptionsManage = "subscriptions.manage";
        public const string PlansManage = "plans.manage";

        // Audit Logs
        public const string AuditLogsView = "audit_logs.view";
        public const string AuditLogsExport = "audit_logs.export";

        // Notifications
        public const string NotificationsView = "notifications.view";
        public const string NotificationsSend = "notifications.send";

        // Roles & Permissions
        public const string RolesView = "roles.view";
        public const string RolesManage = "roles.manage";

        // System & Settings
        public const string SystemSettings = "system.settings";
        public const string SystemHealth = "system.health";
        public const string SystemAiLogs = "system.ai_logs";

        public static readonly List<string> All = new()
        {
            UsersView, UsersCreate, UsersEdit, UsersDelete, UsersRoles,
            CategoriesView, CategoriesCreate, CategoriesEdit, CategoriesDelete,
            TransactionsView, TransactionsExport,
            SubscriptionsView, SubscriptionsManage, PlansManage,
            AuditLogsView, AuditLogsExport,
            NotificationsView, NotificationsSend,
            RolesView, RolesManage,
            SystemSettings, SystemHealth, SystemAiLogs
        };

        public static readonly List<string> AdminDefault = new()
        {
            UsersView, UsersCreate, UsersEdit,
            CategoriesView, CategoriesCreate, CategoriesEdit, CategoriesDelete,
            TransactionsView, TransactionsExport,
            SubscriptionsView,
            AuditLogsView,
            NotificationsView, NotificationsSend,
            RolesView
        };
    }
}
