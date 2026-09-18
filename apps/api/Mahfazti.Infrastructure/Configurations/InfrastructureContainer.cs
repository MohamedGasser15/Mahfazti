using Microsoft.Extensions.DependencyInjection;
using Mahfazti.Core.Interfaces;
using Mahfazti.Infrastructure.Persistence.Repository;

namespace Mahfazti.Infrastructure.Configurations
{
    /// <summary>
    /// Handles dependency injection for Infrastructure Repositories.
    /// </summary>
    public static class InfrastructureContainer
    {
        /// <summary>
        /// Registers all repository dependencies into the DI container.
        /// </summary>
        /// <param name="services">The service collection used for dependency injection.</param>
        /// <returns>The updated service collection.</returns>
        public static IServiceCollection AddInfrastructureRepositories(this IServiceCollection services)
        {
            services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
            services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
            return services;
        }
    }
}
