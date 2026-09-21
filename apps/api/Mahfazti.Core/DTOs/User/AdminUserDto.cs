using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.DTOs.User
{
    public class AdminUserDto
    {
        public string Id { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public bool EmailConfirmed { get; set; }
        public string Currency { get; set; } = "EGP";
        public string Role { get; set; } = "User";
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public int WalletsCount { get; set; } = 1;
    }

    public class CreateAdminUserDto
    {
        [Required]
        [StringLength(100, MinimumLength = 2)]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        public string Role { get; set; } = "User";

        public string Currency { get; set; } = "EGP";

        public bool EmailConfirmed { get; set; } = true;

        public string? Password { get; set; }
    }

    public class UpdateAdminUserDto
    {
        [Required]
        [StringLength(100, MinimumLength = 2)]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        public string Role { get; set; } = "User";

        public string Currency { get; set; } = "EGP";

        public bool EmailConfirmed { get; set; } = true;
    }

    public class UpdateUserRoleDto
    {
        [Required]
        public string Role { get; set; } = "User";
    }

    public class BulkUpdateUserStatusDto
    {
        public List<string> UserIds { get; set; } = new();
        public bool IsActive { get; set; }
    }

    public class BulkDeleteUsersDto
    {
        public List<string> UserIds { get; set; } = new();
    }
}
