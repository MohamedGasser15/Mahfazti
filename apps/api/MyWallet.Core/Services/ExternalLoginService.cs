using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using MyWallet.Core.Constants;
using MyWallet.Core.DTOs.Auth;
using MyWallet.Core.Entities;
using MyWallet.Core.Interfaces;
using System.Security.Claims;

namespace MyWallet.Core.Services
{
    public class ExternalLoginService : IExternalLoginService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly ILogger<ExternalLoginService> _logger;
        private readonly ITokenService _tokenService;

        public ExternalLoginService(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            ILogger<ExternalLoginService> logger,
            ITokenService tokenService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _logger = logger;
            _tokenService = tokenService;
        }

        public AuthenticationProperties ConfigureExternalAuthProperties(string provider, string redirectUrl)
        {
            return _signInManager.ConfigureExternalAuthenticationProperties(provider, redirectUrl);
        }

        public async Task<ExternalLoginInfo> GetExternalLoginInfoAsync()
        {
            return await _signInManager.GetExternalLoginInfoAsync();
        }

        public async Task<ApplicationUser> FindByExternalLoginAsync(string provider, string key)
        {
            return await _userManager.FindByLoginAsync(provider, key);
        }

        public async Task<SignInResult> ExternalLoginSignInAsync(string provider, string key, bool isPersistent)
        {
            return await _signInManager.ExternalLoginSignInAsync(provider, key, isPersistent);
        }

        public async Task UpdateExternalAuthTokensAsync(ExternalLoginInfo info)
        {
            await _signInManager.UpdateExternalAuthenticationTokensAsync(info);
        }

        public async Task<ExternalLoginCallbackResultDTO> HandleExternalLoginCallbackAsync(string remoteError, string returnUrl)
        {
            try
            {
                if (remoteError != null)
                {
                    _logger.LogWarning("External login error from provider: {RemoteError}", remoteError);
                    return new ExternalLoginCallbackResultDTO
                    {
                        Message = $"Error from provider: {remoteError}"
                    };
                }

                var info = await _signInManager.GetExternalLoginInfoAsync();
                if (info == null)
                {
                    _logger.LogWarning("Unable to retrieve external login information");
                    return new ExternalLoginCallbackResultDTO
                    {
                        Message = "Unable to retrieve external login info."
                    };
                }

                var user = await _userManager.FindByLoginAsync(info.LoginProvider, info.ProviderKey);
                if (user != null)
                {
                    var result = await _signInManager.ExternalLoginSignInAsync(info.LoginProvider, info.ProviderKey, false);
                    if (result.Succeeded)
                    {
                        await _signInManager.UpdateExternalAuthenticationTokensAsync(info);

                        _logger.LogInformation("User {UserId} logged in successfully via {Provider}", user.Id, info.LoginProvider);

                        var token = await _tokenService.GenerateAccessToken(user);

                        return new ExternalLoginCallbackResultDTO
                        {
                            IsNewUser = false,
                            Email = user.Email,
                            Message = "Logged in successfully via external provider",
                            ReturnUrl = returnUrl,
                            Token = token
                        };
                    }
                    else
                    {
                        _logger.LogWarning("External login sign-in failed for user {UserId}", user.Id);
                        return new ExternalLoginCallbackResultDTO
                        {
                            Message = "External login sign-in failed"
                        };
                    }
                }

                var email = info.Principal.FindFirstValue(ClaimTypes.Email);
                var name = info.Principal.FindFirstValue(ClaimTypes.Name) ??
                           info.Principal.FindFirstValue(ClaimTypes.GivenName) ?? email;

                _logger.LogInformation("External user detected with email: {Email}", email);

                var existingUser = await _userManager.FindByEmailAsync(email);
                if (existingUser != null)
                {
                    _logger.LogInformation("Email {Email} already exists. Linking external login.", email);
                    await _userManager.AddLoginAsync(existingUser, info);
                    var existingToken = await _tokenService.GenerateAccessToken(existingUser);
                    return new ExternalLoginCallbackResultDTO
                    {
                        IsNewUser = false,
                        Email = existingUser.Email,
                        Message = "Linked and logged in successfully",
                        ReturnUrl = returnUrl,
                        Token = existingToken
                    };
                }

                _logger.LogInformation("Creating new user automatically for email: {Email}", email);
                var newUser = new ApplicationUser
                {
                    FullName = name ?? email,
                    Email = email,
                    UserName = email,
                    EmailConfirmed = true
                };

                var createResult = await _userManager.CreateAsync(newUser);
                if (createResult.Succeeded)
                {
                    await _userManager.AddToRoleAsync(newUser, Roles.User);
                    await _userManager.AddLoginAsync(newUser, info);
                    var newToken = await _tokenService.GenerateAccessToken(newUser);
                    return new ExternalLoginCallbackResultDTO
                    {
                        IsNewUser = false,
                        Email = newUser.Email,
                        Message = "Account created and logged in successfully",
                        ReturnUrl = returnUrl,
                        Token = newToken
                    };
                }
                else
                {
                    _logger.LogError("Failed to create user {Email}: {Errors}", email, string.Join(", ", createResult.Errors.Select(e => e.Description)));
                    return new ExternalLoginCallbackResultDTO
                    {
                        Message = "Failed to create account"
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during external login callback handling");
                return new ExternalLoginCallbackResultDTO
                {
                    Message = "An unexpected error occurred during external login."
                };
            }
        }

        public async Task<ExternalLoginCallbackResultDTO> ConfirmExternalUserAsync(ExternalLoginConfirmationDto model)
        {
            try
            {
                var info = await _signInManager.GetExternalLoginInfoAsync();
                if (info == null)
                {
                    _logger.LogError("Invalid external login info during confirmation");
                    return new ExternalLoginCallbackResultDTO { Message = "Invalid external login info." };
                }

                var existingUser = await _userManager.FindByEmailAsync(model.Email);
                if (existingUser != null)
                {
                    _logger.LogWarning("Email {Email} is already registered", model.Email);
                    return new ExternalLoginCallbackResultDTO { Message = "Email is already registered." };
                }

                var user = new ApplicationUser
                {
                    FullName = model.Name,
                    Email = model.Email,
                    UserName = model.Email,
                    EmailConfirmed = true
                };

                var result = await _userManager.CreateAsync(user);
                if (!result.Succeeded)
                {
                    _logger.LogError("User creation failed for email {Email}: {Errors}", model.Email, string.Join(", ", result.Errors.Select(e => e.Description)));
                    return new ExternalLoginCallbackResultDTO { Message = "User creation failed" };
                }

                await _userManager.AddToRoleAsync(user, Roles.User);

                var loginResult = await _userManager.AddLoginAsync(user, info);
                if (!loginResult.Succeeded)
                {
                    _logger.LogError("Adding external login failed for user {UserId}: {Errors}", user.Id, string.Join(", ", loginResult.Errors.Select(e => e.Description)));
                    return new ExternalLoginCallbackResultDTO { Message = "Adding external login failed" };
                }

                await _userManager.UpdateAsync(user);

                _logger.LogInformation("External user confirmed and created successfully for email: {Email}", model.Email);

                var token = await _tokenService.GenerateAccessToken(user);

                return new ExternalLoginCallbackResultDTO
                {
                    Email = user.Email,
                    Message = "External user confirmed",
                    Token = token,
                    IsNewUser = false
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during external user confirmation for email: {Email}", model?.Email);
                return new ExternalLoginCallbackResultDTO { Message = "An error occurred during external user confirmation." };
            }
        }
    }
}
