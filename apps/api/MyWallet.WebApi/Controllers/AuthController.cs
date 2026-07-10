using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyWallet.Core.DTOs.Auth;
using MyWallet.Core.Interfaces;
using System.Security.Claims;

namespace MyWallet.WebApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IExternalLoginService _externalLoginService;

        public AuthController(
            IAuthService authService,
            IExternalLoginService externalLoginService)
        {
            _authService = authService;
            _externalLoginService = externalLoginService;
        }

        [HttpPost("send-verification")]
        public async Task<IActionResult> SendVerification([FromBody] SendVerificationDto dto)
        {
            var result = await _authService.SendVerificationAsync(dto);

            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("verify-code")]
        public async Task<IActionResult> VerifyCode([FromBody] VerifyCodeDto dto)
        {
            var result = await _authService.VerifyCodeAsync(dto);

            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("resend-code")]
        public async Task<IActionResult> ResendCode([FromBody] SendVerificationDto dto)
        {
            var result = await _authService.ResendVerificationCodeAsync(dto);

            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("verify-complete")]
        public async Task<IActionResult> VerifyAndComplete([FromBody] VerifyAndCompleteDto dto)
        {
            var result = await _authService.VerifyAndCompleteAsync(dto);

            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var result = await _authService.LogoutAsync(userId);

            return Ok(result);
        }

        [HttpGet("check-email")]
        public async Task<IActionResult> CheckEmail([FromQuery] string email)
        {
            try
            {
                var userExists = await _authService.CheckEmailExists(email);

                return Ok(new
                {
                    email,
                    exists = userExists,
                    message = userExists ? "Email is registered" : "Email is not registered"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = "An error occurred", error = ex.Message });
            }
        }

        [Authorize]
        [HttpPost("set-currency")]
        public async Task<IActionResult> SetCurrency([FromBody] SetCurrencyDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var result = await _authService.SetUserCurrencyAsync(userId, dto.Currency);

            if (!result.Success)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("recovery/check-user")]
        public async Task<IActionResult> CheckUser([FromBody] CheckUserDto dto)
        {
            var result = await _authService.CheckUserExistsAsync(dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("recovery/verify-password")]
        public async Task<IActionResult> VerifyPasswordForRecovery([FromBody] VerifyPasswordForRecoveryDto dto)
        {
            var result = await _authService.VerifyPasswordForRecoveryAsync(dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("recovery/request-email-change")]
        public async Task<IActionResult> RequestEmailChange([FromBody] RequestEmailChangeDto dto)
        {
            var result = await _authService.RequestEmailChangeAsync(dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("recovery/confirm-email-change")]
        public async Task<IActionResult> ConfirmEmailChange([FromBody] ConfirmEmailChangeDto dto)
        {
            var result = await _authService.ConfirmEmailChangeAsync(dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }
        [HttpPost("passcode/forgot")]
        public async Task<IActionResult> ForgotPasscode([FromBody] ForgotPasscodeRequestDto dto)
        {
            var result = await _authService.SendPasscodeResetOtpAsync(dto.Email);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpPost("passcode/reset")]
        public async Task<IActionResult> ResetPasscode([FromBody] ResetPasscodeDto dto)
        {
            var result = await _authService.ResetPasscodeAsync(dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        [HttpGet("ExternalLogin")]
        public IActionResult ExternalLogin([FromQuery] string provider, [FromQuery] string? returnUrl = null)
        {
            var redirectUrl = Url.Action(nameof(ExternalLoginCallback), "Auth", new { returnUrl }, Request.Scheme)!;
            var properties = _externalLoginService.ConfigureExternalAuthProperties(provider, redirectUrl!);
            return Challenge(properties, provider);
        }

        [HttpGet("ExternalLoginCallback")]
        public async Task<IActionResult> ExternalLoginCallback([FromQuery] string? returnUrl = null, [FromQuery] string? remoteError = null)
        {
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

        [HttpPost("ExternalLoginConfirmation")]
        public async Task<IActionResult> ExternalLoginConfirmation([FromBody] ExternalLoginConfirmationDto model)
        {
            var result = await _externalLoginService.ConfirmExternalUserAsync(model);
            if (string.IsNullOrEmpty(result.Token))
            {
                return BadRequest(new { success = false, message = result.Message });
            }

            return Ok(new { success = true, message = "User registered via external provider", token = result.Token });
        }

        [HttpPost("GoogleMobile")]
        public async Task<IActionResult> GoogleMobileLogin([FromBody] GoogleMobileLoginDto dto)
        {
            var result = await _externalLoginService.HandleGoogleMobileLoginAsync(dto.IdToken);
            if (result.Token != null)
                return Ok(result);
            return BadRequest(result);
        }

        [HttpPost("FacebookMobile")]
        public async Task<IActionResult> FacebookMobileLogin([FromBody] FacebookMobileLoginDto dto)
        {
            var result = await _externalLoginService.HandleFacebookMobileLoginAsync(dto.AccessToken);
            return Ok(new {
                success = result.Token != null,
                message = result.Message ?? "",
                token = result.Token,
                email = result.Email,
                isNewUser = result.IsNewUser,
                needsRegistration = result.Token == null && !string.IsNullOrEmpty(result.Email)
            });
        }
    }
}
