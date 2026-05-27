namespace MyWallet.Core.DTOs.Auth
{
    public class ExternalLoginCallbackResultDTO
    {
        public bool IsNewUser { get; set; }
        public string? Email { get; set; }
        public string? ReturnUrl { get; set; }
        public string? Message { get; set; }
        public string? Token { get; set; }
    }
}
