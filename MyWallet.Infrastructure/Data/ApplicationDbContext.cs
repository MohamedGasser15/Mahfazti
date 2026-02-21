using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using MyWallet.Domain.Entites;
using MyWallet.Infrastructure.Entities;
using MyWallet.Infrastructure.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyWallet.Infrastructure.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser, ApplicationRole, int>
    {
        // Infrastructure/Data/ApplicationDbContext.cs
        public DbSet<WalletTransaction> WalletTransactions { get; set; }
        public DbSet<CategoryBudget> CategoryBudgets { get; set; }

        public DbSet<UserBudget> UserBudgets { get; set; }

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
        }
    }
}
