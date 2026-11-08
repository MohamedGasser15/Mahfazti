using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Mahfazti.Core.Entities
{
    /// <summary>
    /// Represents an AI chat session / conversation between the user and the financial advisor.
    /// </summary>
    public class AiConversation
    {
        [Key]
        [MaxLength(60)]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [Required]
        public string UserId { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = "محادثة مالية";

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        public virtual ICollection<AiMessage> Messages { get; set; } = new List<AiMessage>();
    }
}
