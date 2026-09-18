using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;
using System.Security.Claims;

namespace Mahfazti.Core.Services
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ITokenService _tokenService;
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IEmailSender _emailSender;
        private readonly IEmailTemplateService _emailTemplateService;
        private readonly ILogger<AuthService> _logger;

        public AuthService(
            UserManager<ApplicationUser> userManager,
            ITokenService tokenService,
            IRefreshTokenRepository refreshTokenRepository,
            IEmailSender emailSender,
            IEmailTemplateService emailTemplateService,
            ILogger<AuthService> logger)
        {
            _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
            _tokenService = tokenService ?? throw new ArgumentNullException(nameof(tokenService));
            _refreshTokenRepository = refreshTokenRepository ?? throw new ArgumentNullException(nameof(refreshTokenRepository));
            _emailSender = emailSender ?? throw new ArgumentNullException(nameof(emailSender));
            _emailTemplateService = emailTemplateService ?? throw new ArgumentNullException(nameof(emailTemplateService));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        #region Authentication Methods

        public async Task<LoginResponseDTO?> Login(LoginRequestDTO request)
        {
            try
            {
                if (request == null)
                    throw new ArgumentNullException(nameof(request));

                _logger.LogInformation("Login attempt for email: {Email}", request.Email);

                var user = await _userManager.FindByEmailAsync(request.Email);
                if (user == null)
                {
                    _logger.LogWarning("Login failed: User with email {Email} not found", request.Email);
                    return null;
                }

                // 1. Check if user is banned
                if (user.IsBanned)
                {
                    _logger.LogWarning("Login failed: User {Email} is banned", request.Email);
                    return new LoginResponseDTO
                    {
                        IsBanned = true,
                        ErrorMessage = "تم حظر هذا الحساب من قبل الإدارة."
                    };
                }

                // 2. Check if user is locked out
                if (await _userManager.IsLockedOutAsync(user))
                {
                    var lockoutEnd = await _userManager.GetLockoutEndDateAsync(user);
                    _logger.LogWarning("Login failed: User {Email} is locked out until {LockoutEnd}", request.Email, lockoutEnd);
                    return new LoginResponseDTO
                    {
                        IsLockedOut = true,
                        ErrorMessage = $"تم قفل الحساب مؤقتاً بسبب محاولات دخول خاطئة متكررة. يرجى المحاولة بعد {lockoutEnd?.LocalDateTime}"
                    };
                }

                // 3. Check password
                var passwordCheck = await _userManager.CheckPasswordAsync(user, request.Password);
                if (!passwordCheck)
                {
                    await _userManager.AccessFailedAsync(user);

                    var failedCount = await _userManager.GetAccessFailedCountAsync(user);
                    _logger.LogWarning("Invalid password for email: {Email}. Failed attempts: {Count}", request.Email, failedCount);

                    if (await _userManager.IsLockedOutAsync(user))
                    {
                        var lockoutEnd = await _userManager.GetLockoutEndDateAsync(user);

                        try
                        {
                            var emailBody = _emailTemplateService.GenerateAccountLockoutEmail(user, lockoutEnd, user.PreferredLanguage ?? "ar");
                            await _emailSender.SendEmailAsync(
                                user.Email!,
                                _emailTemplateService.GetLocalizedText("EmailSubjectAccountLocked", user.PreferredLanguage ?? "ar"),
                                emailBody
                            );
                        }
                        catch (Exception ex)
                        {
                            _logger.LogWarning(ex, "Failed to send lockout email to {Email}", user.Email);
                        }

                        return new LoginResponseDTO
                        {
                            IsLockedOut = true,
                            ErrorMessage = "لقد تجاوزت عدد محاولات الدخول المسموح بها. تم قفل حسابك مؤقتاً."
                        };
                    }

                    return null;
                }

                // Reset failed count on successful login
                await _userManager.ResetAccessFailedCountAsync(user);

                var roles = await _userManager.GetRolesAsync(user);

                // Generate tokens
                var accessToken = await _tokenService.GenerateAccessToken(user);
                var refreshToken = _tokenService.GenerateRefreshToken();
                var refreshTokenExpiry = DateTime.UtcNow.AddDays(7);

                // Save refresh token to database
                await _refreshTokenRepository.SaveRefreshTokenAsync(user.Id.ToString(), refreshToken, refreshTokenExpiry);

                var userDto = new UserDTO
                {
                    Id = user.Id.ToString(),
                    Email = user.Email ?? "",
                    FullName = user.FullName,
                    UserName = user.UserName ?? "",
                    PhoneNumber = user.PhoneNumber ?? "",
                    Currency = user.Currency,
                    PreferredLanguage = user.PreferredLanguage,
                    ImagePath = user.ImagePath,
                    Role = roles.FirstOrDefault() ?? "User",
                    CreatedAt = user.CreatedAt
                };

                // Send login notification email asynchronously
                _ = Task.Run(async () =>
                {
                    try
                    {
                        var emailBody = _emailTemplateService.GenerateLoginEmail(
                            user, null, null, DateTime.Now, null, user.PreferredLanguage ?? "ar"
                        );
                        await _emailSender.SendEmailAsync(
                            user.Email!,
                            _emailTemplateService.GetLocalizedText("EmailSubjectLoginVerification", user.PreferredLanguage ?? "ar"),
                            emailBody
                        );
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "Failed to send login notification email to user {UserId}", user.Id);
                    }
                });

                _logger.LogInformation("User {UserId} logged in successfully", user.Id);

                return new LoginResponseDTO
                {
                    Token = accessToken,
                    RefreshToken = refreshToken,
                    RefreshTokenExpiry = refreshTokenExpiry,
                    User = userDto
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during login for email: {Email}", request?.Email);
                throw;
            }
        }

        public async Task<TokenResponseDTO?> RefreshToken(RefreshTokenRequestDTO request)
        {
            try
            {
                if (request == null)
                    throw new ArgumentNullException(nameof(request));

                _logger.LogInformation("Refresh token request received");

                var principal = _tokenService.GetPrincipalFromExpiredToken(request.AccessToken);
                var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier) ?? principal.FindFirstValue("sub");

                if (string.IsNullOrEmpty(userId))
                    throw new SecurityTokenException("Invalid token: User identifier not found");

                var isValidRefreshToken = await _refreshTokenRepository.ValidateRefreshTokenAsync(userId, request.RefreshToken);
                if (!isValidRefreshToken)
                {
                    _logger.LogWarning("Invalid refresh token for user {UserId}", userId);
                    throw new SecurityTokenException("Invalid refresh token");
                }

                var user = await _userManager.FindByIdAsync(userId);
                if (user == null)
                {
                    _logger.LogWarning("User not found during token refresh: {UserId}", userId);
                    throw new SecurityTokenException("User not found");
                }

                var newAccessToken = await _tokenService.GenerateAccessToken(user);
                var newRefreshToken = _tokenService.GenerateRefreshToken();
                var newRefreshTokenExpiry = DateTime.UtcNow.AddDays(7);

                await _refreshTokenRepository.UpdateRefreshTokenAsync(
                    userId, request.RefreshToken, newRefreshToken, newRefreshTokenExpiry);

                _logger.LogInformation("Tokens refreshed successfully for user {UserId}", userId);

                return new TokenResponseDTO
                {
                    AccessToken = newAccessToken,
                    RefreshToken = newRefreshToken,
                    RefreshTokenExpiry = newRefreshTokenExpiry
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during token refresh");
                throw;
            }
        }

        public async Task RevokeRefreshToken(string userId, string refreshToken)
        {
            try
            {
                if (string.IsNullOrEmpty(userId))
                    throw new ArgumentException("User ID cannot be null or empty.", nameof(userId));

                if (string.IsNullOrEmpty(refreshToken))
                    throw new ArgumentException("Refresh token cannot be null or empty.", nameof(refreshToken));

                _logger.LogInformation("Revoking refresh token for user {UserId}", userId);

                await _refreshTokenRepository.RevokeRefreshTokenAsync(userId, refreshToken);

                _logger.LogInformation("Refresh token revoked successfully for user {UserId}", userId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error while revoking refresh token for user {UserId}", userId);
                throw;
            }
        }

        public async Task<bool> CheckEmailExists(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            return user != null;
        }

        public async Task<ApiResponse<object>> SetUserCurrencyAsync(string userId, string currency)
        {
            try
            {
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null)
                {
                    return ApiResponse<object>.FailResponse("المستخدم غير موجود");
                }

                user.Currency = currency;
                var result = await _userManager.UpdateAsync(user);

                if (!result.Succeeded)
                {
                    return ApiResponse<object>.FailResponse(
                        "فشل تحديث العملة",
                        result.Errors.Select(e => e.Description).ToList()
                    );
                }

                return ApiResponse<object>.SuccessResponse(null, "تم تحديث العملة بنجاح");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.FailResponse("حدث خطأ أثناء تحديث العملة", new List<string> { ex.Message });
            }
        }

        public async Task<ApiResponse<object>> SetUserLanguageAsync(string userId, string language)
        {
            try
            {
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null)
                {
                    return ApiResponse<object>.FailResponse("المستخدم غير موجود");
                }

                user.PreferredLanguage = language;
                var result = await _userManager.UpdateAsync(user);

                if (!result.Succeeded)
                {
                    return ApiResponse<object>.FailResponse(
                        "فشل تحديث اللغة المفضلة",
                        result.Errors.Select(e => e.Description).ToList()
                    );
                }

                return ApiResponse<object>.SuccessResponse(null, "تم تحديث اللغة المفضلة بنجاح");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.FailResponse("حدث خطأ أثناء تحديث اللغة", new List<string> { ex.Message });
            }
        }

        public async Task<ApiResponse<object>> LogoutAsync(string userId)
        {
            try
            {
                await _refreshTokenRepository.RevokeAllRefreshTokensAsync(userId);
                return ApiResponse<object>.SuccessResponse(null, "تم تسجيل الخروج بنجاح");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.FailResponse("حدث خطأ أثناء تسجيل الخروج", new List<string> { ex.Message });
            }
        }

        #endregion
    }
}