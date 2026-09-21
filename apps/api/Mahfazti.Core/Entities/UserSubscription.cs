using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Mahfazti.Core.Entities
{
    public class UserSubscription
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        public int? UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public virtual ApplicationUser? User { get; set; }

        [Required]
        public string PlanId { get; set; } = string.Empty;

        [ForeignKey(nameof(PlanId))]
        public virtual PricingPlan? Plan { get; set; }

        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = "Active"; // Active, Expired, Canceled, Trial

        [Column(TypeName = "decimal(18,2)")]
        public decimal AmountPaidEgp { get; set; }

        [MaxLength(50)]
        public string Gateway { get; set; } = "Paymob"; // Paymob, Fawry, Stripe, ApplePay, GooglePay

        public DateTime StartDate { get; set; } = DateTime.UtcNow;

        public DateTime EndDate { get; set; } = DateTime.UtcNow.AddMonths(1);

        public bool AutoRenew { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
