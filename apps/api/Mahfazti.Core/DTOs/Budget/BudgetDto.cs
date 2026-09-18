namespace Mahfazti.Core.DTOs.Budget
{
    public class BudgetDto
    {
        public decimal MonthlyBudget { get; set; }
        public decimal CurrentSpending { get; set; }
        public List<CategoryBudgetDto> CategoryBudgets { get; set; } = new();
    }
}
