using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.ServiceInterfaces
{
    public interface IEmailTemplateService
    {
        string GenerateVerificationEmail(string code, bool isLogin, string? deviceName = null, string? ipAddress = null);
    }
}
