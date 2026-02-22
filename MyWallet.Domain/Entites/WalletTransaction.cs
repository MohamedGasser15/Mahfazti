// Infrastructure/Entities/WalletTransaction.cs
using MyWallet.Domain.Entites;
using System;

namespace MyWallet.Infrastructure.Entities
{
    public class WalletTransaction
    {
        public int Id { get; set; }
        public string UserId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Amount { get; set; }
        public string Type { get; set; } = string.Empty;
        public int? CategoryId { get; set; }
        public Category? Category { get; set; }

        public DateTime TransactionDate { get; set; }
        public bool IsRecurring { get; set; }
        public string? RecurringInterval { get; set; }
        public DateTime? RecurringEndDate { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public bool IsDeleted { get; set; } = false;
    }
}