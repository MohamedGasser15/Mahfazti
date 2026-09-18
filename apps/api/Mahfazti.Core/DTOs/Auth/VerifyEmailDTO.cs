using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.DTOs.Auth
{
    public class VerifyEmailDTO
    {
        [Required(ErrorMessage = "البريد الإلكتروني مطلوب")]
        [EmailAddress(ErrorMessage = "صيغة البريد الإلكتروني غير صحيحة")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "رمز التحقق مطلوب")]
        public string Code { get; set; } = string.Empty;
    }
}
