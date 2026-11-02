using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Mahfazti.Core.Entities
{
    public class Category
    {
        public int Id { get; set; }

        /// <summary>
        /// Null for system-wide default categories, or set to UserId for custom user-created categories.
        /// </summary>
        public string? UserId { get; set; }

        [MaxLength(60)]
        public string? GroupId { get; set; }

        [ForeignKey(nameof(GroupId))]
        public virtual UserCategoryGroup? Group { get; set; }

        [Required]
        [MaxLength(100)]
        public string NameAr { get; set; } = string.Empty; 

        [Required]
        [MaxLength(100)]
        public string NameEn { get; set; } = string.Empty; 

        [Required]
        [MaxLength(30)]
        public string Type { get; set; } = "Expense"; // Expense, Income, Both

        [MaxLength(60)]
        public string Icon { get; set; } = "layers";

        [MaxLength(20)]
        public string? ColorHex { get; set; }

        public int DisplayOrder { get; set; } = 0;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        public virtual ICollection<WalletTransaction>? Transactions { get; set; }
        public virtual ICollection<UserRecurringBill>? RecurringBills { get; set; }
    }
}
