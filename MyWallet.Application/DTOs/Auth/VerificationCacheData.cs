using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.DTOs.Auth
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
