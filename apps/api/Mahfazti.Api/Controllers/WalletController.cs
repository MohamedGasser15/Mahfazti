// Controllers/WalletController.cs
using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.Wallet;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class WalletController : ControllerBase
    {
        private readonly IWalletService _walletService;
        private readonly IVoiceExpenseService _voiceService;
        private readonly IAiFinancialService _aiService;

        public WalletController(
            IWalletService walletService,
            IVoiceExpenseService voiceService,
            IAiFinancialService aiService)
        {
            _walletService = walletService;
            _voiceService = voiceService;
            _aiService = aiService;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new UnauthorizedAccessException("User ID not found");
        }

        // GET: api/wallet/home
        [HttpGet("home")]
        public async Task<IActionResult> GetHomeData(
            [FromQuery] int? accountId = null,
            [FromQuery] DateTimeOffset? fromDate = null,
            [FromQuery] DateTimeOffset? toDate = null)
        {
            var userId = GetUserId();
            var result = await _walletService.GetHomeDataAsync(
                userId,
                accountId,
                fromDate?.UtcDateTime,
                toDate?.UtcDateTime);
            return Ok(result);
        }

        // GET: api/wallet/balance
        [HttpGet("balance")]
        public async Task<IActionResult> GetBalance([FromQuery] int? accountId = null)
        {
            var userId = GetUserId();
            var result = await _walletService.GetBalanceAsync(userId, accountId);
            return Ok(result);
        }

        // GET: api/wallet/transactions
        [HttpGet("transactions")]
        public async Task<IActionResult> GetTransactions([FromQuery] TransactionFilterDto filter)
        {
            var userId = GetUserId();
            var result = await _walletService.GetTransactionsAsync(userId, filter);
            return Ok(result);
        }

        // GET: api/wallet/transactions/{id}
        [HttpGet("transactions/{id}")]
        public async Task<IActionResult> GetTransaction(int id)
        {
            var userId = GetUserId();
            var transaction = await _walletService.GetTransactionByIdAsync(id, userId);
            if (transaction == null)
                return NotFound();
            return Ok(transaction);
        }

        // POST: api/wallet/transactions/add
        [HttpPost("transactions/add")]
        public async Task<IActionResult> AddTransaction([FromBody] AddTransactionDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            var result = await _walletService.AddTransactionAsync(userId, dto);
            return CreatedAtAction(nameof(GetTransaction), new { id = result.Id }, result);
        }

        // PUT: api/wallet/transactions/update/{id}
        [HttpPut("transactions/update/{id}")]
        public async Task<IActionResult> UpdateTransaction(int id, [FromBody] AddTransactionDto dto)
        {
            var userId = GetUserId();

            try
            {
                var result = await _walletService.UpdateTransactionAsync(id, userId, dto);
                return Ok(result);
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Transaction not found" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }

        // POST: api/wallet/transfer
        [HttpPost("transfer")]
        public async Task<IActionResult> Transfer([FromBody] TransferRequestDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            try
            {
                var result = await _walletService.TransferAsync(userId, dto);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // DELETE: api/wallet/transactions/delete/{id}
        [HttpDelete("transactions/delete/{id}")]
        public async Task<IActionResult> DeleteTransaction(int id)
        {
            var userId = GetUserId();
            var deleted = await _walletService.DeleteTransactionAsync(id, userId);
            if (!deleted)
                return NotFound();
            return NoContent();
        }

        // POST: api/wallet/voice-parse
        [HttpPost("voice-parse")]
        public async Task<IActionResult> ParseVoiceExpense([FromBody] VoiceExpenseRequestDto dto)
        {
            var userId = GetUserId();

            // Try smart AI parser first with fallback
            var aiResult = await _aiService.ParseVoiceExpenseAsync(userId, dto.Text, dto.Language);
            return Ok(new
            {
                amount = aiResult.Amount,
                transactionType = aiResult.Type,
                categoryId = aiResult.CategoryId,
                categoryName = aiResult.CategoryName,
                accountId = aiResult.AccountId,
                title = aiResult.Title,
                isSuccess = aiResult.Amount > 0 || aiResult.CategoryId.HasValue,
                confidence = aiResult.Confidence
            });
        }

        // GET: api/wallet/summary
        [HttpGet("summary")]
        public async Task<IActionResult> GetSummary(
            [FromQuery] DateTimeOffset? fromDate,
            [FromQuery] DateTimeOffset? toDate,
            [FromQuery] int? accountId = null)
        {
            var userId = GetUserId();
            var result = await _walletService.GetSummaryAsync(
                userId,
                fromDate?.UtcDateTime,
                toDate?.UtcDateTime,
                accountId);
            return Ok(result);
        }
    }
}
