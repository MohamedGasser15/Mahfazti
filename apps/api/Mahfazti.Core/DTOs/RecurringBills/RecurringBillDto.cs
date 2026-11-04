using System;

namespace Mahfazti.Core.DTOs.RecurringBills
{
    public class RecurringBillDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "EGP";
        public string BillingCycle { get; set; } = "monthly";
        public int RenewalDay { get; set; }
        public DateTime? NextDueDate { get; set; }
        public int? AccountId { get; set; }
        public string? AccountName { get; set; }
        public int? CategoryId { get; set; }
        public string? CategoryNameAr { get; set; }
        public string? CategoryNameEn { get; set; }
        public int IconCode { get; set; }
        public bool IsActive { get; set; }
        public bool AutoRecordTransaction { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateRecurringBillDto
    {
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "EGP";
        public string BillingCycle { get; set; } = "monthly";
        public int RenewalDay { get; set; } = 1;
        public DateTime? NextDueDate { get; set; }
        public int? AccountId { get; set; }
        public int? CategoryId { get; set; }
        public int IconCode { get; set; }
        public bool IsActive { get; set; } = true;
        public bool AutoRecordTransaction { get; set; } = true;
    }

    public class UpdateRecurringBillDto : CreateRecurringBillDto
    {
    }
}
