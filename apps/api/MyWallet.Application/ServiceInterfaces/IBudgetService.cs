using MyWallet.Application.DTOs.Budget;
using MyWallet.Domain.Entites;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.ServiceInterfaces
{
    public interface IBudgetService
    {
        Task UpdateCategoryBudgetAsync(string userId, int categoryId, decimal budgetAmount);
        Task<BudgetDto> GetBudgetAsync(string userId);
        Task UpdateMonthlyBudgetAsync(string userId, decimal monthlyBudget);
        Task<UserBudget?> GetUserBudgetAsync(string userId, int month, int year);
    }
}
