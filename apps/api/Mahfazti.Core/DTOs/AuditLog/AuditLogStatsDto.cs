namespace Mahfazti.Core.DTOs.AuditLog
{
    public class AuditLogStatsDto
    {
        public int TotalLogs { get; set; }
        public int UserManagementCount { get; set; }
        public int SecurityCount { get; set; }
        public int WarningsAndFailuresCount { get; set; }
    }
}
