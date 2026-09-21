using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.Subscription;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PlansController : ControllerBase
    {
        private readonly ISubscriptionService _subscriptionService;

        public PlansController(ISubscriptionService subscriptionService)
        {
            _subscriptionService = subscriptionService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] bool includeInactive = true)
        {
            var result = await _subscriptionService.GetAllPlansAsync(includeInactive);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var result = await _subscriptionService.GetPlanByIdAsync(id);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPost]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> Create([FromBody] CreatePricingPlanDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _subscriptionService.CreatePlanAsync(dto);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPut("reorder")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> Reorder([FromBody] ReorderPricingPlansDto dto)
        {
            if (dto == null || dto.PlanIds == null || dto.PlanIds.Count == 0)
            {
                return BadRequest("Plan IDs list cannot be empty.");
            }

            var result = await _subscriptionService.ReorderPlansAsync(dto.PlanIds);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdatePricingPlanDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _subscriptionService.UpdatePlanAsync(id, dto);
            return StatusCode((int)result.StatusCode, result);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "AdminPolicy")]
        public async Task<IActionResult> Delete(string id)
        {
            var result = await _subscriptionService.DeletePlanAsync(id);
            return StatusCode((int)result.StatusCode, result);
        }
    }
}
