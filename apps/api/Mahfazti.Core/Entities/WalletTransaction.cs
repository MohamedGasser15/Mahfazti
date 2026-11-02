using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Mahfazti.Core.Entities
{
    public class WalletTransaction
    {
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        public int? AccountId { get; set; }

        [ForeignKey(nameof(AccountId))]
        public virtual Account? Account { get; set; }

        /// <summary>
        /// Destination account when the transaction type is "Transfer".
        /// </summary>
        public int? ToAccountId { get; set; }

        [ForeignKey(nameof(ToAccountId))]
        public virtual Account? ToAccount { get; set; }

        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [MaxLength(1000)]
        public string? Description { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal Amount { get; set; }

        [MaxLength(10)]
        public string Currency { get; set; } = "EGP";

        [Column(TypeName = "decimal(18,4)")]
        public decimal ExchangeRate { get; set; } = 1.0m;

        [Required]
        [MaxLength(30)]
        public string Type { get; set; } = "Withdrawal"; // Deposit, Withdrawal, Transfer (or Income, Expense, Transfer)

        public int? CategoryId { get; set; }

        [ForeignKey(nameof(CategoryId))]
        public virtual Category? Category { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal TransferFee { get; set; } = 0.0m;

        public DateTime TransactionDate { get; set; } = DateTime.UtcNow;

        [MaxLength(500)]
        public string? ReceiptImageUrl { get; set; }

        public int? RecurringBillId { get; set; }

        [ForeignKey(nameof(RecurringBillId))]
        public virtual UserRecurringBill? RecurringBill { get; set; }

        public bool IsRecurring { get; set; } = false;

        [MaxLength(50)]
        public string? RecurringInterval { get; set; }

        public DateTime? RecurringEndDate { get; set; }

        [MaxLength(200)]
        public string? Tags { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        public bool IsDeleted { get; set; } = false;
    }
}
