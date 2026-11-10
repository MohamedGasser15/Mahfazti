using System.Globalization;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    /// <summary>
    /// Controller for handling authentication operations including login, registration, and token management.
    /// All endpoints use the unified ApiResponse{T} format.
    /// </summary>
    [Route("api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IAuthService _authService;
        private readonly IExternalLoginService _externalLoginService;
        private readonly IConfiguration _configuration;
        private readonly IWebHostEnvironment _env;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            IAuthService authService,
            IUserService userService,
            IExternalLoginService externalLoginService,
            IConfiguration configuration,
            IWebHostEnvironment env,
            ILogger<AuthController> logger)
        {
            _authService = authService ?? throw new ArgumentNullException(nameof(authService));
            _userService = userService ?? throw new ArgumentNullException(nameof(userService));
            _externalLoginService = externalLoginService ?? throw new ArgumentNullException(nameof(externalLoginService));
            _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
            _env = env ?? throw new ArgumentNullException(nameof(env));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        #region Authentication Endpoints

        /// <summary>
        /// Authenticates a user and returns access and refresh tokens.
        /// </summary>
        [HttpPost("login")]
        [EnableRateLimiting("auth-login")]
        [ProducesResponseType(typeof(ApiResponse<LoginResponseDTO>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> Login([FromBody] LoginRequestDTO model)
        {
            try
            {
                _logger.LogInformation("Login attempt for email: {Email}", model?.Email);

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var response = await _authService.Login(model!);
                if (response == null)
                {
                    return Unauthorized(ApiResponse<object>.FailResponse("البريد الإلكتروني أو كلمة المرور غير صحيحة"));
                }

                if (!string.IsNullOrEmpty(response.ErrorMessage))
                {
                    return Unauthorized(ApiResponse<object>.FailResponse(response.ErrorMessage));
                }

                _logger.LogInformation("Login successful for email: {Email}", model!.Email);
                return Ok(ApiResponse<LoginResponseDTO>.SuccessResponse(response, "Login successful"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during login");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while processing your login request."
                });
            }
        }

        /// <summary>
        /// Initiates the forgot password process.
        /// </summary>
        [HttpPost("password-reset-codes")]
        [HttpPost("forgot-password")]
        [EnableRateLimiting("auth-strict")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDTO dto)
        {
            try
            {
                _logger.LogInformation("Forgot password request for email");

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var response = await _userService.ForgotPasswordAsync(dto!.Email);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during forgot password");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while processing your request."
                });
            }
        }

        /// <summary>
        /// Initiates the forgot password process specifically for administrators.
        /// Rejects non-admin users with 403 Forbidden.
        /// </summary>
        [HttpPost("admin/forgot-password")]
        [EnableRateLimiting("auth-admin")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> AdminForgotPassword([FromBody] ForgotPasswordDTO dto)
        {
            try
            {
                _logger.LogInformation("Admin forgot password request initiated");

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var origin = Request.Headers.Origin.ToString();
                var allowedOrigins = _configuration.GetSection("AdminPortal:AllowedOrigins").Get<string[]>() ??
                    new[] { "https://mahfazti-six.vercel.app", "https://mahfazti.vercel.app", "https://admin.mahfazti.com" };

                string clientUrl = "https://mahfazti-six.vercel.app/reset-password";
                if (!string.IsNullOrWhiteSpace(origin) && Uri.TryCreate(origin, UriKind.Absolute, out var originUri))
                {
                    var isAllowed = allowedOrigins.Any(ao => Uri.TryCreate(ao, UriKind.Absolute, out var allowedUri) &&
                                                             allowedUri.Host.Equals(originUri.Host, StringComparison.OrdinalIgnoreCase) &&
                                                             (!_env.IsProduction() || originUri.Scheme == Uri.UriSchemeHttps));
                    if (isAllowed)
                    {
                        clientUrl = $"{originUri.Scheme}://{originUri.Authority}/reset-password";
                    }
                }

                var response = await _userService.AdminForgotPasswordAsync(dto!.Email, clientUrl);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during admin forgot password");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while processing your request."
                });
            }
        }

        /// <summary>
        /// Resets the administrator password using the security token sent to their email.
        /// </summary>
        [HttpPost("admin/reset-password")]
        [EnableRateLimiting("auth-admin")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> AdminResetPassword([FromBody] AdminResetPasswordDTO dto)
        {
            try
            {
                _logger.LogInformation("Admin reset password requested for email: {Email}", dto?.Email);

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var response = await _userService.AdminResetPasswordAsync(dto!);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during admin reset password");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while processing your request."
                });
            }
        }

        /// <summary>
        /// Verifies the password reset code.
        /// </summary>
        [HttpPost("password-reset-codes/verify")]
        [HttpPost("verify-reset-code")]
        [EnableRateLimiting("auth-strict")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> VerifyResetCode([FromBody] VerifyEmailDTO dto)
        {
            try
            {
                _logger.LogInformation("Reset code verification attempt");

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var response = await _userService.VerifyResetCodeAsync(dto!.Email, dto.Code);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during reset code verification");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while verifying the reset code."
                });
            }
        }

        /// <summary>
        /// Resets the user's password.
        /// </summary>
        [HttpPost("password-reset")]
        [HttpPost("reset-password")]
        [EnableRateLimiting("auth-strict")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDTO dto)
        {
            try
            {
                _logger.LogInformation("Password reset execution attempt");

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var response = await _userService.ResetPasswordAsync(dto!);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during password reset");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while resetting your password."
                });
            }
        }

        /// <summary>
        /// Refreshes an access token using a valid refresh token.
        /// </summary>
        [HttpPost("token/refresh")]
        [HttpPost("refresh")]
        [ProducesResponseType(typeof(ApiResponse<TokenResponseDTO>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequestDTO request)
        {
            try
            {
                _logger.LogInformation("Refresh token request received");

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var result = await _authService.RefreshToken(request);
                if (result == null)
                {
                    return Unauthorized(ApiResponse<object>.FailResponse("Invalid or expired refresh token"));
                }

                _logger.LogInformation("Token refresh successful");
                return Ok(ApiResponse<TokenResponseDTO>.SuccessResponse(result, "Token refreshed successfully"));
            }
            catch (SecurityTokenException ex)
            {
                _logger.LogWarning(ex, "Security token exception");
                return Unauthorized(ApiResponse<object>.FailResponse("Invalid token", new List<string> { ex.Message }));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during token refresh");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while refreshing your token."
                });
            }
        }

        /// <summary>
        /// Revokes a refresh token for the authenticated user.
        /// </summary>
        [HttpPost("revoke")]
        [Authorize]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> RevokeToken([FromBody] string refreshToken)
        {
            try
            {
                _logger.LogInformation("Revoke token request received");

                if (string.IsNullOrEmpty(refreshToken))
                {
                    return BadRequest(ApiResponse<object>.FailResponse("Refresh token is required"));
                }

                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(ApiResponse<object>.FailResponse("User not authenticated"));
                }

                await _authService.RevokeRefreshToken(userId, refreshToken);
                _logger.LogInformation("Refresh token revoked successfully for user {UserId}", userId);
                return Ok(ApiResponse<object>.SuccessResponse(new { message = "Token revoked successfully" }, "Token revoked"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during token revocation");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while revoking your token."
                });
            }
        }

        /// <summary>
        /// Logs out the user and revokes all refresh tokens.
        /// </summary>
        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var result = await _authService.LogoutAsync(userId);
            return StatusCode((int)result.StatusCode, result);
        }

        #endregion

        #region Registration Endpoints

        /// <summary>
        /// Registers a new user.
        /// </summary>
        [HttpPost("register")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> Register([FromBody] RegisterRequestDTO model)
        {
            try
            {
                _logger.LogInformation("Registration attempt for email: {Email}", model?.Email);

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var preferredLanguage = !string.IsNullOrWhiteSpace(model?.PreferredLanguage)
                    ? model.PreferredLanguage
                    : (Request.Headers.TryGetValue("Accept-Language", out var langHeader) && !string.IsNullOrWhiteSpace(langHeader)
                        ? langHeader.ToString()
                        : (CultureInfo.CurrentUICulture.Name.StartsWith("ar", StringComparison.OrdinalIgnoreCase) ? "ar" : "en"));

                var response = await _userService.Register(model!, preferredLanguage);
                if (response == null)
                {
                    return BadRequest(ApiResponse<object>.FailResponse("Registration failed"));
                }

                _logger.LogInformation("Registration successful for email: {Email}", model!.Email);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during registration");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while processing your registration."
                });
            }
        }

        #endregion

        #region Email Verification Endpoints

        /// <summary>
        /// Verifies a user's email using a verification code.
        /// </summary>
        [HttpPost("registration-codes/verify")]
        [HttpPost("verify-email")]
        [EnableRateLimiting("auth-strict")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> VerifyEmail([FromBody] VerifyEmailDTO dto)
        {
            try
            {
                _logger.LogInformation("Email verification attempt initiated");

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var response = await _userService.VerifyEmailCodeAsync(dto!.Email, dto.Code);
                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during email verification");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while verifying your email."
                });
            }
        }

        /// <summary>
        /// Sends a verification code to the specified email.
        /// </summary>
        [HttpPost("registration-codes")]
        [HttpPost("send-code")]
        [EnableRateLimiting("auth-send-code")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> SendVerificationCodeAsync([FromBody] SendCodeDTO dto)
        {
            try
            {
                _logger.LogInformation("Send verification code request initiated");

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var language = !string.IsNullOrWhiteSpace(dto?.Language)
                    ? dto.Language
                    : (Request.Headers.TryGetValue("Accept-Language", out var langHeader) && !string.IsNullOrWhiteSpace(langHeader)
                        ? langHeader.ToString()
                        : "ar");

                var response = await _userService.SendVerificationCodeAsync(dto!.Email, language);
                if (response == null)
                {
                    return StatusCode(500, ApiResponse<object>.FailResponse("حدث خطأ أثناء إرسال كود التفعيل"));
                }

                return StatusCode((int)response.StatusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error sending verification code");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while sending the verification code."
                });
            }
        }

        #endregion

        #region User Profile & Currency

        [HttpGet("check-email")]
        [EnableRateLimiting("auth-check-email")]
        public async Task<IActionResult> CheckEmail([FromQuery] string email)
        {
            try
            {
                var userExists = await _authService.CheckEmailExists(email);
                return Ok(ApiResponse<object>.SuccessResponse(new
                {
                    email,
                    exists = userExists,
                    message = userExists ? "Email is registered" : "Email is not registered"
                }));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking email status");
                return BadRequest(ApiResponse<object>.FailResponse("An error occurred while checking email status"));
            }
        }

        /// <summary>
        /// Backward-compatibility legacy alias for setting currency.
        /// Clients should migrate to PUT /api/profile/currency.
        /// </summary>
        [Authorize]
        [HttpPost("set-currency")]
        public async Task<IActionResult> SetCurrency([FromBody] SetCurrencyDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier) 
                         ?? User.FindFirstValue("sub");

            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized(ApiResponse<object>.FailResponse("المستخدم غير مسجل"));
            }

            var result = await _authService.SetUserCurrencyAsync(userId, dto.Currency);
            return StatusCode((int)result.StatusCode, result);
        }

        /// <summary>
        /// Backward-compatibility legacy alias for setting language.
        /// Clients should migrate to PUT /api/profile/language.
        /// </summary>
        [Authorize]
        [HttpPost("set-language")]
        public async Task<IActionResult> SetLanguage([FromBody] SetLanguageDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var result = await _authService.SetUserLanguageAsync(userId, dto.Language);
            return StatusCode((int)result.StatusCode, result);
        }

        #endregion

        #region External Authentication Endpoints

        /// <summary>
        /// Initiates external authentication with the specified provider.
        /// </summary>
        [HttpGet("ExternalLogin")]
        [ProducesResponseType(StatusCodes.Status302Found)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        public IActionResult ExternalLogin([FromQuery] string provider, [FromQuery] string? returnUrl = null)
        {
            try
            {
                _logger.LogInformation("External login initiated with provider: {Provider}", provider);

                if (string.IsNullOrEmpty(provider))
                {
                    return BadRequest(ApiResponse<object>.FailResponse("Provider is required"));
                }

                var redirectUrl = Url.Action(nameof(ExternalLoginCallback), "Auth", new { returnUrl }, Request.Scheme)!;
                var properties = _externalLoginService.ConfigureExternalAuthProperties(provider, redirectUrl);
                return Challenge(properties, provider);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error initiating external login");
                return BadRequest(ApiResponse<object>.FailResponse("External login failed", new List<string> { ex.Message }));
            }
        }

        /// <summary>
        /// Handles the callback from external authentication providers.
        /// </summary>
        [HttpGet("ExternalLoginCallback")]
        [ProducesResponseType(StatusCodes.Status302Found)]
        public async Task<IActionResult> ExternalLoginCallback([FromQuery] string? returnUrl = null, [FromQuery] string? remoteError = null)
        {
            try
            {
                _logger.LogInformation("External login callback received");

                var result = await _externalLoginService.HandleExternalLoginCallbackAsync(remoteError ?? "", returnUrl ?? "");
                if (!string.IsNullOrEmpty(remoteError) || result == null || string.IsNullOrEmpty(result.Email))
                {
                    return Redirect($"{returnUrl}?error=external_login_failed");
                }

                var separator = returnUrl!.Contains("?") ? "&" : "?";
                var url = $"{returnUrl}{separator}email={Uri.EscapeDataString(result.Email)}&isNewUser={result.IsNewUser.ToString().ToLower()}";
                if (!string.IsNullOrEmpty(result.Token))
                {
                    url += $"&token={Uri.EscapeDataString(result.Token)}";
                }
                return Redirect(url);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in external login callback");
                return Redirect($"{returnUrl}?error=external_login_failed");
            }
        }

        /// <summary>
        /// Confirms and completes external user registration.
        /// </summary>
        [HttpPost("ExternalLoginConfirmation")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> ExternalLoginConfirmation([FromBody] ExternalLoginConfirmationDto model)
        {
            try
            {
                _logger.LogInformation("External login confirmation for email: {Email}", model?.Email);

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var result = await _externalLoginService.ConfirmExternalUserAsync(model!);
                if (string.IsNullOrEmpty(result.Token))
                {
                    return BadRequest(ApiResponse<object>.FailResponse(
                        "External login confirmation failed",
                        new List<string> { result.Message }
                    ));
                }

                return Ok(ApiResponse<object>.SuccessResponse(new
                {
                    message = "User registered via external provider",
                    token = result.Token
                }, "External user confirmed"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in external login confirmation");
                return BadRequest(ApiResponse<object>.FailResponse("External login confirmation error", new List<string> { ex.Message }));
            }
        }

        /// <summary>
        /// Handles Google login from a mobile app by validating the Google ID token.
        /// </summary>
        [HttpPost("GoogleMobile")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GoogleMobileLogin([FromBody] GoogleMobileLoginDto dto)
        {
            try
            {
                _logger.LogInformation("Google mobile login attempt");

                if (dto == null || string.IsNullOrEmpty(dto.IdToken))
                {
                    return BadRequest(ApiResponse<object>.FailResponse("Id token is required"));
                }

                var result = await _externalLoginService.HandleGoogleMobileLoginAsync(dto.IdToken);
                if (string.IsNullOrEmpty(result.Token))
                {
                    return BadRequest(ApiResponse<object>.FailResponse(
                        "Google login failed",
                        new List<string> { result.Message ?? "Unknown error" }
                    ));
                }

                return Ok(ApiResponse<object>.SuccessResponse(new
                {
                    email = result.Email,
                    currency = result.Currency ?? "EGP",
                    isNewUser = result.IsNewUser,
                    hasPassword = result.HasPassword,
                    token = result.Token,
                    user = new
                    {
                        email = result.Email,
                        currency = result.Currency ?? "EGP"
                    }
                }, result.Message ?? "Google login successful"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in Google mobile login");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while processing Google login."
                });
            }
        }

        /// <summary>
        /// Handles Facebook login from a mobile app by validating the Facebook access token.
        /// </summary>
        [HttpPost("FacebookMobile")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> FacebookMobileLogin([FromBody] FacebookMobileLoginDto dto)
        {
            try
            {
                _logger.LogInformation("Facebook mobile login attempt");

                if (dto == null || string.IsNullOrEmpty(dto.AccessToken))
                {
                    return BadRequest(ApiResponse<object>.FailResponse("Access token is required"));
                }

                var result = await _externalLoginService.HandleFacebookMobileLoginAsync(dto.AccessToken);
                if (string.IsNullOrEmpty(result.Token))
                {
                    return BadRequest(ApiResponse<object>.FailResponse(
                        "Facebook login failed",
                        new List<string> { result.Message ?? "Unknown error" }
                    ));
                }

                return Ok(ApiResponse<object>.SuccessResponse(new
                {
                    email = result.Email,
                    currency = result.Currency ?? "EGP",
                    isNewUser = result.IsNewUser,
                    hasPassword = result.HasPassword,
                    token = result.Token,
                    user = new
                    {
                        email = result.Email,
                        currency = result.Currency ?? "EGP"
                    }
                }, result.Message ?? "Facebook login successful"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in Facebook mobile login");
                return StatusCode(500, new ProblemDetails
                {
                    Title = "Internal server error",
                    Detail = "An error occurred while processing Facebook login."
                });
            }
        }

        /// <summary>
        /// Web OAuth callback bridge for Facebook Login on mobile.
        /// Receives the OAuth redirect with the token fragment/query and redirects to the app custom URL scheme.
        /// </summary>
        [HttpGet("facebook-callback")]
        [AllowAnonymous]
        public IActionResult FacebookCallback()
        {
            var html = @"<!DOCTYPE html>
<html lang=""ar"" dir=""rtl"">
<head>
    <meta charset=""utf-8"" />
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"" />
    <title>جاري تسجيل الدخول...</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background: #f8fafc;
            color: #1e293b;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            padding: 20px;
            box-sizing: border-box;
            text-align: center;
        }
        .card {
            background: white;
            padding: 32px 24px;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.06);
            max-width: 380px;
            width: 100%;
        }
        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #e2e8f0;
            border-top: 4px solid #0284c7;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px auto;
        }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
        h2 { font-size: 20px; margin: 0 0 8px 0; }
        p { font-size: 14px; color: #64748b; margin: 0 0 20px 0; }
        .btn {
            display: inline-block;
            background: #0284c7;
            color: white;
            text-decoration: none;
            padding: 10px 20px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
        }
    </style>
    <script>
        (function() {
            var hash = window.location.hash || '';
            var search = window.location.search || '';
            var target = 'mahfazti://oauth-callback' + (hash || search);
            window.location.href = target;
            window.addEventListener('DOMContentLoaded', function() {
                var btn = document.getElementById('manual-btn');
                if (btn) btn.href = target;
            });
        })();
    </script>
</head>
<body>
    <div class=""card"">
        <div class=""spinner""></div>
        <h2>جاري العودة لتطبيق محفظتي</h2>
        <p>يرجى الانتظار، سيتم تحويلك تلقائياً...</p>
        <a id=""manual-btn"" class=""btn"" href=""mahfazti://oauth-callback"">اضغط هنا إذا لم يتم التحويل</a>
    </div>
</body>
</html>";
            return Content(html, "text/html");
        }

        #endregion
    }
}
