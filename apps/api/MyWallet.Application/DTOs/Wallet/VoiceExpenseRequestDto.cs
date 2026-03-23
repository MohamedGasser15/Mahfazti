using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.DTOs.Wallet
{
    public class VoiceExpenseRequestDto
    {
        [Required]
        public string Text { get; set; } = string.Empty;
        public string Language { get; set; } = "ar";
    }
}
