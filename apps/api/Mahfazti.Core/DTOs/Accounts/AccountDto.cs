using System;

namespace Mahfazti.Core.DTOs.Accounts
{
    public class AccountDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = "cash";
        public string Currency { get; set; } = "EGP";
        public decimal Balance { get; set; }
        public decimal InitialBalance { get; set; }
        public string? InstitutionId { get; set; }
        public string? InstitutionNameAr { get; set; }
        public string? InstitutionNameEn { get; set; }
        public string? InstitutionLogoUrl { get; set; }
        public string? AccountNumber { get; set; }
        public int IconCode { get; set; }
        public bool IsMain { get; set; }
        public bool ExcludeFromTotal { get; set; }

        // SMS & Notifications
        public string? NotificationMethod { get; set; }
        public string? CardNumbersJson { get; set; }
        public bool ReceiveAtmWithdrawals { get; set; }

        // Credit Cards
        public decimal? CreditLimit { get; set; }
        public int? BillingDay { get; set; }
        public int? DueDay { get; set; }
        public decimal? MinPaymentPercentage { get; set; }

        // E-Wallets
        public bool AutoAddInstapayFee { get; set; }

        // Metals (Gold / Silver)
        public string? MetalKarat { get; set; }
        public decimal? MetalWeightGrams { get; set; }
        public decimal? MetalPurchasePricePerGram { get; set; }
        public DateTime? MetalPurchaseDate { get; set; }
        public bool AutoUpdateMetalPrice { get; set; }

        // Investments
        public string? PropertyCategory { get; set; }
        public string? InvestmentPlatform { get; set; }
        public decimal? TotalInvestedAmount { get; set; }
        public decimal? AnnualYieldRate { get; set; }
        public bool AutoEstimateValue { get; set; }

        // Savings Goal
        public decimal? TargetSavingsGoal { get; set; }
        public string? Note { get; set; }

        public DateTime CreatedAt { get; set; }
    }

    public class CreateAccountDto
    {
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = "cash";
        public string Currency { get; set; } = "EGP";
        public decimal Balance { get; set; }
        public string? InstitutionId { get; set; }
        public string? AccountNumber { get; set; }
        public int IconCode { get; set; }
        public bool IsMain { get; set; }
        public bool ExcludeFromTotal { get; set; }

        public string? NotificationMethod { get; set; }
        public string? CardNumbersJson { get; set; }
        public bool ReceiveAtmWithdrawals { get; set; }

        public decimal? CreditLimit { get; set; }
        public int? BillingDay { get; set; }
        public int? DueDay { get; set; }
        public decimal? MinPaymentPercentage { get; set; }

        public bool AutoAddInstapayFee { get; set; }

        public string? MetalKarat { get; set; }
        public decimal? MetalWeightGrams { get; set; }
        public decimal? MetalPurchasePricePerGram { get; set; }
        public DateTime? MetalPurchaseDate { get; set; }
        public bool AutoUpdateMetalPrice { get; set; } = true;

        public string? PropertyCategory { get; set; }
        public string? InvestmentPlatform { get; set; }
        public decimal? TotalInvestedAmount { get; set; }
        public decimal? AnnualYieldRate { get; set; }
        public bool AutoEstimateValue { get; set; }

        public decimal? TargetSavingsGoal { get; set; }
        public string? Note { get; set; }
    }

    public class UpdateAccountDto : CreateAccountDto
    {
    }

    public class TotalWealthSummaryDto
    {
        public decimal NetWorth { get; set; }
        public decimal TotalLiquidBalance { get; set; }
        public decimal TotalAssetsValue { get; set; }
        public decimal TotalDebtsAndCredit { get; set; }
        public string BaseCurrency { get; set; } = "EGP";
        public int AccountsCount { get; set; }
    }
}
