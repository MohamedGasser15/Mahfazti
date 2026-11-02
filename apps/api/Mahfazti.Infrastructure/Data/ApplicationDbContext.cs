using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Mahfazti.Core.Entities;

namespace Mahfazti.Infrastructure.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser, ApplicationRole, int>
    {
        public DbSet<Account> Accounts { get; set; }
        public DbSet<WalletTransaction> WalletTransactions { get; set; }
        public DbSet<CategoryBudget> CategoryBudgets { get; set; }
        public DbSet<UserBudget> UserBudgets { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<UserCategoryGroup> UserCategoryGroups { get; set; }
        public DbSet<UserPreference> UserPreferences { get; set; }
        public DbSet<UserRecurringBill> UserRecurringBills { get; set; }
        public DbSet<AiConversation> AiConversations { get; set; }
        public DbSet<AiMessage> AiMessages { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }
        public DbSet<AuditLog> AuditLogs { get; set; }
        public DbSet<Currency> Currencies { get; set; }
        public DbSet<PricingPlan> PricingPlans { get; set; }
        public DbSet<UserSubscription> UserSubscriptions { get; set; }
        public DbSet<PaymentLog> PaymentLogs { get; set; }
        public DbSet<PromoCode> PromoCodes { get; set; }
        public DbSet<FinancialInstitution> FinancialInstitutions { get; set; }
        public DbSet<EmailVerification> EmailVerifications { get; set; }
        public DbSet<PasswordResetVerification> PasswordResetVerifications { get; set; }

        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.Entity<EmailVerification>(entity =>
            {
                entity.HasKey(v => v.Email);
                entity.Property(v => v.Email).HasMaxLength(256);
                entity.Property(v => v.CodeHash).HasMaxLength(512);
            });

            builder.Entity<PasswordResetVerification>(entity =>
            {
                entity.HasKey(v => v.Email);
                entity.Property(v => v.Email).HasMaxLength(256);
                entity.Property(v => v.CodeHash).HasMaxLength(512);
                entity.Property(v => v.ResetTokenHash).HasMaxLength(512);
            });

            // Soft-delete query filters
            builder.Entity<WalletTransaction>().HasQueryFilter(t => !t.IsDeleted);
            builder.Entity<Account>().HasQueryFilter(a => !a.IsDeleted);
            builder.Entity<UserRecurringBill>().HasQueryFilter(b => !b.IsDeleted);

            // Make PhoneNumber unique
            builder.Entity<ApplicationUser>()
                .HasIndex(u => u.PhoneNumber)
                .IsUnique()
                .HasFilter("[PhoneNumber] IS NOT NULL");

            // Account relationships
            builder.Entity<Account>()
                .HasOne(a => a.Institution)
                .WithMany()
                .HasForeignKey(a => a.InstitutionId)
                .OnDelete(DeleteBehavior.SetNull);

            // Transaction relationships
            builder.Entity<WalletTransaction>()
                .HasOne(wt => wt.Category)
                .WithMany(c => c.Transactions)
                .HasForeignKey(wt => wt.CategoryId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.Entity<WalletTransaction>()
                .HasOne(wt => wt.Account)
                .WithMany(a => a.Transactions)
                .HasForeignKey(wt => wt.AccountId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.Entity<WalletTransaction>()
                .HasOne(wt => wt.ToAccount)
                .WithMany(a => a.TransfersIn)
                .HasForeignKey(wt => wt.ToAccountId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.Entity<WalletTransaction>()
                .HasOne(wt => wt.RecurringBill)
                .WithMany()
                .HasForeignKey(wt => wt.RecurringBillId)
                .OnDelete(DeleteBehavior.SetNull);

            // Category relationships
            builder.Entity<Category>()
                .HasOne(c => c.Group)
                .WithMany(g => g.Categories)
                .HasForeignKey(c => c.GroupId)
                .OnDelete(DeleteBehavior.SetNull);

            // CategoryBudget relationships
            builder.Entity<CategoryBudget>()
                .HasOne(cb => cb.Category)
                .WithMany()
                .HasForeignKey(cb => cb.CategoryId)
                .OnDelete(DeleteBehavior.Cascade);

            // UserRecurringBill relationships
            builder.Entity<UserRecurringBill>()
                .HasOne(b => b.Account)
                .WithMany(a => a.RecurringBills)
                .HasForeignKey(b => b.AccountId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.Entity<UserRecurringBill>()
                .HasOne(b => b.Category)
                .WithMany(c => c.RecurringBills)
                .HasForeignKey(b => b.CategoryId)
                .OnDelete(DeleteBehavior.SetNull);

            // AI Chat relationships
            builder.Entity<AiMessage>()
                .HasOne(m => m.Conversation)
                .WithMany(c => c.Messages)
                .HasForeignKey(m => m.ConversationId)
                .OnDelete(DeleteBehavior.Cascade);

            // RefreshToken relationships
            builder.Entity<RefreshToken>()
                .HasOne(rt => rt.User)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(rt => rt.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // AuditLog
            builder.Entity<AuditLog>()
                .HasOne(al => al.Admin)
                .WithMany()
                .HasForeignKey(al => al.AdminId)
                .OnDelete(DeleteBehavior.SetNull);

            builder.Entity<AuditLog>()
                .HasIndex(al => al.CreatedAt);

            builder.Entity<AuditLog>()
                .HasIndex(al => al.Category);

            // Currency & Budgets precision
            builder.Entity<Currency>()
                .Property(c => c.ExchangeRateToEgp)
                .HasColumnType("decimal(18,4)");

            builder.Entity<CategoryBudget>()
                .Property(cb => cb.BudgetAmount)
                .HasColumnType("decimal(18,2)");

            builder.Entity<UserBudget>()
                .Property(ub => ub.MonthlyBudget)
                .HasColumnType("decimal(18,2)");
        }
    }
}
