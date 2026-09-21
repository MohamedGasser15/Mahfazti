using System.Threading.Tasks;
using Mahfazti.Core.DTOs.AuditLog;
using Mahfazti.Core.DTOs.Common;

namespace Mahfazti.Core.Interfaces
{
    public interface IAuditLogService
    {
        Task LogAsync(
            string action,
            string targetResource,
            string category,
            int? adminId = null,
            string? adminName = null,
            string? adminEmail = null,
            string? ipAddress = null,
            string status = "Success",
            string? details = null);

        Task<PagedResult<AuditLogDto>> GetLogsAsync(AuditLogFilterDto filter);

        Task<AuditLogStatsDto> GetStatsAsync();
    }
}
