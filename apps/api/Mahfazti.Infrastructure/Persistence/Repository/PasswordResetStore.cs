using System.Security.Cryptography;
using System.Text;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Infrastructure.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Mahfazti.Infrastructure.Persistence.Repository;

public class PasswordResetStore : IPasswordResetStore
{
    private readonly ApplicationDbContext _db;
    private readonly PasswordHasher<PasswordResetVerification> _hasher = new();

    public PasswordResetStore(ApplicationDbContext db) => _db = db;

    public async Task<bool> CanSendCodeAsync(string email, TimeSpan cooldown)
    {
        var entry = await _db.PasswordResetVerifications.FindAsync(Normalize(email));
        if (entry == null || !entry.LastSentAtUtc.HasValue) return true;
        return DateTime.UtcNow - entry.LastSentAtUtc.Value >= cooldown;
    }

    public async Task SaveResetCodeAsync(string email, string code)
    {
        var key = Normalize(email);
        var entry = await _db.PasswordResetVerifications.FindAsync(key);
        if (entry == null)
        {
            entry = new PasswordResetVerification { Email = key };
            _db.PasswordResetVerifications.Add(entry);
        }

        entry.CodeHash = _hasher.HashPassword(entry, code);
        entry.ExpiresAtUtc = DateTime.UtcNow.AddMinutes(10);
        entry.FailedAttempts = 0;
        entry.LastSentAtUtc = DateTime.UtcNow;
        entry.ResetTokenHash = null;
        entry.ResetTokenExpiresAtUtc = null;
        await _db.SaveChangesAsync();
    }

    public async Task<ResetCodeVerificationResult> VerifyResetCodeAsync(string email, string code)
    {
        var entry = await _db.PasswordResetVerifications.FindAsync(Normalize(email));
        if (entry == null || string.IsNullOrEmpty(entry.CodeHash) || entry.ExpiresAtUtc <= DateTime.UtcNow)
        {
            return new ResetCodeVerificationResult
            {
                Status = ResetCodeVerificationStatus.Expired,
                Message = "انتهت صلاحية الرمز أو لم يتم طلبه"
            };
        }

        if (entry.FailedAttempts >= 5)
        {
            return new ResetCodeVerificationResult
            {
                Status = ResetCodeVerificationStatus.TooManyAttempts,
                Message = "تم تجاوز الحد الأقصى للمحاولات الخاطئة. يرجى طلب رمز جديد."
            };
        }

        var verifyResult = _hasher.VerifyHashedPassword(entry, entry.CodeHash, code);
        if (verifyResult == PasswordVerificationResult.Failed)
        {
            entry.FailedAttempts++;
            await _db.SaveChangesAsync();
            return new ResetCodeVerificationResult
            {
                Status = ResetCodeVerificationStatus.Invalid,
                Message = "رمز التحقق غير صحيح"
            };
        }

        // Successfully verified: generate cryptographically secure reset token
        var rawResetToken = Convert.ToHexString(RandomNumberGenerator.GetBytes(32));
        entry.CodeHash = string.Empty; // Invalidate OTP once verified
        entry.ResetTokenHash = HashToken(rawResetToken);
        entry.ResetTokenExpiresAtUtc = DateTime.UtcNow.AddMinutes(15);
        await _db.SaveChangesAsync();

        return new ResetCodeVerificationResult
        {
            Status = ResetCodeVerificationStatus.Success,
            ResetToken = rawResetToken,
            Message = "تم التحقق من الرمز بنجاح"
        };
    }

    public async Task<bool> ValidateResetTokenAsync(string email, string? resetToken)
    {
        if (string.IsNullOrWhiteSpace(resetToken)) return false;

        var entry = await _db.PasswordResetVerifications.AsNoTracking()
            .FirstOrDefaultAsync(v => v.Email == Normalize(email));

        if (entry == null || string.IsNullOrEmpty(entry.ResetTokenHash)) return false;
        if (!entry.ResetTokenExpiresAtUtc.HasValue || entry.ResetTokenExpiresAtUtc.Value <= DateTime.UtcNow) return false;

        var inputHash = HashToken(resetToken);
        return CryptographicOperations.FixedTimeEquals(
            Encoding.UTF8.GetBytes(entry.ResetTokenHash),
            Encoding.UTF8.GetBytes(inputHash)
        );
    }

    public async Task DeleteAsync(string email)
    {
        var entry = await _db.PasswordResetVerifications.FindAsync(Normalize(email));
        if (entry == null) return;
        _db.PasswordResetVerifications.Remove(entry);
        await _db.SaveChangesAsync();
    }

    private static string Normalize(string email) => email.Trim().ToUpperInvariant();

    private static string HashToken(string token)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(token));
        return Convert.ToHexString(bytes);
    }
}
