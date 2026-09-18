using System.Security.Claims;
using Mahfazti.Core.Entities;

namespace Mahfazti.Core.Interfaces
{
    /// <summary>
    /// Service interface for token generation and validation operations.
    /// </summary>
    public interface ITokenService
    {
        /// <summary>
        /// Generates a JWT access token for the specified user.
        /// </summary>
        Task<string> GenerateAccessToken(ApplicationUser user);

        /// <summary>
        /// Generates a cryptographically secure refresh token.
        /// </summary>
        string GenerateRefreshToken();

        /// <summary>
        /// Extracts the principal from an expired access token.
        /// </summary>
        ClaimsPrincipal GetPrincipalFromExpiredToken(string token);
    }
}
