using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.DTOs.Auth
{
    public class SendVerificationDto
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        public bool IsLogin { get; set; } = false;
        public string? DeviceName { get; set; } 
        public string? IpAddress { get; set; }
    }
}
