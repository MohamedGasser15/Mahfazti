using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyWallet.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCategoryModelToDB : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Category",
                table: "WalletTransactions");

            migrationBuilder.DropColumn(
                name: "Category",
                table: "CategoryBudgets");

            migrationBuilder.AddColumn<int>(
                name: "CategoryId",
                table: "WalletTransactions",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CategoryId",
                table: "CategoryBudgets",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "Categories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NameAr = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NameEn = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Categories", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_WalletTransactions_CategoryId",
                table: "WalletTransactions",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_CategoryBudgets_CategoryId",
                table: "CategoryBudgets",
                column: "CategoryId");

            migrationBuilder.AddForeignKey(
                name: "FK_CategoryBudgets_Categories_CategoryId",
                table: "CategoryBudgets",
                column: "CategoryId",
                principalTable: "Categories",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_WalletTransactions_Categories_CategoryId",
                table: "WalletTransactions",
                column: "CategoryId",
                principalTable: "Categories",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CategoryBudgets_Categories_CategoryId",
                table: "CategoryBudgets");

            migrationBuilder.DropForeignKey(
                name: "FK_WalletTransactions_Categories_CategoryId",
                table: "WalletTransactions");

            migrationBuilder.DropTable(
                name: "Categories");

            migrationBuilder.DropIndex(
                name: "IX_WalletTransactions_CategoryId",
                table: "WalletTransactions");

            migrationBuilder.DropIndex(
                name: "IX_CategoryBudgets_CategoryId",
                table: "CategoryBudgets");

            migrationBuilder.DropColumn(
                name: "CategoryId",
                table: "WalletTransactions");

            migrationBuilder.DropColumn(
                name: "CategoryId",
                table: "CategoryBudgets");

            migrationBuilder.AddColumn<string>(
                name: "Category",
                table: "WalletTransactions",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Category",
                table: "CategoryBudgets",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }
    }
}
