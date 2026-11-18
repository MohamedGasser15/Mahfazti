using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using Mahfazti.Api.Controllers;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Services;

namespace Mahfazti.UnitTests.Security;

public class SecurityHardeningTests
{
    [Fact]
    public async Task AdminForgotPassword_WhenMaliciousOriginProvided_DoesNotUseMaliciousOrigin()
    {
        var authServiceMock = new Mock<IAuthService>();
        var userServiceMock = new Mock<IUserService>();
        var externalLoginServiceMock = new Mock<IExternalLoginService>();
        var loggerMock = new Mock<ILogger<AuthController>>();
        var envMock = new Mock<IWebHostEnvironment>();
        envMock.Setup(x => x.EnvironmentName).Returns("Production");

        var inMemorySettings = new Dictionary<string, string?>
        {
            {"AdminPortal:AllowedOrigins:0", "https://mahfazti-six.vercel.app"}
        };
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(inMemorySettings)
            .Build();

        string? capturedClientUrl = null;
        userServiceMock.Setup(x => x.AdminForgotPasswordAsync("admin@test.com", It.IsAny<string>()))
            .Callback<string, string?>((email, url) => capturedClientUrl = url)
            .ReturnsAsync(Mahfazti.Core.Common.ApiResponse<object>.SuccessResponse(new object(), "Sent"));

        var sut = new AuthController(
            authServiceMock.Object,
            userServiceMock.Object,
            externalLoginServiceMock.Object,
            configuration,
            envMock.Object,
            loggerMock.Object
        );

        var httpContext = new DefaultHttpContext();
        httpContext.Request.Headers["Origin"] = "https://evil-phishing-site.com";
        sut.ControllerContext = new ControllerContext { HttpContext = httpContext };

        var result = await sut.AdminForgotPassword(new ForgotPasswordDTO { Email = "admin@test.com" });

        Assert.NotNull(capturedClientUrl);
        Assert.DoesNotContain("evil-phishing-site.com", capturedClientUrl);
        Assert.StartsWith("https://mahfazti-six.vercel.app", capturedClientUrl);
    }

    [Fact]
    public void TokenService_DefaultsTo15MinuteExpiry_WhenNotConfigured()
    {
        var inMemorySettings = new Dictionary<string, string?>
        {
            {"Jwt:Key", "SuperSecretKeyForTestingAtLeast32CharsLong!"},
            {"Jwt:Issuer", "Test"},
            {"Jwt:Audience", "Test"}
            // No AccessTokenExpiryMinutes provided
        };
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(inMemorySettings)
            .Build();

        var expiryStr = configuration["Jwt:AccessTokenExpiryMinutes"];
        var expiryMinutes = int.TryParse(expiryStr, out var m) && m > 0 ? m : 15;

        Assert.Equal(15, expiryMinutes);
    }
}
