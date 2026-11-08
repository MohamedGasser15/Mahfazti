using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.DTOs.Subscription
{
    public class VerifyIapSubscriptionDto
    {
        [Required]
        public string ProductId { get; set; } = string.Empty;

        public string? TransactionId { get; set; }

        public string? PurchaseToken { get; set; }

        public string Platform { get; set; } = "ios";
    }
}
