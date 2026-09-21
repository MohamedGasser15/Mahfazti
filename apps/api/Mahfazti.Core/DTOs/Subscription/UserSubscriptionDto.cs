using System;

namespace Mahfazti.Core.DTOs.Subscription
{
    public class UserSubscriptionDto
    {
        public string Id { get; set; } = string.Empty;
        public string UserId { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public string PlanId { get; set; } = string.Empty;
        public string PlanName { get; set; } = string.Empty;
        public string Status { get; set; } = "Active";
        public decimal AmountPaidEgp { get; set; }
        public string Gateway { get; set; } = "Paymob";
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool AutoRenew { get; set; }
    }

    public class SubscriptionStatsDto
    {
        public decimal MonthlyRecurringRevenue { get; set; }
        public int ActivePaidSubscribers { get; set; }
        public int ExpiredSubscribers { get; set; }
        public int TotalSubscribers { get; set; }
        public decimal ChurnRatePercentage { get; set; }
    }
}
