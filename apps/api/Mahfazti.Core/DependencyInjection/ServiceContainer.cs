using Microsoft.Extensions.DependencyInjection;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Services;

namespace Mahfazti.Core.DependencyInjection
{
    /// <summary>
    /// Handles dependency injection for Application layer services.
    /// </summary>
    public static class ServiceContainer
    {
        /// <summary>
        /// Registers all Application-level services into the DI container.
        /// </summary>
        /// <param name="services">The service collection used for dependency injection.</param>
        /// <returns>The updated service collection.</returns>
        public static IServiceCollection AddApplicationServices(this IServiceCollection services)
        {
            services.AddMemoryCache();
            services.AddScoped<IEmailSender, EmailSender>();
            services.AddScoped<IEmailTemplateService, EmailTemplateService>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IWalletService, WalletService>();
            services.AddScoped<IBudgetService, BudgetService>();
            services.AddScoped<ICategoryService, CategoryService>();
            services.AddScoped<IVoiceExpenseService, VoiceExpenseService>();
            services.AddScoped<IProfileService, ProfileService>();
            services.AddScoped<ITokenService, TokenService>();
            services.AddScoped<IExternalLoginService, ExternalLoginService>();
            services.AddScoped<IAdminUserService, AdminUserService>();
            services.AddScoped<IAuditLogService, AuditLogService>();
            services.AddScoped<IRoleService, RoleService>();
            services.AddHttpClient<IExchangeRateService, ExchangeRateService>();
            services.AddScoped<ICurrencyService, CurrencyService>();
            return services;
        }
    }
}
