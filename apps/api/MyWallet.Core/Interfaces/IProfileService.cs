using MyWallet.Core.DTOs.Profile;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Core.Interfaces
{
    public interface IProfileService
    {
        Task<ProfileResponseDto> GetProfileAsync(string userId);
        Task<ProfileResponseDto> UpdateProfileAsync(string userId, UpdateProfileDto dto);
        Task<bool> ChangePasswordAsync(string userId, ChangePasswordDto dto);
    }
}
