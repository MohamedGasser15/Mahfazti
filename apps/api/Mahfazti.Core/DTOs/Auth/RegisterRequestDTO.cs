using System.ComponentModel.DataAnnotations;
using Mahfazti.Core.Attributes;

namespace Mahfazti.Core.DTOs.Auth
{
    public class RegisterRequestDTO
    {
        [Required(ErrorMessage = "الاسم الكامل مطلوب")]
        [MinLength(3, ErrorMessage = "يجب أن يكون الاسم الكامل على الأقل 3 أحرف")]
        public string FullName { get; set; } = string.Empty;

        [Required(ErrorMessage = "البريد الإلكتروني مطلوب")]
        [EmailAddress(ErrorMessage = "صيغة البريد الإلكتروني غير صحيحة")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "كلمة المرور مطلوبة")]
        [DataType(DataType.Password)]
        [CustomPassword]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "تأكيد كلمة المرور مطلوب")]
        [DataType(DataType.Password)]
        [Compare("Password", ErrorMessage = "كلمة المرور وتأكيدها غير متطابقين")]
        public string ConfirmPassword { get; set; } = string.Empty;
    }
}
