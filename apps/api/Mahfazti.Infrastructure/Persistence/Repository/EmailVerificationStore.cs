using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Infrastructure.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Mahfazti.Infrastructure.Persistence.Repository;

public class EmailVerificationStore : IEmailVerificationStore
{
    private readonly ApplicationDbContext _db;
    private readonly PasswordHasher<EmailVerification> _hasher = new();

    public EmailVerificationStore(ApplicationDbContext db) => _db = db;

    public async Task<bool> CanSendCodeAsync(string email, TimeSpan cooldown)
    {
        var entry = await _db.EmailVerifications.FindAsync(Normalize(email));
        if (entry == null || !entry.LastSentAtUtc.HasValue) return true;
        return DateTime.UtcNow - entry.LastSentAtUtc.Value >= cooldown;
    }

    public async Task SaveCodeAsync(string email, string code)
    {
        var key = Normalize(email);
        var entry = await _db.EmailVerifications.FindAsync(key);
        if (entry == null)
        {
            entry = new EmailVerification { Email = key };
            _db.EmailVerifications.Add(entry);
        }

        entry.CodeHash = _hasher.HashPassword(entry, code);
        entry.ExpiresAtUtc = DateTime.UtcNow.AddMinutes(10);
        entry.VerifiedUntilUtc = null;
        entry.FailedAttempts = 0;
        entry.LastSentAtUtc = DateTime.UtcNow;
        await _db.SaveChangesAsync();
    }

    public async Task<EmailCodeVerificationResult> VerifyCodeAsync(string email, string code)
    {
        var entry = await _db.EmailVerifications.FindAsync(Normalize(email));
        if (entry == null || entry.CodeHash.Length == 0 ||
            entry.ExpiresAtUtc <= DateTime.UtcNow || entry.FailedAttempts >= 5)
            return EmailCodeVerificationResult.Expired;

        if (_hasher.VerifyHashedPassword(entry, entry.CodeHash, code) == PasswordVerificationResult.Failed)
        {
            entry.FailedAttempts++;
            await _db.SaveChangesAsync();
            return EmailCodeVerificationResult.Invalid;
        }

        entry.CodeHash = string.Empty;
        entry.VerifiedUntilUtc = DateTime.UtcNow.AddMinutes(30);
        await _db.SaveChangesAsync();
        return EmailCodeVerificationResult.Verified;
    }

    public async Task<bool> IsVerifiedAsync(string email)
    {
        var entry = await _db.EmailVerifications.AsNoTracking()
            .FirstOrDefaultAsync(v => v.Email == Normalize(email));
        return entry?.VerifiedUntilUtc > DateTime.UtcNow;
    }

    public async Task DeleteAsync(string email)
    {
        var entry = await _db.EmailVerifications.FindAsync(Normalize(email));
        if (entry == null) return;
        _db.EmailVerifications.Remove(entry);
        await _db.SaveChangesAsync();
    }

    private static string Normalize(string email) => email.Trim().ToUpperInvariant();
}
