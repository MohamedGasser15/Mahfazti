using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mahfazti.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class PopulateIsActiveDefault : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("UPDATE Categories SET IsActive = 1;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
