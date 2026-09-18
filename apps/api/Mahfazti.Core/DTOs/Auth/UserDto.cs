namespace Mahfazti.Core.DTOs.Auth
{
    public class UserDTO
    {
        public string Id { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string? Currency { get; set; }
        public string? ImagePath { get; set; }
        public string? Role { get; set; }
        public bool IsLocked { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    // Alias for backward compatibility if any legacy reference exists
    public class UserDto : UserDTO
    {
    }
}
