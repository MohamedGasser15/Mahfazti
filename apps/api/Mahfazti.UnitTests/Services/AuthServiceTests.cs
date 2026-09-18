using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Moq;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class AuthServiceTests
{
    private readonly Mock<UserManager<ApplicationUser>> _userManagerMock;
    private readonly Mock<ITokenService> _tokenServiceMock;
    private readonly Mock<IRefreshTokenRepository> _refreshTokenRepoMock;
    private readonly Mock<IEmailSender> _emailSenderMock;
    private readonly Mock<IEmailTemplateService> _emailTemplateMock;
    private readonly Mock<ILogger<AuthService>> _loggerMock;
    private readonly AuthService _sut;

    public AuthServiceTests()
    {
        _userManagerMock = MockUserManager();
        _tokenServiceMock = new Mock<ITokenService>();
        _refreshTokenRepoMock = new Mock<IRefreshTokenRepository>();
        _emailSenderMock = new Mock<IEmailSender>();
        _emailTemplateMock = new Mock<IEmailTemplateService>();
        _loggerMock = new Mock<ILogger<AuthService>>();

        _sut = new AuthService(
            _userManagerMock.Object,
            _tokenServiceMock.Object,
            _refreshTokenRepoMock.Object,
            _emailSenderMock.Object,
            _emailTemplateMock.Object,
            _loggerMock.Object
        );
    }

    [Fact]
    public async Task Login_WhenUserNotFound_ShouldReturnNull()
    {
        var request = new LoginRequestDTO { Email = "nonexistent@test.com", Password = "Password123" };
        _userManagerMock.Setup(x => x.FindByEmailAsync(request.Email)).ReturnsAsync((ApplicationUser?)null);

        var result = await _sut.Login(request);

        Assert.Null(result);
    }

    [Fact]
    public async Task Login_WhenUserIsBanned_ShouldReturnBannedResponse()
    {
        var request = new LoginRequestDTO { Email = "banned@test.com", Password = "Password123" };
        var user = new ApplicationUser { Id = 1, Email = request.Email, IsBanned = true };
        _userManagerMock.Setup(x => x.FindByEmailAsync(request.Email)).ReturnsAsync(user);

        var result = await _sut.Login(request);

        Assert.NotNull(result);
        Assert.True(result.IsBanned);
    }

    [Fact]
    public async Task Login_WhenCredentialsAreValid_ShouldReturnTokenAndUser()
    {
        var request = new LoginRequestDTO { Email = "user@test.com", Password = "Password123" };
        var user = new ApplicationUser
        {
            Id = 1,
            Email = request.Email,
            FullName = "Test User",
            UserName = request.Email
        };

        _userManagerMock.Setup(x => x.FindByEmailAsync(request.Email)).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.IsLockedOutAsync(user)).ReturnsAsync(false);
        _userManagerMock.Setup(x => x.CheckPasswordAsync(user, request.Password)).ReturnsAsync(true);
        _userManagerMock.Setup(x => x.GetRolesAsync(user)).ReturnsAsync(new List<string> { "User" });
        _tokenServiceMock.Setup(x => x.GenerateAccessToken(user)).ReturnsAsync("valid-jwt-token");
        _tokenServiceMock.Setup(x => x.GenerateRefreshToken()).Returns("valid-refresh-token");

        var result = await _sut.Login(request);

        Assert.NotNull(result);
        Assert.Equal("valid-jwt-token", result.Token);
        Assert.Equal("valid-refresh-token", result.RefreshToken);
        Assert.NotNull(result.User);
        Assert.Equal("Test User", result.User.FullName);
    }

    [Fact]
    public async Task RefreshToken_WhenValid_ShouldReturnNewTokens()
    {
        var request = new RefreshTokenRequestDTO { AccessToken = "old-jwt", RefreshToken = "old-refresh" };
        var claimsPrincipal = new System.Security.Claims.ClaimsPrincipal(
            new System.Security.Claims.ClaimsIdentity(new[]
            {
                new System.Security.Claims.Claim(System.Security.Claims.ClaimTypes.NameIdentifier, "1")
            })
        );

        _tokenServiceMock.Setup(x => x.GetPrincipalFromExpiredToken(request.AccessToken)).Returns(claimsPrincipal);
        _refreshTokenRepoMock.Setup(x => x.ValidateRefreshTokenAsync("1", request.RefreshToken)).ReturnsAsync(true);

        var user = new ApplicationUser { Id = 1, Email = "user@test.com", UserName = "user@test.com" };
        _userManagerMock.Setup(x => x.FindByIdAsync("1")).ReturnsAsync(user);
        _tokenServiceMock.Setup(x => x.GenerateAccessToken(user)).ReturnsAsync("new-jwt-token");
        _tokenServiceMock.Setup(x => x.GenerateRefreshToken()).Returns("new-refresh-token");

        var result = await _sut.RefreshToken(request);

        Assert.NotNull(result);
        Assert.Equal("new-jwt-token", result.AccessToken);
        Assert.Equal("new-refresh-token", result.RefreshToken);
    }

    [Fact]
    public async Task LogoutAsync_ShouldRevokeTokensAndReturnSuccess()
    {
        var result = await _sut.LogoutAsync("1");

        Assert.True(result.Success);
        _refreshTokenRepoMock.Verify(x => x.RevokeAllRefreshTokensAsync("1"), Times.Once);
    }

    [Fact]
    public async Task SetUserCurrencyAsync_WhenUserExists_ShouldUpdateCurrency()
    {
        var user = new ApplicationUser { Id = 1, Currency = "USD" };
        _userManagerMock.Setup(x => x.FindByIdAsync("1")).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.UpdateAsync(user)).ReturnsAsync(IdentityResult.Success);

        var result = await _sut.SetUserCurrencyAsync("1", "EGP");

        Assert.True(result.Success);
        Assert.Equal("EGP", user.Currency);
    }

    private static Mock<UserManager<ApplicationUser>> MockUserManager()
    {
        var store = new Mock<IUserStore<ApplicationUser>>();
        return new Mock<UserManager<ApplicationUser>>(
            store.Object, null!, null!, null!, null!, null!, null!, null!, null!);
    }
}
