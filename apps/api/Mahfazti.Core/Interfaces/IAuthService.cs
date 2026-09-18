using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Auth;

namespace Mahfazti.Core.Interfaces
{
    public interface IAuthService
    {
        Task<LoginResponseDTO?> Login(LoginRequestDTO request);
        Task<TokenResponseDTO?> RefreshToken(RefreshTokenRequestDTO request);
        Task RevokeRefreshToken(string userId, string refreshToken);
        Task<bool> CheckEmailExists(string email);
        Task<ApiResponse<object>> SetUserCurrencyAsync(string userId, string currency);
        Task<ApiResponse<object>> LogoutAsync(string userId);
    }
}
