using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.Role;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Route("api/roles")]
    [Authorize(Roles = "SuperAdmin,Admin")]
    public class RolesController : ControllerBase
    {
        private readonly IRoleService _roleService;
        private readonly IAuditLogService _auditLogService;

        public RolesController(IRoleService roleService, IAuditLogService auditLogService)
        {
            _roleService = roleService ?? throw new ArgumentNullException(nameof(roleService));
            _auditLogService = auditLogService ?? throw new ArgumentNullException(nameof(auditLogService));
        }

        private (int? AdminId, string AdminName, string AdminEmail, string IpAddress) GetCurrentAdminContext()
        {
            var adminIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            int? adminId = int.TryParse(adminIdClaim, out var parsedId) ? parsedId : null;
            var adminEmail = User.FindFirstValue(ClaimTypes.Email) ?? "admin@mahfazti.app";
            var adminName = User.FindFirstValue("fullName") ?? User.FindFirstValue(ClaimTypes.Name) ?? "System Administrator";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
            return (adminId, adminName, adminEmail, ipAddress);
        }

        /// <summary>
        /// Retrieves all roles with assigned user counts and granted permission claims.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var roles = await _roleService.GetAllRolesAsync();
            return Ok(roles);
        }

        /// <summary>
        /// Retrieves detailed information for a specific role.
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var role = await _roleService.GetRoleByIdAsync(id);
            if (role == null) return NotFound(new { message = "Role not found." });
            return Ok(role);
        }

        /// <summary>
        /// Retrieves all available system permission definitions grouped by module.
        /// </summary>
        [HttpGet("permissions")]
        public IActionResult GetPermissions()
        {
            var permissions = _roleService.GetAvailablePermissions();
            return Ok(permissions);
        }

        /// <summary>
        /// Creates a new custom role with assigned permissions.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateRoleDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                var created = await _roleService.CreateRoleAsync(dto);

                var ctx = GetCurrentAdminContext();
                await _auditLogService.LogAsync(
                    action: "Created Security Role",
                    targetResource: $"Roles / {created.Name}",
                    category: "Security",
                    adminId: ctx.AdminId,
                    adminName: ctx.AdminName,
                    adminEmail: ctx.AdminEmail,
                    ipAddress: ctx.IpAddress,
                    status: "Success",
                    details: $"Created custom role '{created.Name}' with {created.Permissions.Count} granted permission(s)");

                return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Updates an existing role's name, description, and permission claims.
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateRoleDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                var updated = await _roleService.UpdateRoleAsync(id, dto);

                var ctx = GetCurrentAdminContext();
                await _auditLogService.LogAsync(
                    action: "Updated Security Role",
                    targetResource: $"Roles / {updated.Name}",
                    category: "Security",
                    adminId: ctx.AdminId,
                    adminName: ctx.AdminName,
                    adminEmail: ctx.AdminEmail,
                    ipAddress: ctx.IpAddress,
                    status: "Success",
                    details: $"Updated permissions and details for role '{updated.Name}' ({updated.Permissions.Count} active permissions)");

                return Ok(updated);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Deletes a custom role if no users are currently assigned to it. System default roles cannot be deleted.
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var existing = await _roleService.GetRoleByIdAsync(id);
                var roleName = existing?.Name ?? $"ID #{id}";

                var success = await _roleService.DeleteRoleAsync(id);
                if (!success) return BadRequest(new { message = "Failed to delete role." });

                var ctx = GetCurrentAdminContext();
                await _auditLogService.LogAsync(
                    action: "Deleted Security Role",
                    targetResource: $"Roles / {roleName}",
                    category: "Security",
                    adminId: ctx.AdminId,
                    adminName: ctx.AdminName,
                    adminEmail: ctx.AdminEmail,
                    ipAddress: ctx.IpAddress,
                    status: "Warning",
                    details: $"Deleted custom role '{roleName}'");

                return NoContent();
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
