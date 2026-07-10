using MyWallet.Core.DTOs.Wallet;

namespace MyWallet.Core.Interfaces
{
    public interface IWalletService
    {
        // Home data
        Task<WalletHomeDataDto> GetHomeDataAsync(string userId);

        // Balance
        Task<WalletBalanceDto> GetBalanceAsync(string userId);

        // Transactions
        Task<WalletTransactionDto?> GetTransactionByIdAsync(int id, string userId);
        Task<TransactionListResponseDto> GetTransactionsAsync(string userId, TransactionFilterDto filter);
        Task<WalletTransactionDto> AddTransactionAsync(string userId, AddTransactionDto dto);
        Task<bool> DeleteTransactionAsync(int id, string userId); // soft delete
        Task<WalletTransactionDto> UpdateTransactionAsync(
            int id, string userId, AddTransactionDto dto);
        // Summary for analytics
        Task<object> GetSummaryAsync(string userId, DateTime? fromDate, DateTime? toDate);
    }
}
