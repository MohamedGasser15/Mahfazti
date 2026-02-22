// Application/DTOs/Wallet/AddTransactionDto.cs
using System;
using System.ComponentModel.DataAnnotations;

namespace MyWallet.Application.DTOs.Wallet
{
    public class AddTransactionDto
    {
        [Required]
        public string Title { get; set; } = string.Empty;

        public string? Description { get; set; }

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }

        [Required]
        public string Type { get; set; } = string.Empty;

        [Required]
        public int? CategoryId { get; set; }

        [Required]
        public DateTime TransactionDate { get; set; }

        public bool IsRecurring { get; set; }
        public string? RecurringInterval { get; set; }
        public DateTime? RecurringEndDate { get; set; }
    }
}