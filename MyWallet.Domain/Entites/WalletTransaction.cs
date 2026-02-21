// Infrastructure/Entities/WalletTransaction.cs
using System;

namespace MyWallet.Infrastructure.Entities
{
    public class WalletTransaction
    {
        public int Id { get; set; }

        // UserId as string (no navigation property)
        public string UserId { get; set; } = string.Empty;

        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Amount { get; set; }

        // Transaction type: "Deposit" or "Withdrawal"
        public string Type { get; set; } = string.Empty;

        public string Category { get; set; } = string.Empty;
        public DateTime TransactionDate { get; set; }

        // Recurring transaction fields
        public bool IsRecurring { get; set; }
        public string? RecurringInterval { get; set; } // daily, weekly, monthly, yearly
        public DateTime? RecurringEndDate { get; set; }

        // Audit fields
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public bool IsDeleted { get; set; } = false; // Soft delete
    }
}