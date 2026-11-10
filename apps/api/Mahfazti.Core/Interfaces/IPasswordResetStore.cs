namespace Mahfazti.Core.Interfaces;

public enum ResetCodeVerificationStatus
{
    Success,
    Invalid,
    Expired,
    TooManyAttempts
}

public class ResetCodeVerificationResult
{
    public ResetCodeVerificationStatus Status { get; set; }
    public string? ResetToken { get; set; }
    public string Message { get; set; } = string.Empty;
}

public interface IPasswordResetStore
{
    Task<bool> CanSendCodeAsync(string email, TimeSpan cooldown);
    Task SaveResetCodeAsync(string email, string code);
    Task<ResetCodeVerificationResult> VerifyResetCodeAsync(string email, string code);
    Task<bool> ValidateResetTokenAsync(string email, string? resetToken);
    Task DeleteAsync(string email);
}
