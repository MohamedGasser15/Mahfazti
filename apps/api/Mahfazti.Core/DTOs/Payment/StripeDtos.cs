using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.DTOs.Payment
{
    public class StripePaymentIntentRequestDto
    {
        [Required(ErrorMessage = "PlanId is required.")]
        public string PlanId { get; set; } = string.Empty;

        public string? PromoCode { get; set; }

        public string? Currency { get; set; } = "egp";
    }

    public class StripePaymentSheetResponseDto
    {
        public string PaymentIntentClientSecret { get; set; } = string.Empty;
        public string PaymentIntentId { get; set; } = string.Empty;
        public string EphemeralKeySecret { get; set; } = string.Empty;
        public string CustomerId { get; set; } = string.Empty;
        public string PublishableKey { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "egp";
        public string PlanId { get; set; } = string.Empty;
        public string PlanName { get; set; } = string.Empty;
        public decimal OriginalPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public string? AppliedPromoCode { get; set; }
    }

    public class StripeConfirmPaymentDto
    {
        [Required(ErrorMessage = "PaymentIntentId is required.")]
        public string PaymentIntentId { get; set; } = string.Empty;
    }

    public class StripeConfigDto
    {
        public string PublishableKey { get; set; } = string.Empty;
    }
}
