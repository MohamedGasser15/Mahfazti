using System.Collections.Generic;

namespace MyWallet.Application.DTOs.Wallet
{
    public class WalletHomeDataDto
    {
        public WalletBalanceDto Balance { get; set; } = new();
        public List<WalletTransactionDto> RecentTransactions { get; set; } = new();
        public int TotalTransactionCount { get; set; } 
    }
}