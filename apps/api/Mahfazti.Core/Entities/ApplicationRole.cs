using Microsoft.AspNetCore.Identity;

namespace Mahfazti.Core.Entities
{
    public class ApplicationRole : IdentityRole<int>
    {
        public string? Description { get; set; }
        public bool IsDeleted { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
