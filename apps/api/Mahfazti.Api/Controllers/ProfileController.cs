using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.DTOs.Profile;
using Mahfazti.Core.Interfaces;
using System.Security.Claims;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/profile")]
    public class ProfileController : ControllerBase
    {
        private readonly IProfileService _profileService;

        public ProfileController(IProfileService profileService)
        {
            _profileService = profileService;
        }

        [HttpGet("get")]
        public async Task<IActionResult> GetProfile()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var result = await _profileService.GetProfileAsync(userId);
            return Ok(result);
        }

        [HttpPut("update")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var result = await _profileService.UpdateProfileAsync(userId, dto);
            return Ok(result);
        }

        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var result = await _profileService.ChangePasswordAsync(userId, dto);
            return Ok(result);
        }

        [HttpPost("fcm-token")]
        public async Task<IActionResult> RegisterFcmToken([FromBody] RegisterFcmTokenDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized(new { success = false, message = "User not authenticated" });
            }

            if (dto == null || string.IsNullOrWhiteSpace(dto.FcmToken))
            {
                return BadRequest(new { success = false, message = "FCM token is required" });
            }

            var success = await _profileService.RegisterFcmTokenAsync(userId, dto.FcmToken, dto.Platform);
            return Ok(new { success, message = success ? "FCM token registered successfully" : "Failed to register FCM token" });
        }

        /// <summary>
        /// Updates the authenticated user's preferred currency.
        /// </summary>
        [HttpPut("currency")]
        public async Task<IActionResult> SetCurrency([FromBody] SetCurrencyDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
                         ?? User.FindFirstValue("sub");

            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized(ApiResponse<object>.FailResponse("المستخدم غير مسجل"));
            }

            if (dto == null || string.IsNullOrWhiteSpace(dto.Currency))
            {
                return BadRequest(ApiResponse<object>.FailResponse("Currency is required"));
            }

            var result = await _profileService.SetUserCurrencyAsync(userId, dto.Currency);
            return StatusCode((int)result.StatusCode, result);
        }

        /// <summary>
        /// Updates the authenticated user's preferred language.
        /// </summary>
        [HttpPut("language")]
        public async Task<IActionResult> SetLanguage([FromBody] SetLanguageDto dto)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
                         ?? User.FindFirstValue("sub");

            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized(ApiResponse<object>.FailResponse("المستخدم غير مسجل"));
            }

            if (dto == null || string.IsNullOrWhiteSpace(dto.Language))
            {
                return BadRequest(ApiResponse<object>.FailResponse("Language is required"));
            }

            var result = await _profileService.SetUserLanguageAsync(userId, dto.Language);
            return StatusCode((int)result.StatusCode, result);
        }
    }
}
