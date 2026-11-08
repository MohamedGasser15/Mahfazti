using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Mahfazti.Core.DTOs.Ai;
using Mahfazti.Core.Entities;
using Mahfazti.Core.Interfaces;

namespace Mahfazti.Core.Services
{
    public class AiFinancialService : IAiFinancialService
    {
        private readonly HttpClient _httpClient;
        private readonly IRepository<AiConversation> _convRepo;
        private readonly IRepository<AiMessage> _msgRepo;
        private readonly IRepository<Account> _accountRepo;
        private readonly IRepository<WalletTransaction> _transactionRepo;
        private readonly IRepository<Category> _categoryRepo;
        private readonly IRepository<UserBudget> _budgetRepo;
        private readonly IVoiceExpenseService _fallbackVoiceService;
        private readonly IConfiguration _config;
        private readonly ILogger<AiFinancialService> _logger;

        public AiFinancialService(
            HttpClient httpClient,
            IRepository<AiConversation> convRepo,
            IRepository<AiMessage> msgRepo,
            IRepository<Account> accountRepo,
            IRepository<WalletTransaction> transactionRepo,
            IRepository<Category> categoryRepo,
            IRepository<UserBudget> budgetRepo,
            IVoiceExpenseService fallbackVoiceService,
            IConfiguration config,
            ILogger<AiFinancialService> logger)
        {
            _httpClient = httpClient;
            _convRepo = convRepo;
            _msgRepo = msgRepo;
            _accountRepo = accountRepo;
            _transactionRepo = transactionRepo;
            _categoryRepo = categoryRepo;
            _budgetRepo = budgetRepo;
            _fallbackVoiceService = fallbackVoiceService;
            _config = config;
            _logger = logger;
        }

        public async Task<AiChatResponseDto> ChatAsync(string userId, AiChatRequestDto request)
        {
            var userText = request.Message?.Trim() ?? string.Empty;
            if (string.IsNullOrWhiteSpace(userText))
            {
                return new AiChatResponseDto
                {
                    ConversationId = request.ConversationId ?? string.Empty,
                    Reply = "أهلاً بك! كيف يمكنني مساعدتك مالياً اليوم؟"
                };
            }

            // 1. Resolve or create conversation
            AiConversation? conversation = null;
            if (!string.IsNullOrEmpty(request.ConversationId))
            {
                conversation = await _convRepo.GetAsync(c => c.Id == request.ConversationId && c.UserId == userId);
            }

            if (conversation == null)
            {
                var titleSnippet = userText.Length > 35 ? userText.Substring(0, 35) + "..." : userText;
                conversation = new AiConversation
                {
                    Id = Guid.NewGuid().ToString(),
                    UserId = userId,
                    Title = titleSnippet,
                    CreatedAt = DateTime.UtcNow
                };
                await _convRepo.CreateAsync(conversation);
                await _convRepo.SaveAsync();
            }

            // Save user message
            var userMsgEntity = new AiMessage
            {
                ConversationId = conversation.Id,
                Role = "user",
                Content = userText,
                CreatedAt = DateTime.UtcNow
            };
            await _msgRepo.CreateAsync(userMsgEntity);
            await _msgRepo.SaveAsync();

            // 2. Load context: accounts, current month transactions, budget
            var contextPrompt = await BuildUserFinancialContextAsync(userId);

            // 3. Load previous messages in this conversation (up to last 10)
            var history = await _msgRepo.GetAllAsync(
                filter: m => m.ConversationId == conversation.Id,
                orderBy: q => q.OrderByDescending(m => m.CreatedAt),
                take: 10,
                isTracking: false
            );
            history.Reverse();

            // 4. Call Gemini
            string assistantReply;
            try
            {
                assistantReply = await CallGeminiAsync(
                    contextPrompt, history, userText, request.Language);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Gemini call failed, generating contextual fallback response.");
                assistantReply = GenerateFallbackChatResponse(
                    userText, contextPrompt, request.Language);
            }

            // Save assistant message
            var assistantMsgEntity = new AiMessage
            {
                ConversationId = conversation.Id,
                Role = "assistant",
                Content = assistantReply,
                CreatedAt = DateTime.UtcNow
            };
            await _msgRepo.CreateAsync(assistantMsgEntity);

            conversation.UpdatedAt = DateTime.UtcNow;
            await _convRepo.UpdateAsync(conversation);
            await _convRepo.SaveAsync();

            return new AiChatResponseDto
            {
                ConversationId = conversation.Id,
                Reply = assistantReply,
                Timestamp = DateTime.UtcNow
            };
        }

        public async Task<List<AiConversationDto>> GetConversationsAsync(string userId)
        {
            var list = await _convRepo.GetAllAsync(
                filter: c => c.UserId == userId,
                includeProperties: "Messages",
                orderBy: q => q.OrderByDescending(c => c.UpdatedAt ?? c.CreatedAt),
                isTracking: false
            );

            return list.Select(c => new AiConversationDto
            {
                Id = c.Id,
                Title = c.Title,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt,
                MessagesCount = c.Messages?.Count ?? 0,
                LastMessageSnippet = c.Messages?.OrderByDescending(m => m.CreatedAt).FirstOrDefault()?.Content
            }).ToList();
        }

        public async Task<List<AiMessageDto>> GetConversationMessagesAsync(string conversationId, string userId)
        {
            var conversation = await _convRepo.GetAsync(c => c.Id == conversationId && c.UserId == userId);
            if (conversation == null) return new List<AiMessageDto>();

            var messages = await _msgRepo.GetAllAsync(
                filter: m => m.ConversationId == conversationId,
                orderBy: q => q.OrderBy(m => m.CreatedAt),
                isTracking: false
            );

            return messages.Select(m => new AiMessageDto
            {
                Id = m.Id,
                ConversationId = m.ConversationId,
                Role = m.Role,
                Content = m.Content,
                CreatedAt = m.CreatedAt
            }).ToList();
        }

        public async Task<bool> DeleteConversationAsync(string conversationId, string userId)
        {
            var conversation = await _convRepo.GetAsync(c => c.Id == conversationId && c.UserId == userId, isTracking: true);
            if (conversation == null) return false;

            await _convRepo.DeleteAsync(conversation);
            await _convRepo.SaveAsync();
            return true;
        }

        public async Task<ParsedExpenseResponseDto> ParseVoiceExpenseAsync(
            string userId,
            string text,
            string language = "ar")
        {
            if (string.IsNullOrWhiteSpace(text))
            {
                return new ParsedExpenseResponseDto { RawText = text };
            }

            var categories = await _categoryRepo.GetAllAsync(c => c.IsActive && (c.UserId == null || c.UserId == userId), isTracking: false);
            var accounts = await _accountRepo.GetAllAsync(a => a.UserId == userId && !a.IsDeleted, isTracking: false);

            try
            {
                var apiKey = _config["Gemini:ApiKey"];

                if (string.IsNullOrWhiteSpace(apiKey))
                {
                    throw new InvalidOperationException("Gemini API key is not configured");
                }

                var catListStr = string.Join(", ", categories.Select(c => $"[Id:{c.Id}, Name:{c.NameAr}/{c.NameEn}]"));
                var accListStr = string.Join(", ", accounts.Select(a => $"[Id:{a.Id}, Name:{a.Name}]"));

                var languageInstructions = string.Equals(language, "en", StringComparison.OrdinalIgnoreCase)
                    ? "The spoken text may be English or Arabic. Use the language of the text for title and categoryName."
                    : "حلل النص العربي أو الإنجليزي وأعد العنوان واسم التصنيف باللغة الأقرب للنص.";
                var prompt = $@"
You extract expense or income details for the Mahfazti app. {languageInstructions}
'{text}'

Available categories: {catListStr}
Available accounts: {accListStr}

Return JSON only with this exact shape:
{{
  ""title"": ""merchant or transaction title"",
  ""amount"": 250.0,
  ""type"": ""Withdrawal"", // use ""Deposit"" for income
  ""categoryId"": 1, // closest matching category id, or null
  ""categoryName"": ""category name"",
  ""accountId"": 1, // mentioned account id, or null
  ""currency"": ""EGP""
}}
Do not add text outside the JSON.";

                var primaryModel = _config["Gemini:Model"] ?? "gemini-3.5-flash";
                var fallbackModel = _config["Gemini:FallbackModel"] ?? "gemini-3.5-flash-lite";
                var models = new List<string> { primaryModel, fallbackModel }
                    .Distinct()
                    .ToList();

                var body = new
                {
                    contents = new[]
                    {
                        new { parts = new[] { new { text = prompt } } }
                    },
                    generationConfig = new
                    {
                        temperature = 0.1,
                        responseMimeType = "application/json"
                    }
                };

                var deadline = DateTime.UtcNow.AddSeconds(24);
                foreach (var model in models)
                {
                    try
                    {
                        var remaining = (deadline - DateTime.UtcNow).TotalSeconds;
                        if (remaining <= 0) break;
                        var endpoint = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";
                        using var cts = new System.Threading.CancellationTokenSource(
                            TimeSpan.FromSeconds(Math.Min(12, remaining)));
                        var response = await _httpClient.PostAsJsonAsync(endpoint, body, cts.Token);
                        if (response.IsSuccessStatusCode)
                        {
                            var jsonStr = await response.Content.ReadAsStringAsync();
                            using var doc = JsonDocument.Parse(jsonStr);
                            var candidates = doc.RootElement.GetProperty("candidates");
                            if (candidates.GetArrayLength() > 0)
                            {
                                var textContent = candidates[0].GetProperty("content").GetProperty("parts")[0].GetProperty("text").GetString();
                                if (!string.IsNullOrEmpty(textContent))
                                {
                                    var cleanJson = textContent.Trim();
                                    if (cleanJson.StartsWith("```json")) cleanJson = cleanJson.Replace("```json", "").Replace("```", "").Trim();

                                    var parsed = JsonSerializer.Deserialize<ParsedExpenseResponseDto>(cleanJson, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                                    if (parsed != null)
                                    {
                                        parsed.RawText = text;
                                        return parsed;
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "Voice parse attempt with Gemini model {Model} failed.", model);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Gemini voice parse failed or timed out. Falling back to keyword engine.");
            }

            // Fallback to local keyword engine
            var fallbackResult = await _fallbackVoiceService.ParseVoiceTextAsync(text, language);
            return new ParsedExpenseResponseDto
            {
                Title = fallbackResult.Title ?? fallbackResult.Note ?? text,
                Amount = fallbackResult.Amount ?? 0m,
                Type = fallbackResult.TransactionType,
                CategoryId = fallbackResult.CategoryId,
                CategoryName = fallbackResult.CategoryNameAr ?? fallbackResult.CategoryNameEn,
                Currency = "EGP",
                Confidence = fallbackResult.IsSuccess ? 0.8 : 0.4,
                RawText = text
            };
        }

        private async Task<string> CallGeminiAsync(
            string contextPrompt,
            List<AiMessage> history,
            string userMessage,
            string language)
        {
            var apiKey = _config["Gemini:ApiKey"];
            var primaryModel = _config["Gemini:Model"] ?? "gemini-3.5-flash";
            var fallbackModel = _config["Gemini:FallbackModel"] ?? "gemini-3.5-flash-lite";

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                throw new InvalidOperationException("Gemini API key is not set");
            }

            var models = new List<string> { primaryModel, fallbackModel }
                .Distinct()
                .ToList();

            var languageInstruction = string.Equals(language, "en", StringComparison.OrdinalIgnoreCase)
                ? "Reply in clear, concise English."
                : "تحدث بالعربية العامية المصرية المهذبة وباختصار واضح.";
            var systemInstruction = $@"
You are Mahfazti's personal finance assistant.
- Answer only questions about personal finances, spending, budgets, saving, investing, debt, currencies, gold, financial planning, or using Mahfazti.
- Politely decline unrelated questions and offer help with the user's finances.
- Never invent transaction amounts or claim data that is not present in the supplied context.
- Keep answers concise, direct, and easy to read on a phone.
- $languageInstruction

{contextPrompt}";

            var contents = new List<object>();

            // Add previous history
            foreach (var m in history.Take(history.Count - 1)) // skip the last userMsg which we append now
            {
                contents.Add(new
                {
                    role = m.Role == "user" ? "user" : "model",
                    parts = new[] { new { text = m.Content } }
                });
            }

            // Add current message
            contents.Add(new
            {
                role = "user",
                parts = new[] { new { text = userMessage } }
            });

            var payload = new
            {
                system_instruction = new { parts = new[] { new { text = systemInstruction } } },
                contents,
                generationConfig = new
                {
                    temperature = 0.4,
                    maxOutputTokens = 2048
                }
            };

            var deadline = DateTime.UtcNow.AddSeconds(24);
            foreach (var model in models)
            {
                try
                {
                    var remaining = (deadline - DateTime.UtcNow).TotalSeconds;
                    if (remaining <= 0) break;
                    var endpoint = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";
                    using var cts = new System.Threading.CancellationTokenSource(
                        TimeSpan.FromSeconds(Math.Min(12, remaining)));
                    var response = await _httpClient.PostAsJsonAsync(endpoint, payload, cts.Token);
                    if (response.IsSuccessStatusCode)
                    {
                        var jsonStr = await response.Content.ReadAsStringAsync();
                        using var doc = JsonDocument.Parse(jsonStr);
                        var candidates = doc.RootElement.GetProperty("candidates");
                        if (candidates.GetArrayLength() > 0)
                        {
                            var cand = candidates[0];
                            if (cand.TryGetProperty("content", out var content) &&
                                content.TryGetProperty("parts", out var parts) &&
                                parts.ValueKind == JsonValueKind.Array)
                            {
                                var sb = new StringBuilder();
                                foreach (var part in parts.EnumerateArray())
                                {
                                    if (part.TryGetProperty("thought", out var isThought) && isThought.GetBoolean())
                                    {
                                        continue;
                                    }
                                    if (part.TryGetProperty("text", out var textEl))
                                    {
                                        var partText = textEl.GetString();
                                        if (!string.IsNullOrEmpty(partText))
                                        {
                                            sb.Append(partText);
                                        }
                                    }
                                }
                                var text = sb.ToString().Trim();
                                // Ensure response is substantive and not a truncated meta artifact
                                if (!string.IsNullOrWhiteSpace(text) && text.Length > 20)
                                {
                                    return text;
                                }
                            }
                        }
                    }
                    else
                    {
                        _logger.LogWarning("Gemini chat model {Model} returned HTTP {StatusCode}. Trying fallback model.", model, response.StatusCode);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Gemini chat attempt with model {Model} failed or timed out. Trying next fallback model.", model);
                }
            }

            throw new HttpRequestException("No configured Gemini model returned a usable response.");
        }

        private async Task<string> BuildUserFinancialContextAsync(string userId)
        {
            var accounts = await _accountRepo.GetAllAsync(a => a.UserId == userId && !a.IsDeleted, isTracking: false);
            var now = DateTime.UtcNow;
            var startOfMonth = new DateTime(now.Year, now.Month, 1);

            var transactions = await _transactionRepo.GetAllAsync(
                filter: t => t.UserId == userId && !t.IsDeleted && t.TransactionDate >= startOfMonth,
                includeProperties: "Category",
                isTracking: false
            );

            decimal totalBalance = accounts.Where(a => !a.ExcludeFromTotal).Sum(a => a.Balance);
            decimal totalIncome = transactions.Where(t => t.Type == "Deposit" || t.Type == "Income").Sum(t => t.Amount);
            decimal totalExpenses = transactions.Where(t => t.Type == "Withdrawal" || t.Type == "Expense").Sum(t => t.Amount);

            var topCategories = transactions
                .Where(t => t.Type == "Withdrawal" || t.Type == "Expense")
                .GroupBy(t => t.Category?.NameAr ?? "أخرى")
                .Select(g => $"{g.Key}: {g.Sum(t => t.Amount):N0} جنيه")
                .Take(5);

            var budget = await _budgetRepo.GetAsync(b => b.UserId == userId && b.Month == now.Month && b.Year == now.Year);
            var budgetInfo = budget != null
                ? $"الميزانية المحددة لهذا الشهر: {budget.MonthlyBudget:N0} جنيه (المصروف حتى الآن: {totalExpenses:N0} جنيه)"
                : "لم يحدد المستخدم ميزانية شهرية بعد.";

            var accountsSummary = string.Join(", ", accounts.Select(a => $"{a.Name}: {a.Balance:N0} {a.Currency}"));

            return $@"
[سياق البيانات المالية الحالية للمستخدم]:
- تاريخ اليوم: {now:yyyy-MM-dd}
- إجمالي الرصيد المتاح: {totalBalance:N0} جنيه
- دخل هذا الشهر: {totalIncome:N0} جنيه
- مصاريف هذا الشهر: {totalExpenses:N0} جنيه
- {budgetInfo}
- أعلى مصاريف هذا الشهر: {(topCategories.Any() ? string.Join(", ", topCategories) : "لا توجد مصاريف كافية")}
- الحسابات: {(string.IsNullOrEmpty(accountsSummary) ? "لا توجد حسابات مسجلة" : accountsSummary)}";
        }

        private static string GenerateFallbackChatResponse(
            string userText,
            string context,
            string language)
        {
            if (string.Equals(language, "en", StringComparison.OrdinalIgnoreCase))
            {
                if (userText.Contains("spend", StringComparison.OrdinalIgnoreCase) ||
                    userText.Contains("expense", StringComparison.OrdinalIgnoreCase))
                {
                    return "I can't calculate your spending right now. Please try again shortly or open Analytics for the recorded totals.";
                }
                if (userText.Contains("save", StringComparison.OrdinalIgnoreCase) ||
                    userText.Contains("budget", StringComparison.OrdinalIgnoreCase))
                {
                    return "I can't analyze your budget right now. Please try again shortly, or review your budget in the Budgets screen.";
                }
                return "I can't reach the financial assistant right now. Please try again shortly.";
            }

            if (userText.Contains("صرفت كام") || userText.Contains("مصاريف"))
            {
                return "بناءً على مصاريفك المسجلة هذا الشهر، يمكنك متابعة التفاصيل الدقيقة والرسم البياني في شاشة 'التحليلات' للمحفظة.";
            }
            if (userText.Contains("توفير") || userText.Contains("احوش") || userText.Contains("خطة"))
            {
                return "أفضل استراتيجية هي قاعدة 50/30/20: 50% للاحتياجات الأساسية، 30% للرغبات، و 20% للادخار والاستثمار. يمكنك وضع ميزانية شهرية من شاشة الميزانيات لنساعدك على الالتزام بها!";
            }
            return "أنا هنا لمساعدتك في إدارة أموالك، تتبع مصاريفك، وتخطيط ميزانيتك. كيف يمكنني إفادتك اليوم؟";
        }
    }
}
