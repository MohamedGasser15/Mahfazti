namespace Mahfazti.Core.DTOs.Profile
{
    public class RegisterFcmTokenDto
    {
        public string FcmToken { get; set; } = string.Empty;
        public string? Platform { get; set; }
    }
}
