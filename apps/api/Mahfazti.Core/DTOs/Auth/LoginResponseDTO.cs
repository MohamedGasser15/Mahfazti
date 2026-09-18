namespace Mahfazti.Core.DTOs.Auth
{
    public class LoginResponseDTO
    {
        public UserDTO? User { get; set; }
        public string Token { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
        public DateTime RefreshTokenExpiry { get; set; }
        public string? ErrorMessage { get; set; }
        public bool IsLockedOut { get; set; }
        public bool IsBanned { get; set; }
    }
}
