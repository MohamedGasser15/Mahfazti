using System;

namespace Mahfazti.Core.DTOs.AuditLog
{
    public class AuditLogDto
    {
        public int Id { get; set; }
        public int? AdminId { get; set; }
        public string AdminName { get; set; } = string.Empty;
        public string AdminEmail { get; set; } = string.Empty;
        public string Action { get; set; } = string.Empty;
        public string TargetResource { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string? IpAddress { get; set; }
        public string Status { get; set; } = "Success";
        public string? Details { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
