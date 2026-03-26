using Microsoft.Extensions.DependencyInjection;
using MyWallet.Application.ServiceInterfaces;
using MyWallet.Application.Services;

namespace MyWallet.Application.Configurations
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
            services.AddScoped<IAuthService, AuthService>();
            services.AddScoped<IWalletService, WalletService>();
            services.AddScoped<IBudgetService, BudgetService>();
            services.AddScoped<ICategoryService, CategoryService>();
            services.AddScoped<IVoiceExpenseService, VoiceExpenseService>();
            services.AddScoped<IProfileService, ProfileService>();
            return services;
        }
    }
}
