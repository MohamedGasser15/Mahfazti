using System;
using System.Collections.Generic;

namespace Mahfazti.Core.DTOs.Ai
{
    public class AiChatRequestDto
    {
        public string? ConversationId { get; set; }
        public string Message { get; set; } = string.Empty;
        public string Language { get; set; } = "ar";
    }

    public class AiChatResponseDto
    {
        public string ConversationId { get; set; } = string.Empty;
        public string Reply { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    }

    public class AiConversationDto
    {
        public string Id { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int MessagesCount { get; set; }
        public string? LastMessageSnippet { get; set; }
    }

    public class AiMessageDto
    {
        public int Id { get; set; }
        public string ConversationId { get; set; } = string.Empty;
        public string Role { get; set; } = "user"; // user, assistant
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }

    public class VoiceParseRequestDto
    {
        public string Text { get; set; } = string.Empty;
        public string Language { get; set; } = "ar";
    }

    public class ParsedExpenseResponseDto
    {
        public string Title { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public string Type { get; set; } = "Withdrawal"; // Deposit, Withdrawal
        public int? CategoryId { get; set; }
        public string? CategoryName { get; set; }
        public int? AccountId { get; set; }
        public string? AccountName { get; set; }
        public string? Currency { get; set; } = "EGP";
        public double Confidence { get; set; } = 1.0;
        public string? RawText { get; set; }
    }
}
