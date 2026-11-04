using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.CategoryGroups;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/category-groups")]
    public class CategoryGroupsController : ControllerBase
    {
        private readonly ICategoryGroupService _groupService;

        public CategoryGroupsController(ICategoryGroupService groupService)
        {
            _groupService = groupService;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new UnauthorizedAccessException("User ID not found");
        }

        [HttpGet]
        public async Task<IActionResult> GetGroups()
        {
            var userId = GetUserId();
            var groups = await _groupService.GetGroupsAsync(userId);
            return Ok(groups);
        }

        [HttpPost]
        public async Task<IActionResult> CreateGroup([FromBody] CreateCategoryGroupDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            var group = await _groupService.CreateGroupAsync(userId, dto);
            return Ok(group);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateGroup(string id, [FromBody] UpdateCategoryGroupDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            var group = await _groupService.UpdateGroupAsync(id, userId, dto);
            if (group == null) return NotFound(new { message = "Category group not found" });
            return Ok(group);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteGroup(string id)
        {
            var userId = GetUserId();
            var success = await _groupService.DeleteGroupAsync(id, userId);
            if (!success) return NotFound(new { message = "Category group not found" });
            return Ok(new { message = "Category group deleted successfully" });
        }

        [HttpPost("assign")]
        public async Task<IActionResult> AssignCategory([FromBody] AssignCategoryGroupDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var userId = GetUserId();
            var success = await _groupService.AssignCategoryToGroupAsync(userId, dto);
            if (!success) return BadRequest(new { message = "Could not assign category to group" });
            return Ok(new { message = "Category assigned successfully" });
        }

        [HttpGet("mappings")]
        public async Task<IActionResult> GetMappings()
        {
            var userId = GetUserId();
            var mappings = await _groupService.GetCategoryGroupMappingsAsync(userId);
            return Ok(mappings);
        }
    }
}
