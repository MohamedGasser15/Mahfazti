using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using System.Security.Cryptography;
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
        private readonly IMemoryCache? _cache;
        private readonly IPasswordResetStore _passwordResetStore;
        private readonly IEmailSender _emailSender;
        private readonly IEmailTemplateService _emailTemplateService;
        private readonly ILogger<UserService> _logger;
        private readonly IAccountService _accountService;
        private readonly IEmailVerificationStore _emailVerificationStore;

        public UserService(
            UserManager<ApplicationUser> userManager,
            RoleManager<ApplicationRole> roleManager,
            IPasswordResetStore passwordResetStore,
            IEmailSender emailSender,
            IEmailTemplateService emailTemplateService,
            IAccountService accountService,
            IEmailVerificationStore emailVerificationStore,
            ILogger<UserService> logger,
            IMemoryCache? cache = null)
        {
            _userManager = userManager ?? throw new ArgumentNullException(nameof(userManager));
            _roleManager = roleManager ?? throw new ArgumentNullException(nameof(roleManager));
            _passwordResetStore = passwordResetStore ?? throw new ArgumentNullException(nameof(passwordResetStore));
            _emailSender = emailSender ?? throw new ArgumentNullException(nameof(emailSender));
            _emailTemplateService = emailTemplateService ?? throw new ArgumentNullException(nameof(emailTemplateService));
            _accountService = accountService ?? throw new ArgumentNullException(nameof(accountService));
            _emailVerificationStore = emailVerificationStore ?? throw new ArgumentNullException(nameof(emailVerificationStore));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _cache = cache;
        }

        public async Task<ApiResponse<object>> ForgotPasswordAsync(string email)
        {
            try
            {
                _logger.LogInformation("Forgot password request initiated");

                if (!await _passwordResetStore.CanSendCodeAsync(email, TimeSpan.FromSeconds(60)))
                {
                    return ApiResponse<object>.SuccessResponse(
                        new object(),
                        "إذا كان البريد الإلكتروني مسجلاً لدينا، فسيتم إرسال رمز التحقق"
                    );
                }

                var user = await _userManager.FindByEmailAsync(email);
                if (user == null)
                {
                    // For security reasons, do not reveal whether the email exists
                    _logger.LogWarning("Forgot password attempt for non-existent email");
                    return ApiResponse<object>.SuccessResponse(
                        new object(),
                        "إذا كان البريد الإلكتروني مسجلاً لدينا، فسيتم إرسال رمز التحقق"
                    );
                }

                var resetCode = GenerateRandomCode();
                await _passwordResetStore.SaveResetCodeAsync(email, resetCode);

                var emailBody = _emailTemplateService.GeneratePasswordResetEmail(resetCode, user.PreferredLanguage ?? "ar");
                await _emailSender.SendEmailAsync(
                    email,
                    _emailTemplateService.GetLocalizedText("EmailSubjectPasswordReset", user.PreferredLanguage ?? "ar"),
                    emailBody
                );

                _logger.LogInformation("Password reset code sent to email");
                return ApiResponse<object>.SuccessResponse(
                    new object(),
                    "إذا كان البريد الإلكتروني مسجلاً لدينا، فسيتم إرسال رمز التحقق"
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing forgot password request");
                return ApiResponse<object>.FailResponse("حدث خطأ أثناء معالجة طلبك");
            }
        }

        public async Task<ApiResponse<object>> AdminForgotPasswordAsync(string email, string? clientUrl = null)
        {
            try
            {
                _logger.LogInformation("Admin forgot password request for email: {Email}", email);

                var user = await _userManager.FindByEmailAsync(email);
                if (user == null)
                {
                    var failRes = ApiResponse<object>.FailResponse(
                        "هذا البريد الإلكتروني غير مسجل في النظام كمسؤول",
                        new List<string> { "Access Denied: Email is not registered as an administrator" }
                    );
                    failRes.StatusCode = System.Net.HttpStatusCode.Forbidden;
                    return failRes;
                }

                var roles = await _userManager.GetRolesAsync(user);
                var isAdmin = roles.Any(r => r.Equals(Roles.Admin, StringComparison.OrdinalIgnoreCase) ||
                                             r.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) ||
                                             r.Equals("Auditor", StringComparison.OrdinalIgnoreCase));
                if (!isAdmin)
                {
                    _logger.LogWarning("Admin forgot password rejected: User {Email} is not in an admin role", email);
                    var failRes = ApiResponse<object>.FailResponse(
                        "تم رفض الوصول: هذا الحساب لا يملك صلاحيات إدارية لاستعادة كلمة المرور من لوحة التحكم",
                        new List<string> { "Access Denied: Not an admin" }
                    );
                    failRes.StatusCode = System.Net.HttpStatusCode.Forbidden;
                    return failRes;
                }

                var token = await _userManager.GeneratePasswordResetTokenAsync(user);
                var encodedToken = System.Web.HttpUtility.UrlEncode(token);
                var baseUrl = SanitizeAdminResetBaseUrl(clientUrl);
                var resetLink = $"{baseUrl}?email={Uri.EscapeDataString(email)}&token={encodedToken}";

                var isEn = (user.PreferredLanguage ?? "ar").Equals("en", StringComparison.OrdinalIgnoreCase);
                var subject = isEn ? "Admin Password Reset - Mahfazti Console" : "إعادة تعيين كلمة مرور المسؤول - لوحة تحكم محفظتي";
                var emailBody = $@"
<!DOCTYPE html>
<html lang='{(isEn ? "en" : "ar")}' dir='{(isEn ? "ltr" : "rtl")}'>
<head>
  <meta charset='UTF-8'>
  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
</head>
<body style='font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif; background-color: #f8f9fa; padding: 32px 16px; margin: 0; color: #1e293b;'>
  <div style='max-width: 540px; margin: 0 auto; background: #ffffff; padding: 40px 32px; border-radius: 16px; border: 1px solid #e2e8f0; box-shadow: 0 4px 12px rgba(0,0,0,0.03);'>
    <div style='margin-bottom: 24px; text-align: center;'>
      <span style='font-size: 24px; font-weight: 800; color: #0f172a; letter-spacing: -0.5px;'>Mahfazti <span style='color: #2563eb;'>Admin</span></span>
    </div>
    <h2 style='margin-top: 0; margin-bottom: 12px; color: #0f172a; font-size: 20px; font-weight: 700; text-align: center;'>
      {(isEn ? "Reset Your Password" : "إعادة تعيين كلمة المرور")}
    </h2>
    <p style='font-size: 14px; line-height: 1.6; color: #475569; text-align: center; margin-bottom: 28px;'>
      {(isEn 
        ? "We received a request to reset the password for your administrator account. Click the button below to choose a new password." 
        : "تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بحسابك الإداري. اضغط على الزر أدناه لاختيار كلمة مرور جديدة.")}
    </p>
    <div style='text-align: center; margin: 32px 0;'>
      <a href='{resetLink}' target='_blank' style='background-color: #0f172a; color: #ffffff; padding: 14px 32px; border-radius: 10px; text-decoration: none; font-size: 14px; font-weight: 600; display: inline-block; box-shadow: 0 2px 6px rgba(15,23,42,0.2);'>
        {(isEn ? "Reset Password" : "إعادة تعيين كلمة المرور")}
      </a>
    </div>
    <div style='background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; margin-top: 24px;'>
      <span style='font-size: 11px; color: #64748b; display: block; margin-bottom: 6px;'>{(isEn ? "Or copy and paste this link in your browser:" : "أو انسخ الرابط التالي وضعه في المتصفح:")}</span>
      <a href='{resetLink}' style='color: #2563eb; word-break: break-all; font-size: 11px; text-decoration: underline;'>{resetLink}</a>
    </div>
    <hr style='border: none; border-top: 1px solid #f1f5f9; margin: 28px 0 20px;' />
    <p style='font-size: 12px; color: #94a3b8; text-align: center; margin: 0; line-height: 1.5;'>
      {(isEn ? "This link is valid for 15 minutes. If you did not request a password reset, you can safely ignore this email." : "هذا الرابط صالح لمدة 15 دقيقة فقط. إذا لم تكن قد طلبت استعادة كلمة المرور، يمكنك تجاهل هذه الرسالة بأمان.")}
    </p>
  </div>
</body>
</html>";

                await _emailSender.SendEmailAsync(email, subject, emailBody);
                _logger.LogInformation("Admin password reset email dispatched to: {Email}", email);

                return ApiResponse<object>.SuccessResponse(
                    new { email, sent = true },
                    isEn ? "Password reset link sent to your admin email." : "تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني بنجاح."
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing admin forgot password");
                return ApiResponse<object>.FailResponse(
                    "حدث خطأ أثناء معالجة طلب استعادة كلمة المرور",
                    new List<string> { "An error occurred while processing the request" }
                );
            }
        }

        public async Task<ApiResponse<object>> VerifyResetCodeAsync(string email, string code)
        {
            try
            {
                _logger.LogInformation("Password reset code verification attempt");

                var result = await _passwordResetStore.VerifyResetCodeAsync(email, code);
                if (result.Status == ResetCodeVerificationStatus.Expired)
                {
                    return ApiResponse<object>.FailResponse(
                        "انتهت صلاحية الكود أو غير موجود",
                        new List<string> { "Invalid or expired code" }
                    );
                }

                if (result.Status == ResetCodeVerificationStatus.TooManyAttempts)
                {
                    return ApiResponse<object>.FailResponse(
                        "تم تجاوز الحد الأقصى للمحاولات الخاطئة. يرجى طلب رمز جديد.",
                        new List<string> { "Too many attempts" }
                    );
                }

                if (result.Status == ResetCodeVerificationStatus.Invalid)
                {
                    return ApiResponse<object>.FailResponse(
                        "الكود غير صحيح",
                        new List<string> { "Code mismatch" }
                    );
                }

                return ApiResponse<object>.SuccessResponse(
                    new { resetToken = result.ResetToken },
                    "تم التحقق من الكود بنجاح"
                );
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying password reset code");
                return ApiResponse<object>.FailResponse(
                    "حدث خطأ أثناء التحقق من الكود",
                    new List<string> { "An error occurred while verifying the code" }
                );
            }
        }

        public async Task<ApiResponse<object>> ResetPasswordAsync(ResetPasswordDTO dto)
        {
            try
            {
                _logger.LogInformation("Password reset execution attempt");

                if (!await _passwordResetStore.ValidateResetTokenAsync(dto.Email, dto.ResetToken))
                {
                    return ApiResponse<object>.FailResponse(
                        "رمز التحقق غير صالح أو انتهت صلاحيته. يرجى إعادة طلب رمز جديد.",
                        new List<string> { "Invalid or expired reset token" }
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
                    await _passwordResetStore.DeleteAsync(dto.Email);

                    var emailBody = _emailTemplateService.GeneratePasswordResetConfirmationEmail(user.PreferredLanguage ?? "ar");
                    await _emailSender.SendEmailAsync(
                        dto.Email,
                        _emailTemplateService.GetLocalizedText("EmailSubjectPasswordChanged", user.PreferredLanguage ?? "ar"),
                        emailBody
                    );

                    _logger.LogInformation("Password reset successful for user {UserId}", user.Id);
                    return ApiResponse<object>.SuccessResponse(new object(), "تم تغيير كلمة المرور بنجاح");
                }

                var errors = result.Errors.Select(e => e.Description).ToList();
                _logger.LogWarning("Password reset failed: {Errors}", string.Join(", ", errors));
                return ApiResponse<object>.FailResponse("فشل تغيير كلمة المرور", errors);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error resetting password");
                return ApiResponse<object>.FailResponse(
                    "حدث خطأ أثناء إعادة تعيين كلمة المرور",
                    new List<string> { "An error occurred while resetting password" }
                );
            }
        }

        public async Task<ApiResponse<object>> AdminResetPasswordAsync(AdminResetPasswordDTO dto)
        {
            try
            {
                _logger.LogInformation("Admin password reset attempt for email: {Email}", dto.Email);

                var user = await _userManager.FindByEmailAsync(dto.Email);
                if (user == null)
                {
                    return ApiResponse<object>.FailResponse(
                        "المستخدم غير موجود أو غير مسجل كمسؤول",
                        new List<string> { "User not found" }
                    );
                }

                var roles = await _userManager.GetRolesAsync(user);
                var isAdmin = roles.Any(r => r.Equals(Roles.Admin, StringComparison.OrdinalIgnoreCase) ||
                                             r.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) ||
                                             r.Equals("Auditor", StringComparison.OrdinalIgnoreCase));
                if (!isAdmin)
                {
                    _logger.LogWarning("Admin reset password rejected: User {Email} is not in an admin role", dto.Email);
                    var failRes = ApiResponse<object>.FailResponse(
                        "تم رفض الوصول: هذا الحساب لا يملك صلاحيات إدارية",
                        new List<string> { "Access Denied: Not an admin" }
                    );
                    failRes.StatusCode = System.Net.HttpStatusCode.Forbidden;
                    return failRes;
                }

                var result = await _userManager.ResetPasswordAsync(user, dto.Token, dto.NewPassword);
                if (result.Succeeded)
                {
                    var isEn = (user.PreferredLanguage ?? "ar").Equals("en", StringComparison.OrdinalIgnoreCase);
                    var emailBody = _emailTemplateService.GeneratePasswordResetConfirmationEmail(user.PreferredLanguage ?? "ar");
                    await _emailSender.SendEmailAsync(
                        dto.Email,
                        _emailTemplateService.GetLocalizedText("EmailSubjectPasswordChanged", user.PreferredLanguage ?? "ar"),
                        emailBody
                    );

                    _logger.LogInformation("Admin password reset successful for email: {Email}", dto.Email);
                    return ApiResponse<object>.SuccessResponse(
                        new { email = dto.Email, reset = true },
                        isEn ? "Password reset successfully. You can now log in." : "تم تغيير كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول."
                    );
                }

                var errors = result.Errors.Select(e => e.Description).ToList();
                _logger.LogWarning("Admin password reset failed for {Email}: {Errors}", dto.Email, string.Join(", ", errors));
                return ApiResponse<object>.FailResponse("فشل إعادة تعيين كلمة المرور، يرجى التأكد من صلاحية الرابط والمحاولة مجدداً", errors);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error resetting admin password");
                return ApiResponse<object>.FailResponse(
                    "حدث خطأ أثناء إعادة تعيين كلمة المرور",
                    new List<string> { "An error occurred while resetting the password" }
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

                if (!await _emailVerificationStore.CanSendCodeAsync(email, TimeSpan.FromSeconds(60)))
                {
                    return ApiResponse<object>.FailResponse(
                        "يرجى الانتظار دقيقة واحدة قبل طلب رمز جديد",
                        new List<string> { "Rate limit exceeded" }
                    );
                }

                var code = RandomNumberGenerator.GetInt32(100000, 1000000).ToString("D6");
                await _emailVerificationStore.SaveCodeAsync(email, code);

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
                _logger.LogError(ex, "Error sending verification code");
                var response = ApiResponse<object>.FailResponse(
                    "حدث خطأ غير متوقع أثناء إرسال كود التحقق"
                );
                response.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                return response;
            }
        }

        public async Task<ApiResponse<object>> VerifyEmailCodeAsync(string email, string code)
        {
            try
            {
                var result = await _emailVerificationStore.VerifyCodeAsync(email, code);
                if (result == EmailCodeVerificationResult.Expired)
                {
                    return ApiResponse<object>.FailResponse(
                        "انتهت صلاحية الكود أو غير موجود",
                        new List<string> { "Code expired" }
                    );
                }

                if (result == EmailCodeVerificationResult.Invalid)
                {
                    return ApiResponse<object>.FailResponse(
                        "الكود غير صحيح",
                        new List<string> { "Invalid code" }
                    );
                }

                return ApiResponse<object>.SuccessResponse(new object(), "تم تأكيد البريد الإلكتروني بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying email code for: {Email}", email);
                var response = ApiResponse<object>.FailResponse("حدث خطأ غير متوقع أثناء التحقق من الكود");
                response.StatusCode = System.Net.HttpStatusCode.InternalServerError;
                return response;
            }
        }

        public async Task<ApiResponse<object>> Register(RegisterRequestDTO request, string? preferredLanguage = null)
        {
            try
            {
                if (!await _emailVerificationStore.IsVerifiedAsync(request.Email))
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

                await EnsureDefaultWalletAsync(user);

                try
                {
                    await _emailVerificationStore.DeleteAsync(request.Email);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Could not clear email verification after registration for: {Email}", request.Email);
                }

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

        private async Task EnsureDefaultWalletAsync(ApplicationUser user)
        {
            try
            {
                await _accountService.EnsureDefaultAccountAsync(
                    user.Id.ToString(),
                    user.Currency ?? "EGP",
                    user.PreferredLanguage);
            }
            catch (Exception ex)
            {
                // The Accounts endpoint also repairs missing defaults, so a wallet provisioning
                // failure should not leave an otherwise valid registration unusable.
                _logger.LogError(ex, "Could not provision default wallet for user {UserId}", user.Id);
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

        private static string GenerateRandomCode() =>
            RandomNumberGenerator.GetInt32(100000, 1000000).ToString("D6");

        private static string SanitizeAdminResetBaseUrl(string? clientUrl)
        {
            const string defaultBaseUrl = "https://mahfazti-six.vercel.app/reset-password";
            if (string.IsNullOrWhiteSpace(clientUrl))
                return defaultBaseUrl;

            if (!Uri.TryCreate(clientUrl, UriKind.Absolute, out var uri))
                return defaultBaseUrl;

            var isHttps = uri.Scheme.Equals(Uri.UriSchemeHttps, StringComparison.OrdinalIgnoreCase);
            var isLocalhost = uri.Host.Equals("localhost", StringComparison.OrdinalIgnoreCase) ||
                              uri.Host.Equals("127.0.0.1", StringComparison.Ordinal);

            var allowedHosts = new[]
            {
                "mahfazti-six.vercel.app",
                "mahfazti.vercel.app",
                "admin.mahfazti.com"
            };

            var isAllowedHost = allowedHosts.Any(h => uri.Host.Equals(h, StringComparison.OrdinalIgnoreCase));

            if (isAllowedHost && isHttps)
            {
                return $"{uri.Scheme}://{uri.Authority}/reset-password";
            }

            if (isLocalhost)
            {
                return $"{uri.Scheme}://{uri.Authority}/reset-password";
            }

            return defaultBaseUrl;
        }

        #endregion
    }
}
