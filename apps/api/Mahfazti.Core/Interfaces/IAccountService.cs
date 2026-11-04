using System.Collections.Generic;
using System.Threading.Tasks;
using Mahfazti.Core.DTOs.Accounts;

namespace Mahfazti.Core.Interfaces
{
    public interface IAccountService
    {
        Task<List<AccountDto>> GetAccountsAsync(string userId);
        Task<AccountDto> EnsureDefaultAccountAsync(string userId, string currency = "EGP", string? preferredLanguage = null);
        Task<AccountDto?> GetAccountByIdAsync(int id, string userId);
        Task<AccountDto> CreateAccountAsync(string userId, CreateAccountDto dto);
        Task<AccountDto?> UpdateAccountAsync(int id, string userId, UpdateAccountDto dto);
        Task<bool> DeleteAccountAsync(int id, string userId);
        Task<TotalWealthSummaryDto> GetTotalWealthSummaryAsync(string userId);
    }
}
