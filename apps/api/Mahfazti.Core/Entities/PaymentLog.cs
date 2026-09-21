using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Mahfazti.Core.Entities
{
    public class PaymentLog
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [Required]
        [MaxLength(100)]
        public string InvoiceNumber { get; set; } = string.Empty;

        public int? UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public virtual ApplicationUser? User { get; set; }

        [Required]
        [MaxLength(200)]
        public string UserEmail { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string PlanName { get; set; } = string.Empty;

        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        [MaxLength(10)]
        public string Currency { get; set; } = "EGP";

        [MaxLength(50)]
        public string Gateway { get; set; } = "Paymob"; // Paymob, Fawry, Stripe, ApplePay, GooglePay

        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = "Success"; // Success, Failed, Refunded, Pending

        [MaxLength(200)]
        public string TransactionRef { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
