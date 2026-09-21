using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Mahfazti.Core.Entities;

namespace Mahfazti.Infrastructure.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser, ApplicationRole, int>
    {
        public DbSet<WalletTransaction> WalletTransactions { get; set; }
        public DbSet<CategoryBudget> CategoryBudgets { get; set; }
        public DbSet<UserBudget> UserBudgets { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
        public DbSet<AuditLog> AuditLogs { get; set; }
        public DbSet<Currency> Currencies { get; set; }
        public DbSet<PricingPlan> PricingPlans { get; set; }
        public DbSet<UserSubscription> UserSubscriptions { get; set; }
        public DbSet<PaymentLog> PaymentLogs { get; set; }
        public DbSet<PromoCode> PromoCodes { get; set; }

        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.Entity<WalletTransaction>().HasQueryFilter(t => !t.IsDeleted);

            // Make PhoneNumber unique
            builder.Entity<ApplicationUser>()
                .HasIndex(u => u.PhoneNumber)
                .IsUnique()
                .HasFilter("[PhoneNumber] IS NOT NULL");

            builder.Entity<WalletTransaction>()
                .HasOne(wt => wt.Category)
                .WithMany(c => c.Transactions)
                .HasForeignKey(wt => wt.CategoryId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.Entity<CategoryBudget>()
                .HasOne(cb => cb.Category)
                .WithMany()
                .HasForeignKey(cb => cb.CategoryId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<RefreshToken>()
                .HasOne(rt => rt.User)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(rt => rt.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<AuditLog>()
                .HasOne(al => al.Admin)
                .WithMany()
                .HasForeignKey(al => al.AdminId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.Entity<AuditLog>()
                .HasIndex(al => al.CreatedAt);

            builder.Entity<AuditLog>()
                .HasIndex(al => al.Category);

            builder.Entity<Currency>()
                .Property(c => c.ExchangeRateToEgp)
                .HasColumnType("decimal(18,4)");
        }
    }
}
