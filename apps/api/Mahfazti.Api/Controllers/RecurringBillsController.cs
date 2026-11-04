using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.RecurringBills;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/recurring-bills")]
    public class RecurringBillsController : ControllerBase
    {
        private readonly IRecurringBillService _billService;

        public RecurringBillsController(IRecurringBillService billService)
        {
            _billService = billService;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new UnauthorizedAccessException("User ID not found");
        }

        [HttpGet]
        public async Task<IActionResult> GetBills()
        {
            var userId = GetUserId();
            var bills = await _billService.GetBillsAsync(userId);
            return Ok(bills);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetBillById(int id)
        {
            var userId = GetUserId();
            var bill = await _billService.GetBillByIdAsync(id, userId);
            if (bill == null) return NotFound(new { message = "Bill not found" });
            return Ok(bill);
        }

        [HttpPost]
        public async Task<IActionResult> CreateBill([FromBody] CreateRecurringBillDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            var bill = await _billService.CreateBillAsync(userId, dto);
            return CreatedAtAction(nameof(GetBillById), new { id = bill.Id }, bill);
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> UpdateBill(int id, [FromBody] UpdateRecurringBillDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            var bill = await _billService.UpdateBillAsync(id, userId, dto);
            if (bill == null) return NotFound(new { message = "Bill not found" });
            return Ok(bill);
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> DeleteBill(int id)
        {
            var userId = GetUserId();
            var success = await _billService.DeleteBillAsync(id, userId);
            if (!success) return NotFound(new { message = "Bill not found" });
            return Ok(new { message = "Bill deleted successfully" });
        }

        [HttpPost("{id:int}/pay")]
        public async Task<IActionResult> MarkBillPaid(int id)
        {
            var userId = GetUserId();
            var success = await _billService.MarkBillPaidAsync(id, userId);
            if (!success) return BadRequest(new { message = "Could not record payment for bill" });
            return Ok(new { message = "Bill payment recorded successfully" });
        }
    }
}
