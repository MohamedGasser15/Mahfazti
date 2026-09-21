using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.AuditLog;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [ApiController]
    [Route("api/audit-logs")]
    [Authorize(Roles = "SuperAdmin,Admin")]
    public class AuditLogsController : ControllerBase
    {
        private readonly IAuditLogService _auditLogService;

        public AuditLogsController(IAuditLogService auditLogService)
        {
            _auditLogService = auditLogService ?? throw new ArgumentNullException(nameof(auditLogService));
        }

        /// <summary>
        /// Retrieves paginated audit logs with optional search, category, and status filters.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetLogs([FromQuery] AuditLogFilterDto filter)
        {
            var result = await _auditLogService.GetLogsAsync(filter);
            return Ok(result);
        }

        /// <summary>
        /// Retrieves high-level audit and security activity statistics.
        /// </summary>
        [HttpGet("stats")]
        public async Task<IActionResult> GetStats()
        {
            var stats = await _auditLogService.GetStatsAsync();
            return Ok(stats);
        }
    }
}
