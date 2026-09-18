using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Moq;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class AuthServiceTests
{
    private readonly Mock<UserManager<ApplicationUser>> _userManagerMock;
    private readonly Mock<IEmailSender> _emailSenderMock;
    private readonly Mock<IEmailTemplateService> _emailTemplateMock;
    private readonly Mock<IMemoryCache> _cacheMock;
    private readonly Mock<IConfiguration> _configMock;
    private readonly Mock<IRepository<ApplicationUser>> _userRepoMock;
    private readonly AuthService _sut;

    public AuthServiceTests()
    {
        _userManagerMock = MockUserManager();
        _emailSenderMock = new Mock<IEmailSender>();
        _emailTemplateMock = new Mock<IEmailTemplateService>();
        _cacheMock = new Mock<IMemoryCache>();
        _configMock = new Mock<IConfiguration>();
        _userRepoMock = new Mock<IRepository<ApplicationUser>>();

        _sut = new AuthService(
            _userManagerMock.Object,
            _emailSenderMock.Object,
            _emailTemplateMock.Object,
            _cacheMock.Object,
            _configMock.Object,
            _userRepoMock.Object
        );
    }

    [Fact]
    public async Task SendVerificationAsync_WhenEmailExistsAndIsLogin_ShouldSendCode()
    {
        var dto = new SendVerificationDto { Email = "test@test.com", IsLogin = true };
        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.Email))
            .ReturnsAsync(new ApplicationUser { Email = dto.Email });

        object? ignored = null;
        _cacheMock.Setup(x => x.TryGetValue(It.IsAny<object>(), out ignored)).Returns(false);
        _cacheMock.Setup(x => x.CreateEntry(It.IsAny<object>())).Returns(Mock.Of<ICacheEntry>());
        _emailTemplateMock.Setup(x => x.GenerateVerificationEmail(It.IsAny<string>(), true, null, null))
            .Returns("<html/>");

        var result = await _sut.SendVerificationAsync(dto);

        Assert.True(result.Success);
        _emailSenderMock.Verify(x => x.SendEmailAsync(dto.Email, It.IsAny<string>(), It.IsAny<string>()), Times.Once);
    }

    [Fact]
    public async Task SendVerificationAsync_WhenRegisterWithExistingEmail_ShouldReturnError()
    {
        var dto = new SendVerificationDto { Email = "existing@test.com", IsLogin = false };
        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.Email))
            .ReturnsAsync(new ApplicationUser());

        var result = await _sut.SendVerificationAsync(dto);

        Assert.False(result.Success);
        Assert.Contains("البريد الإلكتروني مسجل بالفعل", result.Message);
    }

    [Fact]
    public async Task SendVerificationAsync_WhenLoginWithNonExistingEmail_ShouldReturnError()
    {
        var dto = new SendVerificationDto { Email = "nonexist@test.com", IsLogin = true };
        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.Email))
            .ReturnsAsync((ApplicationUser?)null);

        var result = await _sut.SendVerificationAsync(dto);

        Assert.False(result.Success);
        Assert.Contains("البريد الإلكتروني غير مسجل", result.Message);
    }

    [Fact]
    public async Task VerifyAndCompleteAsync_WithInvalidCache_ShouldReturnError()
    {
        var dto = new VerifyAndCompleteDto { Email = "test@test.com", VerificationCode = "123456" };
        object? cacheEntry = null;
        _cacheMock.Setup(x => x.TryGetValue(It.IsAny<object>(), out cacheEntry)).Returns(false);

        var result = await _sut.VerifyAndCompleteAsync(dto);

        Assert.False(result.Success);
        Assert.Contains("منتهي الصلاحية", result.Message);
    }

    [Fact]
    public async Task VerifyAndCompleteAsync_WithWrongCode_ShouldReturnError()
    {
        var dto = new VerifyAndCompleteDto { Email = "test@test.com", VerificationCode = "wrong" };
        var cacheData = new VerificationCacheData { Code = "correct", IsLogin = true };
        object? cached = cacheData;
        _cacheMock.Setup(x => x.TryGetValue(It.IsAny<object>(), out cached)).Returns(true);

        var result = await _sut.VerifyAndCompleteAsync(dto);

        Assert.False(result.Success);
        Assert.Contains("غير صحيح", result.Message);
    }

    [Fact]
    public async Task VerifyAndCompleteAsync_WithValidCodeAndExistingUser_ShouldLogin()
    {
        var dto = new VerifyAndCompleteDto
        {
            Email = "test@test.com",
            VerificationCode = "123456",
            Password = "Pass123!"
        };
        var cacheData = new VerificationCacheData { Code = "123456", IsLogin = true };
        object? cached = cacheData;
        _cacheMock.Setup(x => x.TryGetValue(It.IsAny<object>(), out cached)).Returns(true);

        var user = new ApplicationUser
        {
            Id = 1,
            Email = "test@test.com",
            UserName = "testuser",
            FullName = "Test User",
            PhoneNumber = "01000000000"
        };

        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.Email)).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.CheckPasswordAsync(user, dto.Password)).ReturnsAsync(true);
        _userManagerMock.Setup(x => x.GetRolesAsync(user)).ReturnsAsync(new List<string>());

        var jwtSection = new Mock<IConfigurationSection>();
        jwtSection.Setup(x => x.Value).Returns("ThisIsAVeryLongSecretKeyForTestingPurposes123!");
        _configMock.Setup(x => x.GetSection("Jwt:Key")).Returns(jwtSection.Object);
        _configMock.Setup(x => x["Jwt:Key"]).Returns("ThisIsAVeryLongSecretKeyForTestingPurposes123!");
        _configMock.Setup(x => x["Jwt:Issuer"]).Returns("TestIssuer");
        _configMock.Setup(x => x["Jwt:Audience"]).Returns("TestAudience");

        var result = await _sut.VerifyAndCompleteAsync(dto);

        Assert.True(result.Success);
        Assert.NotNull(result.Token);
        Assert.NotNull(result.User);
        Assert.Equal(user.Email, result.User.Email);
    }

    [Fact]
    public async Task VerifyAndCompleteAsync_WithValidCodeAndNewUser_ShouldRegister()
    {
        var dto = new VerifyAndCompleteDto
        {
            Email = "new@test.com",
            VerificationCode = "123456",
            Password = "Pass123!",
            FullName = "New User",
            UserName = "newuser",
            PhoneNumber = "01000000001"
        };
        var cacheData = new VerificationCacheData { Code = "123456", IsLogin = false };
        object? cached = cacheData;
        _cacheMock.Setup(x => x.TryGetValue(It.IsAny<object>(), out cached)).Returns(true);

        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.Email)).ReturnsAsync((ApplicationUser?)null);
        _userManagerMock.Setup(x => x.FindByNameAsync(dto.UserName)).ReturnsAsync((ApplicationUser?)null);
        _userRepoMock.Setup(x => x.GetAsync(It.IsAny<System.Linq.Expressions.Expression<System.Func<ApplicationUser, bool>>>(), null, false, default))
            .ReturnsAsync((ApplicationUser?)null);
        _userManagerMock.Setup(x => x.CreateAsync(It.IsAny<ApplicationUser>(), dto.Password))
            .ReturnsAsync(IdentityResult.Success);
        _userManagerMock.Setup(x => x.GetRolesAsync(It.IsAny<ApplicationUser>())).ReturnsAsync(new List<string>());

        var jwtSection = new Mock<IConfigurationSection>();
        jwtSection.Setup(x => x.Value).Returns("ThisIsAVeryLongSecretKeyForTestingPurposes123!");
        _configMock.Setup(x => x.GetSection("Jwt:Key")).Returns(jwtSection.Object);
        _configMock.Setup(x => x["Jwt:Key"]).Returns("ThisIsAVeryLongSecretKeyForTestingPurposes123!");
        _configMock.Setup(x => x["Jwt:Issuer"]).Returns("TestIssuer");
        _configMock.Setup(x => x["Jwt:Audience"]).Returns("TestAudience");

        var result = await _sut.VerifyAndCompleteAsync(dto);

        Assert.True(result.Success);
        Assert.NotNull(result.Token);
    }

    [Fact]
    public async Task VerifyAndCompleteAsync_WithMissingRegisterFields_ShouldReturnError()
    {
        var dto = new VerifyAndCompleteDto
        {
            Email = "new@test.com",
            VerificationCode = "123456",
            Password = "Pass123!"
        };
        var cacheData = new VerificationCacheData { Code = "123456", IsLogin = false };
        object? cached = cacheData;
        _cacheMock.Setup(x => x.TryGetValue(It.IsAny<object>(), out cached)).Returns(true);

        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.Email)).ReturnsAsync((ApplicationUser?)null);

        var result = await _sut.VerifyAndCompleteAsync(dto);

        Assert.False(result.Success);
        Assert.Contains("جميع البيانات المطلوبة", result.Message);
    }

    [Fact]
    public async Task VerifyCodeAsync_WithValidCode_ShouldSucceed()
    {
        var dto = new VerifyCodeDto { Email = "test@test.com", VerificationCode = "123456" };
        var cacheData = new VerificationCacheData { Code = "123456" };
        object? cached = cacheData;
        _cacheMock.Setup(x => x.TryGetValue(It.IsAny<object>(), out cached)).Returns(true);

        var result = await _sut.VerifyCodeAsync(dto);

        Assert.True(result.Success);
    }

    [Fact]
    public async Task CheckEmailExists_WhenUserExists_ShouldReturnTrue()
    {
        _userManagerMock.Setup(x => x.FindByEmailAsync("test@test.com"))
            .ReturnsAsync(new ApplicationUser());

        var result = await _sut.CheckEmailExists("test@test.com");

        Assert.True(result);
    }

    [Fact]
    public async Task CheckEmailExists_WhenUserDoesNotExist_ShouldReturnFalse()
    {
        _userManagerMock.Setup(x => x.FindByEmailAsync("test@test.com"))
            .ReturnsAsync((ApplicationUser?)null);

        var result = await _sut.CheckEmailExists("test@test.com");

        Assert.False(result);
    }

    [Fact]
    public async Task CheckUserExistsAsync_WhenUserExistsByEmail_ShouldReturnSuccess()
    {
        var dto = new CheckUserDto { EmailOrUsername = "test@test.com" };
        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.EmailOrUsername))
            .ReturnsAsync(new ApplicationUser());

        var result = await _sut.CheckUserExistsAsync(dto);

        Assert.True(result.Success);
    }

    [Fact]
    public async Task CheckUserExistsAsync_WhenUserDoesNotExist_ShouldReturnError()
    {
        var dto = new CheckUserDto { EmailOrUsername = "unknown@test.com" };
        _userManagerMock.Setup(x => x.FindByEmailAsync(dto.EmailOrUsername))
            .ReturnsAsync((ApplicationUser?)null);

        var result = await _sut.CheckUserExistsAsync(dto);

        Assert.False(result.Success);
    }

    [Fact]
    public async Task LogoutAsync_ShouldAlwaysSucceed()
    {
        var result = await _sut.LogoutAsync("user1");
        Assert.True(result.Success);
    }

    [Fact]
    public async Task SetUserCurrencyAsync_WhenUserExists_ShouldUpdate()
    {
        var user = new ApplicationUser { Id = 1, Currency = null };
        _userManagerMock.Setup(x => x.FindByIdAsync("1")).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.UpdateAsync(user)).ReturnsAsync(IdentityResult.Success);

        var result = await _sut.SetUserCurrencyAsync("1", "USD");

        Assert.True(result.Success);
        Assert.Equal("USD", user.Currency);
    }

    [Fact]
    public async Task SetUserCurrencyAsync_WhenUserNotFound_ShouldReturnError()
    {
        _userManagerMock.Setup(x => x.FindByIdAsync("999")).ReturnsAsync((ApplicationUser?)null);

        var result = await _sut.SetUserCurrencyAsync("999", "USD");

        Assert.False(result.Success);
    }

    private static Mock<UserManager<ApplicationUser>> MockUserManager()
    {
        var store = new Mock<IUserStore<ApplicationUser>>();
        return new Mock<UserManager<ApplicationUser>>(
            store.Object, null!, null!, null!, null!, null!, null!, null!, null!);
    }
}
