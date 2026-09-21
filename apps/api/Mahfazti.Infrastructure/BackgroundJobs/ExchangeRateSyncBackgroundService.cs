using System;
using System.Threading;
using System.Threading.Tasks;
using Mahfazti.Core.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Mahfazti.Infrastructure.BackgroundJobs
{
    public class ExchangeRateSyncBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<ExchangeRateSyncBackgroundService> _logger;
        private readonly TimeSpan _syncInterval = TimeSpan.FromHours(24);

        public ExchangeRateSyncBackgroundService(
            IServiceProvider serviceProvider,
            ILogger<ExchangeRateSyncBackgroundService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("ExchangeRateSyncBackgroundService is starting.");

            // Initial brief delay to allow web app startup & migrations to finish
            await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    _logger.LogInformation("Starting scheduled daily exchange rate sync at: {Time}", DateTimeOffset.Now);

                    using (var scope = _serviceProvider.CreateScope())
                    {
                        var currencyService = scope.ServiceProvider.GetRequiredService<ICurrencyService>();
                        var result = await currencyService.SyncLiveRatesAsync();
                        if (result.Success)
                        {
                            _logger.LogInformation("Daily exchange rate sync completed successfully: {Message}", result.Message);
                        }
                        else
                        {
                            _logger.LogWarning("Daily exchange rate sync failed: {Error}", result.Error ?? result.Message);
                        }
                    }
                }
                catch (Exception ex) when (!stoppingToken.IsCancellationRequested)
                {
                    _logger.LogError(ex, "Unhandled error during scheduled exchange rate sync.");
                }

                try
                {
                    await Task.Delay(_syncInterval, stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    break;
                }
            }

            _logger.LogInformation("ExchangeRateSyncBackgroundService has stopped.");
        }
    }
}
