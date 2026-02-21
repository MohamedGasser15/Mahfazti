using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.DTOs.Budget
{
    public class BudgetDto
    {
        public decimal MonthlyBudget { get; set; }
        public decimal CurrentSpending { get; set; }
        public List<CategoryBudgetDto> CategoryBudgets { get; set; } = new();
    }

    public class CategoryBudgetDto
    {
        public string Category { get; set; } = string.Empty;
        public decimal Budget { get; set; }
        public decimal Spent { get; set; }
    }

    public class UpdateMonthlyBudgetDto
    {
        public decimal MonthlyBudget { get; set; }
    }
}
