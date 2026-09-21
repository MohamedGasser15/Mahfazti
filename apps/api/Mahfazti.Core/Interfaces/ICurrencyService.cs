using System.Collections.Generic;
using System.Threading.Tasks;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Currency;

namespace Mahfazti.Core.Interfaces
{
    public interface ICurrencyService
    {
        Task<ApiResponse<List<CurrencyDto>>> GetAllCurrenciesAsync(bool includeInactive = true);
        Task<ApiResponse<CurrencyDto>> GetCurrencyByCodeAsync(string code);
        Task<ApiResponse<CurrencyDto>> AddCurrencyAsync(CreateCurrencyDto dto);
        Task<ApiResponse<CurrencyDto>> UpdateRateAsync(string code, decimal rate);
        Task<ApiResponse<CurrencyDto>> ToggleActiveAsync(string code);
        Task<ApiResponse<CurrencyDto>> ToggleFeaturedAsync(string code);
        Task<ApiResponse<CurrencyDto>> SetBaseCurrencyAsync(string code);
        Task<ApiResponse<List<CurrencyDto>>> SyncLiveRatesAsync();
    }
}
