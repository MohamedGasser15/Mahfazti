using MyWallet.Application.DTOs.Budget;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.ServiceInterfaces
{
    public interface IBudgetService
    {
        Task<BudgetDto> GetBudgetAsync(string userId);
        Task UpdateMonthlyBudgetAsync(string userId, decimal monthlyBudget);
    }
}
