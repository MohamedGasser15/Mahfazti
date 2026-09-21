using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Mahfazti.Core.Constants;
using Mahfazti.Core.Entities;

namespace Mahfazti.Infrastructure.Data.Seeders
{
    public static class UserSeeder
    {
        public static async Task SeedAsync(
            UserManager<ApplicationUser> userManager,
            RoleManager<ApplicationRole> roleManager)
        {
            if (await userManager.Users.AnyAsync()) return;

            // Ensure roles exist
            foreach (var r in new[] { Roles.User, Roles.Admin, Roles.SuperAdmin })
            {
                if (!await roleManager.RoleExistsAsync(r))
                    await roleManager.CreateAsync(new ApplicationRole { Name = r });
            }

            var defaultUsers = new List<(ApplicationUser User, string Password, string Role)>
            {
                (new ApplicationUser
                {
                    UserName = "admin@mahfazti.app",
                    Email = "admin@mahfazti.app",
                    FullName = "Mohamed Gasser",
                    EmailConfirmed = true,
                    Currency = "EGP",
                    IsBanned = false,
                    CreatedAt = DateTime.UtcNow.AddMonths(-3)
                }, "Admin@123456", Roles.SuperAdmin),

                (new ApplicationUser
                {
                    UserName = "ahmed@example.com",
                    Email = "ahmed@example.com",
                    FullName = "Ahmed Hassan",
                    EmailConfirmed = true,
                    Currency = "EGP",
                    IsBanned = false,
                    CreatedAt = DateTime.UtcNow.AddMonths(-2)
                }, "User@123456", Roles.User),

                (new ApplicationUser
                {
                    UserName = "sarah@example.com",
                    Email = "sarah@example.com",
                    FullName = "Sarah Mohamed",
                    EmailConfirmed = true,
                    Currency = "USD",
                    IsBanned = false,
                    CreatedAt = DateTime.UtcNow.AddMonths(-1)
                }, "User@123456", Roles.User),

                (new ApplicationUser
                {
                    UserName = "omar@example.com",
                    Email = "omar@example.com",
                    FullName = "Omar Khaled",
                    EmailConfirmed = false,
                    Currency = "EGP",
                    IsBanned = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-15)
                }, "User@123456", Roles.User),

                (new ApplicationUser
                {
                    UserName = "nour.tarek@example.com",
                    Email = "nour.tarek@example.com",
                    FullName = "Nour El-Din Tarek",
                    EmailConfirmed = true,
                    Currency = "SAR",
                    IsBanned = false,
                    CreatedAt = DateTime.UtcNow.AddMonths(-2)
                }, "Admin@123456", Roles.Admin)
            };

            foreach (var (user, pwd, role) in defaultUsers)
            {
                var res = await userManager.CreateAsync(user, pwd);
                if (res.Succeeded)
                {
                    await userManager.AddToRoleAsync(user, role);
                }
            }
        }
    }
}
