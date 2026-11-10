using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mahfazti.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPasswordResetVerificationAndCooldown : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "LastSentAtUtc",
                table: "EmailVerifications",
                type: "datetime2",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "PasswordResetVerifications",
                columns: table => new
                {
                    Email = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                    CodeHash = table.Column<string>(type: "nvarchar(512)", maxLength: 512, nullable: false),
                    ExpiresAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    FailedAttempts = table.Column<int>(type: "int", nullable: false),
                    LastSentAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ResetTokenHash = table.Column<string>(type: "nvarchar(512)", maxLength: 512, nullable: true),
                    ResetTokenExpiresAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PasswordResetVerifications", x => x.Email);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PasswordResetVerifications");

            migrationBuilder.DropColumn(
                name: "LastSentAtUtc",
                table: "EmailVerifications");
        }
    }
}
