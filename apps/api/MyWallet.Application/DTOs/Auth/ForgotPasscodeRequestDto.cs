using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.DTOs.Auth
{
    // ForgotPasscodeRequestDto.cs
    public class ForgotPasscodeRequestDto
    {
        [Required]
        public string UserId { get; set; } = string.Empty;
    }

    public class ResetPasscodeDto
    {
        public string? UserId { get; set; }

        [Required]
        [StringLength(6, MinimumLength = 6)]
        public string OtpCode { get; set; } = string.Empty;

        [Required]
        [StringLength(100, MinimumLength = 6)]
        public string NewPasscode { get; set; } = string.Empty;
    }
}
