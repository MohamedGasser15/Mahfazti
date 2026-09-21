using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Mahfazti.Core.DTOs.AuditLog;
using Mahfazti.Core.DTOs.Common;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class AuditLogService : IAuditLogService
    {
        private readonly IRepository<AuditLog> _auditLogRepository;
        private readonly ILogger<AuditLogService> _logger;

        public AuditLogService(
            IRepository<AuditLog> auditLogRepository,
            ILogger<AuditLogService> logger)
        {
            _auditLogRepository = auditLogRepository ?? throw new ArgumentNullException(nameof(auditLogRepository));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task LogAsync(
            string action,
            string targetResource,
            string category,
            int? adminId = null,
            string? adminName = null,
            string? adminEmail = null,
            string? ipAddress = null,
            string status = "Success",
            string? details = null)
        {
            try
            {
                var entry = new AuditLog
                {
                    AdminId = adminId,
                    AdminName = string.IsNullOrWhiteSpace(adminName) ? "System Administrator" : adminName,
                    AdminEmail = string.IsNullOrWhiteSpace(adminEmail) ? "admin@mahfazti.app" : adminEmail,
                    Action = action,
                    TargetResource = targetResource,
                    Category = string.IsNullOrWhiteSpace(category) ? "System" : category,
                    IpAddress = string.IsNullOrWhiteSpace(ipAddress) ? "127.0.0.1" : ipAddress,
                    Status = status,
                    Details = details,
                    CreatedAt = DateTime.UtcNow
                };

                await _auditLogRepository.CreateAsync(entry);
                await _auditLogRepository.SaveAsync();

                _logger.LogInformation("AuditLog recorded: {Action} on {TargetResource} by {AdminEmail}", action, targetResource, entry.AdminEmail);
            }
            catch (Exception ex)
            {
                // Never allow logging failures to break the primary operational flow
                _logger.LogError(ex, "Failed to record audit log: {Action} on {TargetResource}", action, targetResource);
            }
        }

        public async Task<PagedResult<AuditLogDto>> GetLogsAsync(AuditLogFilterDto filter)
        {
            var page = filter.Page > 0 ? filter.Page : 1;
            var pageSize = filter.PageSize > 0 ? filter.PageSize : 10;

            var allLogs = await _auditLogRepository.GetAllAsync(
                orderBy: q => q.OrderByDescending(l => l.CreatedAt)
            );

            var query = allLogs.AsQueryable();

            if (!string.IsNullOrWhiteSpace(filter.Category) && !filter.Category.Equals("all", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(l => l.Category.Equals(filter.Category, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(filter.Status) && !filter.Status.Equals("all", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(l => l.Status.Equals(filter.Status, StringComparison.OrdinalIgnoreCase));
            }

            if (!string.IsNullOrWhiteSpace(filter.SearchTerm))
            {
                var term = filter.SearchTerm.Trim().ToLower();
                query = query.Where(l =>
                    (l.Action != null && l.Action.ToLower().Contains(term)) ||
                    (l.TargetResource != null && l.TargetResource.ToLower().Contains(term)) ||
                    (l.AdminName != null && l.AdminName.ToLower().Contains(term)) ||
                    (l.AdminEmail != null && l.AdminEmail.ToLower().Contains(term)) ||
                    (l.IpAddress != null && l.IpAddress.ToLower().Contains(term)) ||
                    (l.Category != null && l.Category.ToLower().Contains(term))
                );
            }

            var totalCount = query.Count();
            var items = query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(l => new AuditLogDto
                {
                    Id = l.Id,
                    AdminId = l.AdminId,
                    AdminName = l.AdminName,
                    AdminEmail = l.AdminEmail,
                    Action = l.Action,
                    TargetResource = l.TargetResource,
                    Category = l.Category,
                    IpAddress = l.IpAddress,
                    Status = l.Status,
                    Details = l.Details,
                    CreatedAt = l.CreatedAt
                })
                .ToList();

            return new PagedResult<AuditLogDto>
            {
                Items = items,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        public async Task<AuditLogStatsDto> GetStatsAsync()
        {
            var logs = await _auditLogRepository.GetAllAsync();

            return new AuditLogStatsDto
            {
                TotalLogs = logs.Count,
                UserManagementCount = logs.Count(l => l.Category.Equals("User Management", StringComparison.OrdinalIgnoreCase)),
                SecurityCount = logs.Count(l => l.Category.Equals("Security", StringComparison.OrdinalIgnoreCase)),
                WarningsAndFailuresCount = logs.Count(l => !l.Status.Equals("Success", StringComparison.OrdinalIgnoreCase))
            };
        }
    }
}
