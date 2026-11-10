namespace Mahfazti.Core.Entities;

public class EmailVerification
{
    public string Email { get; set; } = string.Empty;
    public string CodeHash { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }
    public DateTime? VerifiedUntilUtc { get; set; }
    public int FailedAttempts { get; set; }
    public DateTime? LastSentAtUtc { get; set; }
}
