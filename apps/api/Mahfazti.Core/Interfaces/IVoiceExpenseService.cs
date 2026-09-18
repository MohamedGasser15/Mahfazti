using Mahfazti.Core.DTOs.Wallet;

namespace Mahfazti.Core.Interfaces
{
    public interface IVoiceExpenseService
    {
        Task<VoiceExpenseResultDto> ParseVoiceTextAsync(
            string text,
            string language,
            CancellationToken cancellationToken = default);
    }
}
