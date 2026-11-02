using Microsoft.AspNetCore.Identity;
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
            // Ensure core roles exist
            foreach (var r in new[] { Roles.User, Roles.Admin, Roles.SuperAdmin })
            {
                if (!await roleManager.RoleExistsAsync(r))
                    await roleManager.CreateAsync(new ApplicationRole { Name = r });
            }

            // No fake users are seeded. Users register dynamically through the application.
            await Task.CompletedTask;
        }
    }
}
