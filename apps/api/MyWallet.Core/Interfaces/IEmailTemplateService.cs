

namespace MyWallet.Core.Interfaces
{
    public interface IEmailTemplateService
    {
        string GenerateVerificationEmail(string code, bool isLogin, string? deviceName = null, string? ipAddress = null);
    }
}
