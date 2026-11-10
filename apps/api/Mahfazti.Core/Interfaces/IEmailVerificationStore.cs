namespace Mahfazti.Core.Interfaces;

public enum EmailCodeVerificationResult
{
    Verified,
    Invalid,
    Expired
}

public interface IEmailVerificationStore
{
    Task<bool> CanSendCodeAsync(string email, TimeSpan cooldown);
    Task SaveCodeAsync(string email, string code);
    Task<EmailCodeVerificationResult> VerifyCodeAsync(string email, string code);
    Task<bool> IsVerifiedAsync(string email);
    Task DeleteAsync(string email);
}
