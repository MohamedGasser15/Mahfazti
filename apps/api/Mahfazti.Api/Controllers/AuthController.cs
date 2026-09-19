using System.Globalization;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IAuthService _authService;
        private readonly IExternalLoginService _externalLoginService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            IAuthService authService,
            IUserService userService,
            IExternalLoginService externalLoginService,
            ILogger<AuthController> logger)
        {
            _authService = authService ?? throw new ArgumentNullException(nameof(authService));
            _userService = userService ?? throw new ArgumentNullException(nameof(userService));
            _externalLoginService = externalLoginService ?? throw new ArgumentNullException(nameof(externalLoginService));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        #region Authentication Endpoints

        /// <summary>
        /// Authenticates a user and returns access and refresh tokens.
        /// </summary>
        [HttpPost("Login")]
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
        [HttpPost("forgot-password")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDTO dto)
        {
            try
            {
                _logger.LogInformation("Forgot password request for email: {Email}", dto?.Email);

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
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status403Forbidden)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> AdminForgotPassword([FromBody] ForgotPasswordDTO dto)
        {
            try
            {
                _logger.LogInformation("Admin forgot password request for email: {Email}", dto?.Email);

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    return BadRequest(ApiResponse<object>.FailResponse("Validation failed", errors));
                }

                var origin = Request.Headers.Origin.ToString();
                var clientUrl = (!string.IsNullOrWhiteSpace(origin) && !origin.Contains("localhost", StringComparison.OrdinalIgnoreCase))
                    ? $"{origin.TrimEnd('/')}/reset-password"
                    : "https://mahfazti-six.vercel.app/reset-password";

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
        [HttpPost("verify-reset-code")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> VerifyResetCode([FromBody] VerifyEmailDTO dto)
        {
            try
            {
                _logger.LogInformation("Reset code verification for email: {Email}", dto?.Email);

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
        [HttpPost("reset-password")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDTO dto)
        {
            try
            {
                _logger.LogInformation("Password reset for email: {Email}", dto?.Email);

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
        [HttpPost("Register")]
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
        [HttpPost("verify-email")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> VerifyEmail([FromBody] VerifyEmailDTO dto)
        {
            try
            {
                _logger.LogInformation("Email verification attempt for email: {Email}", dto?.Email);

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
        [HttpPost("send-code")]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> SendVerificationCodeAsync([FromBody] SendCodeDTO dto)
        {
            try
            {
                _logger.LogInformation("Send verification code request for email: {Email}", dto?.Email);

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
                return BadRequest(ApiResponse<object>.FailResponse("An error occurred", new List<string> { ex.Message }));
            }
        }

        [Authorize]
        [HttpPost("set-currency")]
        public async Task<IActionResult> SetCurrency([FromBody] SetCurrencyDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var result = await _authService.SetUserCurrencyAsync(userId, dto.Currency);
            return StatusCode((int)result.StatusCode, result);
        }

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
                    isNewUser = result.IsNewUser,
                    hasPassword = result.HasPassword,
                    token = result.Token
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
                    isNewUser = result.IsNewUser,
                    hasPassword = result.HasPassword,
                    token = result.Token
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

        #endregion
    }
}
