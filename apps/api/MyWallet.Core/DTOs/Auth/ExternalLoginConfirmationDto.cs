using System.ComponentModel.DataAnnotations;

namespace MyWallet.Core.DTOs.Auth
{
    public class ExternalLoginConfirmationDto
    {
        [Required(ErrorMessage = "الاسم مطلوب")]
        public string Name { get; set; } = string.Empty;

        public string? Email { get; set; }
    }
}
