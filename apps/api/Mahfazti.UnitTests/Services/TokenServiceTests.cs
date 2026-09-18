using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Moq;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Services;

public class TokenServiceTests
{
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

        var sut = new TokenService(userManagerMock.Object, configMock.Object);

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

        var sut = new TokenService(userManagerMock.Object, configMock.Object);

        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            sut.GenerateAccessToken(user));
    }

    private static Mock<UserManager<ApplicationUser>> MockUserManager()
    {
        var store = new Mock<IUserStore<ApplicationUser>>();
        return new Mock<UserManager<ApplicationUser>>(
            store.Object, null!, null!, null!, null!, null!, null!, null!, null!);
    }
}
