using System;
using System.IO;
using System.Security.Claims;
using System.Threading.Tasks;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Payment;
using Mahfazti.Core.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentsController : ControllerBase
    {
        private readonly IStripePaymentService _stripeService;

        public PaymentsController(IStripePaymentService stripeService)
        {
            _stripeService = stripeService;
        }

        /// <summary>
        /// Retrieves the public Stripe configuration (Publishable Key) for Mobile and Frontend SDK initialization.
        /// </summary>
        [HttpGet("stripe/config")]
        [AllowAnonymous]
        public async Task<IActionResult> GetStripeConfig()
        {
            var result = await _stripeService.GetConfigAsync();
            return Ok(result);
        }

        /// <summary>
        /// Creates a Stripe Mobile SDK PaymentSheet session (PaymentIntent, EphemeralKey, CustomerId) for the authenticated user.
        /// </summary>
        [HttpPost("stripe/create-payment-intent")]
        [Authorize]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] StripePaymentIntentRequestDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<StripePaymentSheetResponseDto>.FailResponse("Invalid input data."));
            }

            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(ApiResponse<StripePaymentSheetResponseDto>.FailResponse("Unauthorized user session."));
            }

            var result = await _stripeService.CreatePaymentSheetIntentAsync(userId, dto);
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }

        /// <summary>
        /// Confirms and activates a user's subscription immediately after successful completion of the Stripe mobile PaymentSheet.
        /// </summary>
        [HttpPost("stripe/confirm-payment")]
        [Authorize]
        public async Task<IActionResult> ConfirmPayment([FromBody] StripeConfirmPaymentDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<bool>.FailResponse("Invalid input data."));
            }

            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(ApiResponse<bool>.FailResponse("Unauthorized user session."));
            }

            var result = await _stripeService.ConfirmPaymentAsync(userId, dto);
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }

        /// <summary>
        /// Asynchronous webhook endpoint called directly by Stripe servers upon payment completion or subscription events.
        /// </summary>
        [HttpPost("stripe/webhook")]
        [AllowAnonymous]
        public async Task<IActionResult> StripeWebhook()
        {
            string json;
            using (var reader = new StreamReader(HttpContext.Request.Body))
            {
                json = await reader.ReadToEndAsync();
            }

            var stripeSignature = Request.Headers["Stripe-Signature"];
            var result = await _stripeService.HandleWebhookAsync(json, stripeSignature);

            if (!result.Success)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }
    }
}
