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
        public string GenerateVerificationEmail(string code)
        {
            string emailTemplate = $@"
<!DOCTYPE html>
<html lang='ar' dir='rtl'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>تأكيد البريد الإلكتروني - محفظتي</title>
    <style>
        body {{{{
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #000;
        }}}}
        .container {{{{
            max-width: 600px;
            margin: 20px auto;
            background: #ffffff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }}}}
        .header {{{{
            background: #000000;
            padding: 30px;
            text-align: center;
        }}}}
        .logo {{{{
            color: #ffffff;
            font-size: 28px;
            font-weight: bold;
            text-decoration: none;
        }}}}
        .content {{{{
            padding: 40px;
            text-align: center;
        }}}}
        .code {{{{
            background: #f8f9fa;
            border: 2px dashed #dee2e6;
            padding: 20px;
            font-size: 32px;
            font-weight: bold;
            letter-spacing: 8px;
            color: #000;
            margin: 30px 0;
            border-radius: 4px;
        }}}}
        .footer {{{{
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #6c757d;
            font-size: 14px;
        }}}}
        .note {{{{
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 15px;
            border-radius: 4px;
            margin: 20px 0;
            color: #856404;
            text-align: right;
        }}}}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <a href='#' class='logo'>محفظتي 💼</a>
        </div>
        
        <div class='content'>
            <h2 style='color: #000; margin-bottom: 20px;'>تأكيد البريد الإلكتروني</h2>
            <p style='color: #000; font-size: 16px; line-height: 1.6;'>
                عزيزي المستخدم،<br>
                لقد تقدمت بطلب تسجيل في تطبيق ""محفظتي"". استخدم الرمز التالي لإكمال عملية التسجيل:
            </p>
            
            <div class='code'>{code}</div>
            
            <div class='note'>
                ⚠️ هذا الرمز صالح لمدة 10 دقائق فقط.<br>
                ⚠️ لا تشارك هذا الرمز مع أي شخص.
            </div>
            
            <p style='color: #000; font-size: 14px;'>
                إذا لم تطلب هذا الرمز، يمكنك تجاهل هذه الرسالة.
            </p>
        </div>
        
        <div class='footer'>
            © {{DateTime.Now.Year}} محفظتي - جميع الحقوق محفوظة
        </div>
    </div>
</body>
</html>";

            return emailTemplate;
        }

    }
}
