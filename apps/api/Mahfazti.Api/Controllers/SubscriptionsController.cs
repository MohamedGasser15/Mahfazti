using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.Subscription;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Policy = "AdminPolicy")]
    public class SubscriptionsController : ControllerBase
    {
        private readonly ISubscriptionService _subscriptionService;

        public SubscriptionsController(ISubscriptionService subscriptionService)
        {
            _subscriptionService = subscriptionService;
        }

        #region User Subscriptions

        [HttpGet]
        public async Task<IActionResult> GetSubscriptions([FromQuery] string? status, [FromQuery] string? search)
        {
            var result = await _subscriptionService.GetSubscriptionsAsync(status, search);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpGet("stats")]
        public async Task<IActionResult> GetStats()
        {
            var result = await _subscriptionService.GetSubscriptionStatsAsync();
            return StatusCode((int)result.StatusCode, result);
        }

        #endregion

        #region Payment Logs

        [HttpGet("payments")]
        public async Task<IActionResult> GetPayments([FromQuery] string? search, [FromQuery] string? status)
        {
            var result = await _subscriptionService.GetPaymentLogsAsync(search, status);
            return StatusCode((int)result.StatusCode, result);
        }

        #endregion

        #region Promo Codes

        [HttpGet("promo-codes")]
        public async Task<IActionResult> GetPromoCodes()
        {
            var result = await _subscriptionService.GetPromoCodesAsync();
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPost("promo-codes")]
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
        public async Task<IActionResult> TogglePromoCode(string id)
        {
            var result = await _subscriptionService.TogglePromoCodeStatusAsync(id);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpDelete("promo-codes/{id}")]
        public async Task<IActionResult> DeletePromoCode(string id)
        {
            var result = await _subscriptionService.DeletePromoCodeAsync(id);
            return StatusCode((int)result.StatusCode, result);
        }

        #endregion
    }
}
