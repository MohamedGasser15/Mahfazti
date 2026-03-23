// Application/DTOs/Wallet/TransactionListResponseDto.cs
using System.Collections.Generic;

namespace MyWallet.Application.DTOs.Wallet
{
    public class TransactionListResponseDto
    {
        public List<WalletTransactionDto> Transactions { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
    }
}