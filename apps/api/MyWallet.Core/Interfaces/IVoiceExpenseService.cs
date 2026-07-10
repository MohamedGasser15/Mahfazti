using MyWallet.Core.DTOs.Wallet;

namespace MyWallet.Core.Interfaces
{
    public interface IVoiceExpenseService
    {
        Task<VoiceExpenseResultDto> ParseVoiceTextAsync(
            string text,
            string language,
            CancellationToken cancellationToken = default);
    }
}
