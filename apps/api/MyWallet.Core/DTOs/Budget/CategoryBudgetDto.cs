namespace MyWallet.Core.DTOs.Budget
{
    public class CategoryBudgetDto
    {
        public int Id { get; set; }
        public int CategoryId { get; set; }
        public string CategoryNameAr { get; set; } = string.Empty;
        public string CategoryNameEn { get; set; } = string.Empty;
        public decimal BudgetAmount { get; set; }
        public decimal Spent { get; set; }
    }
}
