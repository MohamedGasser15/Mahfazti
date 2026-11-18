using System.Reflection;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Api.Controllers;
using Xunit;

namespace Mahfazti.UnitTests.Security;

public class AuthEndpointRoutingTests
{
    [Fact]
    public void AuthController_HasLowercaseApiAuthRoutePrefix()
    {
        var routeAttr = typeof(AuthController).GetCustomAttribute<RouteAttribute>();
        Assert.NotNull(routeAttr);
        Assert.Equal("api/auth", routeAttr.Template);
    }

    [Theory]
    [InlineData(nameof(AuthController.Login), new[] { "login" })]
    [InlineData(nameof(AuthController.Register), new[] { "register" })]
    [InlineData(nameof(AuthController.Logout), new[] { "logout" })]
    [InlineData(nameof(AuthController.RefreshToken), new[] { "token/refresh", "refresh" })]
    [InlineData(nameof(AuthController.SendVerificationCodeAsync), new[] { "registration-codes", "send-code" })]
    [InlineData(nameof(AuthController.VerifyEmail), new[] { "registration-codes/verify", "verify-email" })]
    [InlineData(nameof(AuthController.ForgotPassword), new[] { "password-reset-codes", "forgot-password" })]
    [InlineData(nameof(AuthController.VerifyResetCode), new[] { "password-reset-codes/verify", "verify-reset-code" })]
    [InlineData(nameof(AuthController.ResetPassword), new[] { "password-reset", "reset-password" })]
    [InlineData(nameof(AuthController.GoogleMobileLogin), new[] { "GoogleMobile" })]
    [InlineData(nameof(AuthController.FacebookMobileLogin), new[] { "FacebookMobile" })]
    public void AuthEndpoints_HaveExpectedRoutesAndAliases(string methodName, string[] expectedTemplates)
    {
        var method = typeof(AuthController).GetMethod(methodName);
        Assert.NotNull(method);

        var httpPostAttrs = method.GetCustomAttributes<HttpPostAttribute>().ToList();
        var actualTemplates = httpPostAttrs.Select(a => a.Template).Where(t => t != null).ToList();

        foreach (var expected in expectedTemplates)
        {
            Assert.Contains(expected, actualTemplates);
        }
    }
}
