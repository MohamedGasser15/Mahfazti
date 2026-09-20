

namespace Mahfazti.Core.DTOs.Category
{
    public class CategoryDto
    {
        public int Id { get; set; }
        public string NameAr { get; set; } = string.Empty;
        public string NameEn { get; set; } = string.Empty;
        public string Type { get; set; } = "Expense";
        public string Icon { get; set; } = "layers";
        public bool IsActive { get; set; } = true;
        public int TransactionCount { get; set; } = 0;
    }
}
