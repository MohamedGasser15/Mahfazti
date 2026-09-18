using Microsoft.AspNetCore.Identity;

namespace Mahfazti.Core.Entities
{
    public class ApplicationUser : IdentityUser<int>
    {
        public string FullName { get; set; } = string.Empty;

        public char Gender { get; set; } = 'M';

        public bool IsDeleted { get; set; } = false;

        public bool IsBanned { get; set; } = false;

        public string? PreferredLanguage { get; set; } = "ar";

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public string? ImagePath { get; set; }
        public string? Currency { get; set; }

        public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    }
}
