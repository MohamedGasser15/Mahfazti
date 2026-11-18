using System.Reflection;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Mahfazti.Api.Controllers;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Interfaces;
using Xunit;

namespace Mahfazti.UnitTests.Controllers;

public class ProfileControllerTests
{
    private readonly Mock<IProfileService> _profileServiceMock;
    private readonly ProfileController _sut;

    public ProfileControllerTests()
    {
        _profileServiceMock = new Mock<IProfileService>();
        _sut = new ProfileController(_profileServiceMock.Object);
    }

    private void SetUserContext(string? userId)
    {
        var httpContext = new DefaultHttpContext();
        if (!string.IsNullOrEmpty(userId))
        {
            var identity = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, userId)
            }, "TestAuth");
            httpContext.User = new ClaimsPrincipal(identity);
        }
        else
        {
            httpContext.User = new ClaimsPrincipal(new ClaimsIdentity());
        }

        _sut.ControllerContext = new ControllerContext { HttpContext = httpContext };
    }

    [Fact]
    public void ProfileController_HasExpectedRoutesAndAttributes()
    {
        var routeAttr = typeof(ProfileController).GetCustomAttribute<RouteAttribute>();
        Assert.NotNull(routeAttr);
        Assert.Equal("api/profile", routeAttr.Template);

        var currencyMethod = typeof(ProfileController).GetMethod(nameof(ProfileController.SetCurrency));
        Assert.NotNull(currencyMethod);
        var currencyPut = currencyMethod.GetCustomAttribute<HttpPutAttribute>();
        Assert.NotNull(currencyPut);
        Assert.Equal("currency", currencyPut.Template);

        var langMethod = typeof(ProfileController).GetMethod(nameof(ProfileController.SetLanguage));
        Assert.NotNull(langMethod);
        var langPut = langMethod.GetCustomAttribute<HttpPutAttribute>();
        Assert.NotNull(langPut);
        Assert.Equal("language", langPut.Template);
    }

    [Fact]
    public async Task SetCurrency_WhenAuthenticated_UpdatesCurrencySuccessfully()
    {
        SetUserContext("42");
        _profileServiceMock.Setup(x => x.SetUserCurrencyAsync("42", "USD"))
            .ReturnsAsync(ApiResponse<object>.SuccessResponse(new object(), "تم تحديث العملة بنجاح"));

        var result = await _sut.SetCurrency(new SetCurrencyDto { Currency = "USD" });

        var objectResult = Assert.IsAssignableFrom<ObjectResult>(result);
        Assert.Equal(200, objectResult.StatusCode);
        var apiResponse = Assert.IsAssignableFrom<ApiResponse<object>>(objectResult.Value);
        Assert.True(apiResponse.Success);
        _profileServiceMock.Verify(x => x.SetUserCurrencyAsync("42", "USD"), Times.Once);
    }

    [Fact]
    public async Task SetCurrency_WhenUnauthenticated_ReturnsUnauthorized()
    {
        SetUserContext(null);

        var result = await _sut.SetCurrency(new SetCurrencyDto { Currency = "USD" });

        var unauthorizedResult = Assert.IsType<UnauthorizedObjectResult>(result);
        var apiResponse = Assert.IsAssignableFrom<ApiResponse<object>>(unauthorizedResult.Value);
        Assert.False(apiResponse.Success);
        _profileServiceMock.Verify(x => x.SetUserCurrencyAsync(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task SetCurrency_WhenEmptyCurrency_ReturnsBadRequest()
    {
        SetUserContext("42");

        var result = await _sut.SetCurrency(new SetCurrencyDto { Currency = "" });

        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        var apiResponse = Assert.IsAssignableFrom<ApiResponse<object>>(badRequestResult.Value);
        Assert.False(apiResponse.Success);
        _profileServiceMock.Verify(x => x.SetUserCurrencyAsync(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task SetLanguage_WhenAuthenticated_UpdatesLanguageSuccessfully()
    {
        SetUserContext("42");
        _profileServiceMock.Setup(x => x.SetUserLanguageAsync("42", "ar"))
            .ReturnsAsync(ApiResponse<object>.SuccessResponse(new object(), "تم تحديث اللغة المفضلة بنجاح"));

        var result = await _sut.SetLanguage(new SetLanguageDto { Language = "ar" });

        var objectResult = Assert.IsAssignableFrom<ObjectResult>(result);
        Assert.Equal(200, objectResult.StatusCode);
        var apiResponse = Assert.IsAssignableFrom<ApiResponse<object>>(objectResult.Value);
        Assert.True(apiResponse.Success);
        _profileServiceMock.Verify(x => x.SetUserLanguageAsync("42", "ar"), Times.Once);
    }

    [Fact]
    public async Task SetLanguage_WhenUnauthenticated_ReturnsUnauthorized()
    {
        SetUserContext(null);

        var result = await _sut.SetLanguage(new SetLanguageDto { Language = "ar" });

        var unauthorizedResult = Assert.IsType<UnauthorizedObjectResult>(result);
        var apiResponse = Assert.IsAssignableFrom<ApiResponse<object>>(unauthorizedResult.Value);
        Assert.False(apiResponse.Success);
        _profileServiceMock.Verify(x => x.SetUserLanguageAsync(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task SetLanguage_WhenEmptyLanguage_ReturnsBadRequest()
    {
        SetUserContext("42");

        var result = await _sut.SetLanguage(new SetLanguageDto { Language = "" });

        var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
        var apiResponse = Assert.IsAssignableFrom<ApiResponse<object>>(badRequestResult.Value);
        Assert.False(apiResponse.Success);
        _profileServiceMock.Verify(x => x.SetUserLanguageAsync(It.IsAny<string>(), It.IsAny<string>()), Times.Never);
    }
}
