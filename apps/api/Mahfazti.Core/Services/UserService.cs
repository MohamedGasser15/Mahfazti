using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Mahfazti.Core.Common;
using Mahfazti.Core.Constants;
using Mahfazti.Core.DTOs.Auth;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class UserService : IUserService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly RoleManager<ApplicationRole> _roleManager;
        private readonly IMemoryCache _cache;
        private readonly IEmailSender _emailSender;
        private readonly IEmailTemplateService _emailTemplateService;
        private readonly ILogger<UserService> _logger;

        public UserService(
            UserManager<ApplicationUser> userManager,
            RoleManager<ApplicationRole> roleManager,
            IMemoryCache cache,
            IEmailSender emailSender,
            IEmailTemplateService emailTemplateService,
            ILogger<UserService> logger)
        {
            _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
            _roleManager = roleManager ?? throw new ArgumentNullException(nameof(roleManager));
            _cache = cache ?? throw new ArgumentNullException(nameof(cache));
            _emailSender = emailSender ?? throw new ArgumentNullException(nameof(emailSender));
            _emailTemplateService = emailTemplateService ?? throw new ArgumentNullException(nameof(emailTemplateService));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task<ApiResponse<object>> ForgotPasswordAsync(string email)
        {
            try
            {
                _logger.LogInformation("Forgot password request for email: {Email}", email);

                var user = await _userManager.FindByEmailAsync(email);
                if (user == null)
                {
                    // For security reasons, do not reveal whether the email exists
                    _logger.LogWarning("Forgot password attempt for non-existent email: {Email}", email);
                    return ApiResponse<object>.SuccessResponse(
                        new object(),
                        "إذا كان البريد الإلكتروني مسجلاً لدينا، فسيتم إرسال رمز التحقق"
                    );
                }

                var resetCode = GenerateRandomCode();
                _cache.Set($"passwordReset:{email}", resetCode, TimeSpan.FromMinutes(10));

                var emailBody = _emailTemplateService.GeneratePasswordResetEmail(resetCode, user.PreferredLanguage ?? "ar");
                await _emailSender.SendEmailAsync(
                    email,
                    _emailTemplateService.GetLocalizedText("EmailSubjectPasswordReset", user.PreferredLanguage ?? "ar"),
                    emailBody
                );

                _logger.LogInformation("Password reset code sent to email: {Email}", email);
                return ApiResponse<object>.SuccessResponse(
                    new object(),
                    "إذا كان البريد الإلكتروني مسجلاً لدينا، فسيتم إرسال رمز التحقق"
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing forgot password for: {Email}", email);
                return ApiResponse<object>.FailResponse(
                    "حدث خطأ أثناء معالجة طلبك",
                    new List<string> { ex.Message }
                );
            }
        }

        public async Task<ApiResponse<object>> VerifyResetCodeAsync(string email, string code)
        {
            try
            {
                _logger.LogInformation("Password reset code verification for email: {Email}", email);

                if (!_cache.TryGetValue($"passwordReset:{email}", out string? cachedCode))
                {
                    return ApiResponse<object>.FailResponse(
                        "انتهت صلاحية الكود أو غير موجود",
                        new List<string> { "Invalid or expired code" }
                    );
                }

                if (cachedCode != code)
                {
                    return ApiResponse<object>.FailResponse(
                        "الكود غير صحيح",
                        new List<string> { "Code mismatch" }
                    );
                }

                _cache.Set($"passwordResetVerified:{email}", true, TimeSpan.FromMinutes(10));
                _cache.Remove($"passwordReset:{email}");

                return ApiResponse<object>.SuccessResponse(new object(), "تم التحقق من الكود بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying password reset code for: {Email}", email);
                return ApiResponse<object>.FailResponse(
                    "حدث خطأ أثناء التحقق من الكود",
                    new List<string> { ex.Message }
                );
            }
        }

        public async Task<ApiResponse<object>> ResetPasswordAsync(ResetPasswordDTO dto)
        {
            try
            {
                _logger.LogInformation("Password reset attempt for email: {Email}", dto.Email);

                if (!_cache.TryGetValue($"passwordResetVerified:{dto.Email}", out _))
                {
                    return ApiResponse<object>.FailResponse(
                        "يجب التحقق من الكود أولاً",
                        new List<string> { "Code not verified" }
                    );
                }

                var user = await _userManager.FindByEmailAsync(dto.Email);
                if (user == null)
                {
                    return ApiResponse<object>.FailResponse(
                        "المستخدم غير موجود",
                        new List<string> { "User not found" }
                    );
                }

                var resetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
                var result = await _userManager.ResetPasswordAsync(user, resetToken, dto.NewPassword);

                if (result.Succeeded)
                {
                    _cache.Remove($"passwordResetVerified:{dto.Email}");

                    var emailBody = _emailTemplateService.GeneratePasswordResetConfirmationEmail(user.PreferredLanguage ?? "ar");
                    await _emailSender.SendEmailAsync(
                        dto.Email,
                        _emailTemplateService.GetLocalizedText("EmailSubjectPasswordChanged", user.PreferredLanguage ?? "ar"),
                        emailBody
                    );

                    _logger.LogInformation("Password reset successful for email: {Email}", dto.Email);
                    return ApiResponse<object>.SuccessResponse(new object(), "تم تغيير كلمة المرور بنجاح");
                }

                var errors = result.Errors.Select(e => e.Description).ToList();
                _logger.LogWarning("Password reset failed for email {Email}: {Errors}", dto.Email, string.Join(", ", errors));
                return ApiResponse<object>.FailResponse("فشل تغيير كلمة المرور", errors);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error resetting password for: {Email}", dto.Email);
                return ApiResponse<object>.FailResponse(
                    "حدث خطأ أثناء إعادة تعيين كلمة المرور",
                    new List<string> { ex.Message }
                );
            }
        }

        public async Task<ApiResponse<object>> SendVerificationCodeAsync(string email, string language = "ar")
        {
            try
            {
                if (await IsEmailExistsAsync(email))
                {
                    return ApiResponse<object>.FailResponse(
                        "هذا البريد الإلكتروني مستخدم مسبقاً",
                        new List<string> { "Email already exists" }
                    );
                }

                var code = GenerateRandomCode();
                _cache.Set($"verify:{email}", code, TimeSpan.FromMinutes(10));

                var emailBody = _emailTemplateService.GenerateVerificationEmail(code, language);
                await _emailSender.SendEmailAsync(
                    email,
                    _emailTemplateService.GetLocalizedText("EmailSubjectVerificationCode", language),
                    emailBody
                );

                return ApiResponse<object>.SuccessResponse(new object(), "تم إرسال كود التفعيل إلى بريدك الإلكتروني");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending verification code to: {Email}", email);
                return ApiResponse<object>.FailResponse(
                    "حدث خطأ غير متوقع أثناء إرسال كود التحقق",
                    new List<string> { ex.Message }
                );
            }
        }

        public async Task<ApiResponse<object>> VerifyEmailCodeAsync(string email, string code)
        {
            try
            {
                if (!_cache.TryGetValue($"verify:{email}", out string? cachedCode))
                {
                    return ApiResponse<object>.FailResponse(
                        "انتهت صلاحية الكود أو غير موجود",
                        new List<string> { "Code expired" }
                    );
                }

                if (cachedCode != code)
                {
                    return ApiResponse<object>.FailResponse(
                        "الكود غير صحيح",
                        new List<string> { "Invalid code" }
                    );
                }

                _cache.Set($"emailConfirmed:{email}", true, TimeSpan.FromMinutes(30));
                _cache.Remove($"verify:{email}");

                return ApiResponse<object>.SuccessResponse(new object(), "تم تأكيد البريد الإلكتروني بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying email code for: {Email}", email);
                return ApiResponse<object>.FailResponse(
                    "حدث خطأ غير متوقع أثناء التحقق من الكود",
                    new List<string> { ex.Message }
                );
            }
        }

        public async Task<ApiResponse<object>> Register(RegisterRequestDTO request, string? preferredLanguage = null)
        {
            try
            {
                if (!_cache.TryGetValue($"emailConfirmed:{request.Email}", out _))
                {
                    return ApiResponse<object>.FailResponse(
                        "يجب تأكيد البريد الإلكتروني أولاً قبل التسجيل.",
                        new List<string> { "Email not confirmed" }
                    );
                }

                if (await IsEmailExistsAsync(request.Email))
                {
                    return ApiResponse<object>.FailResponse(
                        "هذا البريد الإلكتروني مستخدم مسبقاً",
                        new List<string> { "Duplicate email" }
                    );
                }

                var user = new ApplicationUser
                {
                    UserName = request.Email,
                    Email = request.Email,
                    FullName = request.FullName,
                    EmailConfirmed = true,
                    PreferredLanguage = preferredLanguage ?? request.PreferredLanguage ?? "ar",
                    CreatedAt = DateTime.UtcNow
                };

                var result = await CreateUserAsync(user, request.Password);
                if (!result.Succeeded)
                {
                    return ApiResponse<object>.FailResponse(
                        "فشل إنشاء المستخدم",
                        result.Errors.Select(e => e.Description).ToList()
                    );
                }

                _cache.Remove($"emailConfirmed:{request.Email}");

                var userDto = new UserDTO
                {
                    Id = user.Id.ToString(),
                    Email = user.Email ?? "",
                    FullName = user.FullName,
                    UserName = user.UserName ?? "",
                    PhoneNumber = user.PhoneNumber ?? "",
                    Currency = user.Currency,
                    PreferredLanguage = user.PreferredLanguage,
                    Role = Roles.User,
                    CreatedAt = user.CreatedAt
                };

                return ApiResponse<object>.SuccessResponse(userDto, "Registration successful");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error registering user: {Email}", request.Email);
                return ApiResponse<object>.FailResponse(
                    "حدث خطأ غير متوقع أثناء التسجيل",
                    new List<string> { ex.Message }
                );
            }
        }

        public async Task<UserDTO?> GetUserByIdAsync(string id)
        {
            try
            {
                if (!int.TryParse(id, out int parsedId))
                    return null;

                var user = await _userManager.FindByIdAsync(id);
                if (user == null) return null;

                var roles = await _userManager.GetRolesAsync(user);

                return new UserDTO
                {
                    Id = user.Id.ToString(),
                    FullName = user.FullName,
                    Email = user.Email ?? "",
                    PhoneNumber = user.PhoneNumber ?? "",
                    Currency = user.Currency,
                    PreferredLanguage = user.PreferredLanguage,
                    ImagePath = user.ImagePath,
                    Role = roles.FirstOrDefault() ?? Roles.User,
                    IsLocked = await _userManager.IsLockedOutAsync(user),
                    CreatedAt = user.CreatedAt
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user by id: {UserId}", id);
                return null;
            }
        }

        #region Helper Methods

        private async Task<IdentityResult> CreateUserAsync(ApplicationUser user, string password)
        {
            try
            {
                var rolesToCreate = new[] { Roles.Admin, Roles.User };
                foreach (var role in rolesToCreate)
                {
                    if (!await _roleManager.RoleExistsAsync(role))
                    {
                        await _roleManager.CreateAsync(new ApplicationRole { Name = role });
                    }
                }

                var result = await _userManager.CreateAsync(user, password);
                if (!result.Succeeded) return result;

                await _userManager.AddToRoleAsync(user, Roles.User);
                return IdentityResult.Success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating user: {Email}", user.Email);
                return IdentityResult.Failed(new IdentityError
                {
                    Description = "حدث خطأ غير متوقع أثناء إنشاء المستخدم"
                });
            }
        }

        private async Task<bool> IsEmailExistsAsync(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            return user != null;
        }

        private async Task<bool> IsFullNameExistsAsync(string fullName)
        {
            try
            {
                if (_userManager.Users == null) return false;
                var user = await _userManager.Users
                    .AsNoTracking()
                    .FirstOrDefaultAsync(u => u.FullName == fullName);
                return user != null;
            }
            catch
            {
                return false;
            }
        }

        private static string GenerateRandomCode() => new Random().Next(100000, 999999).ToString();

        #endregion
    }
}
