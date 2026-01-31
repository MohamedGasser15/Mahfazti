using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyWallet.Application.DTOs.Auth;
using MyWallet.Application.ServiceInterfaces;
using System.Security.Claims;

namespace MyWallet.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
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
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
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
                    message = userExists ? "البريد الإلكتروني مسجل" : "البريد الإلكتروني غير مسجل"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = "حدث خطأ", error = ex.Message });
            }
        }
    }
}
