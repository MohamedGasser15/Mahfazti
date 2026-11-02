using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Mahfazti.Core.Entities
{
    /// <summary>
    /// Represents any financial account, wallet, card, cash container, or asset owned by the user.
    /// Types: bank, credit_card, cash, ewallet, savings, investment, gold, silver, certificate.
    /// </summary>
    public class Account
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        [MaxLength(60)]
        public string? InstitutionId { get; set; }

        [ForeignKey(nameof(InstitutionId))]
        public virtual FinancialInstitution? Institution { get; set; }

        [Required]
        [MaxLength(120)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(40)]
        public string Type { get; set; } = "cash"; // bank, credit_card, cash, ewallet, savings, investment, gold, silver, certificate

        [Required]
        [MaxLength(10)]
        public string Currency { get; set; } = "EGP";

        [Column(TypeName = "decimal(18,2)")]
        public decimal Balance { get; set; } = 0.0m;

        [Column(TypeName = "decimal(18,2)")]
        public decimal InitialBalance { get; set; } = 0.0m;

        [MaxLength(50)]
        public string? AccountNumber { get; set; }

        public int IconCode { get; set; } = 0;

        public bool IsMain { get; set; } = false;

        public bool ExcludeFromTotal { get; set; } = false;

        // SMS & Notification tracking
        [MaxLength(30)]
        public string? NotificationMethod { get; set; } // sms, notification

        public string? CardNumbersJson { get; set; } // JSON array of card digits

        public bool ReceiveAtmWithdrawals { get; set; } = false;

        // Credit Cards specific
        [Column(TypeName = "decimal(18,2)")]
        public decimal? CreditLimit { get; set; }

        public int? BillingDay { get; set; }

        public int? DueDay { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        public decimal? MinPaymentPercentage { get; set; }

        // E-Wallets specific
        public bool AutoAddInstapayFee { get; set; } = false;

        // Metals (Gold / Silver) specific
        [MaxLength(20)]
        public string? MetalKarat { get; set; } // 24, 21, 18

        [Column(TypeName = "decimal(18,3)")]
        public decimal? MetalWeightGrams { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? MetalPurchasePricePerGram { get; set; }

        public DateTime? MetalPurchaseDate { get; set; }

        public bool AutoUpdateMetalPrice { get; set; } = true;

        // Investments & Assets specific
        [MaxLength(40)]
        public string? PropertyCategory { get; set; } // fund, apartment, car, business, stocksCrypto, somethingElse

        [MaxLength(40)]
        public string? InvestmentPlatform { get; set; } // egx, us_stocks, crypto, other

        [Column(TypeName = "decimal(18,2)")]
        public decimal? TotalInvestedAmount { get; set; }

        [Column(TypeName = "decimal(5,2)")]
        public decimal? AnnualYieldRate { get; set; }

        public bool AutoEstimateValue { get; set; } = false;

        // Savings / Goals specific
        [Column(TypeName = "decimal(18,2)")]
        public decimal? TargetSavingsGoal { get; set; }

        [MaxLength(500)]
        public string? Note { get; set; }

        public bool IsDeleted { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        // Navigation Collections
        public virtual ICollection<WalletTransaction> Transactions { get; set; } = new List<WalletTransaction>();
        public virtual ICollection<WalletTransaction> TransfersIn { get; set; } = new List<WalletTransaction>();
        public virtual ICollection<UserRecurringBill> RecurringBills { get; set; } = new List<UserRecurringBill>();
    }
}
