using System;
using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.DTOs.Wallet
{
    public class AddTransactionDto
    {
        public string? Title { get; set; }

        public string? Description { get; set; }

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }

        [Required]
        public string Type { get; set; } = "Withdrawal"; // Deposit, Withdrawal, Transfer

        public int? CategoryId { get; set; }

        public int? AccountId { get; set; }

        public int? ToAccountId { get; set; }

        public decimal TransferFee { get; set; } = 0.0m;

        public string Currency { get; set; } = "EGP";

        public decimal ExchangeRate { get; set; } = 1.0m;

        public DateTime? TransactionDate { get; set; }

        public string? ReceiptImageUrl { get; set; }

        public int? RecurringBillId { get; set; }

        public bool IsRecurring { get; set; } = false;

        public string? RecurringInterval { get; set; }

        public DateTime? RecurringEndDate { get; set; }

        public string? Tags { get; set; }
    }

    public class UpdateTransactionDto : AddTransactionDto
    {
        public int Id { get; set; }
    }

    public class TransferRequestDto
    {
        [Required]
        public int FromAccountId { get; set; }

        [Required]
        public int ToAccountId { get; set; }

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }

        public decimal TransferFee { get; set; } = 0.0m;

        public string? Title { get; set; } = "تحويل بين الحسابات";

        public string? Note { get; set; }

        public DateTime? TransactionDate { get; set; }
    }
}
