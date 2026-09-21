using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Mahfazti.Core.Interfaces;
using Microsoft.Extensions.Logging;

namespace Mahfazti.Core.Services
{
    public class ExchangeRateService : IExchangeRateService
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger<ExchangeRateService> _logger;
        private const string ExchangeApiUrl = "https://open.er-api.com/v6/latest/USD";

        public ExchangeRateService(HttpClient httpClient, ILogger<ExchangeRateService> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
        }

        public async Task<Dictionary<string, decimal>?> FetchLiveRatesAgainstEgpAsync()
        {
            try
            {
                var response = await _httpClient.GetAsync(ExchangeApiUrl);
                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning("ExchangeRate API responded with status code: {StatusCode}", response.StatusCode);
                    return null;
                }

                var jsonString = await response.Content.ReadAsStringAsync();
                var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
                var apiResponse = JsonSerializer.Deserialize<ExchangeRateApiResponse>(jsonString, options);

                if (apiResponse == null || apiResponse.Rates == null || !apiResponse.Rates.ContainsKey("EGP"))
                {
                    _logger.LogWarning("ExchangeRate API response did not contain valid rates or EGP base.");
                    return null;
                }

                var usdToEgp = apiResponse.Rates["EGP"];
                var ratesAgainstEgp = new Dictionary<string, decimal>(StringComparer.OrdinalIgnoreCase)
                {
                    ["EGP"] = 1.0m,
                    ["USD"] = Math.Round(usdToEgp, 4)
                };

                foreach (var (currencyCode, rateAgainstUsd) in apiResponse.Rates)
                {
                    if (string.Equals(currencyCode, "EGP", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(currencyCode, "USD", StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }

                    if (rateAgainstUsd > 0)
                    {
                        // 1 Currency = (usdToEgp / rateAgainstUsd) EGP
                        var valuationInEgp = Math.Round(usdToEgp / rateAgainstUsd, 4);
                        ratesAgainstEgp[currencyCode] = valuationInEgp;
                    }
                }

                return ratesAgainstEgp;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while fetching live exchange rates from external API.");
                return null;
            }
        }

        private class ExchangeRateApiResponse
        {
            [JsonPropertyName("result")]
            public string? Result { get; set; }

            [JsonPropertyName("base_code")]
            public string? BaseCode { get; set; }

            [JsonPropertyName("rates")]
            public Dictionary<string, decimal>? Rates { get; set; }
        }
    }
}
