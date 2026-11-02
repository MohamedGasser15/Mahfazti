using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.Entities
{
    /// <summary>
    /// User-created category groups (e.g. Needs, Wants, Savings, or custom groupings like House, Travel).
    /// </summary>
    public class UserCategoryGroup
    {
        [Key]
        [MaxLength(60)]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [Required]
        public string UserId { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public int ColorValue { get; set; } = unchecked((int)0xFF6366F1);

        public int IconIndex { get; set; } = 0;

        public int DisplayOrder { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        public virtual ICollection<Category> Categories { get; set; } = new List<Category>();
    }
}
