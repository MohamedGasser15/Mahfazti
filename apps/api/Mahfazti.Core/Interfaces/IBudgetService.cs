using Mahfazti.Core.DTOs.Budget;
using Mahfazti.Core.Entities;

namespace Mahfazti.Core.Interfaces
{
    public interface IBudgetService
    {
        Task UpdateCategoryBudgetAsync(string userId, int categoryId, decimal budgetAmount);
        Task<BudgetDto> GetBudgetAsync(string userId);
        Task UpdateMonthlyBudgetAsync(string userId, decimal monthlyBudget);
        Task<UserBudget?> GetUserBudgetAsync(string userId, int month, int year);
    }
}
