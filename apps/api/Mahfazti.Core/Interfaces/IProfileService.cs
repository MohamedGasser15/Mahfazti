using Mahfazti.Core.DTOs.Profile;

namespace Mahfazti.Core.Interfaces
{
    public interface IProfileService
    {
        Task<ProfileResponseDto> GetProfileAsync(string userId);
        Task<ProfileResponseDto> UpdateProfileAsync(string userId, UpdateProfileDto dto);
        Task<bool> ChangePasswordAsync(string userId, ChangePasswordDto dto);
    }
}
