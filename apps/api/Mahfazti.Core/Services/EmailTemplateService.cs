using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class EmailTemplateService : IEmailTemplateService
    {
        private static bool IsEnglish(string? language) =>
            !string.IsNullOrWhiteSpace(language) && language.Trim().ToLower().StartsWith("en");

        public string GenerateVerificationEmail(string code, string language = "ar")
        {
            var isEn = IsEnglish(language);
            var lang = isEn ? "en" : "ar";
            var dir = isEn ? "ltr" : "rtl";
            var textAlign = isEn ? "left" : "right";
            var font = isEn
                ? "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
                : "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";

            var title = isEn ? "Verification Code - Mahfazti" : "رمز التحقق - محفظتي";
            var greeting = isEn ? "Hello," : "مرحباً بك،";
            var message = isEn
                ? "We received a request to verify your email address. Please use the following verification code to proceed:"
                : "لقد استلمنا طلباً للتحقق من بريدك الإلكتروني. يرجى استخدام الرمز التالي للمتابعة:";
            var noteLabel = isEn ? "Note:" : "ملاحظة:";
            var noteText = isEn
                ? "This verification code is valid for 10 minutes. If you did not request this, you can safely ignore this message."
                : "صلاحية هذا الرمز هي 10 دقائق فقط. إذا لم تكن قد طلبت هذا الرمز، يمكنك تجاهل هذه الرسالة بأمان.";
            var securityText = isEn
                ? "For your security, never share this code with anyone."
                : "لأمانك وحمايتك، لا تشارك هذا الرمز مع أي شخص.";
            var rightsText = isEn
                ? $"© {DateTime.UtcNow.Year} Mahfazti. All rights reserved."
                : $"© {DateTime.UtcNow.Year} محفظتي. جميع الحقوق محفوظة.";

            return $@"
<!DOCTYPE html>
<html lang='{lang}' dir='{dir}'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>{title}</title>
    <style>
        body {{ font-family: {font}; background-color: #f8f9fa; margin: 0; padding: 20px; color: #333333; direction: {dir}; }}
        .email-container {{ max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05); }}
        .header {{ text-align: center; margin-bottom: 25px; border-bottom: 2px solid #f1f3f5; padding-bottom: 15px; }}
        .header h1 {{ color: #0f172a; margin: 0; font-size: 24px; font-weight: 800; letter-spacing: -0.5px; }}
        .content {{ margin-bottom: 25px; line-height: 1.6; text-align: {textAlign}; }}
        .verification-code {{ background-color: #f8fafc; border: 2px dashed #94a3b8; border-radius: 12px; padding: 20px; text-align: center; margin: 24px 0; font-size: 34px; font-weight: 800; letter-spacing: 8px; color: #0f172a; direction: ltr; }}
        .security-alert {{ background-color: #fef2f2; border-{(isEn ? "left" : "right")}: 4px solid #ef4444; padding: 14px; margin: 20px 0; border-radius: 8px; color: #991b1b; font-size: 14px; }}
        .footer {{ text-align: center; font-size: 13px; color: #64748b; margin-top: 25px; border-top: 1px solid #f1f3f5; padding-top: 15px; }}
    </style>
</head>
<body>
    <div class='email-container'>
        <div class='header'>
            <h1>Mahfazti</h1>
        </div>
        <div class='content'>
            <p style='font-size: 16px; font-weight: 600; color: #0f172a;'>{greeting}</p>
            <p>{message}</p>

            <div class='verification-code'>
                {code}
            </div>

            <div class='security-alert'>
                <p style='margin:0;'>⏱️ <strong>{noteLabel}</strong> {noteText}</p>
            </div>

            <p style='font-size: 13px; color: #64748b;'>{securityText}</p>
        </div>
        <div class='footer'>
            <p>{rightsText}</p>
        </div>
    </div>
</body>
</html>";
        }

        public string GeneratePasswordResetEmail(string resetCode, string language = "ar")
        {
            var isEn = IsEnglish(language);
            var lang = isEn ? "en" : "ar";
            var dir = isEn ? "ltr" : "rtl";
            var textAlign = isEn ? "left" : "right";
            var font = isEn
                ? "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
                : "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";

            var title = isEn ? "Reset Your Password - Mahfazti" : "إعادة تعيين كلمة المرور - محفظتي";
            var greeting = isEn ? "Hello," : "مرحباً بك،";
            var message = isEn
                ? "We received a request to reset the password for your Mahfazti account. Use the code below to reset your password:"
                : "لقد تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بحسابك في تطبيق محفظتي. استخدم الرمز التالي لتغيير كلمة المرور:";
            var noteLabel = isEn ? "Note:" : "ملاحظة:";
            var noteText = isEn
                ? "This code expires in 10 minutes. If you did not request a password reset, please ignore this email."
                : "ينتهي هذا الرمز بعد 10 دقائق. إذا لم تكن قد طلبت تغيير كلمة المرور، يرجى تجاهل هذا البريد.";
            var rightsText = isEn
                ? $"© {DateTime.UtcNow.Year} Mahfazti. All rights reserved."
                : $"© {DateTime.UtcNow.Year} محفظتي. جميع الحقوق محفوظة.";

            return $@"
<!DOCTYPE html>
<html lang='{lang}' dir='{dir}'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>{title}</title>
    <style>
        body {{ font-family: {font}; background-color: #f8f9fa; margin: 0; padding: 20px; color: #333333; direction: {dir}; }}
        .email-container {{ max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05); }}
        .header {{ text-align: center; margin-bottom: 25px; border-bottom: 2px solid #f1f3f5; padding-bottom: 15px; }}
        .header h1 {{ color: #0f172a; margin: 0; font-size: 24px; font-weight: 800; }}
        .content {{ margin-bottom: 25px; line-height: 1.6; text-align: {textAlign}; }}
        .verification-code {{ background-color: #f8fafc; border: 2px dashed #94a3b8; border-radius: 12px; padding: 20px; text-align: center; margin: 24px 0; font-size: 34px; font-weight: 800; letter-spacing: 8px; color: #0f172a; direction: ltr; }}
        .security-alert {{ background-color: #fffbeb; border-{(isEn ? "left" : "right")}: 4px solid #f59e0b; padding: 14px; margin: 20px 0; border-radius: 8px; color: #92400e; font-size: 14px; }}
        .footer {{ text-align: center; font-size: 13px; color: #64748b; margin-top: 25px; border-top: 1px solid #f1f3f5; padding-top: 15px; }}
    </style>
</head>
<body>
    <div class='email-container'>
        <div class='header'>
            <h1>Mahfazti</h1>
        </div>
        <div class='content'>
            <p style='font-size: 16px; font-weight: 600; color: #0f172a;'>{greeting}</p>
            <p>{message}</p>

            <div class='verification-code'>
                {resetCode}
            </div>

            <div class='security-alert'>
                <p style='margin:0;'>⏱️ <strong>{noteLabel}</strong> {noteText}</p>
            </div>
        </div>
        <div class='footer'>
            <p>{rightsText}</p>
        </div>
    </div>
</body>
</html>";
        }

        public string GeneratePasswordResetConfirmationEmail(string language = "ar")
        {
            var isEn = IsEnglish(language);
            var lang = isEn ? "en" : "ar";
            var dir = isEn ? "ltr" : "rtl";
            var textAlign = isEn ? "left" : "right";
            var font = isEn
                ? "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
                : "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";

            var title = isEn ? "Password Changed Successfully - Mahfazti" : "تم تغيير كلمة المرور بنجاح - محفظتي";
            var greeting = isEn ? "Hello," : "مرحباً،";
            var message = isEn
                ? "This is a confirmation that the password for your Mahfazti account has been successfully updated."
                : "نود إعلامك بأنه تم تغيير كلمة المرور الخاصة بحسابك في محفظتي بنجاح.";
            var warning = isEn
                ? "If you did not make this change, please contact our support team immediately."
                : "إذا لم تكن أنت من قام بهذا التغيير، يرجى التواصل مع الدعم الفني فوراً.";
            var rightsText = isEn
                ? $"© {DateTime.UtcNow.Year} Mahfazti. All rights reserved."
                : $"© {DateTime.UtcNow.Year} محفظتي. جميع الحقوق محفوظة.";

            return $@"
<!DOCTYPE html>
<html lang='{lang}' dir='{dir}'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>{title}</title>
    <style>
        body {{ font-family: {font}; background-color: #f8f9fa; margin: 0; padding: 20px; color: #333333; direction: {dir}; }}
        .email-container {{ max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05); }}
        .header {{ text-align: center; margin-bottom: 25px; border-bottom: 2px solid #f1f3f5; padding-bottom: 15px; }}
        .header h1 {{ color: #0f172a; margin: 0; font-size: 24px; font-weight: 800; }}
        .content {{ margin-bottom: 25px; line-height: 1.6; text-align: {textAlign}; }}
        .footer {{ text-align: center; font-size: 13px; color: #64748b; margin-top: 25px; border-top: 1px solid #f1f3f5; padding-top: 15px; }}
    </style>
</head>
<body>
    <div class='email-container'>
        <div class='header'>
            <h1>Mahfazti</h1>
        </div>
        <div class='content'>
            <p style='font-size: 16px; font-weight: 600; color: #0f172a;'>{greeting}</p>
            <p>{message}</p>
            <p style='color: #dc2626; font-weight: 500;'>{warning}</p>
        </div>
        <div class='footer'>
            <p>{rightsText}</p>
        </div>
    </div>
</body>
</html>";
        }

        public string GenerateAccountLockoutEmail(ApplicationUser user, DateTimeOffset? lockoutEnd, string language = "ar")
        {
            var isEn = IsEnglish(language);
            var lang = isEn ? "en" : "ar";
            var dir = isEn ? "ltr" : "rtl";
            var textAlign = isEn ? "left" : "right";
            var font = isEn
                ? "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
                : "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";

            var title = isEn ? "Security Alert: Account Locked - Mahfazti" : "تم قفل الحساب مؤقتاً - محفظتي";
            var heading = isEn ? "Security Alert: Account Temporarily Locked" : "تنبيه أمان: تم قفل الحساب مؤقتاً";
            var greeting = isEn ? $"Hello {user.FullName}," : $"مرحباً {user.FullName}،";
            var message = isEn
                ? "Your account has been temporarily locked due to multiple failed login attempts."
                : "تم قفل حسابك مؤقتاً بسبب محاولات دخول خاطئة متعددة.";
            var tryAgainText = isEn
                ? $"You can try logging in again after: <strong>{lockoutEnd?.LocalDateTime}</strong>"
                : $"يمكنك المحاولة مجدداً بعد: <strong>{lockoutEnd?.LocalDateTime}</strong>";

            return $@"
<!DOCTYPE html>
<html lang='{lang}' dir='{dir}'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>{title}</title>
</head>
<body style='font-family: {font}; direction: {dir}; text-align: {textAlign}; padding: 20px; background-color: #f8f9fa;'>
    <div style='max-width: 600px; margin: 0 auto; background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);'>
        <h2 style='color: #dc2626; margin-top: 0;'>{heading}</h2>
        <p>{greeting}</p>
        <p>{message}</p>
        <p>{tryAgainText}</p>
    </div>
</body>
</html>";
        }

        public string GenerateLoginEmail(ApplicationUser user, string? ipAddress, string? deviceName, DateTime requestTime, string? passwordResetLink, string language = "ar")
        {
            var isEn = IsEnglish(language);
            var lang = isEn ? "en" : "ar";
            var dir = isEn ? "ltr" : "rtl";
            var textAlign = isEn ? "left" : "right";
            var font = isEn
                ? "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
                : "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";

            var title = isEn ? "New Login Alert - Mahfazti" : "تسجيل دخول جديد إلى حسابك";
            var heading = isEn ? "New Login Detected" : "تسجيل دخول جديد";
            var greeting = isEn
                ? $"Hello {user.FullName}, you have successfully signed in to your Mahfazti account."
                : $"مرحباً {user.FullName}، تم تسجيل الدخول إلى حسابك في محفظتي بنجاح.";
            var timeLabel = isEn ? "Time" : "الوقت";
            var ipLabel = isEn ? "IP Address" : "عنوان IP";
            var deviceLabel = isEn ? "Device" : "الجهاز";

            return $@"
<!DOCTYPE html>
<html lang='{lang}' dir='{dir}'>
<head>
    <meta charset='UTF-8'>
    <title>{title}</title>
</head>
<body style='font-family: {font}; direction: {dir}; text-align: {textAlign}; padding: 20px; background-color: #f8f9fa;'>
    <div style='max-width: 600px; margin: 0 auto; background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);'>
        <h2 style='color: #0f172a; margin-top: 0;'>{heading}</h2>
        <p>{greeting}</p>
        <p><strong>{timeLabel}:</strong> {requestTime:yyyy-MM-dd HH:mm}</p>
        {(string.IsNullOrEmpty(ipAddress) ? "" : $"<p><strong>{ipLabel}:</strong> {ipAddress}</p>")}
        {(string.IsNullOrEmpty(deviceName) ? "" : $"<p><strong>{deviceLabel}:</strong> {deviceName}</p>")}
    </div>
</body>
</html>";
        }

        public string GetLocalizedText(string key, string language = "ar")
        {
            var isEn = IsEnglish(language);

            return key switch
            {
                "EmailSubjectVerificationCode" => isEn
                    ? "Verification Code - Mahfazti"
                    : "رمز التحقق - محفظتي",
                "EmailSubjectPasswordReset" => isEn
                    ? "Reset Your Password - Mahfazti"
                    : "إعادة تعيين كلمة المرور - محفظتي",
                "EmailSubjectPasswordChanged" => isEn
                    ? "Password Changed Successfully - Mahfazti"
                    : "تم تغيير كلمة المرور بنجاح - محفظتي",
                "EmailSubjectAccountLocked" => isEn
                    ? "Account Temporarily Locked - Mahfazti"
                    : "تم قفل حسابك مؤقتاً - محفظتي",
                "EmailSubjectLoginVerification" => isEn
                    ? "New Login Alert - Mahfazti"
                    : "تسجيل دخول جديد - محفظتي",
                _ => key
            };
        }
    }
}
