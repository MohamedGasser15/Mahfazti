namespace MyWallet.Core.DTOs.Auth
{
    public class CreatePasscodeDto
    {
        public string Passcode { get; set; } = string.Empty;
        public string ConfirmPasscode { get; set; } = string.Empty;
    }
}
