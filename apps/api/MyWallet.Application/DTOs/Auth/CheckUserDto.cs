using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.DTOs.Auth
{
    // CheckUserDto.cs
    public class CheckUserDto
    {
        [Required]
        public string EmailOrUsername { get; set; } = string.Empty;
    }

    // VerifyPasswordForRecoveryDto.cs
    public class VerifyPasswordForRecoveryDto
    {
        [Required]
        public string EmailOrUsername { get; set; } = string.Empty;
        [Required]
        public string Password { get; set; } = string.Empty;
    }

    // RequestEmailChangeDto.cs
    public class RequestEmailChangeDto
    {
        [Required]
        public string EmailOrUsername { get; set; } = string.Empty;
        [Required]
        [EmailAddress]
        public string NewEmail { get; set; } = string.Empty;
    }

    // ConfirmEmailChangeDto.cs
    public class ConfirmEmailChangeDto
    {
        [Required]
        public string EmailOrUsername { get; set; } = string.Empty;
        [Required]
        public string NewEmail { get; set; } = string.Empty;
        [Required]
        [StringLength(6, MinimumLength = 6)]
        public string OtpCode { get; set; } = string.Empty;
    }
    public class EmailChangeCacheData
    {
        public string Code { get; set; } = string.Empty;
        public string NewEmail { get; set; } = string.Empty;
        public string EmailOrUsername { get; set; } = string.Empty;
    }
}
