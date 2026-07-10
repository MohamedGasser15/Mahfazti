

namespace MyWallet.Core.Entities
{
    public class CategoryBudget
    {
        public int Id { get; set; }
        public int UserBudgetId { get; set; }
        public int CategoryId { get; set; }
        public decimal BudgetAmount { get; set; }

        public UserBudget UserBudget { get; set; } = null!;
        public Category Category { get; set; } = null!;
    }
}
