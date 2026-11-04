using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.Accounts;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AccountsController : ControllerBase
    {
        private readonly IAccountService _accountService;

        public AccountsController(IAccountService accountService)
        {
            _accountService = accountService;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new UnauthorizedAccessException("User ID not found");
        }

        [HttpGet]
        public async Task<IActionResult> GetAccounts()
        {
            var userId = GetUserId();
            var accounts = await _accountService.GetAccountsAsync(userId);
            return Ok(accounts);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetAccountById(int id)
        {
            var userId = GetUserId();
            var account = await _accountService.GetAccountByIdAsync(id, userId);
            if (account == null) return NotFound(new { message = "Account not found" });
            return Ok(account);
        }

        [HttpPost]
        public async Task<IActionResult> CreateAccount([FromBody] CreateAccountDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            var result = await _accountService.CreateAccountAsync(userId, dto);
            return CreatedAtAction(nameof(GetAccountById), new { id = result.Id }, result);
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> UpdateAccount(int id, [FromBody] UpdateAccountDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            var result = await _accountService.UpdateAccountAsync(id, userId, dto);
            if (result == null) return NotFound(new { message = "Account not found" });
            return Ok(result);
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> DeleteAccount(int id)
        {
            var userId = GetUserId();
            try
            {
                var success = await _accountService.DeleteAccountAsync(id, userId);
                if (!success) return NotFound(new { message = "Account not found" });
                return Ok(new { message = "Account deleted successfully" });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { message = ex.Message });
            }
        }

        [HttpGet("wealth-summary")]
        public async Task<IActionResult> GetWealthSummary()
        {
            var userId = GetUserId();
            var summary = await _accountService.GetTotalWealthSummaryAsync(userId);
            return Ok(summary);
        }
    }
}
