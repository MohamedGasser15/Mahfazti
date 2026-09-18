using Microsoft.AspNetCore.Identity;

namespace Mahfazti.Core.Entities
{
    public class ApplicationUser : IdentityUser<int>
    {
        public string FullName { get; set; } = string.Empty;

        public char Gender { get; set; } = 'M';

        public bool IsDeleted { get; set; } = false;

        public string? ImagePath { get; set; }
        public string? Currency { get; set; }
    }
}
