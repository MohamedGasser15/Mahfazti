using System;

namespace Mahfazti.Core.DTOs.Subscription
{
    public class PromoCodeDto
    {
        public string Id { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public int DiscountPercentage { get; set; }
        public int MaxUses { get; set; }
        public int UsedCount { get; set; }
        public DateTime? ExpiresAt { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreatePromoCodeDto
    {
        public string Code { get; set; } = string.Empty;
        public int DiscountPercentage { get; set; }
        public int MaxUses { get; set; } = 100;
        public DateTime? ExpiresAt { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
