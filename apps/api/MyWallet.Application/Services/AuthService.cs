// Services/AuthService.cs
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using MyWallet.Application.DTOs.Auth;
using MyWallet.Application.ServiceInterfaces;
using MyWallet.Infrastructure.Identity;
using MyWallet.Infrastructure.Persistence.IRepository;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace MyWallet.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IEmailSender _emailSender;
        private readonly IEmailTemplateService _emailTemplateService;
        private readonly IMemoryCache _cache;
        private readonly IConfiguration _configuration;
        private readonly IRepository<ApplicationUser> _userRepository;

        public AuthService(
            UserManager<ApplicationUser> userManager,
            IEmailSender emailSender,
            IEmailTemplateService emailTemplateService,
            IMemoryCache cache,
            IConfiguration configuration,
            IRepository<ApplicationUser> userRepository)
        {
            _userManager = userManager;
            _emailSender = emailSender;
            _emailTemplateService = emailTemplateService;
            _cache = cache;
            _configuration = configuration;
            _userRepository = userRepository;
        }

        public async Task<AuthResponseDto> SendVerificationAsync(SendVerificationDto dto)
        {
            try
            {
                // Check if user exists
                var existingUser = await _userManager.FindByEmailAsync(dto.Email);

                // If this is for register and user already exists
                if (!dto.IsLogin && existingUser != null)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "البريد الإلكتروني مسجل بالفعل",
                        Errors = new List<string> { "Email already exists" }
                    };
                }

                // If this is for login and user doesn't exist
                if (dto.IsLogin && existingUser == null)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "البريد الإلكتروني غير مسجل",
                        Errors = new List<string> { "Email not registered" }
                    };
                }

                // Generate verification code (6 digits)
                var verificationCode = new Random().Next(100000, 999999).ToString();

                // Store code in cache for 10 minutes with user type info
                var cacheKey = $"Verification_{dto.Email}";
                var cacheData = new VerificationCacheData
                {
                    Code = verificationCode,
                    IsLogin = dto.IsLogin,
                    UserExists = existingUser != null,
                    DeviceName = dto.DeviceName, 
                    IpAddress = dto.IpAddress  
                };

                _cache.Set(cacheKey, cacheData, TimeSpan.FromMinutes(10));

                // Send verification email
                var emailBody = _emailTemplateService.GenerateVerificationEmail(
                              code: verificationCode,
                              isLogin: dto.IsLogin,
                              deviceName: dto.DeviceName,
                              ipAddress: dto.IpAddress
                          );
                await _emailSender.SendEmailAsync(dto.Email, "رمز التحقق - محفظتي", emailBody);

                return new AuthResponseDto
                {
                    Success = true,
                    Message = "تم إرسال رمز التحقق إلى بريدك الإلكتروني"
                };
            }
            catch (Exception ex)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "حدث خطأ أثناء إرسال رمز التحقق",
                    Errors = new List<string> { ex.Message }
                };
            }
        }

        public async Task<AuthResponseDto> VerifyAndCompleteAsync(VerifyAndCompleteDto dto)
        {
            try
            {
                // Get verification data from cache
                var cacheKey = $"Verification_{dto.Email}";
                if (!_cache.TryGetValue(cacheKey, out VerificationCacheData? cacheData))
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "رمز التحقق منتهي الصلاحية أو غير صحيح",
                        Errors = new List<string> { "Invalid or expired verification code" }
                    };
                }

                // Verify code
                if (cacheData.Code != dto.VerificationCode)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "رمز التحقق غير صحيح",
                        Errors = new List<string> { "Invalid verification code" }
                    };
                }

                // Check if user exists
                var existingUser = await _userManager.FindByEmailAsync(dto.Email);

                if (existingUser != null)
                {
                    // LOGIN FLOW
                    // Verify password
                    var passwordValid = await _userManager.CheckPasswordAsync(existingUser, dto.Password);
                    if (!passwordValid)
                    {
                        return new AuthResponseDto
                        {
                            Success = false,
                            Message = "كلمة المرور غير صحيحة",
                            Errors = new List<string> { "Invalid password" }
                        };
                    }

                    // Generate token
                    var token = await GenerateJwtToken(existingUser);

                    // Clear cache
                    _cache.Remove(cacheKey);

                    return new AuthResponseDto
                    {
                        Success = true,
                        Message = "تم تسجيل الدخول بنجاح",
                        Token = token,
                        User = new UserDto
                        {
                            Id = existingUser.Id.ToString(),
                            Email = existingUser.Email,
                            FullName = existingUser.FullName,
                            UserName = existingUser.UserName,
                            PhoneNumber = existingUser.PhoneNumber
                        }
                    };
                }
                else
                {
                    // REGISTER FLOW
                    // Validate required fields for registration
                    if (string.IsNullOrEmpty(dto.FullName) ||
                        string.IsNullOrEmpty(dto.UserName) ||
                        string.IsNullOrEmpty(dto.PhoneNumber))
                    {
                        return new AuthResponseDto
                        {
                            Success = false,
                            Message = "الرجاء إدخال جميع البيانات المطلوبة للتسجيل",
                            Errors = new List<string> { "Missing required fields for registration" }
                        };
                    }

                    // Check if username already exists
                    var existingUsername = await _userManager.FindByNameAsync(dto.UserName);
                    if (existingUsername != null)
                    {
                        return new AuthResponseDto
                        {
                            Success = false,
                            Message = "اسم المستخدم مسجل بالفعل",
                            Errors = new List<string> { "Username already exists" }
                        };
                    }

                    // Check if phone number already exists
                    var existingPhone = await _userRepository.GetAsync(u => u.PhoneNumber == dto.PhoneNumber);
                    if (existingPhone != null)
                    {
                        return new AuthResponseDto
                        {
                            Success = false,
                            Message = "رقم الهاتف مسجل بالفعل",
                            Errors = new List<string> { "Phone number already exists" }
                        };
                    }

                    // Create new user
                    var newUser = new ApplicationUser
                    {
                        UserName = dto.UserName,
                        Email = dto.Email,
                        FullName = dto.FullName,
                        PhoneNumber = dto.PhoneNumber,
                        EmailConfirmed = true
                    };

                    var result = await _userManager.CreateAsync(newUser, dto.Password);

                    if (!result.Succeeded)
                    {
                        var errors = result.Errors.Select(e => e.Description).ToList();
                        return new AuthResponseDto
                        {
                            Success = false,
                            Message = "فشل في إنشاء الحساب",
                            Errors = errors
                        };
                    }

                    // Generate token
                    var token = await GenerateJwtToken(newUser);

                    // Clear cache
                    _cache.Remove(cacheKey);

                    return new AuthResponseDto
                    {
                        Success = true,
                        Message = "تم إنشاء الحساب بنجاح",
                        Token = token,
                        User = new UserDto
                        {
                            Id = newUser.Id.ToString(),
                            Email = newUser.Email,
                            FullName = newUser.FullName,
                            UserName = newUser.UserName,
                            PhoneNumber = newUser.PhoneNumber
                        }
                    };
                }
            }
            catch (Exception ex)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "حدث خطأ أثناء إكمال العملية",
                    Errors = new List<string> { ex.Message }
                };
            }
        }
        public async Task<AuthResponseDto> VerifyCodeAsync(VerifyCodeDto dto)
        {
            var cacheKey = $"Verification_{dto.Email}";
            if (!_cache.TryGetValue(cacheKey, out VerificationCacheData? cacheData))
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "رمز التحقق منتهي الصلاحية أو غير صحيح",
                    Errors = new List<string> { "Invalid or expired verification code" }
                };
            }

            if (cacheData.Code != dto.VerificationCode)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "رمز التحقق غير صحيح",
                    Errors = new List<string> { "Invalid verification code" }
                };
            }

            return new AuthResponseDto
            {
                Success = true,
                Message = "رمز التحقق صحيح"
            };
        }

        // 2️⃣ Resend verification code
        public async Task<AuthResponseDto> ResendVerificationCodeAsync(SendVerificationDto dto)
        {
            var cacheKey = $"Verification_{dto.Email}";

            // Generate a new code
            var verificationCode = new Random().Next(100000, 999999).ToString();

            var cacheData = new VerificationCacheData
            {
                Code = verificationCode,
                IsLogin = dto.IsLogin,
                UserExists = await _userManager.FindByEmailAsync(dto.Email) != null
            };

            // Save in cache
            _cache.Set(cacheKey, cacheData, TimeSpan.FromMinutes(10));

            // Send email
            var emailBody = _emailTemplateService.GenerateVerificationEmail(
    code: verificationCode,
    isLogin: dto.IsLogin,
    deviceName: dto.DeviceName,
    ipAddress: dto.IpAddress
);
            await _emailSender.SendEmailAsync(dto.Email, "رمز التحقق - محفظتي", emailBody);

            return new AuthResponseDto
            {
                Success = true,
                Message = "تم إعادة إرسال رمز التحقق إلى بريدك الإلكتروني"
            };
        }
        public async Task<AuthResponseDto> LogoutAsync(string userId)
        {
            try
            {
                // في حالة استخدام JWT، الـ Logout يكون عادةً على مستوى العميل
                // ولكن يمكننا إضافة Token إلى blacklist إذا أردنا
                // هنا سنقوم فقط بإرجاع نجاح

                return new AuthResponseDto
                {
                    Success = true,
                    Message = "تم تسجيل الخروج بنجاح"
                };
            }
            catch (Exception ex)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "حدث خطأ أثناء تسجيل الخروج",
                    Errors = new List<string> { ex.Message }
                };
            }
        }
        // في نهاية AuthService.cs
        public async Task<bool> CheckEmailExists(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            return user != null;
        }
        public async Task<AuthResponseDto> SetUserCurrencyAsync(string userId, string currency)
        {
            try
            {
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "المستخدم غير موجود"
                    };
                }

                user.Currency = currency;
                var result = await _userManager.UpdateAsync(user);

                if (!result.Succeeded)
                {
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "فشل تحديث العملة",
                        Errors = result.Errors.Select(e => e.Description).ToList()
                    };
                }

                return new AuthResponseDto
                {
                    Success = true,
                    Message = "تم تحديث العملة بنجاح"
                };
            }
            catch (Exception ex)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "حدث خطأ أثناء تحديث العملة",
                    Errors = new List<string> { ex.Message }
                };
            }
        }
        private async Task<string> GenerateJwtToken(ApplicationUser user)
        {
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Name, user.UserName),
                new Claim("fullName", user.FullName),
                new Claim("phoneNumber", user.PhoneNumber ?? ""),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            // Add user roles
            var roles = await _userManager.GetRolesAsync(user);
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
                _configuration["Jwt:Key"] ?? throw new InvalidOperationException("JWT Key not configured")));

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddDays(7),
                signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        // Helper — زوده جوه AuthService فوق GenerateJwtToken
        private async Task<ApplicationUser?> FindByEmailOrUsernameAsync(string emailOrUsername)
        {
            if (emailOrUsername.Contains('@'))
                return await _userManager.FindByEmailAsync(emailOrUsername);
            else
                return await _userManager.FindByNameAsync(emailOrUsername);
        }

        // ─────────────────────────────────────────
        // STEP 1: Check user exists
        // ─────────────────────────────────────────
        public async Task<AuthResponseDto> CheckUserExistsAsync(CheckUserDto dto)
        {
            var user = await FindByEmailOrUsernameAsync(dto.EmailOrUsername);

            if (user == null)
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "المستخدم غير موجود"
                };

            return new AuthResponseDto
            {
                Success = true,
                Message = "المستخدم موجود"
            };
        }

        // ─────────────────────────────────────────
        // STEP 2: Verify password
        // ─────────────────────────────────────────
        public async Task<AuthResponseDto> VerifyPasswordForRecoveryAsync(VerifyPasswordForRecoveryDto dto)
        {
            var user = await FindByEmailOrUsernameAsync(dto.EmailOrUsername);

            if (user == null)
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "المستخدم غير موجود"
                };

            var isValid = await _userManager.CheckPasswordAsync(user, dto.Password);

            if (!isValid)
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "كلمة المرور غير صحيحة"
                };

            return new AuthResponseDto
            {
                Success = true,
                Message = "كلمة المرور صحيحة"
            };
        }

        // ─────────────────────────────────────────
        // STEP 3: Request email change → send OTP
        // ─────────────────────────────────────────
        public async Task<AuthResponseDto> RequestEmailChangeAsync(RequestEmailChangeDto dto)
        {
            // Check new email not already taken
            var emailTaken = await _userManager.FindByEmailAsync(dto.NewEmail);
            if (emailTaken != null)
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "هذا البريد الإلكتروني مسجل بالفعل"
                };

            var user = await FindByEmailOrUsernameAsync(dto.EmailOrUsername);
            if (user == null)
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "المستخدم غير موجود"
                };

            var otp = new Random().Next(100000, 999999).ToString();

            var cacheKey = $"EmailChange_{dto.EmailOrUsername}";
            _cache.Set(cacheKey, new EmailChangeCacheData
            {
                Code = otp,
                NewEmail = dto.NewEmail,
                EmailOrUsername = dto.EmailOrUsername
            }, TimeSpan.FromMinutes(10));

            // بعت OTP على الإيميل الجديد عشان يثبت إنه عنده access عليه
            var emailBody = _emailTemplateService.GenerateVerificationEmail(
                code: otp,
                isLogin: false,
                deviceName: null,
                ipAddress: null
            );

            await _emailSender.SendEmailAsync(dto.NewEmail, "تأكيد تغيير البريد الإلكتروني - محفظتي", emailBody);

            return new AuthResponseDto
            {
                Success = true,
                Message = "تم إرسال رمز التحقق إلى بريدك الإلكتروني الجديد"
            };
        }

        // ─────────────────────────────────────────
        // STEP 4: Confirm OTP → update email → return JWT
        // ─────────────────────────────────────────
        public async Task<AuthResponseDto> ConfirmEmailChangeAsync(ConfirmEmailChangeDto dto)
        {
            var cacheKey = $"EmailChange_{dto.EmailOrUsername}";

            if (!_cache.TryGetValue(cacheKey, out EmailChangeCacheData? cacheData))
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "رمز التحقق منتهي الصلاحية"
                };

            if (cacheData.Code != dto.OtpCode || cacheData.NewEmail != dto.NewEmail)
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "رمز التحقق غير صحيح"
                };

            var user = await FindByEmailOrUsernameAsync(dto.EmailOrUsername);
            if (user == null)
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "المستخدم غير موجود"
                };

            // Update email
            user.Email = dto.NewEmail;
            user.NormalizedEmail = dto.NewEmail.ToUpper();
            user.EmailConfirmed = true;

            var result = await _userManager.UpdateAsync(user);

            if (!result.Succeeded)
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "فشل تحديث البريد الإلكتروني",
                    Errors = result.Errors.Select(e => e.Description).ToList()
                };

            _cache.Remove(cacheKey);

            var token = await GenerateJwtToken(user);

            return new AuthResponseDto
            {
                Success = true,
                Message = "تم تغيير البريد الإلكتروني بنجاح",
                Token = token,
                User = new UserDto
                {
                    Id = user.Id.ToString(),
                    Email = user.Email,
                    FullName = user.FullName,
                    UserName = user.UserName!,
                    PhoneNumber = user.PhoneNumber ?? ""
                }
            };
        }

        public async Task<AuthResponseDto> SendPasscodeResetOtpAsync(string userId)
        {
            try
            {
                var user = await _userManager.FindByIdAsync(userId);
                if (user == null)
                    return new AuthResponseDto { Success = false, Message = "المستخدم غير موجود" };

                var otp = new Random().Next(100000, 999999).ToString();
                var cacheKey = $"PasscodeReset_{userId}";

                _cache.Set(cacheKey, otp, TimeSpan.FromMinutes(10));

                var emailBody = _emailTemplateService.GenerateVerificationEmail(
                    code: otp,
                    isLogin: false,
                    deviceName: null,
                    ipAddress: null
                );

                await _emailSender.SendEmailAsync(
                    user.Email!,
                    "إعادة تعيين الرمز السري - محفظتي",
                    emailBody
                );

                return new AuthResponseDto
                {
                    Success = true,
                    Message = "تم إرسال رمز التحقق إلى بريدك الإلكتروني"
                };
            }
            catch (Exception ex)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "حدث خطأ",
                    Errors = new List<string> { ex.Message }
                };
            }
        }

        public async Task<AuthResponseDto> ResetPasscodeAsync(ResetPasscodeDto dto)
        {
            try
            {
                var cacheKey = $"PasscodeReset_{dto.UserId}";

                if (!_cache.TryGetValue(cacheKey, out string? cachedOtp))
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "رمز التحقق منتهي الصلاحية"
                    };

                if (cachedOtp != dto.OtpCode)
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "رمز التحقق غير صحيح"
                    };

                var user = await _userManager.FindByIdAsync(dto.UserId);
                if (user == null)
                    return new AuthResponseDto { Success = false, Message = "المستخدم غير موجود" };

                // Reset password using Identity
                var resetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
                var result = await _userManager.ResetPasswordAsync(user, resetToken, dto.NewPasscode);

                if (!result.Succeeded)
                    return new AuthResponseDto
                    {
                        Success = false,
                        Message = "فشل تغيير الرمز السري",
                        Errors = result.Errors.Select(e => e.Description).ToList()
                    };

                _cache.Remove(cacheKey);

                return new AuthResponseDto
                {
                    Success = true,
                    Message = "تم تغيير الرمز السري بنجاح"
                };
            }
            catch (Exception ex)
            {
                return new AuthResponseDto
                {
                    Success = false,
                    Message = "حدث خطأ",
                    Errors = new List<string> { ex.Message }
                };
            }
        }
    }
}