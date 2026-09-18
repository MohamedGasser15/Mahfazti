using Mahfazti.Core.Entities;

namespace Mahfazti.Core.Interfaces
{
    public interface ITokenService
    {
        Task<string> GenerateAccessToken(ApplicationUser user);
    }
}
