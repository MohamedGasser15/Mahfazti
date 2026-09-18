using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class TokenServiceTests
{
    private readonly Mock<RoleManager<ApplicationRole>> _roleManagerMock;
    private readonly Mock<ILogger<TokenService>> _loggerMock;

    public TokenServiceTests()
    {
        _roleManagerMock = MockRoleManager();
        _loggerMock = new Mock<ILogger<TokenService>>();
    }

    [Fact]
    public async Task GenerateAccessToken_ShouldReturnValidJwt()
    {
        var configMock = new Mock<IConfiguration>();
        configMock.Setup(x => x["Jwt:Key"]).Returns("ThisIsAVeryLongSecretKeyForTestingPurposes123!");
        configMock.Setup(x => x["Jwt:Issuer"]).Returns("TestIssuer");
        configMock.Setup(x => x["Jwt:Audience"]).Returns("TestAudience");

        var userManagerMock = MockUserManager();
        var user = new ApplicationUser
        {
            Id = 1,
            Email = "test@test.com",
            UserName = "testuser",
            FullName = "Test User",
            PhoneNumber = "01000000000"
        };

        userManagerMock.Setup(x => x.GetRolesAsync(user)).ReturnsAsync(new List<string> { "User" });
        userManagerMock.Setup(x => x.GetClaimsAsync(user)).ReturnsAsync(new List<System.Security.Claims.Claim>());

        var sut = new TokenService(configMock.Object, userManagerMock.Object, _roleManagerMock.Object, _loggerMock.Object);

        var token = await sut.GenerateAccessToken(user);

        Assert.NotNull(token);
        Assert.NotEmpty(token);
        Assert.Contains(".", token);
    }

    [Fact]
    public async Task GenerateAccessToken_WhenKeyMissing_ShouldThrow()
    {
        var configMock = new Mock<IConfiguration>();
        configMock.Setup(x => x["Jwt:Key"]).Returns((string?)null);

        var user = new ApplicationUser
        {
            Id = 1,
            Email = "test@test.com",
            UserName = "testuser",
            FullName = "Test User",
            PhoneNumber = "01000000000"
        };

        var userManagerMock = MockUserManager();
        userManagerMock.Setup(x => x.GetRolesAsync(user)).ReturnsAsync(new List<string>());

        var sut = new TokenService(configMock.Object, userManagerMock.Object, _roleManagerMock.Object, _loggerMock.Object);

        await Assert.ThrowsAsync<ArgumentException>(() =>
            sut.GenerateAccessToken(user));
    }

    [Fact]
    public void GenerateRefreshToken_ShouldReturnNonEmptyBase64()
    {
        var configMock = new Mock<IConfiguration>();
        var userManagerMock = MockUserManager();

        var sut = new TokenService(configMock.Object, userManagerMock.Object, _roleManagerMock.Object, _loggerMock.Object);

        var token = sut.GenerateRefreshToken();

        Assert.NotNull(token);
        Assert.NotEmpty(token);
    }

    private static Mock<UserManager<ApplicationUser>> MockUserManager()
    {
        var store = new Mock<IUserStore<ApplicationUser>>();
        return new Mock<UserManager<ApplicationUser>>(
            store.Object, null!, null!, null!, null!, null!, null!, null!, null!);
    }

    private static Mock<RoleManager<ApplicationRole>> MockRoleManager()
    {
        var store = new Mock<IRoleStore<ApplicationRole>>();
        return new Mock<RoleManager<ApplicationRole>>(
            store.Object, null!, null!, null!, null!);
    }
}
