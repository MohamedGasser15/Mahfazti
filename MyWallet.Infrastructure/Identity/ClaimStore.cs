using System.Security.Claims;

namespace MyWallet.Infrastructure.Identity
{
    public static class ClaimStore
    {
        public static List<Claim> HistoryClaims = new List<Claim>
        {
            new Claim("ViewHistory", "عرض التاريخ"),
        };

        public static List<Claim> UserClaims = new List<Claim>
        {
            new Claim("ViewUsers", "عرض المستخدمين"),
            new Claim("CreateUsers", "إنشاء مستخدمين"),
            new Claim("EditUsers", "تعديل مستخدمين"),
            new Claim("LockUsers", "حظر مستخدمين"),
            new Claim("DeleteUsers", "حذف مستخدمين"),
        };

        public static List<Claim> RoleClaims = new List<Claim>
        {
            new Claim("ViewRoles", "عرض المجموعات"),
            new Claim("CreateRoles", "إنشاء مجموعة"),
            new Claim("EditRoles", "تعديل مجموعة"),
            new Claim("DeleteRoles", "حذف مجموعة"),
        };
    }
}