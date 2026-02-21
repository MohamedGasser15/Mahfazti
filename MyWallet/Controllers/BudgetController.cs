using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyWallet.Application.DTOs.Budget;
using MyWallet.Application.ServiceInterfaces;
using System.Security.Claims;

namespace MyWallet.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BudgetController : ControllerBase
    {
        private readonly IBudgetService _budgetService;

        public BudgetController(IBudgetService budgetService)
        {
            _budgetService = budgetService;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new UnauthorizedAccessException("User ID not found");
        }

        [HttpGet]
        public async Task<IActionResult> GetBudget()
        {
            var userId = GetUserId();
            var result = await _budgetService.GetBudgetAsync(userId);
            return Ok(result);
        }

        [HttpPut]
        public async Task<IActionResult> UpdateMonthlyBudget([FromBody] UpdateMonthlyBudgetDto dto)
        {
            var userId = GetUserId();
            await _budgetService.UpdateMonthlyBudgetAsync(userId, dto.MonthlyBudget);
            return NoContent();
        }
    }
}
