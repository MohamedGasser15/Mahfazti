using Google.Apis.Auth;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;
using Mahfazti.Core.Constants;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Mahfazti.Core.Services
{
    public class ExternalLoginService : IExternalLoginService
    {
        private static readonly ConfigurationManager<OpenIdConnectConfiguration> _facebookConfigManager =
            new ConfigurationManager<OpenIdConnectConfiguration>(
                "https://www.facebook.com/.well-known/openid-configuration/",
                new OpenIdConnectConfigurationRetriever());

        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly ILogger<ExternalLoginService> _logger;
        private readonly ITokenService _tokenService;
        private readonly IConfiguration _configuration;
        private readonly IAccountService _accountService;

        public ExternalLoginService(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            ILogger<ExternalLoginService> logger,
            ITokenService tokenService,
            IConfiguration configuration,
            IAccountService accountService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _logger = logger;
            _tokenService = tokenService;
            _configuration = configuration;
            _accountService = accountService;
        }

        public AuthenticationProperties ConfigureExternalAuthProperties(string provider, string redirectUrl)
        {
            return _signInManager.ConfigureExternalAuthenticationProperties(provider, redirectUrl);
        }

        public async Task<ExternalLoginInfo?> GetExternalLoginInfoAsync()
        {
            return await _signInManager.GetExternalLoginInfoAsync();
        }

        public async Task<ApplicationUser?> FindByExternalLoginAsync(string provider, string key)
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
                        var hasPassword = await _userManager.HasPasswordAsync(user);

                        return new ExternalLoginCallbackResultDTO
                        {
                            IsNewUser = false,
                            Email = user.Email,
                            Message = "Logged in successfully via external provider",
                            ReturnUrl = returnUrl,
                            Token = token,
                            HasPassword = hasPassword
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

                var existingUser = await _userManager.FindByEmailAsync(email!);
                if (existingUser != null)
                {
                    _logger.LogInformation("Email {Email} already exists. Linking external login.", email);
                    await _userManager.AddLoginAsync(existingUser, info);
                    var existingToken = await _tokenService.GenerateAccessToken(existingUser);
                    var hasPassword = await _userManager.HasPasswordAsync(existingUser);
                    return new ExternalLoginCallbackResultDTO
                    {
                        IsNewUser = false,
                        Email = existingUser.Email,
                        Message = "Linked and logged in successfully",
                        ReturnUrl = returnUrl,
                        Token = existingToken,
                        HasPassword = hasPassword
                    };
                }

                _logger.LogInformation("Creating new user automatically for email: {Email}", email);
                var newUser = new ApplicationUser
                {
                    FullName = name ?? email ?? "",
                    Email = email,
                    UserName = email,
                    EmailConfirmed = true
                };

                var createResult = await _userManager.CreateAsync(newUser);
                if (createResult.Succeeded)
                {
                    await _userManager.AddToRoleAsync(newUser, Roles.User);
                    await _userManager.AddLoginAsync(newUser, info);
                    await EnsureDefaultWalletAsync(newUser);
                    var newToken = await _tokenService.GenerateAccessToken(newUser);
                    return new ExternalLoginCallbackResultDTO
                    {
                        IsNewUser = false,
                        Email = newUser.Email,
                        Message = "Account created and logged in successfully",
                        ReturnUrl = returnUrl,
                        Token = newToken,
                        HasPassword = false
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

                var existingUser = await _userManager.FindByEmailAsync(model.Email!);
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

                await EnsureDefaultWalletAsync(user);

                await _userManager.UpdateAsync(user);

                _logger.LogInformation("External user confirmed and created successfully for email: {Email}", model.Email);

                var token = await _tokenService.GenerateAccessToken(user);

                return new ExternalLoginCallbackResultDTO
                {
                    Email = user.Email,
                    Message = "External user confirmed",
                    Token = token,
                    IsNewUser = false,
                    HasPassword = false
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during external user confirmation for email: {Email}", model?.Email);
                return new ExternalLoginCallbackResultDTO { Message = "An error occurred during external user confirmation." };
            }
        }

        public async Task<ExternalLoginCallbackResultDTO> HandleGoogleMobileLoginAsync(string idToken)
        {
            if (string.IsNullOrEmpty(idToken))
                return new ExternalLoginCallbackResultDTO { Message = "idToken is required." };

            try
            {
                var audiences = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                var googleClientId = _configuration["Authentication:Google:ClientId"];
                if (!string.IsNullOrWhiteSpace(googleClientId) && !googleClientId.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase))
                    audiences.Add(googleClientId);

                var serverClientId = _configuration["Authentication:Google:ServerClientId"];
                if (!string.IsNullOrWhiteSpace(serverClientId) && !serverClientId.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase))
                    audiences.Add(serverClientId);

                var mobileClients = new[]
                {
                    "45964007233-vr2d10oiv0454k0kku15mfjdnnd9dqan.apps.googleusercontent.com",
                    "45964007233-jjso2nsuiq04dnqg1l7cc0bdi9he7gl0.apps.googleusercontent.com"
                };
                foreach (var mc in mobileClients) audiences.Add(mc);

                if (audiences.Count == 0)
                {
                    _logger.LogError("Google authentication error: No valid Google client IDs configured");
                    return new ExternalLoginCallbackResultDTO { Message = "Google authentication configuration error." };
                }

                var settings = new GoogleJsonWebSignature.ValidationSettings
                {
                    Audience = audiences.ToList()
                };

                var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);

                if (!string.Equals(payload.Issuer, "https://accounts.google.com", StringComparison.Ordinal) &&
                    !string.Equals(payload.Issuer, "accounts.google.com", StringComparison.Ordinal))
                {
                    _logger.LogWarning("Invalid Google token issuer: {Issuer}", payload.Issuer);
                    return new ExternalLoginCallbackResultDTO { Message = "Invalid Google token issuer." };
                }

                var email = payload.Email;
                var name = payload.Name ?? email;
                var providerKey = payload.Subject;

                var user = await _userManager.FindByLoginAsync("Google", providerKey);
                if (user != null)
                {
                    var token = await _tokenService.GenerateAccessToken(user);
                    var hasPassword = await _userManager.HasPasswordAsync(user);
                    return new ExternalLoginCallbackResultDTO
                    {
                        IsNewUser = false,
                        Email = user.Email,
                        Currency = user.Currency ?? "EGP",
                        Message = "Logged in successfully via Google",
                        Token = token,
                        HasPassword = hasPassword
                    };
                }

                var existingUser = await _userManager.FindByEmailAsync(email);
                if (existingUser != null)
                {
                    await _userManager.AddLoginAsync(existingUser, new UserLoginInfo("Google", providerKey, "Google"));
                    var existingToken = await _tokenService.GenerateAccessToken(existingUser);
                    var hasPassword = await _userManager.HasPasswordAsync(existingUser);
                    return new ExternalLoginCallbackResultDTO
                    {
                        IsNewUser = false,
                        Email = existingUser.Email,
                        Currency = existingUser.Currency ?? "EGP",
                        Message = "Linked and logged in successfully via Google",
                        Token = existingToken,
                        HasPassword = hasPassword
                    };
                }

                var newUser = new ApplicationUser
                {
                    FullName = name,
                    Email = email,
                    UserName = email,
                    EmailConfirmed = true,
                    Currency = "EGP"
                };

                var createResult = await _userManager.CreateAsync(newUser);
                if (!createResult.Succeeded)
                    return new ExternalLoginCallbackResultDTO { Message = "User creation failed" };

                await _userManager.AddToRoleAsync(newUser, Roles.User);
                await _userManager.AddLoginAsync(newUser, new UserLoginInfo("Google", providerKey, "Google"));
                await EnsureDefaultWalletAsync(newUser);

                var newToken = await _tokenService.GenerateAccessToken(newUser);
                return new ExternalLoginCallbackResultDTO
                {
                    IsNewUser = false,
                    Email = newUser.Email,
                    Currency = newUser.Currency ?? "EGP",
                    Message = "Account created and logged in successfully via Google",
                    Token = newToken,
                    HasPassword = false
                };
            }
            catch (InvalidJwtException ex)
            {
                _logger.LogError(ex, "Invalid Google idToken: {Message}", ex.Message);
                return new ExternalLoginCallbackResultDTO { Message = "Invalid Google token." };
            }
        }

        public async Task<ExternalLoginCallbackResultDTO> HandleFacebookMobileLoginAsync(string accessToken)
        {
            if (string.IsNullOrEmpty(accessToken))
                return new ExternalLoginCallbackResultDTO { Message = "Access token is required." };

            try
            {
                var appId = _configuration["Authentication:Facebook:AppId"];
                string? fbId = null;
                string? fbEmail = null;
                string? fbName = null;

                // 1. Try JWT validation if token has JWT structure
                if (accessToken.Contains('.'))
                {
                    try
                    {
                        var discoveryDocument = await _facebookConfigManager.GetConfigurationAsync();
                        var tokenHandler = new JwtSecurityTokenHandler();

                        var validationParameters = new TokenValidationParameters
                        {
                            ValidateIssuer = true,
                            ValidIssuer = "https://www.facebook.com",
                            ValidateAudience = true,
                            ValidAudience = appId,
                            ValidateLifetime = true,
                            IssuerSigningKeys = discoveryDocument.SigningKeys,
                            NameClaimType = "name",
                            RoleClaimType = "role"
                        };

                        var principal = tokenHandler.ValidateToken(accessToken, validationParameters, out var validatedToken);

                        fbId = principal.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
                               ?? principal.FindFirst("sub")?.Value;
                        fbEmail = principal.FindFirst("email")?.Value
                                  ?? principal.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;
                        fbName = principal.FindFirst("name")?.Value
                                 ?? principal.FindFirst(System.Security.Claims.ClaimTypes.Name)?.Value;
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "JWT validation failed for Facebook token, attempting Graph API fallback");
                    }
                }

                // 2. Fallback to Facebook Graph API verification for standard OAuth access tokens
                if (string.IsNullOrEmpty(fbId))
                {
                    using var httpClient = new System.Net.Http.HttpClient();

                    // Security check: Verify token was issued specifically for Mahfazti's AppId
                    if (!string.IsNullOrWhiteSpace(appId) && !appId.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase))
                    {
                        var appUrl = $"https://graph.facebook.com/app?access_token={Uri.EscapeDataString(accessToken)}";
                        var appResponse = await httpClient.GetAsync(appUrl);
                        if (!appResponse.IsSuccessStatusCode)
                        {
                            _logger.LogWarning("Facebook app introspection failed with status: {StatusCode}", appResponse.StatusCode);
                            return new ExternalLoginCallbackResultDTO { Message = "Invalid Facebook token." };
                        }

                        var appContent = await appResponse.Content.ReadAsStringAsync();
                        using var appDoc = System.Text.Json.JsonDocument.Parse(appContent);
                        if (!appDoc.RootElement.TryGetProperty("id", out var appIdProp) ||
                            !string.Equals(appIdProp.GetString(), appId, StringComparison.OrdinalIgnoreCase))
                        {
                            _logger.LogWarning("Facebook token was issued for foreign application ID");
                            return new ExternalLoginCallbackResultDTO { Message = "Facebook token does not match application." };
                        }
                    }

                    var graphUrl = $"https://graph.facebook.com/me?fields=id,name,email&access_token={Uri.EscapeDataString(accessToken)}";
                    var response = await httpClient.GetAsync(graphUrl);
                    if (response.IsSuccessStatusCode)
                    {
                        var content = await response.Content.ReadAsStringAsync();
                        using var doc = System.Text.Json.JsonDocument.Parse(content);
                        if (doc.RootElement.TryGetProperty("id", out var idProp))
                        {
                            fbId = idProp.GetString();
                        }
                        if (doc.RootElement.TryGetProperty("name", out var nameProp))
                        {
                            fbName = nameProp.GetString();
                        }
                        if (doc.RootElement.TryGetProperty("email", out var emailProp))
                        {
                            fbEmail = emailProp.GetString();
                        }
                    }
                    else
                    {
                        _logger.LogError("Facebook Graph API verification failed with status: {StatusCode}", response.StatusCode);
                    }
                }

                if (string.IsNullOrEmpty(fbId))
                    return new ExternalLoginCallbackResultDTO { Message = "Failed to retrieve Facebook user info." };

                var email = fbEmail;
                var name = fbName ?? email;
                var providerKey = fbId;

                var user = await _userManager.FindByLoginAsync("Facebook", providerKey);
                if (user != null)
                {
                    var token = await _tokenService.GenerateAccessToken(user);
                    var hasPassword = await _userManager.HasPasswordAsync(user);
                    return new ExternalLoginCallbackResultDTO
                    {
                        IsNewUser = false,
                        Email = user.Email,
                        Currency = user.Currency ?? "EGP",
                        Message = "Logged in successfully via Facebook",
                        Token = token,
                        HasPassword = hasPassword
                    };
                }

                if (!string.IsNullOrEmpty(email))
                {
                var existingUser = await _userManager.FindByEmailAsync(email!);
                    if (existingUser != null)
                    {
                        try
                        {
                            await _userManager.AddLoginAsync(existingUser, new UserLoginInfo("Facebook", providerKey, "Facebook"));
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, "Failed to link Facebook login for existing user {Email}", email);
                            return new ExternalLoginCallbackResultDTO { Message = $"Failed to link Facebook: {ex.Message}" };
                        }
                        var existingToken = await _tokenService.GenerateAccessToken(existingUser);
                        var hasPassword = await _userManager.HasPasswordAsync(existingUser);
                        return new ExternalLoginCallbackResultDTO
                        {
                            IsNewUser = false,
                            Email = existingUser.Email,
                            Currency = existingUser.Currency ?? "EGP",
                            Message = "Linked and logged in successfully via Facebook",
                            Token = existingToken,
                            HasPassword = hasPassword
                        };
                    }
                }

                var newUser = new ApplicationUser
                {
                    FullName = name ?? email ?? "Facebook User",
                    Email = email,
                    UserName = email ?? $"fb_{providerKey}",
                    EmailConfirmed = email != null,
                    Currency = "EGP"
                };

                var createResult = await _userManager.CreateAsync(newUser);
                if (!createResult.Succeeded)
                {
                    var errors = string.Join("; ", createResult.Errors.Select(e => $"{e.Code}: {e.Description}"));
                    _logger.LogError("Facebook user creation failed: {Errors}", errors);
                    return new ExternalLoginCallbackResultDTO { Message = $"User creation failed: {errors}" };
                }

                await _userManager.AddToRoleAsync(newUser, Roles.User);
                await _userManager.AddLoginAsync(newUser, new UserLoginInfo("Facebook", providerKey, "Facebook"));
                await EnsureDefaultWalletAsync(newUser);

                var newToken = await _tokenService.GenerateAccessToken(newUser);
                return new ExternalLoginCallbackResultDTO
                {
                    IsNewUser = false,
                    Email = newUser.Email,
                    Currency = newUser.Currency ?? "EGP",
                    Message = "Account created and logged in successfully via Facebook",
                    Token = newToken,
                    HasPassword = false
                };
            }
            catch (SecurityTokenException ex)
            {
                _logger.LogError(ex, "Invalid Facebook JWT token");
                return new ExternalLoginCallbackResultDTO { Message = "Invalid Facebook token." };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Facebook login error");
                return new ExternalLoginCallbackResultDTO { Message = "Facebook login failed." };
            }
        }

        private async Task EnsureDefaultWalletAsync(ApplicationUser user)
        {
            try
            {
                await _accountService.EnsureDefaultAccountAsync(
                    user.Id.ToString(),
                    user.Currency ?? "EGP",
                    user.PreferredLanguage);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not provision default wallet for external user {UserId}", user.Id);
            }
        }
    }
}
