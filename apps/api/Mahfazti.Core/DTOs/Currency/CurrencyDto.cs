using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.DTOs.Currency
{
    public class CurrencyDto
    {
        public string Code { get; set; } = string.Empty;
        public string NameEn { get; set; } = string.Empty;
        public string NameAr { get; set; } = string.Empty;
        public string Symbol { get; set; } = string.Empty;
        public decimal ExchangeRateToEgp { get; set; }
        public bool IsDefault { get; set; }
        public bool IsActive { get; set; }
        public bool IsFeatured { get; set; }
        public DateTime LastUpdated { get; set; }
    }

    public class CreateCurrencyDto
    {
        [Required]
        [MaxLength(10)]
        public string Code { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string NameEn { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string NameAr { get; set; } = string.Empty;

        [Required]
        [MaxLength(10)]
        public string Symbol { get; set; } = string.Empty;

        [Range(0.000001, 1000000)]
        public decimal ExchangeRateToEgp { get; set; } = 1.0m;

        public bool IsActive { get; set; } = true;
    }

    public class UpdateCurrencyRateDto
    {
        [Required]
        [Range(0.000001, 1000000)]
        public decimal ExchangeRateToEgp { get; set; }
    }
}
