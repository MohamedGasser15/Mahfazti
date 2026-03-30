// Controllers/WalletController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyWallet.Application.DTOs.Wallet;
using MyWallet.Application.ServiceInterfaces;
using System.Security.Claims;
using System.Threading.Tasks;

namespace MyWallet.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class WalletController : ControllerBase
    {
        private readonly IWalletService _walletService;
        private readonly IVoiceExpenseService _voiceService;

        public WalletController(IWalletService walletService, IVoiceExpenseService voiceService)
        {
            _walletService = walletService;
            _voiceService = voiceService;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new UnauthorizedAccessException("User ID not found");
        }

        // GET: api/wallet/home
        [HttpGet("home")]
        public async Task<IActionResult> GetHomeData()
        {
            var userId = GetUserId();
            var result = await _walletService.GetHomeDataAsync(userId);
            return Ok(result);
        }

        // GET: api/wallet/balance
        [HttpGet("balance")]
        public async Task<IActionResult> GetBalance()
        {
            var userId = GetUserId();
            var result = await _walletService.GetBalanceAsync(userId);
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
                return NotFound();
            }
            catch (Exception ex)
            {
                // optional logging
                return StatusCode(500, "Something went wrong");
            }
        }
        // POST: api/wallet/transactions/add
        [HttpPost("transactions/add")]
        public async Task<IActionResult> AddTransaction([FromBody] AddTransactionDto dto)
        {
            var userId = GetUserId();
            var result = await _walletService.AddTransactionAsync(userId, dto);
            return CreatedAtAction(nameof(GetTransaction), new { id = result.Id }, result);
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
        [HttpPost("voice-parse")]
        public async Task<IActionResult> ParseVoiceExpense(
    [FromBody] VoiceExpenseRequestDto dto,
    [FromServices] IVoiceExpenseService voiceService)
        {
            var result = await _voiceService.ParseVoiceTextAsync(dto.Text, dto.Language);
            return Ok(result);
        }
        // GET: api/wallet/summary
        [HttpGet("summary")]
        public async Task<IActionResult> GetSummary([FromQuery] DateTime? fromDate, [FromQuery] DateTime? toDate)
        {
            var userId = GetUserId();
            var result = await _walletService.GetSummaryAsync(userId, fromDate, toDate);
            return Ok(result);
        }
    }
}