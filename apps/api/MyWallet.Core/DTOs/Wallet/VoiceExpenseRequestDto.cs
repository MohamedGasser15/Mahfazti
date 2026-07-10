using System.ComponentModel.DataAnnotations;

namespace MyWallet.Core.DTOs.Wallet
{
    public class VoiceExpenseRequestDto
    {
        [Required]
        public string Text { get; set; } = string.Empty;
        public string Language { get; set; } = "ar";
    }
}
