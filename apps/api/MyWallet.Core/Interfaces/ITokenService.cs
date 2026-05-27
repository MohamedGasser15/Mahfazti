using MyWallet.Core.Entities;

namespace MyWallet.Core.Interfaces
{
    public interface ITokenService
    {
        Task<string> GenerateAccessToken(ApplicationUser user);
    }
}
