using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mahfazti.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddIsFeaturedToCurrency : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsFeatured",
                table: "Currencies",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsFeatured",
                table: "Currencies");
        }
    }
}
