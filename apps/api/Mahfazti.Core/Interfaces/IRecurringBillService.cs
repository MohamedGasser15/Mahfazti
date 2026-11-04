using System.Collections.Generic;
using System.Threading.Tasks;
using Mahfazti.Core.DTOs.RecurringBills;

namespace Mahfazti.Core.Interfaces
{
    public interface IRecurringBillService
    {
        Task<List<RecurringBillDto>> GetBillsAsync(string userId);
        Task<RecurringBillDto?> GetBillByIdAsync(int id, string userId);
        Task<RecurringBillDto> CreateBillAsync(string userId, CreateRecurringBillDto dto);
        Task<RecurringBillDto?> UpdateBillAsync(int id, string userId, UpdateRecurringBillDto dto);
        Task<bool> DeleteBillAsync(int id, string userId);
        Task<bool> MarkBillPaidAsync(int id, string userId);
    }
}
