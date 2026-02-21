using MyWallet.Application.ServiceInterfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Application.Services
{
    public class EmailTemplateService : IEmailTemplateService
    {
        public string GenerateVerificationEmail(string code, bool isLogin, string? deviceName = null, string? ipAddress = null)
        {
            // نحدد النص حسب نوع العملية
            string actionText = isLogin ? "Sign in to your account" : "Complete your registration";
            string greeting = isLogin ? "Welcome back!" : "Thanks for signing up!";
            string codePurpose = isLogin ? "sign-in" : "registration";

            // رابط عميق لتطبيق Flutter (يجب تعديله حسب الـ scheme اللي هتستخدمه)
            // مثال: mahfazati://verify?code=XXXXX
            string deepLinkUrl = $"https://mahfazati.app/verify?code={code}"; // أو mahfazati://verify?code={code}

            string deviceInfo = "";
            if (!string.IsNullOrEmpty(deviceName) || !string.IsNullOrEmpty(ipAddress))
            {
                deviceInfo = $@"
                <div style='background-color: #f8f9fa; border-radius: 8px; padding: 16px; margin: 20px 0;'>
                    <p style='margin: 0 0 8px 0; font-weight: 600;'>Request details:</p>
                    {(string.IsNullOrEmpty(deviceName) ? "" : $"<p style='margin: 4px 0;'><span style='color: #555;'>Device:</span> {deviceName}</p>")}
                    {(string.IsNullOrEmpty(ipAddress) ? "" : $"<p style='margin: 4px 0;'><span style='color: #555;'>IP Address:</span> {ipAddress}</p>")}
                    <p style='margin: 4px 0;'><span style='color: #555;'>Time:</span> {DateTime.Now:MMMM dd, yyyy 'at' h:mm tt}</p>
                </div>";
            }

            string emailTemplate = $@"
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Verify Your Email · Mahfazati</title>
    <style>
        body {{ font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px; color: #333333; }}
        .email-container {{ max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 12px; box-shadow: 0 8px 20px rgba(0, 0, 0, 0.05); }}
        .header {{ text-align: center; margin-bottom: 25px; border-bottom: 1px solid #eaeaea; padding-bottom: 15px; }}
        .header h1 {{ color: #000000; margin: 0; font-size: 26px; font-weight: 700; letter-spacing: -0.5px; }}
        .content {{ margin-bottom: 25px; line-height: 1.6; }}
        .content p {{ font-size: 16px; color: #333333; margin-bottom: 15px; }}
        .verification-code {{ background-color: #f8f9fa; border: 2px dashed #dddddd; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0; font-size: 32px; font-weight: 700; letter-spacing: 8px; color: #000000; }}
        .security-alert {{ background-color: #f8f9fa; border-left: 4px solid #000000; padding: 15px; margin: 20px 0; border-radius: 4px; }}
        .info-item {{ margin-bottom: 8px; font-size: 15px; }}
        .info-label {{ font-weight: 600; color: #555555; }}
        .button {{ display: inline-block; padding: 12px 24px; background-color: #000000; color: #ffffff; text-decoration: none; border-radius: 8px; margin: 20px 0 10px; font-weight: 600; font-size: 16px; transition: background-color 0.2s; }}
        .button:hover {{ background-color: #333333; }}
        .footer {{ text-align: center; font-size: 14px; color: #777777; margin-top: 25px; border-top: 1px solid #eaeaea; padding-top: 15px; }}
        .footer a {{ color: #000000; text-decoration: none; }}
    </style>
</head>
<body>
    <div class='email-container'>
        <div class='header'>
            <h1>Mahfazati</h1>
        </div>
        <div class='content'>
            <p>{greeting}</p>
            <p>We received a request to {actionText}. Use the verification code below to proceed.</p>

            <div class='verification-code'>
                {code}
            </div>

            <div class='security-alert'>
                <p><strong>⏱️ This code expires in 10 minutes.</strong> If you didn't request this, you can safely ignore this email.</p>
            </div>

            {deviceInfo}

            <p>For your security, never share this code with anyone.</p>

            <a href='{deepLinkUrl}' class='button'>Verify Email Address</a>
            <p style='font-size: 14px; color: #777;'>Or copy and paste this link: {deepLinkUrl}</p>
        </div>
        <div class='footer'>
            <p>© {DateTime.Now.Year} Mahfazati. All rights reserved.</p>
            <p><a href='#'>Privacy Policy</a> • <a href='#'>Help Center</a></p>
        </div>
    </div>
</body>
</html>";

            return emailTemplate;
        }
    }
}
