using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Auth;

namespace Mahfazti.Core.Interfaces
{
    public interface IUserService
    {
        Task<ApiResponse<object>> Register(RegisterRequestDTO request, string? preferredLanguage = null);
        Task<ApiResponse<object>> SendVerificationCodeAsync(string email, string language = "ar");
        Task<ApiResponse<object>> VerifyEmailCodeAsync(string email, string code);
        Task<ApiResponse<object>> ForgotPasswordAsync(string email);
        Task<ApiResponse<object>> VerifyResetCodeAsync(string email, string code);
        Task<ApiResponse<object>> ResetPasswordAsync(ResetPasswordDTO dto);
        Task<UserDTO?> GetUserByIdAsync(string id);
    }
}
