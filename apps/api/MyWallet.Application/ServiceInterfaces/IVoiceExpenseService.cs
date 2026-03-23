using MyWallet.Application.DTOs.Wallet;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.ServiceInterfaces
{
    public interface IVoiceExpenseService
    {
        Task<VoiceExpenseResultDto> ParseVoiceTextAsync(
            string text,
            string language,
            CancellationToken cancellationToken = default);
    }
}
