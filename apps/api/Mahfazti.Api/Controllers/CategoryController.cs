using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.Category;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class CategoryController : ControllerBase
    {
        private readonly ICategoryService _categoryService;

        public CategoryController(ICategoryService categoryService)
        {
            _categoryService = categoryService;
        }

        private string? GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var userId = GetUserId();
            var categories = await _categoryService.GetAllCategoriesAsync(userId);
            return Ok(categories);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var userId = GetUserId();
            var category = await _categoryService.GetCategoryByIdAsync(id, userId);
            if (category == null) return NotFound();
            return Ok(category);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateCategoryDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var userId = GetUserId();
            var created = await _categoryService.CreateCategoryAsync(dto, userId);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateCategoryDto dto)
        {
            if (id != dto.Id) return BadRequest("ID mismatch");
            var userId = GetUserId();
            var updated = await _categoryService.UpdateCategoryAsync(dto, userId);
            if (updated == null) return NotFound();
            return Ok(updated);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var userId = GetUserId();
            var deleted = await _categoryService.DeleteCategoryAsync(id, userId);
            if (!deleted) return NotFound();
            return NoContent();
        }

        [HttpPost("{id}/restore")]
        public async Task<IActionResult> Restore(int id)
        {
            var userId = GetUserId();
            var restored = await _categoryService.RestoreCategoryAsync(id, userId);
            if (!restored) return NotFound();
            return Ok(new { success = true, message = "Category restored successfully" });
        }

        [HttpPost("bulk-delete")]
        public async Task<IActionResult> BulkDelete([FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any()) return BadRequest("No category IDs provided");
            var userId = GetUserId();
            var result = await _categoryService.BulkDeleteCategoriesAsync(ids, userId);
            return Ok(result);
        }

        [HttpPost("bulk-restore")]
        public async Task<IActionResult> BulkRestore([FromBody] List<int> ids)
        {
            if (ids == null || !ids.Any()) return BadRequest("No category IDs provided");
            var userId = GetUserId();
            var count = await _categoryService.BulkRestoreCategoriesAsync(ids, userId);
            return Ok(new { success = true, restoredCount = count, message = $"Successfully restored {count} categories" });
        }

        /// <summary>Returns the top N categories used most by the current user.</summary>
        [HttpGet("most-used")]
        public async Task<IActionResult> GetMostUsed([FromQuery] int limit = 5)
        {
            var userId = GetUserId();
            if (string.IsNullOrEmpty(userId)) return Unauthorized();
            var categories = await _categoryService.GetMostUsedCategoriesAsync(userId, limit);
            return Ok(categories);
        }
    }
}
