using Mahfazti.Core.Entities;

namespace Mahfazti.Core.Interfaces
{
    /// <summary>
    /// Service interface for generating localized email templates
    /// </summary>
    public interface IEmailTemplateService
    {
        string GenerateVerificationEmail(string code, string language = "ar");
        string GeneratePasswordResetEmail(string resetCode, string language = "ar");
        string GeneratePasswordResetConfirmationEmail(string language = "ar");
        string GenerateAccountLockoutEmail(ApplicationUser user, DateTimeOffset? lockoutEnd, string language = "ar");
        string GenerateLoginEmail(ApplicationUser user, string? ipAddress, string? deviceName, DateTime requestTime, string? passwordResetLink, string language = "ar");
        string GetLocalizedText(string key, string language = "ar");
    }
}
