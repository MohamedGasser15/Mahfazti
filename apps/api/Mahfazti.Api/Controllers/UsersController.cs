using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using Mahfazti.Core.DTOs.User;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "SuperAdmin,Admin")]
    public class UsersController : ControllerBase
    {
        private readonly IAdminUserService _adminUserService;
        private readonly IAuditLogService _auditLogService;

        public UsersController(IAdminUserService adminUserService, IAuditLogService auditLogService)
        {
            _adminUserService = adminUserService;
            _auditLogService = auditLogService;
        }

        private (int? AdminId, string AdminName, string AdminEmail, string IpAddress) GetCurrentAdminContext()
        {
            var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            int? adminId = int.TryParse(idClaim, out var id) ? id : null;
            var adminName = User.FindFirstValue(ClaimTypes.Name) ?? "Administrator";
            var adminEmail = User.FindFirstValue(ClaimTypes.Email) ?? "admin@mahfazti.app";
            var ipAddress = HttpContext?.Connection?.RemoteIpAddress?.ToString() ?? "127.0.0.1";
            return (adminId, adminName, adminEmail, ipAddress);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var users = await _adminUserService.GetAllUsersAsync();
            return Ok(users);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var user = await _adminUserService.GetUserByIdAsync(id);
            if (user == null) return NotFound();
            return Ok(user);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateAdminUserDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                var created = await _adminUserService.CreateUserAsync(dto);

                var ctx = GetCurrentAdminContext();
                await _auditLogService.LogAsync(
                    action: "Created User Account",
                    targetResource: $"Users / {created.Email}",
                    category: "User Management",
                    adminId: ctx.AdminId,
                    adminName: ctx.AdminName,
                    adminEmail: ctx.AdminEmail,
                    ipAddress: ctx.IpAddress,
                    status: "Success",
                    details: $"Role: {created.Role}, Full Name: {created.FullName}");

                return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
            }
            catch (InvalidOperationException ex)
            {
                var ctx = GetCurrentAdminContext();
                await _auditLogService.LogAsync(
                    action: "Failed User Creation",
                    targetResource: $"Users / {dto.Email}",
                    category: "User Management",
                    adminId: ctx.AdminId,
                    adminName: ctx.AdminName,
                    adminEmail: ctx.AdminEmail,
                    ipAddress: ctx.IpAddress,
                    status: "Failed",
                    details: ex.Message);

                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateAdminUserDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                var updated = await _adminUserService.UpdateUserAsync(id, dto);
                if (updated == null) return NotFound();

                var ctx = GetCurrentAdminContext();
                await _auditLogService.LogAsync(
                    action: "Updated User Details",
                    targetResource: $"Users / {updated.Email}",
                    category: "User Management",
                    adminId: ctx.AdminId,
                    adminName: ctx.AdminName,
                    adminEmail: ctx.AdminEmail,
                    ipAddress: ctx.IpAddress,
                    status: "Success",
                    details: $"Updated profile info for {updated.FullName}");

                return Ok(updated);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> ToggleStatus(int id)
        {
            try
            {
                var updated = await _adminUserService.ToggleUserStatusAsync(id);
                if (updated == null) return NotFound();

                var ctx = GetCurrentAdminContext();
                await _auditLogService.LogAsync(
                    action: updated.IsActive ? "Activated User Account" : "Suspended User Account",
                    targetResource: $"Users / {updated.Email}",
                    category: "User Management",
                    adminId: ctx.AdminId,
                    adminName: ctx.AdminName,
                    adminEmail: ctx.AdminEmail,
                    ipAddress: ctx.IpAddress,
                    status: updated.IsActive ? "Success" : "Warning");

                return Ok(updated);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}/role")]
        public async Task<IActionResult> UpdateRole(int id, [FromBody] UpdateUserRoleDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Role))
                return BadRequest("Role is required");

            var updated = await _adminUserService.UpdateUserRoleAsync(id, dto.Role);
            if (updated == null) return NotFound();

            var ctx = GetCurrentAdminContext();
            await _auditLogService.LogAsync(
                action: $"Changed User Role to {dto.Role}",
                targetResource: $"Users / {updated.Email}",
                category: "Security",
                adminId: ctx.AdminId,
                adminName: ctx.AdminName,
                adminEmail: ctx.AdminEmail,
                ipAddress: ctx.IpAddress,
                status: "Success");

            return Ok(updated);
        }

        [HttpPost("bulk-status")]
        public async Task<IActionResult> BulkUpdateStatus([FromBody] BulkUpdateUserStatusDto dto)
        {
            if (dto.UserIds == null || !dto.UserIds.Any())
                return BadRequest("No user IDs provided");

            var intIds = dto.UserIds
                .Select(s => int.TryParse(s.Replace("u-", ""), out var i) ? i : (int?)null)
                .Where(i => i.HasValue)
                .Select(i => i!.Value)
                .ToList();

            var count = await _adminUserService.BulkUpdateUserStatusAsync(intIds, dto.IsActive);

            var ctx = GetCurrentAdminContext();
            await _auditLogService.LogAsync(
                action: dto.IsActive ? $"Bulk Activated ({count}) Users" : $"Bulk Suspended ({count}) Users",
                targetResource: $"Users ({count} users)",
                category: "User Management",
                adminId: ctx.AdminId,
                adminName: ctx.AdminName,
                adminEmail: ctx.AdminEmail,
                ipAddress: ctx.IpAddress,
                status: dto.IsActive ? "Success" : "Warning");

            return Ok(new { success = true, updatedCount = count, message = $"Successfully updated {count} users" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var currentUserIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            int? currentUserId = int.TryParse(currentUserIdClaim, out var parsedId) ? parsedId : null;

            if (currentUserId.HasValue && currentUserId.Value == id)
            {
                return BadRequest(new { message = "لا يمكنك حذف حسابك الخاص (You cannot delete your own account)" });
            }

            try
            {
                var deleted = await _adminUserService.DeleteUserAsync(id, currentUserId);
                if (!deleted) return NotFound();

                var ctx = GetCurrentAdminContext();
                await _auditLogService.LogAsync(
                    action: "Permanently Deleted User",
                    targetResource: $"Users / ID #{id}",
                    category: "User Management",
                    adminId: ctx.AdminId,
                    adminName: ctx.AdminName,
                    adminEmail: ctx.AdminEmail,
                    ipAddress: ctx.IpAddress,
                    status: "Warning",
                    details: "Hard cascading deletion of user account, wallets, transactions, and budgets");

                return NoContent();
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("bulk-delete")]
        public async Task<IActionResult> BulkDelete([FromBody] BulkDeleteUsersDto dto)
        {
            if (dto.UserIds == null || !dto.UserIds.Any())
                return BadRequest("No user IDs provided");

            var currentUserIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            int? currentUserId = int.TryParse(currentUserIdClaim, out var parsedId) ? parsedId : null;

            var intIds = dto.UserIds
                .Select(s => int.TryParse(s.Replace("u-", ""), out var i) ? i : (int?)null)
                .Where(i => i.HasValue)
                .Select(i => i!.Value)
                .ToList();

            var count = await _adminUserService.BulkDeleteUsersAsync(intIds, currentUserId);

            var ctx = GetCurrentAdminContext();
            await _auditLogService.LogAsync(
                action: $"Bulk Deleted ({count}) Users Permanently",
                targetResource: $"Users ({count} users)",
                category: "User Management",
                adminId: ctx.AdminId,
                adminName: ctx.AdminName,
                adminEmail: ctx.AdminEmail,
                ipAddress: ctx.IpAddress,
                status: "Warning",
                details: $"Hard cascading deletion of {count} users and all their associated financial records");

            return Ok(new { success = true, deletedCount = count, message = $"Successfully deleted {count} users" });
        }
    }
}
