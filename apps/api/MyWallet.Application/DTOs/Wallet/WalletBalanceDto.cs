namespace MyWallet.Application.DTOs.Wallet
{
    public class WalletBalanceDto
    {
        public decimal TotalBalance { get; set; }
        public decimal TotalDeposits { get; set; }
        public decimal TotalWithdrawals { get; set; }
    }
}