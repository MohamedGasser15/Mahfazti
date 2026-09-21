using Microsoft.AspNetCore.Identity;
using Mahfazti.Core.Entities;

namespace Mahfazti.Infrastructure.Data.Seeders
{
    public static class RoleSeeder
    {
        public static async Task SeedAsync(RoleManager<ApplicationRole> roleManager)
        {
            var roleDefinitions = new[]
            {
                new { Name = "SuperAdmin", Description = "المالك الرئيسي للنظام بكافة الصلاحيات والجذور الإدارية وإدارة التكوينات وسجلات الأمان.", Permissions = Mahfazti.Core.Constants.Permissions.All },
                new { Name = "Admin", Description = "مشرف تشغيلي مع صلاحيات إدارة المستخدمين والتصنيفات ومراقبة العمليات المالية وسجل النشاط.", Permissions = Mahfazti.Core.Constants.Permissions.AdminDefault },
                new { Name = "User", Description = "مستخدم قياسي للمحفظة وتتبع المصروفات والمعاملات الشخصية.", Permissions = new List<string>() }
            };

            foreach (var def in roleDefinitions)
            {
                var role = await roleManager.FindByNameAsync(def.Name);
                if (role == null)
                {
                    role = new ApplicationRole
                    {
                        Name = def.Name,
                        Description = def.Description,
                        CreatedAt = DateTime.UtcNow,
                        IsDeleted = false
                    };
                    await roleManager.CreateAsync(role);
                }
                else if (string.IsNullOrWhiteSpace(role.Description))
                {
                    role.Description = def.Description;
                    await roleManager.UpdateAsync(role);
                }

                // Seed permissions
                if (def.Permissions.Count > 0)
                {
                    var existingClaims = await roleManager.GetClaimsAsync(role);
                    var existingPerms = existingClaims
                        .Where(c => c.Type == Mahfazti.Core.Constants.Permissions.ClaimType)
                        .Select(c => c.Value)
                        .ToHashSet();

                    foreach (var perm in def.Permissions)
                    {
                        if (!existingPerms.Contains(perm))
                        {
                            await roleManager.AddClaimAsync(role, new System.Security.Claims.Claim(Mahfazti.Core.Constants.Permissions.ClaimType, perm));
                        }
                    }
                }
            }
        }
    }
}
