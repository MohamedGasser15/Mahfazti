using System.Collections.Generic;

namespace Mahfazti.Core.DTOs.Subscription
{
    public class PricingPlanDto
    {
        public string Id { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string NameAr { get; set; } = string.Empty;
        public decimal PriceEgp { get; set; }
        public string BillingCycle { get; set; } = "Monthly";
        public string Description { get; set; } = string.Empty;
        public string DescriptionAr { get; set; } = string.Empty;
        public List<string> Features { get; set; } = new();
        public List<string> FeaturesAr { get; set; } = new();
        public bool IsPopular { get; set; }
        public bool IsActive { get; set; }
        public int DisplayOrder { get; set; }
        public int MaxWallets { get; set; }
        public int MaxAiRequestsPerMonth { get; set; }
        public bool CanExportReports { get; set; }
        public bool CanUseMultiCurrency { get; set; }
    }

    public class CreatePricingPlanDto
    {
        public string? Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string NameAr { get; set; } = string.Empty;
        public decimal PriceEgp { get; set; }
        public string BillingCycle { get; set; } = "Monthly";
        public string Description { get; set; } = string.Empty;
        public string DescriptionAr { get; set; } = string.Empty;
        public List<string> Features { get; set; } = new();
        public List<string> FeaturesAr { get; set; } = new();
        public bool IsPopular { get; set; }
        public bool IsActive { get; set; } = true;
        public int DisplayOrder { get; set; } = 0;
        public int MaxWallets { get; set; } = 1;
        public int MaxAiRequestsPerMonth { get; set; } = 15;
        public bool CanExportReports { get; set; }
        public bool CanUseMultiCurrency { get; set; }
    }

    public class UpdatePricingPlanDto
    {
        public string Name { get; set; } = string.Empty;
        public string NameAr { get; set; } = string.Empty;
        public decimal PriceEgp { get; set; }
        public string BillingCycle { get; set; } = "Monthly";
        public string Description { get; set; } = string.Empty;
        public string DescriptionAr { get; set; } = string.Empty;
        public List<string> Features { get; set; } = new();
        public List<string> FeaturesAr { get; set; } = new();
        public bool IsPopular { get; set; }
        public bool IsActive { get; set; }
        public int DisplayOrder { get; set; }
        public int MaxWallets { get; set; }
        public int MaxAiRequestsPerMonth { get; set; }
        public bool CanExportReports { get; set; }
        public bool CanUseMultiCurrency { get; set; }
    }

    public class ReorderPricingPlansDto
    {
        public List<string> PlanIds { get; set; } = new();
    }
}
