namespace MyWallet.Core.DTOs.Auth
{
    public class FacebookMobileLoginDto
    {
        public string AccessToken { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? DisplayName { get; set; }
    }
}
