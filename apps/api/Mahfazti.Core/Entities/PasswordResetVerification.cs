namespace Mahfazti.Core.Entities;

public class PasswordResetVerification
{
    public string Email { get; set; } = string.Empty;
    public string CodeHash { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }
    public int FailedAttempts { get; set; }
    public DateTime? LastSentAtUtc { get; set; }
    public string? ResetTokenHash { get; set; }
    public DateTime? ResetTokenExpiresAtUtc { get; set; }
}
