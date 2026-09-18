using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class EmailTemplateService : IEmailTemplateService
    {
        public string GenerateVerificationEmail(string code, string language = "ar")
        {
            return $@"
<!DOCTYPE html>
<html lang='ar' dir='rtl'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>رمز التحقق - محفظتي</title>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8f9fa; margin: 0; padding: 20px; color: #333333; direction: rtl; }}
        .email-container {{ max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); }}
        .header {{ text-align: center; margin-bottom: 25px; border-bottom: 2px solid #f1f3f5; padding-bottom: 15px; }}
        .header h1 {{ color: #1e293b; margin: 0; font-size: 24px; font-weight: 700; }}
        .content {{ margin-bottom: 25px; line-height: 1.6; text-align: right; }}
        .verification-code {{ background-color: #f1f5f9; border: 2px dashed #94a3b8; border-radius: 8px; padding: 18px; text-align: center; margin: 20px 0; font-size: 32px; font-weight: 700; letter-spacing: 6px; color: #0f172a; direction: ltr; }}
        .security-alert {{ background-color: #fef2f2; border-right: 4px solid #ef4444; padding: 12px; margin: 20px 0; border-radius: 4px; color: #991b1b; font-size: 14px; }}
        .footer {{ text-align: center; font-size: 13px; color: #64748b; margin-top: 25px; border-top: 1px solid #f1f3f5; padding-top: 15px; }}
    </style>
</head>
<body>
    <div class='email-container'>
        <div class='header'>
            <h1>محفظتي - Mahfazti</h1>
        </div>
        <div class='content'>
            <p>مرحباً بك،</p>
            <p>لقد استلمنا طلباً للتحقق من بريدك الإلكتروني. يرجى استخدام الرمز التالي للمتابعة:</p>

            <div class='verification-code'>
                {code}
            </div>

            <div class='security-alert'>
                <p style='margin:0;'>⏱️ <strong>ملاحظة:</strong> صلاحية هذا الرمز هي 10 دقائق فقط. إذا لم تكن قد طلبت هذا الرمز، يمكنك تجاهل هذه الرسالة بأمان.</p>
            </div>

            <p>لأمانك وحمايتك، لا تشارك هذا الرمز مع أي شخص.</p>
        </div>
        <div class='footer'>
            <p>© {DateTime.Now.Year} محفظتي. جميع الحقوق محفوظة.</p>
        </div>
    </div>
</body>
</html>";
        }

        public string GeneratePasswordResetEmail(string resetCode, string language = "ar")
        {
            return $@"
<!DOCTYPE html>
<html lang='ar' dir='rtl'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>إعادة تعيين كلمة المرور - محفظتي</title>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8f9fa; margin: 0; padding: 20px; color: #333333; direction: rtl; }}
        .email-container {{ max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); }}
        .header {{ text-align: center; margin-bottom: 25px; border-bottom: 2px solid #f1f3f5; padding-bottom: 15px; }}
        .header h1 {{ color: #1e293b; margin: 0; font-size: 24px; font-weight: 700; }}
        .content {{ margin-bottom: 25px; line-height: 1.6; text-align: right; }}
        .verification-code {{ background-color: #f1f5f9; border: 2px dashed #94a3b8; border-radius: 8px; padding: 18px; text-align: center; margin: 20px 0; font-size: 32px; font-weight: 700; letter-spacing: 6px; color: #0f172a; direction: ltr; }}
        .security-alert {{ background-color: #fffbeb; border-right: 4px solid #f59e0b; padding: 12px; margin: 20px 0; border-radius: 4px; color: #92400e; font-size: 14px; }}
        .footer {{ text-align: center; font-size: 13px; color: #64748b; margin-top: 25px; border-top: 1px solid #f1f3f5; padding-top: 15px; }}
    </style>
</head>
<body>
    <div class='email-container'>
        <div class='header'>
            <h1>محفظتي - Mahfazti</h1>
        </div>
        <div class='content'>
            <p>مرحباً بك،</p>
            <p>لقد تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بحسابك في تطبيق محفظتي. استخدم الرمز التالي لتغيير كلمة المرور:</p>

            <div class='verification-code'>
                {resetCode}
            </div>

            <div class='security-alert'>
                <p style='margin:0;'>⏱️ ينتهي هذا الرمز بعد 10 دقائق. إذا لم تكن قد طلبت تغيير كلمة المرور، يرجى تجاهل هذا البريد.</p>
            </div>
        </div>
        <div class='footer'>
            <p>© {DateTime.Now.Year} محفظتي. جميع الحقوق محفوظة.</p>
        </div>
    </div>
</body>
</html>";
        }

        public string GeneratePasswordResetConfirmationEmail(string language = "ar")
        {
            return $@"
<!DOCTYPE html>
<html lang='ar' dir='rtl'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>تم تغيير كلمة المرور بنجاح - محفظتي</title>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8f9fa; margin: 0; padding: 20px; color: #333333; direction: rtl; }}
        .email-container {{ max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); }}
        .header {{ text-align: center; margin-bottom: 25px; border-bottom: 2px solid #f1f3f5; padding-bottom: 15px; }}
        .header h1 {{ color: #1e293b; margin: 0; font-size: 24px; font-weight: 700; }}
        .content {{ margin-bottom: 25px; line-height: 1.6; text-align: right; }}
        .footer {{ text-align: center; font-size: 13px; color: #64748b; margin-top: 25px; border-top: 1px solid #f1f3f5; padding-top: 15px; }}
    </style>
</head>
<body>
    <div class='email-container'>
        <div class='header'>
            <h1>محفظتي - Mahfazti</h1>
        </div>
        <div class='content'>
            <p>مرحباً،</p>
            <p>نود إعلامك بأنه تم تغيير كلمة المرور الخاصة بحسابك في محفظتي بنجاح.</p>
            <p>إذا لم تكن أنت من قام بهذا التغيير، يرجى التواصل مع الدعم الفني فوراً.</p>
        </div>
        <div class='footer'>
            <p>© {DateTime.Now.Year} محفظتي. جميع الحقوق محفوظة.</p>
        </div>
    </div>
</body>
</html>";
        }

        public string GenerateAccountLockoutEmail(ApplicationUser user, DateTimeOffset? lockoutEnd, string language = "ar")
        {
            return $@"
<!DOCTYPE html>
<html lang='ar' dir='rtl'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>تم قفل الحساب مؤقتاً - محفظتي</title>
</head>
<body style='font-family: Tahoma, sans-serif; direction: rtl; padding: 20px; background-color: #f8f9fa;'>
    <div style='max-width: 600px; margin: 0 auto; background: #fff; padding: 25px; border-radius: 10px;'>
        <h2 style='color: #dc2626;'>تنبيه أمان: تم قفل الحساب مؤقتاً</h2>
        <p>مرحباً {user.FullName}،</p>
        <p>تم قفل حسابك مؤقتاً بسبب محاولات دخول خاطئة متعددة.</p>
        <p>يمكنك المحاولة مجدداً بعد: <strong>{lockoutEnd?.LocalDateTime}</strong></p>
    </div>
</body>
</html>";
        }

        public string GenerateLoginEmail(ApplicationUser user, string? ipAddress, string? deviceName, DateTime requestTime, string? passwordResetLink, string language = "ar")
        {
            return $@"
<!DOCTYPE html>
<html lang='ar' dir='rtl'>
<head>
    <meta charset='UTF-8'>
    <title>تسجيل دخول جديد إلى حسابك</title>
</head>
<body style='font-family: Tahoma, sans-serif; direction: rtl; padding: 20px; background-color: #f8f9fa;'>
    <div style='max-width: 600px; margin: 0 auto; background: #fff; padding: 25px; border-radius: 10px;'>
        <h2>تسجيل دخول جديد</h2>
        <p>مرحباً {user.FullName}، تم تسجيل الدخول إلى حسابك في محفظتي بنجاح.</p>
        <p>الوقت: {requestTime:yyyy-MM-dd HH:mm}</p>
        {(string.IsNullOrEmpty(ipAddress) ? "" : $"<p>عنوان IP: {ipAddress}</p>")}
    </div>
</body>
</html>";
        }

        public string GetLocalizedText(string key, string language = "ar")
        {
            return key switch
            {
                "EmailSubjectVerificationCode" => "رمز التحقق - محفظتي",
                "EmailSubjectPasswordReset" => "إعادة تعيين كلمة المرور - محفظتي",
                "EmailSubjectPasswordChanged" => "تم تغيير كلمة المرور - محفظتي",
                "EmailSubjectAccountLocked" => "تم قفل حسابك مؤقتاً - محفظتي",
                "EmailSubjectLoginVerification" => "تسجيل دخول جديد - محفظتي",
                _ => key
            };
        }
    }
}
