namespace Mahfazti.Core.DTOs.Wallet
{
    public class WalletHomeDataDto
    {
        public WalletBalanceDto Balance { get; set; } = new();
        public List<WalletTransactionDto> RecentTransactions { get; set; } = new();
        public int TotalTransactionCount { get; set; } 
    }
}