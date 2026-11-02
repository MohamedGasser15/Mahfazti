using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Mahfazti.Core.Entities
{
    /// <summary>
    /// User's personal subscriptions and recurring bills (e.g. Netflix, Gym, Internet, Club).
    /// </summary>
    public class UserRecurringBill
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        public int? AccountId { get; set; }

        [ForeignKey(nameof(AccountId))]
        public virtual Account? Account { get; set; }

        public int? CategoryId { get; set; }

        [ForeignKey(nameof(CategoryId))]
        public virtual Category? Category { get; set; }

        [Required]
        [MaxLength(150)]
        public string Title { get; set; } = string.Empty;

        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        [MaxLength(10)]
        public string Currency { get; set; } = "EGP";

        [Required]
        [MaxLength(30)]
        public string BillingCycle { get; set; } = "monthly"; // monthly, yearly, weekly

        public int RenewalDay { get; set; } = 1; // 1-31

        public DateTime? NextDueDate { get; set; }

        public int IconCode { get; set; } = 0;

        public bool IsActive { get; set; } = true;

        public bool AutoRecordTransaction { get; set; } = true;

        public bool IsDeleted { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }
    }
}
