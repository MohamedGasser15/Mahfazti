using Microsoft.EntityFrameworkCore;
using Mahfazti.Core.Interfaces;
using Mahfazti.Infrastructure.Data;
using Mahfazti.Infrastructure.Persistence.Repository;

namespace Mahfazti.UnitTests.Repositories;

public class PasswordResetStoreTests
{
    private ApplicationDbContext CreateInMemoryDbContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        return new ApplicationDbContext(options);
    }

    [Fact]
    public async Task CanSendCodeAsync_WhenNoPreviousCode_ReturnsTrue()
    {
        using var db = CreateInMemoryDbContext();
        var sut = new PasswordResetStore(db);

        var canSend = await sut.CanSendCodeAsync("user@example.com", TimeSpan.FromSeconds(60));

        Assert.True(canSend);
    }

    [Fact]
    public async Task CanSendCodeAsync_WhenCooldownNotElapsed_ReturnsFalse()
    {
        using var db = CreateInMemoryDbContext();
        var sut = new PasswordResetStore(db);

        await sut.SaveResetCodeAsync("user@example.com", "123456");

        var canSend = await sut.CanSendCodeAsync("user@example.com", TimeSpan.FromSeconds(60));

        Assert.False(canSend);
    }

    [Fact]
    public async Task VerifyResetCodeAsync_WithValidCode_ReturnsSuccessAndResetToken()
    {
        using var db = CreateInMemoryDbContext();
        var sut = new PasswordResetStore(db);

        await sut.SaveResetCodeAsync("user@example.com", "654321");

        var result = await sut.VerifyResetCodeAsync("user@example.com", "654321");

        Assert.Equal(ResetCodeVerificationStatus.Success, result.Status);
        Assert.NotNull(result.ResetToken);
        Assert.NotEmpty(result.ResetToken);

        // Validate that reset token can now be validated
        var isValid = await sut.ValidateResetTokenAsync("user@example.com", result.ResetToken);
        Assert.True(isValid);

        // OTP should no longer be valid for reuse
        var reuseResult = await sut.VerifyResetCodeAsync("user@example.com", "654321");
        Assert.Equal(ResetCodeVerificationStatus.Expired, reuseResult.Status);
    }

    [Fact]
    public async Task VerifyResetCodeAsync_WithInvalidCode_IncrementsAttemptsAndRejects()
    {
        using var db = CreateInMemoryDbContext();
        var sut = new PasswordResetStore(db);

        await sut.SaveResetCodeAsync("user@example.com", "111111");

        var result = await sut.VerifyResetCodeAsync("user@example.com", "999999");
        Assert.Equal(ResetCodeVerificationStatus.Invalid, result.Status);

        // Fail 4 more times to reach 5
        for (int i = 0; i < 4; i++)
        {
            await sut.VerifyResetCodeAsync("user@example.com", "999999");
        }

        var lockedResult = await sut.VerifyResetCodeAsync("user@example.com", "111111");
        Assert.Equal(ResetCodeVerificationStatus.TooManyAttempts, lockedResult.Status);
    }

    [Fact]
    public async Task ValidateResetTokenAsync_WithWrongToken_ReturnsFalse()
    {
        using var db = CreateInMemoryDbContext();
        var sut = new PasswordResetStore(db);

        await sut.SaveResetCodeAsync("user@example.com", "123456");
        var result = await sut.VerifyResetCodeAsync("user@example.com", "123456");

        var isValid = await sut.ValidateResetTokenAsync("user@example.com", "wrong_token_value");
        Assert.False(isValid);
    }

    [Fact]
    public async Task DeleteAsync_RemovesRecord()
    {
        using var db = CreateInMemoryDbContext();
        var sut = new PasswordResetStore(db);

        await sut.SaveResetCodeAsync("user@example.com", "123456");
        await sut.DeleteAsync("user@example.com");

        var entry = await db.PasswordResetVerifications.FindAsync("USER@EXAMPLE.COM");
        Assert.Null(entry);
    }
}
