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
        public int CategoryId { get; set; }
        public decimal BudgetAmount { get; set; }

        public UserBudget UserBudget { get; set; } = null!;
        public Category Category { get; set; } = null!;
    }
}
