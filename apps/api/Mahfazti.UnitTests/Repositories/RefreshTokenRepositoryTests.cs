using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Moq;
using Mahfazti.Infrastructure.Data;
using Mahfazti.Infrastructure.Persistence.Repository;

namespace Mahfazti.UnitTests.Repositories;

public class RefreshTokenRepositoryTests
{
    private ApplicationDbContext CreateInMemoryDbContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        return new ApplicationDbContext(options);
    }

    [Fact]
    public async Task SaveRefreshTokenAsync_StoresSha256HashedToken()
    {
        using var db = CreateInMemoryDbContext();
        var loggerMock = new Mock<ILogger<RefreshTokenRepository>>();
        var sut = new RefreshTokenRepository(db, loggerMock.Object);

        const string rawToken = "my_super_secret_refresh_token_12345";
        await sut.SaveRefreshTokenAsync("1", rawToken, DateTime.UtcNow.AddDays(7));

        var stored = await db.RefreshTokens.FirstOrDefaultAsync(rt => rt.UserId == 1);
        Assert.NotNull(stored);
        Assert.NotEqual(rawToken, stored.Token);

        var expectedHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(rawToken)));
        Assert.Equal(expectedHash, stored.Token);
    }

    [Fact]
    public async Task ValidateRefreshTokenAsync_ValidatesAgainstStoredHash()
    {
        using var db = CreateInMemoryDbContext();
        var loggerMock = new Mock<ILogger<RefreshTokenRepository>>();
        var sut = new RefreshTokenRepository(db, loggerMock.Object);

        const string rawToken = "my_token_to_validate";
        await sut.SaveRefreshTokenAsync("1", rawToken, DateTime.UtcNow.AddDays(7));

        var isValid = await sut.ValidateRefreshTokenAsync("1", rawToken);
        Assert.True(isValid);

        var isInvalid = await sut.ValidateRefreshTokenAsync("1", "different_token");
        Assert.False(isInvalid);
    }

    [Fact]
    public async Task UpdateRefreshTokenAsync_RotatesAtomicallyAndRevokesOld()
    {
        using var db = CreateInMemoryDbContext();
        var loggerMock = new Mock<ILogger<RefreshTokenRepository>>();
        var sut = new RefreshTokenRepository(db, loggerMock.Object);

        const string oldToken = "old_token_value";
        const string newToken = "new_token_value";

        await sut.SaveRefreshTokenAsync("1", oldToken, DateTime.UtcNow.AddDays(7));
        await sut.UpdateRefreshTokenAsync("1", oldToken, newToken, DateTime.UtcNow.AddDays(7));

        // Old token should be revoked
        var isOldValid = await sut.ValidateRefreshTokenAsync("1", oldToken);
        Assert.False(isOldValid);

        // New token should be valid
        var isNewValid = await sut.ValidateRefreshTokenAsync("1", newToken);
        Assert.True(isNewValid);
    }

    [Fact]
    public async Task UpdateRefreshTokenAsync_WhenOldTokenAlreadyRevoked_DetectsReuseAndRevokesAll()
    {
        using var db = CreateInMemoryDbContext();
        var loggerMock = new Mock<ILogger<RefreshTokenRepository>>();
        var sut = new RefreshTokenRepository(db, loggerMock.Object);

        const string token1 = "token_1";
        const string token2 = "token_2";
        const string token3 = "token_3";

        // Initial issue and rotation
        await sut.SaveRefreshTokenAsync("1", token1, DateTime.UtcNow.AddDays(7));
        await sut.UpdateRefreshTokenAsync("1", token1, token2, DateTime.UtcNow.AddDays(7));

        // Malicious client tries to reuse token1
        await Assert.ThrowsAsync<SecurityTokenException>(() =>
            sut.UpdateRefreshTokenAsync("1", token1, token3, DateTime.UtcNow.AddDays(7))
        );

        // Both token1 and token2 must now be revoked due to reuse detection
        var isToken2Valid = await sut.ValidateRefreshTokenAsync("1", token2);
        Assert.False(isToken2Valid);
    }
}
