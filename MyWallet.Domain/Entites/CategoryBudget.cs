using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Domain.Entites
{
    public class CategoryBudget
    {
        public int Id { get; set; }
        public int UserBudgetId { get; set; }
        public string Category { get; set; } = string.Empty;
        public decimal BudgetAmount { get; set; }
        public UserBudget UserBudget { get; set; } = null!;
    }
}
