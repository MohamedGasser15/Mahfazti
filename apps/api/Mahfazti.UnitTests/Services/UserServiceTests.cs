using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Moq;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class UserServiceTests
{
    private readonly Mock<UserManager<ApplicationUser>> _userManagerMock;
    private readonly Mock<RoleManager<ApplicationRole>> _roleManagerMock;
    private readonly IMemoryCache _cache;
    private readonly Mock<IEmailSender> _emailSenderMock;
    private readonly Mock<IEmailTemplateService> _emailTemplateMock;
    private readonly Mock<ILogger<UserService>> _loggerMock;
    private readonly UserService _sut;

    public UserServiceTests()
    {
        _userManagerMock = MockUserManager();
        _roleManagerMock = MockRoleManager();
        _cache = new MemoryCache(new MemoryCacheOptions());
        _emailSenderMock = new Mock<IEmailSender>();
        _emailTemplateMock = new Mock<IEmailTemplateService>();
        _loggerMock = new Mock<ILogger<UserService>>();

        _sut = new UserService(
            _userManagerMock.Object,
            _roleManagerMock.Object,
            _cache,
            _emailSenderMock.Object,
            _emailTemplateMock.Object,
            _loggerMock.Object
        );
    }

    [Fact]
    public async Task SendVerificationCodeAsync_WhenEmailIsNew_ShouldSendCode()
    {
        _userManagerMock.Setup(x => x.FindByEmailAsync("new@test.com")).ReturnsAsync((ApplicationUser?)null);
        _emailTemplateMock.Setup(x => x.GenerateVerificationEmail(It.IsAny<string>(), "ar")).Returns("<html/>");

        var result = await _sut.SendVerificationCodeAsync("new@test.com");

        Assert.True(result.Success);
        _emailSenderMock.Verify(x => x.SendEmailAsync("new@test.com", It.IsAny<string>(), It.IsAny<string>()), Times.Once);
    }

    [Fact]
    public async Task VerifyEmailCodeAsync_WhenCodeIsValid_ShouldConfirmEmail()
    {
        _cache.Set("verify:user@test.com", "123456", TimeSpan.FromMinutes(10));

        var result = await _sut.VerifyEmailCodeAsync("user@test.com", "123456");

        Assert.True(result.Success);
        Assert.True(_cache.TryGetValue("emailConfirmed:user@test.com", out _));
    }

    [Fact]
    public async Task Register_WhenEmailConfirmed_ShouldCreateUser()
    {
        _cache.Set("emailConfirmed:user@test.com", true, TimeSpan.FromMinutes(30));
        _userManagerMock.Setup(x => x.FindByEmailAsync("user@test.com")).ReturnsAsync((ApplicationUser?)null);
        _userManagerMock.Setup(x => x.CreateAsync(It.IsAny<ApplicationUser>(), "Password123!"))
            .ReturnsAsync(IdentityResult.Success);
        _roleManagerMock.Setup(x => x.RoleExistsAsync(It.IsAny<string>())).ReturnsAsync(true);

        var request = new RegisterRequestDTO
        {
            FullName = "New User",
            Email = "user@test.com",
            Password = "Password123!",
            ConfirmPassword = "Password123!"
        };

        var result = await _sut.Register(request);

        Assert.True(result.Success);
        Assert.NotNull(result.Data);
    }

    [Fact]
    public async Task ForgotPasswordAsync_WhenEmailExists_ShouldSendResetCode()
    {
        var user = new ApplicationUser { Email = "user@test.com" };
        _userManagerMock.Setup(x => x.FindByEmailAsync("user@test.com")).ReturnsAsync(user);
        _emailTemplateMock.Setup(x => x.GeneratePasswordResetEmail(It.IsAny<string>(), "ar")).Returns("<html/>");

        var result = await _sut.ForgotPasswordAsync("user@test.com");

        Assert.True(result.Success);
        _emailSenderMock.Verify(x => x.SendEmailAsync("user@test.com", It.IsAny<string>(), It.IsAny<string>()), Times.Once);
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
