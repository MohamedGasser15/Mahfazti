using Microsoft.Extensions.Logging;
using Mahfazti.Core.DTOs.Category;
using Mahfazti.Core.Interfaces;
using Mahfazti.Core.Entities;

namespace Mahfazti.Core.Services
{
    public class CategoryService : ICategoryService
    {
        private readonly IRepository<Category> _categoryRepository;
        private readonly IRepository<WalletTransaction>? _transactionRepository;
        private readonly ILogger<CategoryService> _logger;

        public static readonly List<(string NameAr, string NameEn, string Type, string Icon)> DefaultCategories = new()
        {
            ("طعام ومشروبات", "Food & Dining", "Expense", "utensils"),
            ("مواصلات ووقود", "Transport & Fuel", "Expense", "car"),
            ("تسوق ومشتريات", "Shopping & Retail", "Expense", "shopping-bag"),
            ("ترفيه وأنشطة", "Entertainment & Leisure", "Expense", "sparkles"),
            ("صحة ورعاية طبية", "Health & Wellness", "Expense", "activity"),
            ("فواتير واشتراكات", "Bills & Utilities", "Expense", "receipt"),
            ("تعليم وتطوير", "Education & Learning", "Expense", "graduation-cap"),
            ("نفقات متنوعة أخرى", "General & Miscellaneous", "Expense", "tag"),
            ("راتب شهري", "Monthly Salary", "Income", "wallet"),
            ("مكافآت وحوافز", "Bonuses & Rewards", "Income", "gift"),
            ("استثمارات وإيرادات", "Investments & Extra Income", "Income", "trending-up"),
        };

        public CategoryService(
            IRepository<Category> categoryRepository,
            ILogger<CategoryService> logger)
        {
            _categoryRepository = categoryRepository;
            _transactionRepository = null;
            _logger = logger;
        }

        public CategoryService(
            IRepository<Category> categoryRepository,
            IRepository<WalletTransaction> transactionRepository,
            ILogger<CategoryService> logger)
        {
            _categoryRepository = categoryRepository;
            _transactionRepository = transactionRepository;
            _logger = logger;
        }

        public async Task SeedDefaultCategoriesForUserAsync(string userId)
        {
            if (string.IsNullOrEmpty(userId)) return;

            bool hasCategories = await _categoryRepository.AnyAsync(c => c.UserId == userId);
            if (hasCategories) return;

            int order = 1;
            foreach (var item in DefaultCategories)
            {
                await _categoryRepository.CreateAsync(new Category
                {
                    UserId = userId,
                    NameAr = item.NameAr,
                    NameEn = item.NameEn,
                    Type = item.Type,
                    Icon = item.Icon,
                    DisplayOrder = order++,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                });
            }
            _logger.LogInformation("Seeded default categories for user {UserId}", userId);
        }

        public async Task<IEnumerable<CategoryDto>> GetAllCategoriesAsync(string? userId = null)
        {
            if (!string.IsNullOrEmpty(userId))
            {
                bool hasCategories = await _categoryRepository.AnyAsync(c => c.UserId == userId);
                if (!hasCategories)
                {
                    await SeedDefaultCategoriesForUserAsync(userId);
                }

                var userCategories = await _categoryRepository.GetAllAsync(
                    filter: c => c.UserId == userId && c.IsActive,
                    includeProperties: "Transactions",
                    orderBy: q => q.OrderBy(c => c.DisplayOrder).ThenBy(c => c.NameEn)
                );

                return userCategories.Select(c => new CategoryDto
                {
                    Id = c.Id,
                    NameAr = c.NameAr,
                    NameEn = c.NameEn,
                    Type = c.Type,
                    Icon = c.Icon,
                    IsActive = c.IsActive,
                    TransactionCount = c.Transactions?.Count(t => !t.IsDeleted) ?? 0,
                });
            }

            var categories = await _categoryRepository.GetAllAsync(
                filter: c => c.UserId == null && c.IsActive,
                includeProperties: "Transactions",
                orderBy: q => q.OrderBy(c => c.DisplayOrder).ThenBy(c => c.NameEn)
            );

            return categories.Select(c => new CategoryDto
            {
                Id = c.Id,
                NameAr = c.NameAr,
                NameEn = c.NameEn,
                Type = c.Type,
                Icon = c.Icon,
                IsActive = c.IsActive,
                TransactionCount = c.Transactions?.Count(t => !t.IsDeleted) ?? 0,
            });
        }

        public async Task<CategoryDto?> GetCategoryByIdAsync(int id, string? userId = null)
        {
            var category = await _categoryRepository.GetAsync(
                c => c.Id == id && (userId == null || c.UserId == userId || c.UserId == null),
                includeProperties: "Transactions"
            );
            if (category == null) return null;
            return new CategoryDto
            {
                Id = category.Id,
                NameAr = category.NameAr,
                NameEn = category.NameEn,
                Type = category.Type,
                Icon = category.Icon,
                IsActive = category.IsActive,
                TransactionCount = category.Transactions?.Count(t => !t.IsDeleted) ?? 0,
            };
        }

        public async Task<CategoryDto> CreateCategoryAsync(CreateCategoryDto dto, string? userId = null)
        {
            var category = new Category
            {
                UserId = userId,
                NameAr = dto.NameAr,
                NameEn = dto.NameEn,
                Type = string.IsNullOrWhiteSpace(dto.Type) ? "Expense" : dto.Type,
                Icon = string.IsNullOrWhiteSpace(dto.Icon) ? "layers" : dto.Icon,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };
            await _categoryRepository.CreateAsync(category);
            return new CategoryDto
            {
                Id = category.Id,
                NameAr = category.NameAr,
                NameEn = category.NameEn,
                Type = category.Type,
                Icon = category.Icon,
                IsActive = category.IsActive,
                TransactionCount = 0,
            };
        }

        public async Task<CategoryDto?> UpdateCategoryAsync(UpdateCategoryDto dto, string? userId = null)
        {
            var category = await _categoryRepository.GetAsync(
                c => c.Id == dto.Id && (userId == null || c.UserId == userId),
                isTracking: true
            );
            if (category == null) return null;

            category.NameAr = dto.NameAr;
            category.NameEn = dto.NameEn;
            if (!string.IsNullOrWhiteSpace(dto.Type))
            {
                category.Type = dto.Type;
            }
            if (!string.IsNullOrWhiteSpace(dto.Icon))
            {
                category.Icon = dto.Icon;
            }
            category.UpdatedAt = DateTime.UtcNow;

            await _categoryRepository.UpdateAsync(category);
            return new CategoryDto
            {
                Id = category.Id,
                NameAr = category.NameAr,
                NameEn = category.NameEn,
                Type = category.Type,
                Icon = category.Icon,
                IsActive = category.IsActive,
            };
        }

        public async Task<bool> DeleteCategoryAsync(int id, string? userId = null)
        {
            var category = await _categoryRepository.GetAsync(
                c => c.Id == id && (userId == null || c.UserId == userId),
                isTracking: true
            );
            if (category == null) return false;

            // Check if category has any active transactions
            bool hasTransactions = false;
            if (_transactionRepository != null)
            {
                hasTransactions = await _transactionRepository.AnyAsync(t => t.CategoryId == id && !t.IsDeleted);
            }

            // Always soft-delete (hide) for this user to preserve transaction history and integrity
            category.IsActive = false;
            category.UpdatedAt = DateTime.UtcNow;
            await _categoryRepository.UpdateAsync(category);
            _logger.LogInformation("Category #{Id} for user {UserId} marked as inactive (hidden).", id, userId);

            return true;
        }

        public async Task<bool> RestoreCategoryAsync(int id, string? userId = null)
        {
            var category = await _categoryRepository.GetAsync(
                c => c.Id == id && (userId == null || c.UserId == userId),
                isTracking: true
            );
            if (category == null) return false;

            category.IsActive = true;
            category.UpdatedAt = DateTime.UtcNow;
            await _categoryRepository.UpdateAsync(category);
            _logger.LogInformation("Category #{Id} restored to active state for user {UserId}.", id, userId);
            return true;
        }

        public async Task<int> BulkRestoreCategoriesAsync(IEnumerable<int> ids, string? userId = null)
        {
            if (ids == null) return 0;
            var distinctIds = ids.Distinct().ToList();
            if (distinctIds.Count == 0) return 0;

            int restoredCount = 0;
            foreach (var id in distinctIds)
            {
                var category = await _categoryRepository.GetAsync(
                    c => c.Id == id && (userId == null || c.UserId == userId),
                    isTracking: true
                );
                if (category != null && !category.IsActive)
                {
                    category.IsActive = true;
                    category.UpdatedAt = DateTime.UtcNow;
                    await _categoryRepository.UpdateAsync(category);
                    restoredCount++;
                }
            }
            _logger.LogInformation("Bulk restored {Count} categories for user {UserId}.", restoredCount, userId);
            return restoredCount;
        }

        public async Task<BulkDeleteResultDto> BulkDeleteCategoriesAsync(IEnumerable<int> ids, string? userId = null)
        {
            var distinctIds = ids?.Distinct().ToList() ?? new List<int>();
            var result = new BulkDeleteResultDto
            {
                TotalRequested = distinctIds.Count
            };

            foreach (var id in distinctIds)
            {
                var category = await _categoryRepository.GetAsync(
                    c => c.Id == id && (userId == null || c.UserId == userId),
                    isTracking: true
                );
                if (category == null) continue;

                bool hasTransactions = false;
                if (_transactionRepository != null)
                {
                    hasTransactions = await _transactionRepository.AnyAsync(t => t.CategoryId == id && !t.IsDeleted);
                }

                if (hasTransactions)
                {
                    category.IsActive = false;
                    category.UpdatedAt = DateTime.UtcNow;
                    await _categoryRepository.UpdateAsync(category);
                    result.ArchivedCount++;
                }
                else
                {
                    await _categoryRepository.DeleteAsync(category);
                    result.DeletedCount++;
                }

                result.ProcessedIds.Add(id);
            }

            result.Message = $"Successfully processed {result.ProcessedIds.Count} categories ({result.DeletedCount} deleted, {result.ArchivedCount} archived).";
            return result;
        }

        public async Task<IEnumerable<CategoryDto>> GetMostUsedCategoriesAsync(string userId, int limit = 5)
        {
            if (string.IsNullOrEmpty(userId) || _transactionRepository == null)
                return Enumerable.Empty<CategoryDto>();

            // Load all non-deleted transactions for this user (with category)
            var transactions = await _transactionRepository.GetAllAsync(
                filter: t => t.UserId == userId && !t.IsDeleted && t.CategoryId != null
            );

            // Count usage per category, ordered descending
            var topCategoryIds = transactions
                .GroupBy(t => t.CategoryId!.Value)
                .OrderByDescending(g => g.Count())
                .Take(limit)
                .Select(g => g.Key)
                .ToList();

            if (topCategoryIds.Count == 0)
                return Enumerable.Empty<CategoryDto>();

            // Load the actual category entities
            var categories = await _categoryRepository.GetAllAsync(
                filter: c => topCategoryIds.Contains(c.Id) && c.UserId == userId && c.IsActive
            );

            // Preserve the usage-count ordering
            var countByCategory = transactions
                .Where(t => t.CategoryId != null)
                .GroupBy(t => t.CategoryId!.Value)
                .ToDictionary(g => g.Key, g => g.Count());

            return categories
                .OrderByDescending(c => countByCategory.GetValueOrDefault(c.Id, 0))
                .Select(c => new CategoryDto
                {
                    Id = c.Id,
                    NameAr = c.NameAr,
                    NameEn = c.NameEn,
                    Type = c.Type,
                    Icon = c.Icon,
                    IsActive = c.IsActive,
                    TransactionCount = countByCategory.GetValueOrDefault(c.Id, 0),
                });
        }
    }
}
