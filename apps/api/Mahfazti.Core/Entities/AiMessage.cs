using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Mahfazti.Core.Entities
{
    /// <summary>
    /// Represents a single message in an AI financial consultation session.
    /// Role: "user" or "assistant".
    /// </summary>
    public class AiMessage
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(60)]
        public string ConversationId { get; set; } = string.Empty;

        [ForeignKey(nameof(ConversationId))]
        public virtual AiConversation? Conversation { get; set; }

        [Required]
        [MaxLength(30)]
        public string Role { get; set; } = "user"; // user, assistant

        [Required]
        public string Content { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
