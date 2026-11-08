using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.Subscription;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class SubscriptionsController : ControllerBase
    {
        private readonly ISubscriptionService _subscriptionService;

        public SubscriptionsController(ISubscriptionService subscriptionService)
        {
            _subscriptionService = subscriptionService;
        }

        #region User Endpoints (In-App Purchases)

        /// <summary>
        /// Verifies and activates an in-app subscription purchase (Apple StoreKit / Google Play).
        /// </summary>
        [HttpPost("verify-iap")]
        public async Task<IActionResult> VerifyIap([FromBody] VerifyIapSubscriptionDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { message = "User not authenticated" });
            }

            var result = await _subscriptionService.VerifyIapSubscriptionAsync(userId, dto);
            return StatusCode((int)result.StatusCode, result);
        }

        /// <summary>
        /// Retrieves the active subscription for the authenticated user.
        /// </summary>
        [HttpGet("current")]
        public async Task<IActionResult> GetCurrent()
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { message = "User not authenticated" });
            }

            var result = await _subscriptionService.GetUserActiveSubscriptionAsync(userId);
            return StatusCode((int)result.StatusCode, result);
        }

        /// <summary>
        /// Cancels the active subscription for the authenticated user.
        /// </summary>
        [HttpPost("cancel")]
        public async Task<IActionResult> Cancel()
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { message = "User not authenticated" });
            }

            var result = await _subscriptionService.CancelUserSubscriptionAsync(userId);
            return StatusCode((int)result.StatusCode, result);
        }

        #endregion

        #region Admin Endpoints

        [HttpGet]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> GetSubscriptions([FromQuery] string? status, [FromQuery] string? search)
        {
            var result = await _subscriptionService.GetSubscriptionsAsync(status, search);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpGet("stats")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> GetStats()
        {
            var result = await _subscriptionService.GetSubscriptionStatsAsync();
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpGet("payments")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> GetPayments([FromQuery] string? search, [FromQuery] string? status)
        {
            var result = await _subscriptionService.GetPaymentLogsAsync(search, status);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpGet("promo-codes")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> GetPromoCodes()
        {
            var result = await _subscriptionService.GetPromoCodesAsync();
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPost("promo-codes")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> CreatePromoCode([FromBody] CreatePromoCodeDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _subscriptionService.CreatePromoCodeAsync(dto);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPut("promo-codes/{id}/toggle-status")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> TogglePromoCode(string id)
        {
            var result = await _subscriptionService.TogglePromoCodeStatusAsync(id);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpDelete("promo-codes/{id}")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> DeletePromoCode(string id)
        {
            var result = await _subscriptionService.DeletePromoCodeAsync(id);
            return StatusCode((int)result.StatusCode, result);
        }

        #endregion
    }
}
