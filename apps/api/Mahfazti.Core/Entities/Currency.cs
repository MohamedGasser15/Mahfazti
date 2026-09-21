using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.Entities
{
    public class Currency
    {
        [Key]
        [MaxLength(10)]
        public string Code { get; set; } = string.Empty; // e.g. EGP, USD, EUR, SAR

        [Required]
        [MaxLength(100)]
        public string NameEn { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string NameAr { get; set; } = string.Empty;

        [Required]
        [MaxLength(10)]
        public string Symbol { get; set; } = string.Empty;

        public decimal ExchangeRateToEgp { get; set; } = 1.0m; // 1 Currency = X EGP

        public bool IsDefault { get; set; } = false;

        public bool IsActive { get; set; } = true;

        public bool IsFeatured { get; set; } = false;

        public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
    }
}
