using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Entities;

namespace Mahfazti.Core.Interfaces
{
    public interface IExternalLoginService
    {
        AuthenticationProperties ConfigureExternalAuthProperties(string provider, string redirectUrl);

        Task<ExternalLoginInfo?> GetExternalLoginInfoAsync();

        Task<ApplicationUser?> FindByExternalLoginAsync(string provider, string key);

        Task<SignInResult> ExternalLoginSignInAsync(string provider, string key, bool isPersistent);

        Task UpdateExternalAuthTokensAsync(ExternalLoginInfo info);

        Task<ExternalLoginCallbackResultDTO> HandleExternalLoginCallbackAsync(string remoteError, string returnUrl);

        Task<ExternalLoginCallbackResultDTO> ConfirmExternalUserAsync(ExternalLoginConfirmationDto model);

        Task<ExternalLoginCallbackResultDTO> HandleGoogleMobileLoginAsync(string idToken);

        Task<ExternalLoginCallbackResultDTO> HandleFacebookMobileLoginAsync(string accessToken);
    }
}
