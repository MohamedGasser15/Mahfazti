using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.DTOs.Wallet
{
    public class VoiceExpenseResultDto
    {
        public decimal? Amount { get; set; }
        public string TransactionType { get; set; } = "Withdrawal";
        public int? CategoryId { get; set; }
        public string? CategoryNameAr { get; set; }
        public string? CategoryNameEn { get; set; }
        public string? Note { get; set; }
        public string? Title { get; set; }
        public bool IsSuccess { get; set; }
        public string? ErrorMessage { get; set; }
    }
}
