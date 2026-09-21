using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Currency;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Microsoft.Extensions.Logging;

namespace Mahfazti.Core.Services
{
    public class CurrencyService : ICurrencyService
    {
        private readonly IRepository<Currency> _currencyRepository;
        private readonly IExchangeRateService _exchangeRateService;
        private readonly ILogger<CurrencyService> _logger;

        public CurrencyService(
            IRepository<Currency> currencyRepository,
            IExchangeRateService exchangeRateService,
            ILogger<CurrencyService> logger)
        {
            _currencyRepository = currencyRepository;
            _exchangeRateService = exchangeRateService;
            _logger = logger;
        }

        public async Task<ApiResponse<List<CurrencyDto>>> GetAllCurrenciesAsync(bool includeInactive = true)
        {
            try
            {
                var currencies = await _currencyRepository.GetAllAsync(
                    filter: includeInactive ? null : (c => c.IsActive),
                    orderBy: q => q.OrderByDescending(c => c.IsDefault)
                                   .ThenByDescending(c => c.IsFeatured)
                                   .ThenByDescending(c => c.IsActive)
                                   .ThenBy(c => c.Code)
                );

                var dtos = currencies.Select(MapToDto).ToList();
                return ApiResponse<List<CurrencyDto>>.SuccessResponse(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to retrieve currencies.");
                return ApiResponse<List<CurrencyDto>>.FailResponse("Failed to load currencies.");
            }
        }

        public async Task<ApiResponse<CurrencyDto>> GetCurrencyByCodeAsync(string code)
        {
            try
            {
                var normalizedCode = code.Trim().ToUpperInvariant();
                var currency = await _currencyRepository.GetAsync(c => c.Code == normalizedCode);
                if (currency == null)
                {
                    return ApiResponse<CurrencyDto>.FailResponse($"Currency '{code}' not found.");
                }

                return ApiResponse<CurrencyDto>.SuccessResponse(MapToDto(currency));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving currency {Code}", code);
                return ApiResponse<CurrencyDto>.FailResponse("Error retrieving currency.");
            }
        }

        public async Task<ApiResponse<CurrencyDto>> AddCurrencyAsync(CreateCurrencyDto dto)
        {
            try
            {
                var normalizedCode = dto.Code.Trim().ToUpperInvariant();
                var exists = await _currencyRepository.AnyAsync(c => c.Code == normalizedCode);
                if (exists)
                {
                    return ApiResponse<CurrencyDto>.FailResponse($"Currency with code '{normalizedCode}' already exists.");
                }

                var currency = new Currency
                {
                    Code = normalizedCode,
                    NameEn = dto.NameEn.Trim(),
                    NameAr = dto.NameAr.Trim(),
                    Symbol = dto.Symbol.Trim(),
                    ExchangeRateToEgp = dto.ExchangeRateToEgp,
                    IsDefault = false,
                    IsActive = dto.IsActive,
                    LastUpdated = DateTime.UtcNow
                };

                await _currencyRepository.CreateAsync(currency);
                _logger.LogInformation("Added new currency: {Code}", normalizedCode);

                return ApiResponse<CurrencyDto>.SuccessResponse(MapToDto(currency), "Currency added successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding currency {Code}", dto.Code);
                return ApiResponse<CurrencyDto>.FailResponse("Failed to add currency.");
            }
        }

        public async Task<ApiResponse<CurrencyDto>> UpdateRateAsync(string code, decimal rate)
        {
            try
            {
                if (rate <= 0)
                {
                    return ApiResponse<CurrencyDto>.FailResponse("Exchange rate must be greater than zero.");
                }

                var normalizedCode = code.Trim().ToUpperInvariant();
                var currency = await _currencyRepository.GetAsync(c => c.Code == normalizedCode, isTracking: true);
                if (currency == null)
                {
                    return ApiResponse<CurrencyDto>.FailResponse($"Currency '{code}' not found.");
                }

                currency.ExchangeRateToEgp = rate;
                currency.LastUpdated = DateTime.UtcNow;

                await _currencyRepository.UpdateAsync(currency);
                _logger.LogInformation("Updated currency {Code} rate to {Rate}", normalizedCode, rate);

                return ApiResponse<CurrencyDto>.SuccessResponse(MapToDto(currency), "Exchange rate updated successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating rate for currency {Code}", code);
                return ApiResponse<CurrencyDto>.FailResponse("Failed to update exchange rate.");
            }
        }

        public async Task<ApiResponse<CurrencyDto>> ToggleActiveAsync(string code)
        {
            try
            {
                var normalizedCode = code.Trim().ToUpperInvariant();
                var currency = await _currencyRepository.GetAsync(c => c.Code == normalizedCode, isTracking: true);
                if (currency == null)
                {
                    return ApiResponse<CurrencyDto>.FailResponse($"Currency '{code}' not found.");
                }

                if (currency.IsDefault)
                {
                    return ApiResponse<CurrencyDto>.FailResponse("Default base currency (EGP) cannot be disabled.");
                }

                currency.IsActive = !currency.IsActive;
                currency.LastUpdated = DateTime.UtcNow;

                await _currencyRepository.UpdateAsync(currency);
                _logger.LogInformation("Toggled active status for currency {Code} to {IsActive}", normalizedCode, currency.IsActive);

                return ApiResponse<CurrencyDto>.SuccessResponse(
                    MapToDto(currency),
                    currency.IsActive ? "Currency enabled successfully." : "Currency disabled successfully."
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error toggling active status for currency {Code}", code);
                return ApiResponse<CurrencyDto>.FailResponse("Failed to change currency status.");
            }
        }

        public async Task<ApiResponse<CurrencyDto>> SetBaseCurrencyAsync(string code)
        {
            try
            {
                var normalizedCode = code.Trim().ToUpperInvariant();
                var allCurrencies = await _currencyRepository.GetAllAsync(isTracking: true);
                var targetCurrency = allCurrencies.FirstOrDefault(c => c.Code == normalizedCode);

                if (targetCurrency == null)
                {
                    return ApiResponse<CurrencyDto>.FailResponse($"Currency '{code}' not found.");
                }

                foreach (var c in allCurrencies)
                {
                    c.IsDefault = (c.Code == normalizedCode);
                    if (c.Code == normalizedCode)
                    {
                        c.IsActive = true; // Base currency must always be active
                    }
                }

                await _currencyRepository.SaveAsync();

                _logger.LogInformation("Base currency updated to {Code}", normalizedCode);
                return ApiResponse<CurrencyDto>.SuccessResponse(MapToDto(targetCurrency), $"Base currency set to {normalizedCode}.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error setting base currency to {Code}", code);
                return ApiResponse<CurrencyDto>.FailResponse("Failed to set base currency.");
            }
        }

        public async Task<ApiResponse<CurrencyDto>> ToggleFeaturedAsync(string code)
        {
            try
            {
                var normalizedCode = code.Trim().ToUpperInvariant();
                var currency = await _currencyRepository.GetAsync(c => c.Code == normalizedCode, isTracking: true);
                if (currency == null)
                {
                    return ApiResponse<CurrencyDto>.FailResponse($"Currency '{code}' not found.");
                }

                currency.IsFeatured = !currency.IsFeatured;
                if (currency.IsFeatured)
                {
                    currency.IsActive = true; // Featured currencies should be active
                }
                currency.LastUpdated = DateTime.UtcNow;

                await _currencyRepository.UpdateAsync(currency);
                _logger.LogInformation("Toggled featured status for currency {Code} to {IsFeatured}", normalizedCode, currency.IsFeatured);

                return ApiResponse<CurrencyDto>.SuccessResponse(
                    MapToDto(currency),
                    currency.IsFeatured ? "Currency marked as featured." : "Currency removed from featured."
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error toggling featured status for currency {Code}", code);
                return ApiResponse<CurrencyDto>.FailResponse("Failed to update featured status.");
            }
        }

        public async Task<ApiResponse<List<CurrencyDto>>> SyncLiveRatesAsync()
        {
            try
            {
                var liveRates = await _exchangeRateService.FetchLiveRatesAgainstEgpAsync();
                if (liveRates == null || liveRates.Count == 0)
                {
                    return ApiResponse<List<CurrencyDto>>.FailResponse("Failed to fetch live rates from external provider.");
                }

                var existingCurrencies = await _currencyRepository.GetAllAsync(isTracking: true);
                var now = DateTime.UtcNow;
                int updatedCount = 0;

                foreach (var currency in existingCurrencies)
                {
                    if (currency.IsDefault || currency.Code == "EGP")
                    {
                        currency.ExchangeRateToEgp = 1.0m;
                        currency.LastUpdated = now;
                        continue;
                    }

                    if (liveRates.TryGetValue(currency.Code, out var liveRate) && liveRate > 0)
                    {
                        currency.ExchangeRateToEgp = liveRate;
                        currency.LastUpdated = now;
                        updatedCount++;
                    }
                }

                await _currencyRepository.SaveAsync();

                _logger.LogInformation("Successfully synced live exchange rates for {Count} currencies.", updatedCount);

                var refreshedCurrencies = await _currencyRepository.GetAllAsync(
                    orderBy: q => q.OrderByDescending(c => c.IsDefault)
                                   .ThenByDescending(c => c.IsFeatured)
                                   .ThenByDescending(c => c.IsActive)
                                   .ThenBy(c => c.Code)
                );

                return ApiResponse<List<CurrencyDto>>.SuccessResponse(
                    refreshedCurrencies.Select(MapToDto).ToList(),
                    $"Successfully synced rates ({updatedCount} currencies updated)."
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred during live rates synchronization.");
                return ApiResponse<List<CurrencyDto>>.FailResponse("Error syncing live exchange rates.");
            }
        }

        private static CurrencyDto MapToDto(Currency entity)
        {
            return new CurrencyDto
            {
                Code = entity.Code,
                NameEn = entity.NameEn,
                NameAr = entity.NameAr,
                Symbol = entity.Symbol,
                ExchangeRateToEgp = entity.ExchangeRateToEgp,
                IsDefault = entity.IsDefault,
                IsActive = entity.IsActive,
                IsFeatured = entity.IsFeatured,
                LastUpdated = entity.LastUpdated
            };
        }
    }
}
