using System;

namespace Mahfazti.Core.DTOs.Subscription
{
    public class PaymentLogDto
    {
        public string Id { get; set; } = string.Empty;
        public string InvoiceNumber { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public string PlanName { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Currency { get; set; } = "EGP";
        public string Gateway { get; set; } = "Paymob";
        public string Status { get; set; } = "Success";
        public string TransactionRef { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }
}
