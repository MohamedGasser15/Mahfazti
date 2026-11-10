using Microsoft.AspNetCore.Identity;
using Mahfazti.Core.Common;
using Mahfazti.Core.DTOs.Profile;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Entities;

namespace Mahfazti.Core.Services
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
                FullName = user.FullName ?? "",
                UserName = user.UserName ?? "",
                Email = user.Email ?? "",
                PhoneNumber = user.PhoneNumber ?? "",
                PreferredLanguage = user.PreferredLanguage,
                ImagePath = user.ImagePath
            };
        }

        public async Task<ProfileResponseDto> UpdateProfileAsync(string userId, UpdateProfileDto dto)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) throw new Exception("User not found");

            if (!string.IsNullOrWhiteSpace(dto.FullName))
                user.FullName = dto.FullName;
            if (!string.IsNullOrWhiteSpace(dto.UserName))
                user.UserName = dto.UserName;
            if (!string.IsNullOrWhiteSpace(dto.PhoneNumber))
                user.PhoneNumber = dto.PhoneNumber;
            if (!string.IsNullOrWhiteSpace(dto.PreferredLanguage))
                user.PreferredLanguage = dto.PreferredLanguage;

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

        public async Task<bool> RegisterFcmTokenAsync(string userId, string fcmToken, string? platform = null)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return false;

            var result = await _userManager.SetAuthenticationTokenAsync(user, "Firebase", "FcmToken", fcmToken);
            if (platform != null)
            {
                await _userManager.SetAuthenticationTokenAsync(user, "Firebase", "Platform", platform);
            }
            return result.Succeeded;
        }

        public async Task<string?> GetFcmTokenAsync(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null) return null;

            return await _userManager.GetAuthenticationTokenAsync(user, "Firebase", "FcmToken");
        }

        public async Task<ApiResponse<object>> SetUserCurrencyAsync(string userId, string currency)
        {
            try
            {
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null)
                {
                    return ApiResponse<object>.FailResponse("المستخدم غير موجود");
                }

                user.Currency = currency;
                var result = await _userManager.UpdateAsync(user);

                if (!result.Succeeded)
                {
                    return ApiResponse<object>.FailResponse(
                        "فشل تحديث العملة",
                        result.Errors.Select(e => e.Description).ToList()
                    );
                }

                return ApiResponse<object>.SuccessResponse(new object(), "تم تحديث العملة بنجاح");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.FailResponse("حدث خطأ أثناء تحديث العملة", new List<string> { ex.Message });
            }
        }

        public async Task<ApiResponse<object>> SetUserLanguageAsync(string userId, string language)
        {
            try
            {
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null)
                {
                    return ApiResponse<object>.FailResponse("المستخدم غير موجود");
                }

                user.PreferredLanguage = language;
                var result = await _userManager.UpdateAsync(user);

                if (!result.Succeeded)
                {
                    return ApiResponse<object>.FailResponse(
                        "فشل تحديث اللغة المفضلة",
                        result.Errors.Select(e => e.Description).ToList()
                    );
                }

                return ApiResponse<object>.SuccessResponse(new object(), "تم تحديث اللغة المفضلة بنجاح");
            }
            catch (Exception ex)
            {
                return ApiResponse<object>.FailResponse("حدث خطأ أثناء تحديث اللغة المفضلة", new List<string> { ex.Message });
            }
        }
    }
}
