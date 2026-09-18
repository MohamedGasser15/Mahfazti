

namespace Mahfazti.Core.DTOs.Auth
{
    public class VerificationCacheData
    {
        public string Code { get; set; } = string.Empty;
        public bool IsLogin { get; set; }
        public bool UserExists { get; set; }
        public string? DeviceName { get; set; } 
        public string? IpAddress { get; set; }
    }
}
