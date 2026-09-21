using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mahfazti.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddBilingualPlanFeatures : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DescriptionAr",
                table: "PricingPlans",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "FeaturesArJson",
                table: "PricingPlans",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DescriptionAr",
                table: "PricingPlans");

            migrationBuilder.DropColumn(
                name: "FeaturesArJson",
                table: "PricingPlans");
        }
    }
}
