using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using MyWallet.Core.DTOs.Auth;
using MyWallet.Core.Entities;

namespace MyWallet.Core.Interfaces
{
    public interface IExternalLoginService
    {
        AuthenticationProperties ConfigureExternalAuthProperties(string provider, string redirectUrl);

        Task<ExternalLoginInfo> GetExternalLoginInfoAsync();

        Task<ApplicationUser> FindByExternalLoginAsync(string provider, string key);

        Task<SignInResult> ExternalLoginSignInAsync(string provider, string key, bool isPersistent);

        Task UpdateExternalAuthTokensAsync(ExternalLoginInfo info);

        Task<ExternalLoginCallbackResultDTO> HandleExternalLoginCallbackAsync(string remoteError, string returnUrl);

        Task<ExternalLoginCallbackResultDTO> ConfirmExternalUserAsync(ExternalLoginConfirmationDto model);

        Task<ExternalLoginCallbackResultDTO> HandleGoogleMobileLoginAsync(string idToken);
    }
}
