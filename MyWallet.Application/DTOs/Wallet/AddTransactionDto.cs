// Application/DTOs/Wallet/AddTransactionDto.cs
using System;
using System.ComponentModel.DataAnnotations;

namespace MyWallet.Application.DTOs.Wallet
{
    public class AddTransactionDto
    {
        public string? Description { get; set; }

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }

        [Required]
        public string Type { get; set; } = string.Empty;

        [Required]
        public int? CategoryId { get; set; }
    }
}