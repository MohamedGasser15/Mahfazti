using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mahfazti.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class PopulateCategoryTypeAndIcon : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
UPDATE Categories SET [Type] = 'Expense', [Icon] = 'utensils' WHERE [NameEn] LIKE '%Food%' OR [NameAr] LIKE N'%طعام%';
UPDATE Categories SET [Type] = 'Expense', [Icon] = 'car' WHERE [NameEn] LIKE '%Transport%' OR [NameAr] LIKE N'%مواصلات%';
UPDATE Categories SET [Type] = 'Expense', [Icon] = 'shopping-bag' WHERE [NameEn] LIKE '%Shopping%' OR [NameAr] LIKE N'%تسوق%';
UPDATE Categories SET [Type] = 'Expense', [Icon] = 'sparkles' WHERE [NameEn] LIKE '%Entertainment%' OR [NameAr] LIKE N'%ترفيه%';
UPDATE Categories SET [Type] = 'Expense', [Icon] = 'activity' WHERE [NameEn] LIKE '%Health%' OR [NameAr] LIKE N'%صحة%';
UPDATE Categories SET [Type] = 'Expense', [Icon] = 'receipt' WHERE [NameEn] LIKE '%Bill%' OR [NameEn] LIKE '%Util%' OR [NameAr] LIKE N'%فواتير%';
UPDATE Categories SET [Type] = 'Expense', [Icon] = 'graduation-cap' WHERE [NameEn] LIKE '%Education%' OR [NameAr] LIKE N'%تعليم%';
UPDATE Categories SET [Type] = 'Income', [Icon] = 'wallet' WHERE [NameEn] LIKE '%Salary%' OR [NameAr] LIKE N'%راتب%';
UPDATE Categories SET [Type] = 'Income', [Icon] = 'gift' WHERE [NameEn] LIKE '%Bonus%' OR [NameEn] LIKE '%Reward%' OR [NameAr] LIKE N'%مكافآت%';
UPDATE Categories SET [Type] = 'Income', [Icon] = 'trending-up' WHERE [NameEn] LIKE '%Invest%' OR [NameEn] LIKE '%Income%' OR [NameAr] LIKE N'%استثمار%';
UPDATE Categories SET [Type] = 'Expense', [Icon] = 'tag' WHERE [NameEn] LIKE '%General%' OR [NameAr] LIKE N'%نفقات%';
UPDATE Categories SET [Type] = 'Expense' WHERE [Type] = '' OR [Type] IS NULL;
UPDATE Categories SET [Icon] = 'layers' WHERE [Icon] = '' OR [Icon] IS NULL;
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
