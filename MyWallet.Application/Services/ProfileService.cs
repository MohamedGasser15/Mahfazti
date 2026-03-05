using Microsoft.AspNetCore.Identity;
using MyWallet.Application.DTOs.Profile;
using MyWallet.Application.ServiceInterfaces;
using MyWallet.Infrastructure.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.Services
{
    public class ProfileService : IProfileService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        public ProfileService(UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
        }
        public async Task<ProfileResponseDto> GetProfileAsync(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) throw new Exception("User not found");

            return new ProfileResponseDto
            {
                FullName = user.FullName,
                UserName = user.UserName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                ImagePath = user.ImagePath
            };
        }

        public async Task<ProfileResponseDto> UpdateProfileAsync(string userId, UpdateProfileDto dto)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) throw new Exception("User not found");

            user.FullName = dto.FullName;
            user.UserName = dto.UserName;
            user.PhoneNumber = dto.PhoneNumber;
            // تحديث الصورة لو موجودة

            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded)
                throw new Exception(string.Join(", ", result.Errors.Select(e => e.Description)));

            return await GetProfileAsync(userId);
        }

        public async Task<bool> ChangePasswordAsync(string userId, ChangePasswordDto dto)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) throw new Exception("User not found");

            var result = await _userManager.ChangePasswordAsync(user, dto.CurrentPassword, dto.NewPassword);
            return result.Succeeded;
        }
    }
}
