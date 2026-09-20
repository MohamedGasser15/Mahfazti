using Microsoft.EntityFrameworkCore;
using Mahfazti.Core.Entities;

namespace Mahfazti.Infrastructure.Data.Seeders
{
    public static class CategorySeeder
    {
        public static async Task SeedAsync(ApplicationDbContext context)
        {
            if (await context.Categories.AnyAsync()) return;

            var categories = new List<Category>
        {
            new() { NameAr = "طعام ومشروبات",           NameEn = "Food & Dining",             Type = "Expense", Icon = "utensils" },
            new() { NameAr = "مواصلات ووقود",           NameEn = "Transport & Fuel",          Type = "Expense", Icon = "car" },
            new() { NameAr = "تسوق ومشتريات",           NameEn = "Shopping & Retail",         Type = "Expense", Icon = "shopping-bag" },
            new() { NameAr = "ترفيه وأنشطة",            NameEn = "Entertainment & Leisure",   Type = "Expense", Icon = "sparkles" },
            new() { NameAr = "صحة ورعاية طبية",         NameEn = "Health & Wellness",         Type = "Expense", Icon = "activity" },
            new() { NameAr = "فواتير واشتراكات",        NameEn = "Bills & Utilities",         Type = "Expense", Icon = "receipt" },
            new() { NameAr = "تعليم وتطوير",            NameEn = "Education & Learning",      Type = "Expense", Icon = "graduation-cap" },
            new() { NameAr = "راتب شهري",               NameEn = "Monthly Salary",            Type = "Income",  Icon = "wallet" },
            new() { NameAr = "مكافآت وحوافز",           NameEn = "Bonuses & Rewards",         Type = "Income",  Icon = "gift" },
            new() { NameAr = "استثمارات وإيرادات",      NameEn = "Investments & Extra Income", Type = "Income",  Icon = "trending-up" },
            new() { NameAr = "نفقات متنوعة أخرى",       NameEn = "General & Miscellaneous",   Type = "Expense", Icon = "tag" },
        };

            await context.Categories.AddRangeAsync(categories);
            await context.SaveChangesAsync();
        }
    }
}
