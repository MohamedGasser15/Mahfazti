namespace MyWallet.Core.DTOs.Profile
{
    public class ProfileResponseDto
    {
        public string FullName { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string? ImagePath { get; set; }
    }
}
