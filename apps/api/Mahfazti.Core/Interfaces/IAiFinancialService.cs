using System.Collections.Generic;
using System.Threading.Tasks;
using Mahfazti.Core.DTOs.Ai;

namespace Mahfazti.Core.Interfaces
{
    public interface IAiFinancialService
    {
        Task<AiChatResponseDto> ChatAsync(string userId, AiChatRequestDto request);
        Task<List<AiConversationDto>> GetConversationsAsync(string userId);
        Task<List<AiMessageDto>> GetConversationMessagesAsync(string conversationId, string userId);
        Task<bool> DeleteConversationAsync(string conversationId, string userId);
        Task<ParsedExpenseResponseDto> ParseVoiceExpenseAsync(string userId, string text, string language = "ar");
    }
}
