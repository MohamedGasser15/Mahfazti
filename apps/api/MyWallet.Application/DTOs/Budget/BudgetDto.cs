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
        public int Id { get; set; }
        public int CategoryId { get; set; }
        public string CategoryNameAr { get; set; } = string.Empty;
        public string CategoryNameEn { get; set; } = string.Empty;
        public decimal BudgetAmount { get; set; }
        public decimal Spent { get; set; }
    }
    public class UpdateCategoryBudgetDto
    {
        public int CategoryId { get; set; }
        public decimal Budget { get; set; }
    }
    public class UpdateMonthlyBudgetDto
    {
        public decimal MonthlyBudget { get; set; }
    }
}
