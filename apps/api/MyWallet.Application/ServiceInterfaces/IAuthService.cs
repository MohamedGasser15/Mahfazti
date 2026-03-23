using MyWallet.Application.DTOs.Auth;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.ServiceInterfaces
{
    public interface IAuthService
    {
        Task<AuthResponseDto> SendVerificationAsync(SendVerificationDto dto);
        Task<AuthResponseDto> VerifyAndCompleteAsync(VerifyAndCompleteDto dto);
        Task<AuthResponseDto> LogoutAsync(string userId);
        Task<bool> CheckEmailExists(string email);
        Task<AuthResponseDto> ResendVerificationCodeAsync(SendVerificationDto dto);
        Task<AuthResponseDto> VerifyCodeAsync(VerifyCodeDto dto);
        Task<AuthResponseDto> SetUserCurrencyAsync(string userId, string currency);
    }
}
