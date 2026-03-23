using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.DTOs.Auth
{
    public class VerifyCodeDto
    {
        public string Email { get; set; } = string.Empty;

        public string VerificationCode { get; set; } = string.Empty;
    }
}
