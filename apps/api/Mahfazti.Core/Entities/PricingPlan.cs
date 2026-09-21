using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Mahfazti.Core.Entities
{
    public class PricingPlan
    {
        [Key]
        public string Id { get; set; } = string.Empty; // e.g. "plan-free", "plan-pro-monthly", "plan-pro-yearly"

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string NameAr { get; set; } = string.Empty;

        [Column(TypeName = "decimal(18,2)")]
        public decimal PriceEgp { get; set; }

        [Required]
        [MaxLength(50)]
        public string BillingCycle { get; set; } = "Monthly"; // Monthly, Yearly, Lifetime

        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;

        [MaxLength(500)]
        public string DescriptionAr { get; set; } = string.Empty;

        public string FeaturesJson { get; set; } = "[]"; // JSON serialized list of string features (EN)

        public string FeaturesArJson { get; set; } = "[]"; // JSON serialized list of string features (AR)

        public bool IsPopular { get; set; } = false;

        public bool IsActive { get; set; } = true;

        public int DisplayOrder { get; set; } = 0;

        public int MaxWallets { get; set; } = 1;

        public int MaxAiRequestsPerMonth { get; set; } = 15;

        public bool CanExportReports { get; set; } = false;

        public bool CanUseMultiCurrency { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }
    }
}
