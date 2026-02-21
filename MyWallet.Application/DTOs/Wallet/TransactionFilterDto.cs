// Application/DTOs/Wallet/TransactionFilterDto.cs (optional for list endpoints)
namespace MyWallet.Application.DTOs.Wallet
{
    public class TransactionFilterDto
    {
        public string? Type { get; set; } 
        public string? Category { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }
}