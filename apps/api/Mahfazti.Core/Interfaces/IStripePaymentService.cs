using System.Threading.Tasks;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Payment;

namespace Mahfazti.Core.Interfaces
{
    public interface IStripePaymentService
    {
        Task<ApiResponse<StripeConfigDto>> GetConfigAsync();

        Task<ApiResponse<StripePaymentSheetResponseDto>> CreatePaymentSheetIntentAsync(int userId, StripePaymentIntentRequestDto dto);

        Task<ApiResponse<bool>> ConfirmPaymentAsync(int userId, StripeConfirmPaymentDto dto);

        Task<ApiResponse<bool>> HandleWebhookAsync(string json, string? stripeSignature);
    }
}
