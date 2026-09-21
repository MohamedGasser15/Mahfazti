using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Mahfazti.Core.Entities
{
    public class PromoCode
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [Required]
        [MaxLength(50)]
        public string Code { get; set; } = string.Empty;

        [Range(1, 100)]
        public int DiscountPercentage { get; set; }

        public int MaxUses { get; set; } = 100;

        public int UsedCount { get; set; } = 0;

        public DateTime? ExpiresAt { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
