using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Mahfazti.Core.DTOs.Ai;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Api.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AiController : ControllerBase
    {
        private readonly IAiFinancialService _aiService;

        public AiController(IAiFinancialService aiService)
        {
            _aiService = aiService;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? throw new UnauthorizedAccessException("User ID not found");
        }

        /// <summary>
        /// Sends a message to the AI Financial Advisor with user context and conversation history.
        /// </summary>
        [HttpPost("chat")]
        public async Task<IActionResult> Chat([FromBody] AiChatRequestDto request)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
            {
                return BadRequest(new { message = "Message content is required" });
            }

            var userId = GetUserId();
            var response = await _aiService.ChatAsync(userId, request);
            return Ok(response);
        }

        /// <summary>
        /// Gets all past AI conversation sessions for the user.
        /// </summary>
        [HttpGet("conversations")]
        public async Task<IActionResult> GetConversations()
        {
            var userId = GetUserId();
            var list = await _aiService.GetConversationsAsync(userId);
            return Ok(list);
        }

        /// <summary>
        /// Gets messages within a specific conversation.
        /// </summary>
        [HttpGet("conversations/{conversationId}/messages")]
        public async Task<IActionResult> GetMessages(string conversationId)
        {
            var userId = GetUserId();
            var messages = await _aiService.GetConversationMessagesAsync(conversationId, userId);
            return Ok(messages);
        }

        /// <summary>
        /// Deletes a conversation session.
        /// </summary>
        [HttpDelete("conversations/{conversationId}")]
        public async Task<IActionResult> DeleteConversation(string conversationId)
        {
            var userId = GetUserId();
            var success = await _aiService.DeleteConversationAsync(conversationId, userId);
            if (!success) return NotFound(new { message = "Conversation not found" });
            return Ok(new { message = "Conversation deleted successfully" });
        }

        /// <summary>
        /// Parses voice or free-text expense into structured transaction JSON.
        /// </summary>
        [HttpPost("voice-parse")]
        public async Task<IActionResult> ParseVoice([FromBody] VoiceParseRequestDto request)
        {
            if (string.IsNullOrWhiteSpace(request.Text))
            {
                return BadRequest(new { message = "Text is required" });
            }

            var userId = GetUserId();
            var parsed = await _aiService.ParseVoiceExpenseAsync(userId, request.Text, request.Language);
            return Ok(parsed);
        }
    }
}
