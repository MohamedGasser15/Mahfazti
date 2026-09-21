using System;

namespace Mahfazti.Core.Entities
{
    /// <summary>
    /// Represents an immutable audit trail entry tracking administrator activities, security events, and operations.
    /// </summary>
    public class AuditLog
    {
        public int Id { get; set; }

        public int? AdminId { get; set; }
        public string AdminName { get; set; } = string.Empty;
        public string AdminEmail { get; set; } = string.Empty;

        public string Action { get; set; } = string.Empty;
        public string TargetResource { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty; // "User Management", "Security", "Billing & Pricing", "System"

        public string? IpAddress { get; set; }
        public string Status { get; set; } = "Success"; // "Success", "Warning", "Failed"

        public string? Details { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation property to ApplicationUser (set null on delete so audit trails remain intact)
        public ApplicationUser? Admin { get; set; }
    }
}
