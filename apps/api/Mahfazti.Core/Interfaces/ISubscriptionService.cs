using System.Collections.Generic;
using System.Threading.Tasks;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Subscription;

namespace Mahfazti.Core.Interfaces
{
    public interface ISubscriptionService
    {
        // Plans
        Task<ApiResponse<List<PricingPlanDto>>> GetAllPlansAsync(bool includeInactive = true);
        Task<ApiResponse<PricingPlanDto>> GetPlanByIdAsync(string id);
        Task<ApiResponse<PricingPlanDto>> CreatePlanAsync(CreatePricingPlanDto dto);
        Task<ApiResponse<PricingPlanDto>> UpdatePlanAsync(string id, UpdatePricingPlanDto dto);
        Task<ApiResponse<bool>> ReorderPlansAsync(List<string> orderedPlanIds);
        Task<ApiResponse<bool>> DeletePlanAsync(string id);

        // Subscriptions & Stats
        Task<ApiResponse<List<UserSubscriptionDto>>> GetSubscriptionsAsync(string? status = null, string? search = null);
        Task<ApiResponse<SubscriptionStatsDto>> GetSubscriptionStatsAsync();

        // Payment Logs
        Task<ApiResponse<List<PaymentLogDto>>> GetPaymentLogsAsync(string? search = null, string? status = null);

        // Promo Codes
        Task<ApiResponse<List<PromoCodeDto>>> GetPromoCodesAsync();
        Task<ApiResponse<PromoCodeDto>> CreatePromoCodeAsync(CreatePromoCodeDto dto);
        Task<ApiResponse<PromoCodeDto>> TogglePromoCodeStatusAsync(string id);
        Task<ApiResponse<bool>> DeletePromoCodeAsync(string id);
    }
}
