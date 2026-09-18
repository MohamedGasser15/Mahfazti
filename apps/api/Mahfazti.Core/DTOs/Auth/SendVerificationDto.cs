using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.DTOs.Auth
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
