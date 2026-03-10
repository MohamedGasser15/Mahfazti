using Microsoft.EntityFrameworkCore;
using MyWallet.Domain.Entites;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Infrastructure.Data.Seeders
{
    public static class CategorySeeder
    {
        public static async Task SeedAsync(ApplicationDbContext context)
        {
            if (await context.Categories.AnyAsync()) return;

            var categories = new List<Category>
        {
            new() { NameAr = "طعام وشراب",     NameEn = "Food" },
            new() { NameAr = "مواصلات",         NameEn = "Transport" },
            new() { NameAr = "تسوق",            NameEn = "Shopping" },
            new() { NameAr = "ترفيه",           NameEn = "Entertainment" },
            new() { NameAr = "صحة",             NameEn = "Health" },
            new() { NameAr = "فواتير",          NameEn = "Bills" },
            new() { NameAr = "تعليم",           NameEn = "Education" },
            new() { NameAr = "راتب",            NameEn = "Salary" },
            new() { NameAr = "مكافأة",          NameEn = "Bonus" },
            new() { NameAr = "إيرادات أخرى",   NameEn = "Income" },
            new() { NameAr = "مصاريف أخرى",    NameEn = "Other" },
        };

            await context.Categories.AddRangeAsync(categories);
            await context.SaveChangesAsync();
        }
    }
}
