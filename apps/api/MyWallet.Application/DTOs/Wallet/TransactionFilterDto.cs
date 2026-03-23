// Application/DTOs/Wallet/TransactionFilterDto.cs
namespace MyWallet.Application.DTOs.Wallet
{
    public class TransactionFilterDto
    {
        public string? Type { get; set; }
        public int? CategoryId { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }
}