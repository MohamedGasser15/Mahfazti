

namespace Mahfazti.Core.Entities
{
    public class UserBudget
    {
        public int Id { get; set; }
        public string UserId { get; set; } = string.Empty;
        public decimal MonthlyBudget { get; set; }
        public int Month { get; set; }
        public int Year { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}
