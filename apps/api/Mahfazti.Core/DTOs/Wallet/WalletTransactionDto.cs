using System;

namespace Mahfazti.Core.DTOs.Wallet
{
    public class WalletTransactionDto
    {
        public int Id { get; set; }
        public string? UserId { get; set; }
        public int? AccountId { get; set; }
        public string? AccountName { get; set; }
        public int? ToAccountId { get; set; }
        public string? ToAccountName { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "EGP";
        public decimal ExchangeRate { get; set; } = 1.0m;
        public string Type { get; set; } = string.Empty;
        public int? CategoryId { get; set; }
        public string? CategoryNameAr { get; set; }
        public string? CategoryNameEn { get; set; }
        public decimal TransferFee { get; set; }
        public DateTime TransactionDate { get; set; }
        public string? ReceiptImageUrl { get; set; }
        public int? RecurringBillId { get; set; }
        public bool IsRecurring { get; set; }
        public string? RecurringInterval { get; set; }
        public DateTime? RecurringEndDate { get; set; }
        public string? Tags { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        public bool IsDeposit => Type.Equals("Deposit", StringComparison.OrdinalIgnoreCase) || Type.Equals("Income", StringComparison.OrdinalIgnoreCase);
        public bool IsWithdrawal => Type.Equals("Withdrawal", StringComparison.OrdinalIgnoreCase) || Type.Equals("Expense", StringComparison.OrdinalIgnoreCase);
        public bool IsTransfer => Type.Equals("Transfer", StringComparison.OrdinalIgnoreCase);
        public string FormattedAmount => IsDeposit ? $"+{Amount:F2}" : (IsWithdrawal ? $"-{Amount:F2}" : $"{Amount:F2}");
    }
}
