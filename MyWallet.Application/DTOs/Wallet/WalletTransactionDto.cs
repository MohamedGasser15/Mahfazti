using System;

namespace MyWallet.Application.DTOs.Wallet
{
    public class WalletTransactionDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Amount { get; set; }
        public string Type { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public DateTime TransactionDate { get; set; }
        public bool IsRecurring { get; set; }
        public string? RecurringInterval { get; set; }
        public DateTime? RecurringEndDate { get; set; }

        public bool IsDeposit => Type == "Deposit";
        public bool IsWithdrawal => Type == "Withdrawal";
        public string FormattedAmount => IsDeposit ? $"+{Amount:F2}" : $"-{Amount:F2}";
    }
}