using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.DTOs.Auth
{
    public class ForgotPasswordDTO
    {
        [Required(ErrorMessage = "البريد الإلكتروني مطلوب")]
        [EmailAddress(ErrorMessage = "صيغة البريد الإلكتروني غير صحيحة")]
        public string Email { get; set; } = string.Empty;
    }
}
