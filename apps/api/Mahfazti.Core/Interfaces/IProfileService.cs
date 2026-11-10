using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Profile;

namespace Mahfazti.Core.Interfaces
{
    public interface IProfileService
    {
        Task<ProfileResponseDto> GetProfileAsync(string userId);
        Task<ProfileResponseDto> UpdateProfileAsync(string userId, UpdateProfileDto dto);
        Task<bool> ChangePasswordAsync(string userId, ChangePasswordDto dto);
        Task<bool> RegisterFcmTokenAsync(string userId, string fcmToken, string? platform = null);
        Task<string?> GetFcmTokenAsync(string userId);
        Task<ApiResponse<object>> SetUserCurrencyAsync(string userId, string currency);
        Task<ApiResponse<object>> SetUserLanguageAsync(string userId, string language);
    }
}
