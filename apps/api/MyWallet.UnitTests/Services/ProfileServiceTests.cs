using Microsoft.AspNetCore.Identity;
using Moq;
using MyWallet.Core.DTOs.Profile;
using MyWallet.Core.Entities;
using MyWallet.Core.Services;

namespace MyWallet.UnitTests.Services;

public class ProfileServiceTests
{
    private readonly Mock<UserManager<ApplicationUser>> _userManagerMock;
    private readonly ProfileService _sut;

    public ProfileServiceTests()
    {
        _userManagerMock = MockUserManager();
        _sut = new ProfileService(_userManagerMock.Object);
    }

    [Fact]
    public async Task GetProfileAsync_WhenUserExists_ShouldReturnProfile()
    {
        var user = new ApplicationUser
        {
            Id = 1,
            FullName = "Test User",
            UserName = "testuser",
            Email = "test@test.com",
            PhoneNumber = "01000000000",
            ImagePath = "/images/test.jpg"
        };

        _userManagerMock.Setup(x => x.FindByIdAsync("1")).ReturnsAsync(user);

        var result = await _sut.GetProfileAsync("1");

        Assert.Equal("Test User", result.FullName);
        Assert.Equal("testuser", result.UserName);
        Assert.Equal("test@test.com", result.Email);
        Assert.Equal("01000000000", result.PhoneNumber);
        Assert.Equal("/images/test.jpg", result.ImagePath);
    }

    [Fact]
    public async Task GetProfileAsync_WhenUserNotFound_ShouldThrow()
    {
        _userManagerMock.Setup(x => x.FindByIdAsync("999")).ReturnsAsync((ApplicationUser?)null);

        await Assert.ThrowsAsync<Exception>(() => _sut.GetProfileAsync("999"));
    }

    [Fact]
    public async Task UpdateProfileAsync_WhenUserExists_ShouldUpdate()
    {
        var user = new ApplicationUser
        {
            Id = 1,
            FullName = "Old Name",
            UserName = "olduser",
            PhoneNumber = "01000000000"
        };

        var dto = new UpdateProfileDto
        {
            FullName = "New Name",
            UserName = "newuser",
            PhoneNumber = "01000000001"
        };

        _userManagerMock.Setup(x => x.FindByIdAsync("1")).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.UpdateAsync(user)).ReturnsAsync(IdentityResult.Success);
        _userManagerMock.Setup(x => x.FindByIdAsync("1")).ReturnsAsync(user);

        var result = await _sut.UpdateProfileAsync("1", dto);

        Assert.NotNull(result);
        Assert.Equal("New Name", user.FullName);
        Assert.Equal("newuser", user.UserName);
        Assert.Equal("01000000001", user.PhoneNumber);
    }

    [Fact]
    public async Task UpdateProfileAsync_WhenUserNotFound_ShouldThrow()
    {
        _userManagerMock.Setup(x => x.FindByIdAsync("999")).ReturnsAsync((ApplicationUser?)null);

        await Assert.ThrowsAsync<Exception>(() =>
            _sut.UpdateProfileAsync("999", new UpdateProfileDto()));
    }

    [Fact]
    public async Task ChangePasswordAsync_WithValidPassword_ShouldSucceed()
    {
        var user = new ApplicationUser { Id = 1 };
        var dto = new ChangePasswordDto
        {
            CurrentPassword = "OldPass123!",
            NewPassword = "NewPass123!",
            ConfirmPassword = "NewPass123!"
        };

        _userManagerMock.Setup(x => x.FindByIdAsync("1")).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.ChangePasswordAsync(user, dto.CurrentPassword, dto.NewPassword))
            .ReturnsAsync(IdentityResult.Success);

        var result = await _sut.ChangePasswordAsync("1", dto);

        Assert.True(result);
    }

    [Fact]
    public async Task ChangePasswordAsync_WithWrongPassword_ShouldReturnFalse()
    {
        var user = new ApplicationUser { Id = 1 };
        var dto = new ChangePasswordDto
        {
            CurrentPassword = "WrongPass",
            NewPassword = "NewPass123!",
            ConfirmPassword = "NewPass123!"
        };

        _userManagerMock.Setup(x => x.FindByIdAsync("1")).ReturnsAsync(user);
        _userManagerMock.Setup(x => x.ChangePasswordAsync(user, dto.CurrentPassword, dto.NewPassword))
            .ReturnsAsync(IdentityResult.Failed(new IdentityError { Description = "Incorrect password." }));

        var result = await _sut.ChangePasswordAsync("1", dto);

        Assert.False(result);
    }

    private static Mock<UserManager<ApplicationUser>> MockUserManager()
    {
        var store = new Mock<IUserStore<ApplicationUser>>();
        return new Mock<UserManager<ApplicationUser>>(
            store.Object, null!, null!, null!, null!, null!, null!, null!, null!);
    }
}
