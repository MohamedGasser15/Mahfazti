using Microsoft.Extensions.Logging;
using MyWallet.Application.DTOs.Wallet;
using MyWallet.Application.ServiceInterfaces;
using MyWallet.Domain.Entites;
using MyWallet.Infrastructure.Persistence.IRepository;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace MyWallet.Application.Services
{
    public class VoiceExpenseService : IVoiceExpenseService
    {
        private readonly IRepository<Category> _categoryRepository;
        private readonly ILogger<VoiceExpenseService> _logger;

        // ===== أرقام عربية =====
        private static readonly Dictionary<string, decimal> ArabicNumbers = new()
        {
            {"واحد", 1}, {"اتنين", 2}, {"تلاتة", 3}, {"اربعة", 4},
            {"خمسة", 5}, {"ستة", 6}, {"سبعة", 7}, {"تمانية", 8},
            {"تسعة", 9}, {"عشرة", 10}, {"عشرين", 20}, {"تلاتين", 30},
            {"اربعين", 40}, {"خمسين", 50}, {"ستين", 60}, {"سبعين", 70},
            {"تمانين", 80}, {"تسعين", 90}, {"مية", 100}, {"ميه", 100},
            {"مئة", 100}, {"مئتين", 200}, {"تلتمية", 300}, {"اربعمية", 400},
            {"خمسمية", 500}, {"ستمية", 600}, {"سبعمية", 700}, {"تمنمية", 800},
            {"تسعمية", 900}, {"الف", 1000}, {"ألف", 1000}, {"مليون", 1000000}
        };

        // ===== كاتيجوري عربي =====
        private static readonly Dictionary<string, string[]> ArabicCategoryKeywords = new()
        {
            { "Food",          new[] { "أكل", "اكل", "طعام", "فطار", "غدا", "عشا", "مطعم", "كافيه", "قهوة", "شاي", "عصير", "ساندوتش", "فول", "طعمية", "كشري", "بيتزا", "برجر" } },
            { "Transport",     new[] { "تاكسي", "اوبر", "كريم", "مترو", "باص", "عربية", "بنزين", "مواصلات", "توك توك", "ميكروباص" } },
            { "Shopping",      new[] { "اشتريت", "اشترت", "شراء", "ملابس", "هدوم", "موبايل", "لاب توب", "جهاز", "حاجه", "حاجة", "غرض" } },
            { "Entertainment", new[] { "سينما", "لعبة", "فرفشة", "نزهة", "تذكرة", "مول", "كافيه", "قعدة" } },
            { "Health",        new[] { "دكتور", "دواء", "صيدلية", "مستشفى", "علاج", "كشف", "عيادة", "تحاليل" } },
            { "Bills",         new[] { "فاتورة", "كهرباء", "مياه", "انترنت", "تليفون", "ايجار", "غاز", "نت" } },
            { "Education",     new[] { "كورس", "كتاب", "مدرسة", "جامعة", "دروس", "كلية", "محاضرة" } },
        };

        // ===== كاتيجوري إنجليزي =====
        private static readonly Dictionary<string, string[]> EnglishCategoryKeywords = new()
        {
            { "Food",          new[] { "food", "eat", "eating", "lunch", "dinner", "breakfast", "restaurant", "cafe", "coffee", "tea", "juice", "pizza", "burger", "sandwich", "meal" } },
            { "Transport",     new[] { "taxi", "uber", "careem", "metro", "bus", "car", "petrol", "fuel", "transport", "ride", "lyft" } },
            { "Shopping",      new[] { "bought", "buy", "purchase", "shopping", "clothes", "shirt", "phone", "laptop", "device", "stuff", "item", "thing" } },
            { "Entertainment", new[] { "cinema", "movie", "game", "fun", "trip", "ticket", "mall", "outing", "netflix", "spotify" } },
            { "Health",        new[] { "doctor", "medicine", "pharmacy", "hospital", "clinic", "treatment", "checkup", "lab", "pills" } },
            { "Bills",         new[] { "bill", "electricity", "water", "internet", "phone bill", "rent", "gas", "subscription" } },
            { "Education",     new[] { "course", "book", "school", "university", "college", "lesson", "class", "tuition" } },
        };

        // ===== كلمات إيراد عربي =====
        // ===== كلمات إيراد إنجليزي - موسّعة =====
        private static readonly string[] EnglishIncomeKeywords = new[]
        {
    // فعل مباشر
    "received", "receive",
    "earned", "earn",
    "got paid", "got",
    "income",
    "salary",
    "bonus",
    "wage", "wages",
    "payment",
    "profit",
    "revenue",
    "refund",
    "reward",
    "gift",
    "deposit",
    "added",
    "credited",
    "transferred to",
    "paid me",
    "sent me",
};

        // ===== كلمات إيراد عربي - موسّعة =====
        private static readonly string[] ArabicIncomeKeywords = new[]
        {
    "استلمت", "استلم",
    "اخدت", "اخد", "أخدت",
    "حصلت", "حصل",
    "راتب", "مرتب",
    "بونص", "بونوس",
    "هدية", "هديه",
    "دخل",
    "ربح",
    "عائد",
    "مكافأة", "مكافاة",
    "حولتلي", "حولت لي",
    "ضافت", "ضاف",
    "جالي", "جالى",
    "فلوس جت", "فلوس اجت",
    "اتحول", "اتحولت",
    "استردت", "استرداد",
};

        // ===== كلمات شائعة نشيلها من الـ Note =====
        private static readonly string[] EnglishNoiseWords = new[]
        {
    // أفعال المعاملة بس - مش كلمات income
    "spent", "paid", "bought", "purchased", "spend",
    // حروف جر
    "for", "on", "at", "with", "from", "into",
    // أدوات
    "the", "a", "an", "some", "my", "our",
    // ضمائر
    "i", "we",
};

        private static readonly string[] ArabicNoiseWords = new[]
        {
    // أفعال مصروف
    "اشتريت", "اشترت", "دفعت", "دفع", "سحبت", "سحب", "صرفت", "صرف",
    // أفعال إيراد - نشيلها من الـ note بس مش من الـ detection
    "استلمت", "اخدت", "حصلت", "حولت",
    // ضمائر وأدوات
    "انا", "أنا", "احنا", "هو", "هي",
    "عايز", "بقا", "دلوقتي", "كده", "يعني", "بقى", "ده", "دي",
    // عملات
    "جنيه", "جنيهات", "جنيهًا", "قرش", "دولار", "يورو", "ريال",
    // حروف
    "من", "في", "على", "عن", "مع", "لـ", "ب",
};

        public VoiceExpenseService(
            IRepository<Category> categoryRepository,
            ILogger<VoiceExpenseService> logger)
        {
            _categoryRepository = categoryRepository;
            _logger = logger;
        }

        public async Task<VoiceExpenseResultDto> ParseVoiceTextAsync(
            string text, string language, CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("Parsing: '{Text}' | Lang hint: {Lang}", text, language);

                var normalizedText = text.Trim().ToLower();

                // ✅ 1. اكتشف اللغة الأول
                var detectedLang = DetectLanguage(normalizedText, language);
                _logger.LogInformation("Detected language: {Lang}", detectedLang);

                // ✅ 2. اكتشف نوع المعاملة من النص الكامل (قبل أي تنظيف)
                var transactionType = DetectTransactionType(normalizedText, detectedLang);
                _logger.LogInformation("Transaction type: {Type}", transactionType);

                // ✅ 3. استخرج المبلغ
                var amount = ExtractAmount(normalizedText);
                if (amount == null)
                    return new VoiceExpenseResultDto
                    {
                        IsSuccess = false,
                        ErrorMessage = detectedLang == "ar"
                            ? "لم أستطع تحديد المبلغ من الجملة"
                            : "Could not detect the amount from your speech"
                    };

                // ✅ 4. اكتشف الكاتيجوري
                var (categoryNameEn, matchedKeyword) = DetectCategory(normalizedText, transactionType, detectedLang);

                var category = await _categoryRepository.GetAsync(
                    c => c.NameEn.ToLower() == categoryNameEn.ToLower(),
                    cancellationToken: cancellationToken
                );

                // ✅ 5. استخرج note نظيفة
                var note = ExtractCleanNote(normalizedText, amount.Value, matchedKeyword, detectedLang);
                var title = BuildTitle(note, matchedKeyword, categoryNameEn, transactionType, detectedLang);

                return new VoiceExpenseResultDto
                {
                    Amount = amount,
                    TransactionType = transactionType,
                    CategoryId = category?.Id,
                    CategoryNameAr = category?.NameAr,
                    CategoryNameEn = category?.NameEn,
                    Note = note,
                    Title = title,
                    IsSuccess = true
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error parsing voice text");
                return new VoiceExpenseResultDto
                {
                    IsSuccess = false,
                    ErrorMessage = "حدث خطأ أثناء تحليل النص / Error parsing voice"
                };
            }
        }
        // ✅ تحديد اللغة من النص الفعلي
        private string DetectLanguage(string text, string hintLanguage)
        {
            if (Regex.IsMatch(text, @"[\u0600-\u06FF]"))
                return "ar";

            if (Regex.IsMatch(text, @"[a-zA-Z]"))
                return "en";

            return hintLanguage ?? "ar";
        }

        private string DetectTransactionType(string text, string lang)
        {
            var keywords = lang == "en" ? EnglishIncomeKeywords : ArabicIncomeKeywords;

            foreach (var keyword in keywords.OrderByDescending(k => k.Length))
            {
                if (keyword.Contains(" "))
                {
                    if (text.Contains(keyword.ToLower()))
                        return "Deposit";
                }
                else
                {
                    var pattern = lang == "en"
                        ? $@"\b{Regex.Escape(keyword.ToLower())}\b"
                        : Regex.Escape(keyword.ToLower());

                    if (Regex.IsMatch(text, pattern))
                        return "Deposit";
                }
            }

            return "Withdrawal";
        }

        private decimal? ExtractAmount(string text)
        {
            var normalizedDigits = text
                .Replace('٠', '0').Replace('١', '1').Replace('٢', '2')
                .Replace('٣', '3').Replace('٤', '4').Replace('٥', '5')
                .Replace('٦', '6').Replace('٧', '7').Replace('٨', '8')
                .Replace('٩', '9');

            var numericMatch = Regex.Match(normalizedDigits, @"\d+(\.\d+)?");
            if (numericMatch.Success)
                return decimal.Parse(numericMatch.Value);

            foreach (var (word, value) in ArabicNumbers.OrderByDescending(k => k.Value))
            {
                if (text.Contains(word))
                    return value;
            }

            return null;
        }

        private (string CategoryEn, string? MatchedKeyword) DetectCategory(
            string text, string transactionType, string lang)
        {
            if (transactionType == "Deposit")
            {
                if (lang == "ar")
                {
                    if (text.Contains("راتب") || text.Contains("مرتب")) return ("Salary", "راتب");
                    if (text.Contains("بونص") || text.Contains("مكافأة")) return ("Bonus", "بونص");
                }
                else
                {
                    if (text.Contains("salary") || text.Contains("wage")) return ("Salary", "salary");
                    if (text.Contains("bonus")) return ("Bonus", "bonus");
                }
                return ("Income", null);
            }

            var keywords = lang == "en" ? EnglishCategoryKeywords : ArabicCategoryKeywords;
            foreach (var (category, kws) in keywords)
            {
                foreach (var kw in kws)
                {
                    if (text.Contains(kw.ToLower()))
                        return (category, kw);
                }
            }

            return ("Other", null);
        }

        private string? ExtractCleanNote(string text, decimal amount, string? matchedKeyword, string lang)
        {
            var working = text;

            working = Regex.Replace(working, @"\d+(\.\d+)?", "");
            working = Regex.Replace(working, @"(جنيه|جنيهات|قرش|دولار|يورو|ريال|pound|dollar|euro|egp|usd|eur|sar|aed)\w*", "", RegexOptions.IgnoreCase);

            var noiseWords = lang == "en" ? EnglishNoiseWords : ArabicNoiseWords;
            foreach (var noise in noiseWords)
            {
                working = Regex.Replace(working, $@"\b{Regex.Escape(noise)}\b", "", RegexOptions.IgnoreCase);
            }

            working = Regex.Replace(working, @"\s+", " ").Trim();

            if (!string.IsNullOrWhiteSpace(working) && working.Length >= 3)
            {
                if (lang == "en" && working.Length > 0)
                    working = char.ToUpper(working[0]) + working[1..];

                return working;
            }

            return matchedKeyword;
        }

        private string BuildTitle(string? note, string? matchedKeyword, string categoryEn, string transactionType, string lang)
        {
            if (!string.IsNullOrWhiteSpace(note) && note.Length >= 2)
                return note;

            if (!string.IsNullOrWhiteSpace(matchedKeyword))
            {
                if (lang == "en")
                    return char.ToUpper(matchedKeyword[0]) + matchedKeyword[1..];
                return matchedKeyword;
            }

            return lang == "en"
                ? (transactionType == "Deposit" ? "Income" : categoryEn)
                : (transactionType == "Deposit" ? "إيراد" : GetArabicCategoryName(categoryEn));
        }

        private string GetArabicCategoryName(string nameEn) => nameEn switch
        {
            "Food" => "طعام",
            "Transport" => "مواصلات",
            "Shopping" => "تسوق",
            "Entertainment" => "ترفيه",
            "Health" => "صحة",
            "Bills" => "فواتير",
            "Education" => "تعليم",
            "Salary" => "راتب",
            "Bonus" => "مكافأة",
            "Income" => "إيراد",
            _ => "مصروف"
        };
    }
}