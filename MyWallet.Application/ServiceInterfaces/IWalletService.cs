using MyWallet.Application.DTOs.Wallet;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.ServiceInterfaces
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

        // Summary for analytics
        Task<object> GetSummaryAsync(string userId, DateTime? fromDate, DateTime? toDate);
    }
}
