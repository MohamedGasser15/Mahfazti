using System;
using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.Entities
{
    /// <summary>
    /// Represents a bank, neo-bank, digital wallet, or fintech financial institution.
    /// </summary>
    public class FinancialInstitution
    {
        [Key]
        [MaxLength(60)]
        public string Id { get; set; } = string.Empty;

        [Required]
        [MaxLength(150)]
        public string NameAr { get; set; } = string.Empty;

        [Required]
        [MaxLength(150)]
        public string NameEn { get; set; } = string.Empty;

        [MaxLength(60)]
        public string ShortName { get; set; } = string.Empty;

        [MaxLength(20)]
        public string? SwiftCode { get; set; }

        [Required]
        [MaxLength(50)]
        public string Category { get; set; } = "egyptian"; // "egyptian", "fintech", "international"

        [MaxLength(10)]
        public string CountryCode { get; set; } = "EG";

        [MaxLength(500)]
        public string? LogoAsset { get; set; }

        [MaxLength(500)]
        public string? LogoUrl { get; set; }

        [MaxLength(500)]
        public string? Website { get; set; }

        public bool IsPopular { get; set; } = false;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
